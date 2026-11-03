package cinema.service;

import cinema.dao.Consulta;
import cinema.model.Modelo.Tabela;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/** Chama as funções de relatório criadas na parte 3. */
public class RelatorioService {
    private static final String[] FUNCOES = {"faturamento_por_filme", "faturamento_por_sala", "faturamento_por_periodo"};

    public Tabela gerar(int tipo, String ini, String fim) throws NegocioException {
        try {
            LocalDate i = LocalDate.parse(ini.trim()), f = LocalDate.parse(fim.trim());
            if (f.isBefore(i)) throw new NegocioException("A data final não pode ser anterior à inicial.");
            return Consulta.executar("select * from " + FUNCOES[tipo] + "(?, ?)", i, f);
        } catch (DateTimeParseException e) {
            throw new NegocioException("Use datas no formato AAAA-MM-DD.");
        } catch (SQLException e) { throw NegocioException.de(e); }
    }
}
