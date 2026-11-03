package cinema.ui;

import javax.swing.*;

public class MainFrame extends JFrame {
    public MainFrame() {
        super("Sistema de Gerenciamento de Cinema");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        JTabbedPane abas = new JTabbedPane();
        abas.add("Venda de Ingressos", new PainelVenda());
        abas.add("Filmes", new PainelFilmes());
        abas.add("Sessões", new PainelSessoes());
        abas.add("Relatórios", new PainelRelatorios());
        abas.add("Cadastros", new PainelCadastros());
        add(abas);
        setSize(1000, 650);
        setMinimumSize(new java.awt.Dimension(700, 550));
        setLocationRelativeTo(null);
    }
}
