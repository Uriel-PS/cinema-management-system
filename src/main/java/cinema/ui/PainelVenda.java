package cinema.ui;

import cinema.model.Modelo.Poltrona;
import cinema.model.Modelo.ResultadoVenda;
import cinema.service.SessaoService;
import cinema.service.VendaService;
import java.awt.*;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import javax.swing.*;

class PainelVenda extends JPanel {
    private final VendaService vendaService = new VendaService();
    private final SessaoService sessaoService = new SessaoService();
    private final JTable tbSessoes = new JTable();
    private final JPanel mapa = new JPanel();
    private final JLabel telao = new JLabel("T E L A", SwingConstants.CENTER);
    private final Map<Integer, JToggleButton> botoes = new LinkedHashMap<>();
    private final JComboBox<String> cbCanal = new JComboBox<>(new String[]{"PRESENCIAL", "ONLINE"});
    private final JComboBox<String> cbTipo = new JComboBox<>(new String[]{"INTEIRA", "MEIA-ENTRADA", "PROMOCIONAL"});
    private final JTextField tfAtendente = new JTextField(4), tfPromo = new JTextField(4), tfPagto = new JTextField("PIX", 8);
    private int sessaoAtual = -1;

    PainelVenda() {
        setLayout(new BorderLayout(6, 6));

        JPanel topo = new JPanel(new BorderLayout());
        JScrollPane sp = new JScrollPane(tbSessoes);
        sp.setPreferredSize(new Dimension(900, 150));
        topo.add(sp, BorderLayout.CENTER);
        JPanel bt = new JPanel();
        JButton atualizar = new JButton("Atualizar sessões"), carregar = new JButton("Carregar mapa da sessão");
        atualizar.addActionListener(e -> atualizarSessoes());
        carregar.addActionListener(e -> carregarMapa());
        bt.add(atualizar); bt.add(carregar);
        topo.add(bt, BorderLayout.SOUTH);
        add(topo, BorderLayout.NORTH);

        telao.setOpaque(true);
        telao.setBackground(Color.DARK_GRAY);
        telao.setForeground(Color.WHITE);
        telao.setFont(telao.getFont().deriveFont(Font.BOLD, 14f));
        telao.setPreferredSize(new Dimension(100, 28));
        telao.setVisible(false);   // só aparece depois de carregar o mapa

        JPanel areaMapa = new JPanel(new BorderLayout(0, 10));
        areaMapa.setBorder(BorderFactory.createEmptyBorder(8, 40, 8, 40));
        areaMapa.add(telao, BorderLayout.NORTH);
        areaMapa.add(mapa, BorderLayout.CENTER);
        add(new JScrollPane(areaMapa), BorderLayout.CENTER);

        JPanel linha1 = new JPanel(new FlowLayout(FlowLayout.LEFT));
        linha1.add(new JLabel("Canal:")); linha1.add(cbCanal);
        linha1.add(new JLabel("Tipo:")); linha1.add(cbTipo);

        JPanel linha2 = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JLabel lbAtendente = new JLabel("Cód. usuário/funcionário:");
        lbAtendente.setToolTipText("Usuário se o canal for ONLINE, funcionário se for PRESENCIAL");
        linha2.add(lbAtendente); linha2.add(tfAtendente);
        linha2.add(new JLabel("Cód. promoção:")); linha2.add(tfPromo);

        JPanel linha3 = new JPanel(new FlowLayout(FlowLayout.LEFT));
        linha3.add(new JLabel("Pagamento:")); linha3.add(tfPagto);
        JButton finalizar = new JButton("Finalizar venda");
        finalizar.addActionListener(e -> finalizar());
        linha3.add(finalizar);

        JPanel rodape = new JPanel(new GridLayout(3, 1));
        rodape.add(linha1);
        rodape.add(linha2);
        rodape.add(linha3);
        add(rodape, BorderLayout.SOUTH);

        atualizarSessoes();
    }

    private void atualizarSessoes() {
        try { Ui.preencher(tbSessoes, sessaoService.listar()); } catch (Exception e) { Ui.erro(this, e); }
    }

    private void carregarMapa() {
        int row = tbSessoes.getSelectedRow();
        if (row < 0) { JOptionPane.showMessageDialog(this, "Selecione uma sessão."); return; }
        try {
            sessaoAtual = (Integer) tbSessoes.getValueAt(row, 0);
            List<Poltrona> ps = vendaService.mapa(sessaoAtual);
            int colunas = ps.stream().mapToInt(Poltrona::numero).max().orElse(1);
            mapa.removeAll();
            telao.setVisible(true);          
            botoes.clear();
            mapa.setLayout(new GridLayout(0, colunas, 4, 4));
            for (Poltrona p : ps) {
                JToggleButton b = new JToggleButton("F" + p.fileira() + "-" + p.numero());
                if (p.ocupada()) { b.setEnabled(false); b.setBackground(Color.RED); }
                botoes.put(p.id(), b);
                mapa.add(b);
            }
            mapa.revalidate();
            mapa.repaint();
        } catch (Exception e) { Ui.erro(this, e); }
    }

    private void finalizar() {
        if (sessaoAtual < 0) { JOptionPane.showMessageDialog(this, "Carregue o mapa de uma sessão."); return; }
        try {
            List<Integer> escolhidas = new ArrayList<>();
            botoes.forEach((id, b) -> { if (b.isSelected()) escolhidas.add(id); });
            ResultadoVenda r = vendaService.vender((String) cbCanal.getSelectedItem(), tfAtendente.getText(),
                    tfPagto.getText(), sessaoAtual, escolhidas, (String) cbTipo.getSelectedItem(), tfPromo.getText());
            JOptionPane.showMessageDialog(this, "Venda concluída!\nCódigo: " + r.codConfirmacao()
                    + "\nTotal: R$ " + r.valorTotal() + "\nValores: " + r.valoresPagos() + "\nQR codes:\n" + String.join("\n", r.qrCodes()));
            recarregarMapaSessaoAtual();
            atualizarSessoes();   // status pode ter mudado para ESGOTADA (gatilho)
        } catch (Exception e) { Ui.erro(this, e); recarregarMapaSessaoAtual(); }
    }

    /** Recarrega o mapa usando sessaoAtual (sem depender da seleção da tabela). */
    private void recarregarMapaSessaoAtual() {
        if (sessaoAtual < 0) return;
        try {
            List<Poltrona> ps = vendaService.mapa(sessaoAtual);
            int colunas = ps.stream().mapToInt(Poltrona::numero).max().orElse(1);
            mapa.removeAll();
            telao.setVisible(true);
            botoes.clear();
            mapa.setLayout(new GridLayout(0, colunas, 4, 4));
            for (Poltrona p : ps) {
                JToggleButton b = new JToggleButton("F" + p.fileira() + "-" + p.numero());
                if (p.ocupada()) { b.setEnabled(false); b.setBackground(Color.RED); }
                botoes.put(p.id(), b);
                mapa.add(b);
            }
            mapa.revalidate();
            mapa.repaint();
        } catch (Exception ex) { Ui.erro(this, ex); }
    }
}
