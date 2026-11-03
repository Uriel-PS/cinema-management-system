-- SISTEMA DE GERENCIAMENTO DE CINEMA
-- Parte 3 - Funcoes e Gatilhos - PostgreSQL
-- Banco de Dados II - UDESC CCT

/*
Funcao auxiliar: Horário de Término da Sessão
Calcula o horário de término (atributo derivado): horário de início
mais a duração do filme mais 30 minutos de intervalo entre sessões.
*/
create or replace function horario_termino(p_data date, p_id_filme int, p_inicio time) returns timestamp as
$$
declare
    v_duracao int;
begin
    select duracao into v_duracao from filme where id_filme = p_id_filme; 

    -- duracao é int e em MINUTOS, converter para retornar o HORARIO do termino.
    -- Intervalo arbitrário de 30 minutos
    return (p_data + p_inicio) + (v_duracao + 30) * interval '1 minute'; 
end;
$$
language plpgsql;


/*
Gatilho 1: Validar Sessão
Antes de inserir ou alterar uma sessão, impede que ela se sobreponha
a outra sessão (não cancelada) na mesma sala.
Modificado para comparar o intervalo (TIMESTAMP).
*/
create or replace function valida_sessao() returns trigger as
$$
declare
    v_tipo_sala varchar;
    v_inicio_nova timestamp;
    v_termino_nova timestamp;
    v_duracao_filme int;
    qtd_conflitos int;
begin
    -- restrição 14: com ingressos vendidos, a sessão não pode trocar de sala
    -- (as poltronas vendidas deixariam de pertencer à sala da sessão)
    if tg_op = 'UPDATE' and new.id_sala != old.id_sala
       and exists (select 1 from ingresso where id_sessao = new.id_sessao) then
        raise exception 'A sessão % já possui ingressos vendidos e não pode mudar de sala', new.id_sessao;
    end if;

    if new.status = 'CANCELADA' then
        return new;
    end if;

    select duracao into v_duracao_filme from filme where id_filme = new.id_filme;
    if v_duracao_filme <= 0 or v_duracao_filme is null then
        raise exception 'Duração de filme invalida ou nula. O filme deve ter uma duração maior que zero';
    end if;

    select tipo into v_tipo_sala from sala where id_sala = new.id_sala;
    if new.formato_projecao = '3D' and v_tipo_sala = '2D' then
        raise exception 'A sala % é do tipo 2D e não permite projeção 3D', new.id_sala;
    end if;

    
    v_inicio_nova := new.data + new.horario_inicio;
    v_termino_nova := horario_termino(new.data, new.id_filme, new.horario_inicio);

   
    select count(*) into qtd_conflitos
    from sessao s
    where s.id_sala = new.id_sala
      and s.status != 'CANCELADA'
      and s.id_sessao != coalesce(new.id_sessao, 0)
      and (s.data + s.horario_inicio) < v_termino_nova
      and horario_termino(s.data, s.id_filme, s.horario_inicio) > v_inicio_nova;

    if qtd_conflitos > 0 then
        raise exception 'Conflito de horário: a sala % já possui sessão nesse período', new.id_sala;
    end if;

    return new;
end;
$$
language plpgsql;

create trigger tg_valida_sessao
before insert or update on sessao
for each row
execute function valida_sessao();

/*
Gatilho 2: Validar Ingresso
Antes de inserir ou alterar um ingresso: a poltrona precisa pertencer à sala da
sessão; 
Não se vende ingresso em sessão CANCELADA ou ESGOTADA; 
Ingresso PROMOCIONAL exige promoção; a promoção deve estar vigente e dentro do limite de uso.
Também gera o QR code único quando ele não é informado.
*/
create or replace function valida_ingresso() returns trigger as
$$
declare
    v_sala_sessao int;
    v_status varchar;
    v_sala_poltrona int;
    v_inicio date;
    v_fim date;
    v_limite int;
    v_usos int;
begin
    select id_sala, status into v_sala_sessao, v_status
    from sessao where id_sessao = new.id_sessao;

    select id_sala into v_sala_poltrona
    from poltrona where id_poltrona = new.id_poltrona;

    if v_sala_poltrona != v_sala_sessao then
        raise exception 'A poltrona % não pertence à sala % da sessão %', new.id_poltrona, v_sala_sessao, new.id_sessao;
    end if;

    if (tg_op = 'INSERT' or new.id_sessao is distinct from old.id_sessao) and v_status in ('CANCELADA', 'ESGOTADA') then
        raise exception 'A sessão % está com status %, venda não permitida', new.id_sessao, v_status;
    end if;

    if new.tipo_ingresso = 'PROMOCIONAL' and new.id_promocao is null then
        raise exception 'Ingresso PROMOCIONAL exige uma promoção';
    end if;

    if new.id_promocao is not null then
        select data_inicio, data_fim, limite_uso into v_inicio, v_fim, v_limite
        from promocao where id_promocao = new.id_promocao;

        -- Vigência da promoção avaliada na data da VENDA (current_date), talvez usar sessao.data
        if (tg_op = 'INSERT' or new.id_promocao is distinct from old.id_promocao) 
        and (current_date < v_inicio or current_date > v_fim) then
            raise exception 'A promoção % não está vigente (% a %)', new.id_promocao, v_inicio, v_fim;
        end if;

        if tg_op = 'INSERT' and v_limite is not null then
            select count(*) into v_usos from ingresso where id_promocao = new.id_promocao;
            if v_usos >= v_limite then
                raise exception 'A promoção % atingiu o limite de uso (%)', new.id_promocao, v_limite;
            end if;
        end if;
    end if;

    if new.qr_code is null then
        new.qr_code := md5(random()::text || now()::text);
    end if;

    return new;
end;
$$
language plpgsql;

create trigger tg_ingresso_1_valida
before insert or update on ingresso
for each row
execute function valida_ingresso();


-- Gatilho 3: Verificação de Promoção
create or replace function valida_promocao() returns trigger as
$$
begin
    
    if new.data_fim < new.data_inicio then
        raise exception 'A data de fim (%) não pode ser anterior à data de início (%)', new.data_fim, new.data_inicio;
    end if;

    if new.valor_desconto is null or new.valor_desconto <= 0 then
        raise exception 'O valor do desconto deve ser maior que zero (Valor informado: %)', new.valor_desconto;
    end if;

    if new.tipo_desconto = 'PERCENTUAL' and new.valor_desconto > 100 then
        raise exception 'Descontos percentuais não podem exceder 100%% (Valor informado: %)', new.valor_desconto;
    end if;

    if new.limite_uso is not null and new.limite_uso <= 0 then
        raise exception 'O limite de uso deve ser superior a zero (Valor informado: %)', new.limite_uso;
    end if;

    return new;
end;
$$
language plpgsql;

create trigger tg_valida_promocao
before insert or update on promocao
for each row
execute function valida_promocao();


/*
Gatilho 4: Calcular Valor Pago do Ingresso
Antes de inserir ou alterar o ingresso, calcula o valor_pago a partir do
valor_base da sessão: MEIA-ENTRADA paga 50% e, se houver promoção,
aplica o desconto (PERCENTUAL ou VALOR). O valor nunca fica negativo.
Dispara depois do gatilho 2 (ordem alfabética dos nomes).
*/
create or replace function calcula_valor_ingresso() returns trigger as
$$
declare
    v_valor numeric;
    v_tipo varchar;
    v_desconto numeric;
begin
    select coalesce(valor_base, 0) into v_valor from sessao where id_sessao = new.id_sessao;

    if new.tipo_ingresso = 'MEIA-ENTRADA' then
        v_valor := v_valor / 2;
    end if;

    if new.id_promocao is not null then
        select tipo_desconto, valor_desconto into v_tipo, v_desconto
        from promocao where id_promocao = new.id_promocao;

        if v_tipo = 'PERCENTUAL' then
            v_valor := v_valor - v_valor * v_desconto / 100;
        elsif v_tipo = 'VALOR' then
            v_valor := v_valor - v_desconto;
        end if;
    end if;

    if v_valor < 0 then
        v_valor := 0;
    end if;

    new.valor_pago := v_valor;
    return new;
end;
$$
language plpgsql;

create trigger tg_ingresso_2_calcula_valor
before insert or update of tipo_ingresso, id_promocao, id_sessao on ingresso
for each row
execute function calcula_valor_ingresso();


/*
Gatilho 5: Atualização do Valor Total da Venda
Mantém o valor_total da venda atualizado conforme ingressos são
inseridos, alterados ou removidos.
Funciona como um "carrinho"
*/
create or replace function atualiza_total_venda() returns trigger as
$$
begin
    if (tg_op = 'INSERT') then
        update venda set valor_total = coalesce(valor_total, 0) + new.valor_pago
        where id_venda = new.id_venda;
    end if;
    if (tg_op = 'UPDATE') then
        update venda set valor_total = coalesce(valor_total, 0) - old.valor_pago
        where id_venda = old.id_venda;
        update venda set valor_total = coalesce(valor_total, 0) + new.valor_pago
        where id_venda = new.id_venda;
    end if;
    if (tg_op = 'DELETE') then
        update venda set valor_total = coalesce(valor_total, 0) - old.valor_pago
        where id_venda = old.id_venda;
    end if;

    return null;
end;
$$
language plpgsql;

create trigger tg_atualiza_total_venda
after insert or update or delete on ingresso
for each row
execute function atualiza_total_venda();


/*
Gatilho 6: Atualização do Status da Sessão
Quando todas as poltronas da sala estiverem vendidas para a sessão, o status
passa para ESGOTADA. Se um ingresso for removido e sobrar poltrona, volta
para DISPONIVEL.
*/
create or replace function atualiza_status_sessao() returns trigger as
$$
declare
    v_id_sessao int;
    v_vendidos int;
    v_poltronas int;
begin
    if (tg_op = 'INSERT') then
        v_id_sessao := new.id_sessao;
    else
        v_id_sessao := old.id_sessao;
    end if;

    select count(*) into v_vendidos from ingresso where id_sessao = v_id_sessao;

    select count(*) into v_poltronas
    from poltrona p, sessao s
    where s.id_sessao = v_id_sessao and p.id_sala = s.id_sala;

    if v_poltronas > 0 and v_vendidos >= v_poltronas then
        update sessao set status = 'ESGOTADA'
        where id_sessao = v_id_sessao and status = 'DISPONIVEL';
    else
        update sessao set status = 'DISPONIVEL'
        where id_sessao = v_id_sessao and status = 'ESGOTADA';
    end if;

    return null;
end;
$$
language plpgsql;

create trigger tg_atualiza_status_sessao
after insert or delete on ingresso
for each row
execute function atualiza_status_sessao();

/*
Gatilho 7: Código de Confirmação da Venda
Antes de inserir uma venda sem código de confirmação, gera um automaticamente aleatório.
*/
create or replace function gera_cod_confirmacao() returns trigger as
$$
begin
    if new.cod_confirmacao is null then
        new.cod_confirmacao := 'VND-' || upper(substr(md5(random()::text || now()::text), 1, 8));
        -- gera um codigo hash de 128 bits (32 caracteres), corta até do 1 até o 8 caractere colocando em CAIXA ALTA.
        -- e concatena com o VND, para gerar o codigo de confirmação.
    end if;

    return new;
end;
$$
language plpgsql;

create trigger tg_gera_cod_confirmacao
before insert on venda
for each row
execute function gera_cod_confirmacao();

/*
Gatilho 8: Criptografar Senha do Usuário
Antes de inserir um usuário (ou alterar a senha), guarda a senha criptografada
(md5) em vez do texto puro.
*/
create or replace function criptografa_senha() returns trigger as
$$
begin
    if tg_op = 'INSERT' or new.senha != old.senha then
        new.senha := md5(new.senha);
    end if;

    return new;
end;
$$
language plpgsql;

create trigger tg_criptografa_senha
before insert or update of senha on usuario
for each row
execute function criptografa_senha();


/*
Gatilho 9: Validar Item da Venda de Alimentos
Antes de inserir ou alterar um item vendido, impede a venda de item
indisponível.
*/
create or replace function valida_item_vendido() returns trigger as
$$
declare
    v_disponivel boolean;
    v_nome varchar;
begin
    select disponibilidade, nome into v_disponivel, v_nome -- nome só para o texto
    from item where id_item = new.id_item;

    if v_disponivel is not true then
        raise exception 'O item % está indisponível', v_nome;
    end if;

    return new;
end;
$$
language plpgsql;

create trigger tg_valida_item_vendido
before insert or update on item_vendido
for each row
execute function valida_item_vendido();


/*
Gatilho 10: Atualização do Valor Total da Venda de Alimentos
Mantém o valor_total da venda_alimento atualizado (quantidade x valor do item)
conforme itens são inseridos, alterados ou removidos.
*/
create or replace function atualiza_total_alimento() returns trigger as
$$
declare
    v_valor_novo numeric;
    v_valor_antigo numeric;
begin
    if (tg_op = 'INSERT') then
        select coalesce(valor,0) into v_valor_novo from item where id_item = new.id_item;
        update venda_alimento
        set valor_total = coalesce(valor_total, 0) + new.quantidade * v_valor_novo
        where id_venda_alimento = new.id_venda_alimento;
    end if;
    if (tg_op = 'UPDATE') then
        select coalesce(valor,0) into v_valor_antigo from item where id_item = old.id_item;
        select coalesce(valor,0) into v_valor_novo from item where id_item = new.id_item;
        update venda_alimento
        set valor_total = coalesce(valor_total, 0) - old.quantidade * v_valor_antigo
                          + new.quantidade * v_valor_novo
        where id_venda_alimento = new.id_venda_alimento;
    end if;
    if (tg_op = 'DELETE') then
        select coalesce(valor,0) into v_valor_antigo from item where id_item = old.id_item;
        update venda_alimento
        set valor_total = coalesce(valor_total, 0) - old.quantidade * v_valor_antigo
        where id_venda_alimento = old.id_venda_alimento;
    end if;

    return null;
end;
$$
language plpgsql;

create trigger tg_atualiza_total_alimento
after insert or update or delete on item_vendido
for each row
execute function atualiza_total_alimento();


-- complementar com a de cima
create or replace function impede_alteracao_preco() returns trigger as
$$
declare
    v_qtd_vendas int;
begin
    -- Verifica se o item já foi vendido alguma vez
    select count(*) into v_qtd_vendas from item_vendido where id_item = old.id_item;

    if v_qtd_vendas > 0 then
        raise exception 'Não é possível alterar o valor do item "%". Ele já possui vendas registradas. Desative a disponibilidade e crie um novo item com o novo preço.', old.nome;
    end if;

    return new;
end;
$$
language plpgsql;

-- Dispara apenas quando tentarem fazer um UPDATE na coluna "valor"
create trigger tg_impede_alteracao_preco
before update of valor on item
for each row
execute function impede_alteracao_preco();

/*
Gatilho 11: Validar Poltrona no Layout da Sala
Antes de inserir ou alterar uma poltrona, garante que a fileira e o
número da poltrona existam no layout (num_fileiras e num_colunas) da sala.
*/
create or replace function valida_poltrona() returns trigger as
$$
declare
    v_fileiras int;
    v_colunas int;
begin
    select num_fileiras, num_colunas into v_fileiras, v_colunas
    from sala where id_sala = new.id_sala;

    if new.num_fileira < 1 or new.num_poltrona < 1 then
        raise exception 'Fileira e número da poltrona devem ser maiores que zero';
    end if;
    if new.num_fileira > v_fileiras then
        raise exception 'A fileira % excede o layout da sala % (% fileiras)', new.num_fileira, new.id_sala, v_fileiras;
    end if;
    if new.num_poltrona > v_colunas then
        raise exception 'A poltrona % excede o layout da sala % (% colunas)', new.num_poltrona, new.id_sala, v_colunas;
    end if;

    return new;
end;
$$
language plpgsql;

create trigger tg_valida_poltrona
before insert or update on poltrona
for each row
execute function valida_poltrona();


/*
Gatilho 12: Atualização da Capacidade Total da Sala
Mantém sala.capacidade_total igual ao número de poltronas cadastradas.
*/
create or replace function atualiza_capacidade_sala() returns trigger as
$$
declare
    v_id_sala int;
begin
    if (tg_op = 'INSERT') then
        v_id_sala := new.id_sala;
    else
        v_id_sala := old.id_sala;
    end if;

    update sala
    set capacidade_total = (select count(*) from poltrona where id_sala = v_id_sala)
    where id_sala = v_id_sala;

    return null;
end;
$$
language plpgsql;

create trigger tg_atualiza_capacidade_sala
after insert or delete on poltrona
for each row
execute function atualiza_capacidade_sala();


/*
Gatilho 13: Atualização do Número de Salas do Complexo
Mantém complexo.numero_salas igual ao número de salas cadastradas.
*/
create or replace function atualiza_numero_salas() returns trigger as
$$
declare
    v_id_complexo int;
begin
    if (tg_op = 'INSERT') then
        v_id_complexo := new.id_complexo;
    else
        v_id_complexo := old.id_complexo;
    end if;

    -- recalcula contando as salas (funciona mesmo que o complexo já tenha sido cadastrado com algum valor em numero_salas)
    update complexo
    set numero_salas = (select count(*) from sala where id_complexo = v_id_complexo)
    where id_complexo = v_id_complexo;

    return null;
end;
$$
language plpgsql;

create trigger tg_atualiza_numero_salas
after insert or delete on sala
for each row
execute function atualiza_numero_salas();

/*
Função de Relatório 1: Faturamento por Filme e Repasse à Distribuidora
Retorna, para o período informado, o faturamento de cada filme (ingressos de
sessões não canceladas), o percentual de participação da distribuidora e o
valor de repasse devido.
*/
create or replace function faturamento_por_filme(p_inicio date, p_fim date)
returns table (titulo varchar, distribuidora varchar, qtd_ingressos bigint,
               faturamento numeric, perc_repasse numeric, valor_repasse numeric) as
$$
begin
    return query
    select f.titulo_original as titulo, 
           d.nome as distribuidora, 
           count(i.id_ingresso) as qtd_ingressos,
           coalesce(sum(i.valor_pago), 0) as faturamento,
           coalesce(d.percentual_participacao, 0) as perc_repasse,
           round(coalesce(sum(i.valor_pago), 0) * coalesce(d.percentual_participacao, 0) / 100, 2) as valor_repasse
    from filme f
    join distribuidora d on d.id_distribuidora = f.id_distribuidora
    join sessao s on s.id_filme = f.id_filme
    join ingresso i on i.id_sessao = s.id_sessao
    where s.status != 'CANCELADA'
      and s.data between p_inicio and p_fim
    group by f.id_filme, f.titulo_original, d.nome, d.percentual_participacao
    order by faturamento desc;
end;
$$
language plpgsql;

/*
Função de Relatório 2: Faturamento por Sala
Retorna o faturamento de cada sala no período informado.
*/
create or replace function faturamento_por_sala(p_inicio date, p_fim date)
returns table (codigo_sala int, nome_complexo varchar, tipo_sala varchar,
               qtd_ingressos bigint, faturamento numeric) as
$$
begin
    return query
    select sa.id_sala as codigo_sala, 
           c.nome as nome_complexo, 
           sa.tipo as tipo_sala, 
           count(i.id_ingresso) as qtd_ingressos,
           coalesce(sum(i.valor_pago), 0) as faturamento
    from sala sa
    join complexo c on c.id_complexo = sa.id_complexo
    join sessao s on s.id_sala = sa.id_sala
    join ingresso i on i.id_sessao = s.id_sessao
    where s.status != 'CANCELADA'
      and s.data between p_inicio and p_fim
    group by sa.id_sala, c.nome, sa.tipo
    order by faturamento desc;
end;
$$
language plpgsql;

/*
Função de Relatório 3: Faturamento por Período
Retorna o faturamento total diário dentro do período informado.
*/
create or replace function faturamento_por_periodo(p_inicio date, p_fim date)
returns table (dia date, qtd_ingressos bigint, faturamento numeric) as
$$
begin
    return query
    select s.data as dia, 
           count(i.id_ingresso) as qtd_ingressos, 
           coalesce(sum(i.valor_pago), 0) as faturamento
    from sessao s
    join ingresso i on i.id_sessao = s.id_sessao
    where s.status != 'CANCELADA'
      and s.data between p_inicio and p_fim
    group by s.data
    order by s.data;
end;
$$
language plpgsql;