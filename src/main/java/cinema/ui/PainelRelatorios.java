package cinema.ui;

import cinema.service.RelatorioService;
import java.awt.BorderLayout;
import javax.swing.*;

class PainelRelatorios extends JPanel {
    private final RelatorioService service = new RelatorioService();
    private final JTextField tfIni = new JTextField("2026-01-01", 9), tfFim = new JTextField("2026-12-31", 9);
    private final JComboBox<String> cbTipo = new JComboBox<>(new String[]{
            "Faturamento por filme (com repasse)", "Faturamento por sala", "Faturamento por período"});
    private final JTable tabela = new JTable();

    PainelRelatorios() {
        setLayout(new BorderLayout(6, 6));
        JPanel topo = new JPanel();
        topo.add(new JLabel("Relatório:")); topo.add(cbTipo);
        topo.add(new JLabel("De:")); topo.add(tfIni);
        topo.add(new JLabel("Até:")); topo.add(tfFim);
        JButton gerar = new JButton("Gerar");
        gerar.addActionListener(e -> {
            try { Ui.preencher(tabela, service.gerar(cbTipo.getSelectedIndex(), tfIni.getText(), tfFim.getText())); }
            catch (Exception ex) { Ui.erro(this, ex); }
        });
        topo.add(gerar);
        add(topo, BorderLayout.NORTH);
        add(new JScrollPane(tabela), BorderLayout.CENTER);
    }
}
