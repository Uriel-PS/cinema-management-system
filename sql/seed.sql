-- Dados de teste (rodar DEPOIS do DDL da parte 2 e dos gatilhos da parte 3, em banco vazio)
insert into complexo(nome, rua, numero, bairro, cidade, estado, cep)
values ('Cine Floripa', 'Rua Felipe Schmidt', '100', 'Centro', 'Florianópolis', 'SC', '88010-000');

insert into sala(tipo, num_fileiras, num_colunas, id_complexo) values ('3D', 5, 8, 1), ('2D', 4, 6, 1);
-- capacidade_total e complexo.numero_salas são atualizados pelos gatilhos
insert into poltrona(num_fileira, num_poltrona, tipo, id_sala)
  select f, n, 'normal', 1 from generate_series(1,5) f, generate_series(1,8) n;
insert into poltrona(num_fileira, num_poltrona, tipo, id_sala)
  select f, n, 'normal', 2 from generate_series(1,4) f, generate_series(1,6) n;

insert into genero(nome, descricao) values
 ('ACAO','Ação'),('COMEDIA','Comédia'),('DRAMA','Drama'),('TERROR','Terror'),('AVENTURA','Aventura'),('DOCUMENTARIO','Documentário');

insert into distribuidora(nome, cnpj, percentual_participacao) values
 ('Distribuidora Alfa', '11.111.111/0001-11', 40), ('Distribuidora Beta', '22.222.222/0001-22', 35);

insert into filme(titulo_original, titulo_pt, duracao, ano_lancamento, pais_origem, classificacao, diretor, id_distribuidora) values
 ('Space Run', 'Corrida Espacial', 120, 2026, 'EUA', '12', 'A. Silva', 1),
 ('The Laugh', 'A Risada', 95, 2025, 'Brasil', 'L', 'B. Costa', 2);
insert into filme_genero values (1,1),(1,5),(2,2);

insert into funcionario(matricula, nome, cargo, turno, data_admissao) values ('F001', 'Maria Souza', 'BILHETERIA', 'MANHA', '2024-01-10');
insert into usuario(nome, cpf, email, senha) values ('João Silva', '123.456.789-00', 'joao@email.com', 'senha123');
insert into promocao(descricao, regras_aplicacao, tipo_desconto, valor_desconto, data_inicio, data_fim, limite_uso)
values ('Promo de teste', 'Qualquer dia', 'PERCENTUAL', 20, current_date - 30, current_date + 365, 100);

insert into sessao(data, horario_inicio, formato_projecao, idioma, status, valor_base, id_sala, id_filme) values
 (current_date + 1, '18:00', '3D', 'DUBLADO',   'DISPONIVEL', 40.00, 1, 1),
 (current_date + 1, '21:00', '2D', 'LEGENDADO', 'DISPONIVEL', 30.00, 1, 2),
 (current_date + 2, '19:00', '2D', 'DUBLADO',   'DISPONIVEL', 28.00, 2, 2);
