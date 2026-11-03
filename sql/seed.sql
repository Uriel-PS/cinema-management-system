-- ============================================================================
-- SISTEMA DE GERENCIAMENTO DE CINEMA
-- Script de Povoamento (Seed) com Dados Realistas para Testes e Apresentação
-- Executar no PostgreSQL (pgAdmin 4 ou psql) após o DDL (Parte 2) e Gatilhos (Parte 3)
-- ============================================================================

-- Dica: se já existirem dados e quiser reiniciar do zero, descomente a linha abaixo:
-- truncate complexo, distribuidora, genero, funcionario, usuario, promocao, item restart identity cascade;

-- ----------------------------------------------------------------------------
-- 1. COMPLEXOS (3 complexos)
-- ----------------------------------------------------------------------------
insert into complexo(nome, rua, numero, bairro, cidade, estado, cep) values
 ('Cine Floripa Centro', 'Rua Felipe Schmidt', '100', 'Centro', 'Florianópolis', 'SC', '88010-000'),
 ('Cine Shopping Beiramar', 'Rua Bocaiúva', '2468', 'Centro', 'Florianópolis', 'SC', '88015-902'),
 ('Cine Continente Park', 'Rodovia BR-101', 'km 210', 'Distrito Industrial', 'São José', 'SC', '88104-800');

insert into complexo_telefone(numero, id_complexo) values
 ('(48) 3222-1000', 1),
 ('(48) 3333-2000', 2),
 ('(48) 3288-3000', 3);

-- ----------------------------------------------------------------------------
-- 2. SALAS (7 salas em diferentes formatos)
-- Nota: complexo.numero_salas é atualizado automaticamente pelo gatilho 13
-- ----------------------------------------------------------------------------
insert into sala(tipo, num_fileiras, num_colunas, id_complexo) values
 ('3D',   5, 8,  1), -- Sala 1 (Floripa Centro): 40 poltronas
 ('2D',   4, 6,  1), -- Sala 2 (Floripa Centro): 24 poltronas
 ('VIP',  3, 6,  1), -- Sala 3 (Floripa Centro): 18 poltronas
 ('IMAX', 6, 10, 2), -- Sala 4 (Beiramar): 60 poltronas
 ('3D',   5, 8,  2), -- Sala 5 (Beiramar): 40 poltronas
 ('2D',   5, 8,  3), -- Sala 6 (Continente): 40 poltronas
 ('VIP',  4, 5,  3); -- Sala 7 (Continente): 20 poltronas

-- ----------------------------------------------------------------------------
-- 3. POLTRONAS (Geração em massa por sala)
-- Nota: sala.capacidade_total é atualizada automaticamente pelo gatilho 12
-- ----------------------------------------------------------------------------
-- Sala 1: 5 fileiras x 8 colunas (última fileira com 2 adaptadas)
insert into poltrona(num_fileira, num_poltrona, tipo, id_sala)
  select f, n, case when f = 5 and n in (1,2) then 'adaptada para deficientes' else 'normal' end, 1
  from generate_series(1,5) f, generate_series(1,8) n;

-- Sala 2: 4 fileiras x 6 colunas
insert into poltrona(num_fileira, num_poltrona, tipo, id_sala)
  select f, n, 'normal', 2
  from generate_series(1,4) f, generate_series(1,6) n;

-- Sala 3: 3 fileiras x 6 colunas (VIP)
insert into poltrona(num_fileira, num_poltrona, tipo, id_sala)
  select f, n, 'VIP', 3
  from generate_series(1,3) f, generate_series(1,6) n;

-- Sala 4: 6 fileiras x 10 colunas (IMAX)
insert into poltrona(num_fileira, num_poltrona, tipo, id_sala)
  select f, n, case when f = 6 and n in (1,2) then 'adaptada para deficientes' else 'normal' end, 4
  from generate_series(1,6) f, generate_series(1,10) n;

-- Sala 5: 5 fileiras x 8 colunas (3D)
insert into poltrona(num_fileira, num_poltrona, tipo, id_sala)
  select f, n, 'normal', 5
  from generate_series(1,5) f, generate_series(1,8) n;

-- Sala 6: 5 fileiras x 8 colunas (2D)
insert into poltrona(num_fileira, num_poltrona, tipo, id_sala)
  select f, n, 'normal', 6
  from generate_series(1,5) f, generate_series(1,8) n;

-- Sala 7: 4 fileiras x 5 colunas (VIP)
insert into poltrona(num_fileira, num_poltrona, tipo, id_sala)
  select f, n, 'VIP', 7
  from generate_series(1,4) f, generate_series(1,5) n;

-- ----------------------------------------------------------------------------
-- 4. GÊNEROS (6 gêneros permitidos pela restrição CHECK)
-- ----------------------------------------------------------------------------
insert into genero(nome, descricao) values
 ('ACAO',         'Filmes com cenas de impacto, perseguição e ritmo acelerado'),
 ('COMEDIA',      'Narrativas leves focadas em humor e entretenimento'),
 ('DRAMA',        'Foco no desenvolvimento profundo de personagens e conflitos'),
 ('TERROR',       'Histórias de suspense, tensão psicológica e elementos sobrenaturais'),
 ('AVENTURA',     'Jornadas épicas, exploração e descobertas em mundos novos'),
 ('DOCUMENTARIO', 'Obras de não-ficção que retratam fatos, pessoas e histórias reais');

-- ----------------------------------------------------------------------------
-- 5. DISTRIBUIDORAS (7 distribuidoras com % de repasse)
-- ----------------------------------------------------------------------------
insert into distribuidora(nome, cnpj, percentual_participacao) values
 ('Warner Bros. Pictures',       '11.111.111/0001-11', 45.00),
 ('Universal Pictures Brasil',   '22.222.222/0001-22', 40.00),
 ('Walt Disney Studios',         '33.333.333/0001-33', 50.00),
 ('Sony Pictures Releasing',     '44.444.444/0001-44', 38.50),
 ('Paramount Pictures Brasil',   '55.555.555/0001-55', 42.00),
 ('Paris Filmes',                '66.666.666/0001-66', 35.00),
 ('O2 Play / Imovision',         '77.777.777/0001-77', 30.00);

insert into distribuidora_telefone(numero, id_distribuidora) values
 ('(11) 4004-1111', 1),
 ('(11) 4004-2222', 2),
 ('(11) 4004-3333', 3),
 ('(11) 4004-4444', 4),
 ('(11) 4004-5555', 5),
 ('(11) 4004-6666', 6),
 ('(21) 3003-7777', 7);

-- ----------------------------------------------------------------------------
-- 6. FILMES (8 filmes com sinopse, classificação e vínculos de gênero)
-- ----------------------------------------------------------------------------
insert into filme(titulo_original, titulo_pt, duracao, ano_lancamento, pais_origem, classificacao, diretor, sinopse, link_trailer, id_distribuidora) values
 ('Interstellar Odyssey', 'Odisseia Interestelar', 145, 2026, 'EUA', '12', 'Christopher Nolan', 'Uma tripulação de astronautas viaja através de um buraco de minhoca em busca de um novo lar para a humanidade.', 'https://trailers.com/interstellar', 1),
 ('The Laugh Project',   'Operação Risada',        98, 2025, 'Brasil', 'L', 'Ingrid Guimarães', 'Dois detetives trapalhões precisam se infiltrar em uma convenção de humoristas para desvendar um crime.', 'https://trailers.com/laugh', 6),
 ('Midnight Shadows',    'Sombras da Meia-Noite', 110, 2026, 'EUA', '16', 'James Wan', 'Fenômenos inexplicáveis aterrorizam uma família que se muda para um casarão isolado na Nova Inglaterra.', 'https://trailers.com/shadows', 1),
 ('Kingdom of Secrets',  'O Reino dos Segredos',  125, 2025, 'Reino Unido', '10', 'David Yates', 'Um jovem arqueólogo descobre um artefato ancestral que pode mudar o destino de um império esquecido.', 'https://trailers.com/kingdom', 3),
 ('Speed Drift: Tokyo',  'Velozes no Asfalto',    118, 2026, 'Japão', '14', 'Justin Lin', 'Corridas clandestinas nas ruas iluminadas por neon de Tóquio levam a rivalidade entre pilotos ao limite.', 'https://trailers.com/speed', 2),
 ('Echoes of Amazon',    'Vozes da Floresta',      92, 2024, 'Brasil', 'L', 'Fernando Meirelles', 'Documentário fascinante sobre as comunidades ribeirinhas e a biodiversidade inexplorada da Amazônia.', 'https://trailers.com/amazonia', 7),
 ('Cyber Heist 2099',    'Golpe Cibernético',     130, 2026, 'EUA', '14', 'Denis Villeneuve', 'Em uma megalópole futurista, hackers de elite planejam o maior roubo de dados da história corporativa.', 'https://trailers.com/cyber', 4),
 ('Distant Horizon',     'Horizonte Distante',    105, 2025, 'França', '12', 'Damien Chazelle', 'Dois músicos talentosos buscam o sucesso em Paris enquanto tentam manter vivo seu amor improvável.', 'https://trailers.com/horizon', 5);

-- Vínculos N:N filme_genero (1:ACAO, 2:COMEDIA, 3:DRAMA, 4:TERROR, 5:AVENTURA, 6:DOCUMENTARIO)
insert into filme_genero(id_filme, id_genero) values
 (1, 1), (1, 5), -- Interstellar: Ação, Aventura
 (2, 2),         -- Operação Risada: Comédia
 (3, 4),         -- Sombras: Terror
 (4, 5), (4, 3), -- Reino: Aventura, Drama
 (5, 1),         -- Velozes: Ação
 (6, 6),         -- Vozes: Documentário
 (7, 1), (7, 5), -- Golpe Cibernético: Ação, Aventura
 (8, 3);         -- Horizonte Distante: Drama

-- ----------------------------------------------------------------------------
-- 7. FUNCIONÁRIOS (7 funcionários cobrindo todos os cargos e turnos)
-- ----------------------------------------------------------------------------
insert into funcionario(matricula, nome, cargo, turno, data_admissao) values
 ('F001', 'Maria Souza',         'BILHETERIA',    'MANHA', '2024-01-10'),
 ('F002', 'Carlos Eduardo Lima', 'BILHETERIA',    'TARDE', '2024-02-15'),
 ('F003', 'Ana Beatriz Ramos',   'BILHETERIA',    'NOITE', '2024-03-01'),
 ('F004', 'Lucas Ferreira',      'BOMBONIERE',    'MANHA', '2024-04-12'),
 ('F005', 'Juliana Mendes',      'BOMBONIERE',    'NOITE', '2024-05-20'),
 ('F006', 'Roberto Alcântara',   'PROJECIONISTA', 'TARDE', '2023-11-05'),
 ('F007', 'Fernanda Oliveira',   'GERENTE',       'MANHA', '2023-08-01');

-- ----------------------------------------------------------------------------
-- 8. USUÁRIOS (7 clientes cadastrados)
-- Nota: a senha é criptografada automaticamente em MD5 pelo gatilho 8
-- ----------------------------------------------------------------------------
insert into usuario(nome, cpf, email, senha) values
 ('João Silva',           '123.456.789-00', 'joao.silva@email.com',       'senha123'),
 ('Camila Rodrigues',     '234.567.890-11', 'camila.rodrigues@email.com', 'senha456'),
 ('Pedro Henrique Santos','345.678.901-22', 'pedro.santos@email.com',     'cinema2026'),
 ('Larissa Albuquerque',  '456.789.012-33', 'larissa.alb@email.com',      'filmes@99'),
 ('Gabriel Martins',      '567.890.123-44', 'gabriel.martins@email.com',  'pipoca123'),
 ('Beatriz Cavalcanti',   '678.901.234-55', 'beatriz.caval@email.com',    'pass!2026'),
 ('Rafael Nogueira',      '789.012.345-66', 'rafael.nog@email.com',       'cinema@top');

insert into usuario_telefone(numero, id_usuario) values
 ('(48) 99111-2233', 1),
 ('(48) 99222-3344', 2),
 ('(48) 99333-4455', 3),
 ('(48) 99444-5566', 4),
 ('(48) 99555-6677', 5),
 ('(48) 99666-7788', 6),
 ('(48) 99777-8899', 7);

-- ----------------------------------------------------------------------------
-- 9. PROMOÇÕES (7 promoções vigentes)
-- ----------------------------------------------------------------------------
insert into promocao(descricao, regras_aplicacao, tipo_desconto, valor_desconto, data_inicio, data_fim, limite_uso) values
 ('Quarta Maluca',          'Válido para todas as sessões nas quartas-feiras', 'PERCENTUAL', 25.00, current_date - 60, current_date + 300, 500),
 ('Estudante Universitário','Apresentação de carteirinha estudantil ativa',    'PERCENTUAL', 20.00, current_date - 90, current_date + 365, 1000),
 ('Clube Cinéfilo VIP',     'Clientes fidelidade cadastrados no clube',        'PERCENTUAL', 15.00, current_date - 30, current_date + 180, 300),
 ('Cupom Primeira Compra',  'Desconto fixo na primeira compra online',         'VALOR',      10.00, current_date - 15, current_date + 90,  150),
 ('Festival Cinema Nacional','Desconto em filmes de produção brasileira',       'PERCENTUAL', 30.00, current_date - 10, current_date + 60,  200),
 ('Combo Matinê da Tarde',  'Sessões com início antes das 16h',                'VALOR',       8.00, current_date - 30, current_date + 120, 200),
 ('Aniversariante do Mês',  'Desconto especial durante o mês do aniversário',  'PERCENTUAL', 50.00, current_date - 365,current_date + 365, 400);

-- ----------------------------------------------------------------------------
-- 10. ITENS DE BOMBONIERE (7 produtos)
-- ----------------------------------------------------------------------------
insert into item(nome, descricao, categoria, valor, disponibilidade) values
 ('Pipoca Balde Grande',   'Balde 3L de pipoca amanteigada artesanal',       'PIPOCA', 28.00, true),
 ('Pipoca Saco Médio',     'Saco 1.5L de pipoca salgada crocante',           'PIPOCA', 20.00, true),
 ('Refrigerante Copo 700ml','Refri gelado servido no balcão (sabores)',      'BEBIDA', 14.00, true),
 ('Refrigerante Copo 500ml','Refri gelado servido no balcão (sabores)',      'BEBIDA', 11.00, true),
 ('Água Mineral 500ml',    'Garrafa 500ml sem gás purificada',               'BEBIDA',  6.00, true),
 ('Nachos com Molho Cheddar','Porção crocante de nachos com cheddar quente', 'SNACK',  22.00, true),
 ('Barra de Chocolate 100g','Chocolate nobre ao leite com castanhas',       'DOCE',   10.00, true);

-- ----------------------------------------------------------------------------
-- 11. SESSÕES (10 sessões distribuídas em várias salas e horários)
-- Nota: horários calculados respeitando o gatilho 1 (sem sobreposição na mesma sala)
-- ----------------------------------------------------------------------------
-- Sala 1 (3D, Floripa Centro):
insert into sessao(data, horario_inicio, formato_projecao, idioma, status, valor_base, id_sala, id_filme) values
 (current_date + 1, '14:00', '3D', 'DUBLADO',   'DISPONIVEL', 38.00, 1, 1),
 (current_date + 1, '17:30', '3D', 'LEGENDADO', 'DISPONIVEL', 42.00, 1, 1),
 (current_date + 1, '21:00', '2D', 'DUBLADO',   'DISPONIVEL', 35.00, 1, 7);

-- Sala 2 (2D, Floripa Centro):
insert into sessao(data, horario_inicio, formato_projecao, idioma, status, valor_base, id_sala, id_filme) values
 (current_date + 1, '15:00', '2D', 'DUBLADO',   'DISPONIVEL', 28.00, 2, 2),
 (current_date + 1, '18:00', '2D', 'ORIGINAL',  'DISPONIVEL', 26.00, 2, 6),
 (current_date + 1, '20:30', '2D', 'LEGENDADO', 'DISPONIVEL', 30.00, 2, 8);

-- Sala 3 (VIP, Floripa Centro):
insert into sessao(data, horario_inicio, formato_projecao, idioma, status, valor_base, id_sala, id_filme) values
 (current_date + 1, '19:00', '2D', 'LEGENDADO', 'DISPONIVEL', 60.00, 3, 7);

-- Sala 4 (IMAX, Shopping Beiramar):
insert into sessao(data, horario_inicio, formato_projecao, idioma, status, valor_base, id_sala, id_filme) values
 (current_date + 2, '16:00', '3D', 'DUBLADO',   'DISPONIVEL', 48.00, 4, 5),
 (current_date + 2, '19:30', '3D', 'LEGENDADO', 'DISPONIVEL', 52.00, 4, 3);

-- Sala 5 (3D, Shopping Beiramar):
insert into sessao(data, horario_inicio, formato_projecao, idioma, status, valor_base, id_sala, id_filme) values
 (current_date + 2, '18:00', '2D', 'DUBLADO',   'DISPONIVEL', 32.00, 5, 4);

-- ----------------------------------------------------------------------------
-- 12. VENDAS E INGRESSOS INICIAIS (Para demonstrar poltronas ocupadas e relatórios)
-- Os gatilhos calculam automaticamente: valor_pago, qr_code, cod_confirmacao e valor_total
-- ----------------------------------------------------------------------------
-- Venda Online 1: João Silva compra 2 ingressos para a Sessão 1 (Sala 1)
insert into venda(canal_venda, tipo_pagamento, id_usuario, id_funcionario)
values ('ONLINE', 'PIX', 1, null);

insert into ingresso(tipo_ingresso, id_sessao, id_venda, id_poltrona, id_promocao)
select 'INTEIRA', 1, currval('venda_id_venda_seq'), id_poltrona, null
from poltrona where id_sala = 1 and num_fileira = 1 and num_poltrona = 1;

insert into ingresso(tipo_ingresso, id_sessao, id_venda, id_poltrona, id_promocao)
select 'MEIA-ENTRADA', 1, currval('venda_id_venda_seq'), id_poltrona, null
from poltrona where id_sala = 1 and num_fileira = 1 and num_poltrona = 2;

-- Venda Presencial 2: Maria Souza vende 2 ingressos para a Sessão 1 (Sala 1)
insert into venda(canal_venda, tipo_pagamento, id_usuario, id_funcionario)
values ('PRESENCIAL', 'CARTAO DE CREDITO', null, 1);

insert into ingresso(tipo_ingresso, id_sessao, id_venda, id_poltrona, id_promocao)
select 'PROMOCIONAL', 1, currval('venda_id_venda_seq'), id_poltrona, 1
from poltrona where id_sala = 1 and num_fileira = 2 and num_poltrona = 3;

insert into ingresso(tipo_ingresso, id_sessao, id_venda, id_poltrona, id_promocao)
select 'INTEIRA', 1, currval('venda_id_venda_seq'), id_poltrona, null
from poltrona where id_sala = 1 and num_fileira = 2 and num_poltrona = 4;

-- Venda Online 3: Camila Rodrigues compra 1 ingresso para a Sessão 4 (Sala 2)
insert into venda(canal_venda, tipo_pagamento, id_usuario, id_funcionario)
values ('ONLINE', 'CARTAO DE DEBITO', 2, null);

insert into ingresso(tipo_ingresso, id_sessao, id_venda, id_poltrona, id_promocao)
select 'INTEIRA', 4, currval('venda_id_venda_seq'), id_poltrona, null
from poltrona where id_sala = 2 and num_fileira = 1 and num_poltrona = 1;

-- Venda Presencial 4: Carlos Eduardo vende 1 ingresso para a Sessão 4 (Sala 2)
insert into venda(canal_venda, tipo_pagamento, id_usuario, id_funcionario)
values ('PRESENCIAL', 'DINHEIRO', null, 2);

insert into ingresso(tipo_ingresso, id_sessao, id_venda, id_poltrona, id_promocao)
select 'MEIA-ENTRADA', 4, currval('venda_id_venda_seq'), id_poltrona, null
from poltrona where id_sala = 2 and num_fileira = 1 and num_poltrona = 2;

-- ----------------------------------------------------------------------------
-- 13. VENDA DE ALIMENTOS (BOMBONIERE)
-- Demonstra os gatilhos 9 e 10 (validação de item e cálculo automático de total)
-- ----------------------------------------------------------------------------
insert into venda_alimento(data, hora, forma_pagamento, id_ingresso, id_funcionario)
values (current_date, '14:30', 'PIX', 1, 4);

insert into item_vendido(id_item, id_venda_alimento, quantidade) values
 (1, currval('venda_alimento_id_venda_alimento_seq'), 1), -- 1 Pipoca Grande
 (3, currval('venda_alimento_id_venda_alimento_seq'), 2); -- 2 Refrigerantes 700ml
