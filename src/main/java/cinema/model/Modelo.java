package cinema.model;

import java.math.BigDecimal;
import java.util.List;

/** Classes de entidade/transferência (camada de modelo). */
public final class Modelo {
    private Modelo() {}

    public record Filme(String tituloOriginal, String tituloPt, int duracao, int ano,
                        String classificacao, String diretor, int idDistribuidora, List<String> generos) {}

    public record Poltrona(int id, int fileira, int numero, boolean ocupada) {}

    /** Resultado de uma venda: tudo isto foi calculado/gerado pelos gatilhos do banco. */
    public record ResultadoVenda(String codConfirmacao, BigDecimal valorTotal,
                                 List<BigDecimal> valoresPagos, List<String> qrCodes) {}

    /** Resultado genérico de consulta, usado pelas telas de listagem e relatórios. */
    public record Tabela(String[] colunas, List<Object[]> linhas) {}
}
