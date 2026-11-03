package cinema.dao;

import cinema.model.Modelo.Tabela;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;

public class SessaoDAO {

    /** Os gatilhos validam conflito de horário e 3D em sala 2D. */
    public void inserir(LocalDate data, LocalTime inicio, String formato, String idioma,
                        BigDecimal valorBase, int idSala, int idFilme) throws SQLException {
        try (Connection c = ConexaoDB.obter(); PreparedStatement ps = c.prepareStatement(
                "insert into sessao(data, horario_inicio, formato_projecao, idioma, status, valor_base, id_sala, id_filme) "
              + "values (?,?,?,?,'DISPONIVEL',?,?,?)")) {
            ps.setObject(1, data);
            ps.setObject(2, inicio);
            ps.setString(3, formato);
            ps.setString(4, idioma);
            ps.setBigDecimal(5, valorBase);
            ps.setInt(6, idSala);
            ps.setInt(7, idFilme);
            ps.executeUpdate();
        }
    }

    public Tabela listar() throws SQLException {
        return Consulta.executar(
            "select s.id_sessao as \"Cód\", f.titulo_original as \"Filme\", s.id_sala as \"Sala\", s.data as \"Data\", "
          + "s.horario_inicio as \"Início\", "
          + "to_char(horario_termino(s.data, s.id_filme, s.horario_inicio), 'HH24:MI') as \"Término\", "
          + "s.idioma as \"Idioma\", s.formato_projecao as \"Formato\", s.valor_base as \"Valor\", s.status as \"Status\" "
          + "from sessao s join filme f on f.id_filme = s.id_filme order by s.data, s.horario_inicio");
    }
}
