package cinema.dao;

import cinema.model.Modelo.Filme;
import cinema.model.Modelo.Tabela;
import java.sql.*;

public class FilmeDAO {

    public void inserir(Filme f) throws SQLException {
        try (Connection c = ConexaoDB.obter()) {
            c.setAutoCommit(false);
            try {
                int id;
                try (PreparedStatement ps = c.prepareStatement(
                        "insert into filme(titulo_original, titulo_pt, duracao, ano_lancamento, classificacao, diretor, id_distribuidora) "
                      + "values (?,?,?,?,?,?,?) returning id_filme")) {
                    ps.setString(1, f.tituloOriginal());
                    ps.setString(2, f.tituloPt());
                    ps.setInt(3, f.duracao());
                    ps.setInt(4, f.ano());
                    ps.setString(5, f.classificacao());
                    ps.setString(6, f.diretor());
                    ps.setInt(7, f.idDistribuidora());
                    try (ResultSet rs = ps.executeQuery()) { rs.next(); id = rs.getInt(1); }
                }
                try (PreparedStatement ps = c.prepareStatement(
                        "insert into filme_genero select ?, id_genero from genero where nome = any(?)")) {
                    ps.setInt(1, id);
                    ps.setArray(2, c.createArrayOf("varchar", f.generos().toArray()));
                    ps.executeUpdate();
                }
                c.commit();
            } catch (SQLException e) { c.rollback(); throw e; }
        }
    }

    public Tabela listar() throws SQLException {
        return Consulta.executar(
            "select f.id_filme as \"Cód\", f.titulo_original as \"Título\", f.titulo_pt as \"Título PT\", "
          + "f.duracao as \"Min\", f.classificacao as \"Class.\", f.diretor as \"Diretor\", d.nome as \"Distribuidora\", "
          + "(select string_agg(g.nome, ', ') from filme_genero fg join genero g using (id_genero) "
          + " where fg.id_filme = f.id_filme) as \"Gêneros\" "
          + "from filme f join distribuidora d on d.id_distribuidora = f.id_distribuidora order by f.id_filme");
    }
}
