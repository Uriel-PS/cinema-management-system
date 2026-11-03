package cinema.dao;

import cinema.model.Modelo.Tabela;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/** Executa um SELECT qualquer e devolve colunas + linhas. */
public final class Consulta {
    private Consulta() {}

    public static Tabela executar(String sql, Object... params) throws SQLException {
        try (Connection c = ConexaoDB.obter(); PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) ps.setObject(i + 1, params[i]);
            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData m = rs.getMetaData();
                int n = m.getColumnCount();
                String[] cols = new String[n];
                for (int i = 0; i < n; i++) cols[i] = m.getColumnLabel(i + 1);
                List<Object[]> linhas = new ArrayList<>();
                while (rs.next()) {
                    Object[] r = new Object[n];
                    for (int i = 0; i < n; i++) r[i] = rs.getObject(i + 1);
                    linhas.add(r);
                }
                return new Tabela(cols, linhas);
            }
        }
    }
}
