-- SISTEMA DE GERENCIAMENTO DE CINEMA
-- Script DDL - PostgreSQL
-- Banco de Dados II - UDESC CCT

-- COMPLEXO
create table complexo(
    id_complexo serial primary key,
    nome varchar(100) not null,
    numero_salas int,
    rua varchar(100),
    numero varchar(20),
    bairro varchar(100),
    cidade varchar(100),
    estado varchar(2),
    cep varchar(10)
);

create table complexo_telefone(
    id_telefone serial primary key,
    numero varchar(20) not null,
    id_complexo int not null references complexo on delete cascade on update cascade
);

-- DISTRIBUIDORA
create table distribuidora(
    id_distribuidora serial primary key,
    nome varchar(100) not null,
    cnpj varchar(20) unique not null,
    percentual_participacao numeric(5,2)
);

create table distribuidora_telefone(
    id_telefone serial primary key,
    numero varchar(20) not null,
    id_distribuidora int not null references distribuidora on delete cascade on update cascade
);

-- FILME 
create table filme(
    id_filme serial primary key,
    titulo_original varchar(150) not null,
    titulo_pt varchar(150),
    duracao int,
    ano_lancamento int,
    pais_origem varchar(50),
    sinopse text,
    classificacao varchar(10),
    diretor varchar(100),
    link_trailer varchar(255),
    id_distribuidora int not null references distribuidora on update cascade
);

-- GENERO 
create table genero(
    id_genero serial primary key,
    nome varchar(50) unique not null
        check (nome in ('ACAO','COMEDIA','DRAMA','TERROR','AVENTURA','DOCUMENTARIO')),
    descricao varchar(200)
);

create table filme_genero(
    id_filme int not null references filme on delete cascade on update cascade,
    id_genero int not null references genero on delete cascade on update cascade,
    primary key (id_filme, id_genero)
);

-- SALA / POLTRONA
create table sala(
    id_sala serial primary key,
    tipo varchar(10) check (tipo in ('2D','3D','IMAX','VIP')),
    capacidade_total int,
    num_fileiras int,
    num_colunas int,
    id_complexo int not null references complexo on delete cascade on update cascade
);

create table poltrona(
    id_poltrona serial primary key,
    num_fileira int not null,
    num_poltrona int not null,
    tipo varchar(30) check (tipo in ('normal','VIP','adaptada para deficientes')),
    id_sala int not null references sala on delete cascade on update cascade,
    unique (id_sala, num_fileira, num_poltrona)
);

-- SESSAO
-- horario_termino nao entra aqui: é atributo derivado (duracao do filme + intervalo),
-- sera obtido via consulta/funcao
create table sessao(
    id_sessao serial primary key,
    data date not null,
    horario_inicio time not null,
    formato_projecao varchar(2) check (formato_projecao in ('2D','3D')),
    idioma varchar(15) check (idioma in ('DUBLADO','LEGENDADO','ORIGINAL')),
    status varchar(20) check (status in ('DISPONIVEL','EM EXIBICAO','ESGOTADA','CANCELADA')),
    valor_base numeric(10,2),
    id_sala int not null references sala on update cascade,
    id_filme int not null references filme on update cascade
);

-- USUARIO
create table usuario(
    id_usuario serial primary key,
    nome varchar(100) not null,
    cpf varchar(14) unique not null,
    email varchar(100) unique,
    senha varchar(255) not null
);

create table usuario_telefone(
    id_telefone serial primary key,
    numero varchar(20) not null,
    id_usuario int not null references usuario on delete cascade on update cascade
);

-- FUNCIONARIO
create table funcionario(
    id_funcionario serial primary key,
    matricula varchar(20) unique not null,
    nome varchar(100) not null,
    cargo varchar(20) check (cargo in ('BILHETERIA','BOMBONIERE','PROJECIONISTA','GERENTE')),
    turno varchar(20),
    data_admissao date
);

-- PROMOCAO 
create table promocao(
    id_promocao serial primary key,
    descricao varchar(200),
    regras_aplicacao text,
    tipo_desconto varchar(15) check (tipo_desconto in ('PERCENTUAL','VALOR')),
    valor_desconto numeric(10,2),
    data_inicio date,
    data_fim date,
    limite_uso int
);

-- VENDA
-- tabela unica, com id_usuario e id_funcionario
-- definida por atributo, conforme diagrama EER).
create table venda(
    id_venda serial primary key,
    valor_total numeric(10,2),
    cod_confirmacao varchar(50) unique,
    tipo_pagamento varchar(30),
    canal_venda varchar(15) not null check (canal_venda in ('ONLINE','PRESENCIAL')),
    id_usuario int references usuario on update cascade,
    id_funcionario int references funcionario on update cascade,
    check (
        (canal_venda = 'ONLINE'     and id_usuario     is not null and id_funcionario is null)
        or
        (canal_venda = 'PRESENCIAL' and id_funcionario is not null and id_usuario     is null)
    )
);

-- INGRESSO 
create table ingresso(
    id_ingresso serial primary key,
    valor_pago numeric(10,2),
    tipo_ingresso varchar(15) check (tipo_ingresso in ('INTEIRA','MEIA-ENTRADA','PROMOCIONAL')),
    qr_code varchar(255) unique,
    id_sessao int not null references sessao on update cascade,
    id_venda int not null references venda on delete cascade on update cascade,
    id_poltrona int not null references poltrona on update cascade,
    id_promocao int references promocao on update cascade,
    -- a mesma poltrona nao pode ser vendida duas vezes na mesma sessao
    unique (id_sessao, id_poltrona)
);

-- ITEM
create table item(
    id_item serial primary key,
    nome varchar(100) not null,
    descricao varchar(200),
    categoria varchar(50),
    valor numeric(10,2),
    disponibilidade boolean default true
);

-- VENDA_ALIMENTO 
create table venda_alimento(
    id_venda_alimento serial primary key,
    data date not null,
    hora time not null,
    valor_total numeric(10,2),
    forma_pagamento varchar(30),
    id_ingresso int references ingresso on update cascade,
    id_funcionario int not null references funcionario on update cascade
);

create table item_vendido(
    id_item int not null references item on update cascade,
    id_venda_alimento int not null references venda_alimento on delete cascade on update cascade,
    quantidade int not null check (quantidade > 0),
    primary key (id_item, id_venda_alimento)
);