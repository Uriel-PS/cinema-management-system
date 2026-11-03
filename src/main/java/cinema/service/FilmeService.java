package cinema.service;

import cinema.dao.FilmeDAO;
import cinema.model.Modelo.Filme;
import cinema.model.Modelo.Tabela;
import java.sql.SQLException;

public class FilmeService {
    private final FilmeDAO dao = new FilmeDAO();

    public void cadastrar(Filme f) throws NegocioException {
        if (f.tituloOriginal() == null || f.tituloOriginal().isBlank()) throw new NegocioException("Informe o título original.");
        if (f.duracao() <= 0) throw new NegocioException("A duração deve ser maior que zero.");
        if (f.generos().isEmpty()) throw new NegocioException("Selecione ao menos um gênero.");
        try { dao.inserir(f); } catch (SQLException e) { throw NegocioException.de(e); }
    }

    public Tabela listar() throws NegocioException {
        try { return dao.listar(); } catch (SQLException e) { throw NegocioException.de(e); }
    }
}
