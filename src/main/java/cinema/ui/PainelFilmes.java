package cinema.ui;

import cinema.model.Modelo.Filme;
import cinema.service.FilmeService;
import java.awt.BorderLayout;
import java.util.ArrayList;
import java.util.List;
import javax.swing.*;

class PainelFilmes extends JPanel {
    private final FilmeService service = new FilmeService();
    private final JTextField tfOrig = new JTextField(), tfPt = new JTextField(), tfDur = new JTextField(),
            tfAno = new JTextField(), tfClass = new JTextField(), tfDir = new JTextField(), tfDist = new JTextField();
    private final JCheckBox[] generos = {new JCheckBox("ACAO"), new JCheckBox("COMEDIA"), new JCheckBox("DRAMA"),
            new JCheckBox("TERROR"), new JCheckBox("AVENTURA"), new JCheckBox("DOCUMENTARIO")};
    private final JTable tabela = new JTable();

    PainelFilmes() {
        setLayout(new BorderLayout(6, 6));
        JPanel form = new JPanel(new BorderLayout());
        form.add(Ui.campos("Título original", tfOrig, "Título PT", tfPt, "Duração (min)", tfDur, "Ano", tfAno,
                "Classificação", tfClass, "Diretor", tfDir, "Cód. distribuidora", tfDist), BorderLayout.NORTH);
        JPanel gen = new JPanel();
        for (JCheckBox g : generos) gen.add(g);
        JButton salvar = new JButton("Cadastrar filme");
        salvar.addActionListener(e -> salvar());
        gen.add(salvar);
        form.add(gen, BorderLayout.SOUTH);
        add(form, BorderLayout.NORTH);
        add(new JScrollPane(tabela), BorderLayout.CENTER);
        atualizar();
    }

    private void salvar() {
        try {
            List<String> gs = new ArrayList<>();
            for (JCheckBox g : generos) if (g.isSelected()) gs.add(g.getText());
            service.cadastrar(new Filme(tfOrig.getText(), tfPt.getText(), Integer.parseInt(tfDur.getText().trim()),
                    Integer.parseInt(tfAno.getText().trim()), tfClass.getText(), tfDir.getText(),
                    Integer.parseInt(tfDist.getText().trim()), gs));
            atualizar();
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "Duração, ano e distribuidora devem ser números.", "Erro", JOptionPane.ERROR_MESSAGE);
        } catch (Exception e) { Ui.erro(this, e); }
    }

    private void atualizar() {
        try { Ui.preencher(tabela, service.listar()); } catch (Exception e) { Ui.erro(this, e); }
    }
}
