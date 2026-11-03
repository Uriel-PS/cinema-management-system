package cinema.service;

import cinema.dao.SessaoDAO;
import cinema.model.Modelo.Tabela;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

public class SessaoService {
    private final SessaoDAO dao = new SessaoDAO();

    public void cadastrar(String data, String hora, String formato, String idioma,
                          String valor, String idSala, String idFilme) throws NegocioException {
        try {
            dao.inserir(LocalDate.parse(data.trim()), LocalTime.parse(hora.trim()), formato, idioma,
                        new BigDecimal(valor.trim().replace(',', '.')),
                        Integer.parseInt(idSala.trim()), Integer.parseInt(idFilme.trim()));
        } catch (DateTimeParseException | NumberFormatException e) {
            throw new NegocioException("Dados inválidos. Use data AAAA-MM-DD, hora HH:MM e números nos demais campos.");
        } catch (SQLException e) { throw NegocioException.de(e); }
    }

    public Tabela listar() throws NegocioException {
        try { return dao.listar(); } catch (SQLException e) { throw NegocioException.de(e); }
    }
}
