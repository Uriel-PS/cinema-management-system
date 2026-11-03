package cinema.dao;

import cinema.model.Modelo.Poltrona;
import cinema.model.Modelo.ResultadoVenda;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VendaDAO {

    public List<Poltrona> mapaPoltronas(int idSessao) throws SQLException {
        String sql = "select p.id_poltrona, p.num_fileira, p.num_poltrona, "
                   + "exists (select 1 from ingresso i where i.id_sessao = s.id_sessao and i.id_poltrona = p.id_poltrona) "
                   + "from sessao s join poltrona p on p.id_sala = s.id_sala "
                   + "where s.id_sessao = ? order by p.num_fileira, p.num_poltrona";
        List<Poltrona> lista = new ArrayList<>();
        try (Connection c = ConexaoDB.obter(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, idSessao);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(new Poltrona(rs.getInt(1), rs.getInt(2), rs.getInt(3), rs.getBoolean(4)));
            }
        }
        return lista;
    }

    /**
     * Cria a venda e todos os ingressos na MESMA transação.
     * valor_pago, qr_code, cod_confirmacao e valor_total são gerados pelos gatilhos;
     * aqui só lemos de volta com RETURNING / SELECT.
     */
    public ResultadoVenda vender(String canal, int idAtendente, String tipoPagamento, int idSessao,
                                 List<Integer> poltronas, String tipoIngresso, Integer idPromocao) throws SQLException {
        boolean online = "ONLINE".equals(canal);
        try (Connection c = ConexaoDB.obter()) {
            c.setAutoCommit(false);
            try {
                int idVenda;
                try (PreparedStatement ps = c.prepareStatement(
                        "insert into venda(canal_venda, tipo_pagamento, id_usuario, id_funcionario) values (?,?,?,?) returning id_venda")) {
                    ps.setString(1, canal);
                    ps.setString(2, tipoPagamento);
                    if (online) { ps.setInt(3, idAtendente); ps.setNull(4, Types.INTEGER); }
                    else        { ps.setNull(3, Types.INTEGER); ps.setInt(4, idAtendente); }
                    try (ResultSet rs = ps.executeQuery()) { rs.next(); idVenda = rs.getInt(1); }
                }
                List<BigDecimal> valores = new ArrayList<>();
                List<String> qrs = new ArrayList<>();
                for (int idPoltrona : poltronas) {
                    try (PreparedStatement ps = c.prepareStatement(
                            "insert into ingresso(tipo_ingresso, id_sessao, id_venda, id_poltrona, id_promocao) "
                          + "values (?,?,?,?,?) returning valor_pago, qr_code")) {
                        ps.setString(1, tipoIngresso);
                        ps.setInt(2, idSessao);
                        ps.setInt(3, idVenda);
                        ps.setInt(4, idPoltrona);
                        if (idPromocao == null) ps.setNull(5, Types.INTEGER); else ps.setInt(5, idPromocao);
                        try (ResultSet rs = ps.executeQuery()) {
                            rs.next();
                            valores.add(rs.getBigDecimal(1));
                            qrs.add(rs.getString(2));
                        }
                    }
                }
                String cod; BigDecimal total;
                try (PreparedStatement ps = c.prepareStatement("select cod_confirmacao, valor_total from venda where id_venda = ?")) {
                    ps.setInt(1, idVenda);
                    try (ResultSet rs = ps.executeQuery()) { rs.next(); cod = rs.getString(1); total = rs.getBigDecimal(2); }
                }
                c.commit();
                return new ResultadoVenda(cod, total, valores, qrs);
            } catch (SQLException e) { c.rollback(); throw e; }
        }
    }
}
