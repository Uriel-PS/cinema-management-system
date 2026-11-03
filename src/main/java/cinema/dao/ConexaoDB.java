package cinema.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class ConexaoDB {
    private ConexaoDB() {}

    /** Configurável por variáveis de ambiente DB_URL, DB_USER, DB_PASS. */
    public static Connection obter() throws SQLException {
        var env = System.getenv();
        return DriverManager.getConnection(
            env.getOrDefault("DB_URL", "jdbc:postgresql://localhost:5432/cinema"),
            env.getOrDefault("DB_USER", "postgres"),
            env.getOrDefault("DB_PASS", "udesc"));
    }
}
