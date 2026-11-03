package cinema.ui;

import cinema.model.Modelo.Tabela;
import java.awt.Component;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;

final class Ui {
    private Ui() {}

    static void preencher(JTable tb, Tabela t) {
        tb.setModel(new DefaultTableModel(t.linhas().toArray(new Object[0][]), t.colunas()) {
            @Override public boolean isCellEditable(int r, int c) { return false; }
        });
    }

    static void erro(Component pai, Exception e) {
        JOptionPane.showMessageDialog(pai, e.getMessage(), "Erro", JOptionPane.ERROR_MESSAGE);
    }

    static JPanel campos(Object... rotuloCampo) {
        JPanel p = new JPanel(new java.awt.GridLayout(0, 4, 6, 4));
        for (int i = 0; i < rotuloCampo.length; i += 2) { p.add(new JLabel((String) rotuloCampo[i])); p.add((Component) rotuloCampo[i + 1]); }
        return p;
    }
}
