package cinema.service;

import java.sql.SQLException;

/** Erro de regra de negócio com mensagem pronta para o usuário. */
public class NegocioException extends Exception {
    public NegocioException(String msg) { super(msg); }
    public NegocioException(String msg, Throwable causa) { super(msg, causa); }

    /** Extrai a mensagem do RAISE EXCEPTION dos gatilhos (primeira linha, sem o prefixo "ERROR:"). */
    public static NegocioException de(SQLException e) {
        if ("23505".equals(e.getSQLState())) return new NegocioException("Registro duplicado (ex.: poltrona já vendida nesta sessão).", e);
        if ("23503".equals(e.getSQLState())) return new NegocioException("Referência inexistente (verifique os códigos informados).", e);
        String m = e.getMessage() == null ? "Erro de banco de dados" : e.getMessage().split("\n")[0];
        if (m.startsWith("ERROR: ")) m = m.substring(7);
        return new NegocioException(m, e);
    }
}
