package cinema;

import cinema.ui.MainFrame;
import com.formdev.flatlaf.FlatLightLaf;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;

public class Main {
    public static void main(String[] args) {
        try { UIManager.setLookAndFeel(new FlatLightLaf()); }
        catch (Exception e) { /* fallback para o padrão */ }
        SwingUtilities.invokeLater(() -> new MainFrame().setVisible(true));
    }
}
