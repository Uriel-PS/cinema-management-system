package cinema.ui;

import cinema.dao.Consulta;
import java.awt.BorderLayout;
import javax.swing.*;

/**
 * Aba de consulta rápida dos cadastros auxiliares.
 * Permite visualizar os registros (e seus códigos) de todas as tabelas
 * referenciadas por código em outras partes do sistema.
 */
class PainelCadastros extends JPanel {

    private static final String[][] CONSULTAS = {
        {"Funcionários",   "select id_funcionario as código, matricula as matrícula, nome, cargo, turno, data_admissao as admissão from funcionario order by id_funcionario"},
        {"Usuários",       "select id_usuario as código, nome, cpf, email from usuario order by id_usuario"},
        {"Distribuidoras", "select id_distribuidora as código, nome, cnpj, percentual_participacao as \"participação (%)\" from distribuidora order by id_distribuidora"},
        {"Filmes",         "select id_filme as código, titulo_original as \"título original\", titulo_pt as \"título PT\", duracao as \"duração (min)\", ano_lancamento as ano, classificacao as classificação, diretor from filme order by id_filme"},
        {"Salas",          "select s.id_sala as código, s.tipo, s.capacidade_total as capacidade, s.num_fileiras as fileiras, s.num_colunas as colunas, c.nome as complexo from sala s join complexo c on c.id_complexo = s.id_complexo order by s.id_sala"},
        {"Complexos",      "select id_complexo as código, nome, rua, numero, bairro, cidade, estado, cep from complexo order by id_complexo"},
        {"Gêneros",        "select id_genero as código, nome, descricao as descrição from genero order by id_genero"},
        {"Promoções",      "select id_promocao as código, descricao as descrição, tipo_desconto as \"tipo desconto\", valor_desconto as \"valor desconto\", data_inicio as início, data_fim as fim, limite_uso as \"limite uso\" from promocao order by id_promocao"},
    };

    private final JComboBox<String> cbTabela;
    private final JTable tabela = new JTable();

    PainelCadastros() {
        setLayout(new BorderLayout(6, 6));

        String[] nomes = new String[CONSULTAS.length];
        for (int i = 0; i < CONSULTAS.length; i++) nomes[i] = CONSULTAS[i][0];
        cbTabela = new JComboBox<>(nomes);

        JPanel topo = new JPanel();
        topo.add(new JLabel("Consultar:"));
        topo.add(cbTabela);
        JButton carregar = new JButton("Carregar");
        carregar.addActionListener(e -> carregar());
        topo.add(carregar);
        add(topo, BorderLayout.NORTH);

        add(new JScrollPane(tabela), BorderLayout.CENTER);

        carregar(); // já carrega a primeira tabela ao abrir
    }

    private void carregar() {
        try {
            String sql = CONSULTAS[cbTabela.getSelectedIndex()][1];
            Ui.preencher(tabela, Consulta.executar(sql));
        } catch (Exception e) { Ui.erro(this, e); }
    }
}

