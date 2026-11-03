package cinema.ui;

import cinema.service.SessaoService;
import java.awt.BorderLayout;
import javax.swing.*;

class PainelSessoes extends JPanel {
    private final SessaoService service = new SessaoService();
    private final JTextField tfData = new JTextField(), tfHora = new JTextField(), tfValor = new JTextField(),
            tfSala = new JTextField(), tfFilme = new JTextField();
    private final JComboBox<String> cbFormato = new JComboBox<>(new String[]{"2D", "3D"});
    private final JComboBox<String> cbIdioma = new JComboBox<>(new String[]{"DUBLADO", "LEGENDADO", "ORIGINAL"});
    private final JTable tabela = new JTable();

    PainelSessoes() {
        setLayout(new BorderLayout(6, 6));
        JPanel form = new JPanel(new BorderLayout());
        form.add(Ui.campos("Data (AAAA-MM-DD)", tfData, "Início (HH:MM)", tfHora, "Formato", cbFormato, "Idioma", cbIdioma,
                "Valor base", tfValor, "Cód. sala", tfSala, "Cód. filme", tfFilme), BorderLayout.NORTH);
        JButton salvar = new JButton("Cadastrar sessão");
        salvar.addActionListener(e -> salvar());
        form.add(salvar, BorderLayout.SOUTH);
        add(form, BorderLayout.NORTH);
        add(new JScrollPane(tabela), BorderLayout.CENTER);
        atualizar();
    }

    private void salvar() {
        try {
            service.cadastrar(tfData.getText(), tfHora.getText(), (String) cbFormato.getSelectedItem(),
                    (String) cbIdioma.getSelectedItem(), tfValor.getText(), tfSala.getText(), tfFilme.getText());
            atualizar();
        } catch (Exception e) { Ui.erro(this, e); }
    }

    private void atualizar() {
        try { Ui.preencher(tabela, service.listar()); } catch (Exception e) { Ui.erro(this, e); }
    }
}
