package cinema.service;

import cinema.dao.VendaDAO;
import cinema.model.Modelo.Poltrona;
import cinema.model.Modelo.ResultadoVenda;
import java.sql.SQLException;
import java.util.List;

public class VendaService {
    private final VendaDAO dao = new VendaDAO();

    public List<Poltrona> mapa(int idSessao) throws NegocioException {
        try { return dao.mapaPoltronas(idSessao); } catch (SQLException e) { throw NegocioException.de(e); }
    }

    public ResultadoVenda vender(String canal, String atendente, String pagamento, int idSessao,
                                 List<Integer> poltronas, String tipoIngresso, String promocao) throws NegocioException {
        if (poltronas.isEmpty()) throw new NegocioException("Selecione ao menos uma poltrona.");
        try {
            int idAtendente = Integer.parseInt(atendente.trim());
            Integer idPromo = (promocao == null || promocao.isBlank()) ? null : Integer.parseInt(promocao.trim());
            return dao.vender(canal, idAtendente, pagamento, idSessao, poltronas, tipoIngresso, idPromo);
        } catch (NumberFormatException e) {
            throw new NegocioException("Informe o código numérico do " + ("ONLINE".equals(canal) ? "usuário" : "funcionário") + " (e da promoção, se houver).");
        } catch (SQLException e) { throw NegocioException.de(e); }
    }
}
