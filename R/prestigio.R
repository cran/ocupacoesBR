# ---------------------------------------------------------------------------
# C4 — prestigio ocupacional: o nome que a sigla SIOPS ocupa no Brasil
# ---------------------------------------------------------------------------
# No Brasil, SIOPS e o Sistema de Informacoes sobre Orcamentos Publicos em
# Saude (Ministerio da Saude, LC 141/2012). Um pacote em portugues que exporta
# `tse_para_siops()` colide em toda busca, e a intersecao de publicos — saude,
# orcamento, dados administrativos — nao e pequena. Ganzeboom pode usar a sigla;
# um pacote brasileiro nao deveria, sem mais.
#
# As funcoes `*_siops()` continuam existindo e continuam corretas: sao alias
# depreciados, nunca removidos de uma vez.

#' Prestigio ocupacional de Treiman
#'
#' Devolve o escore da Standard International Occupational Prestige Scale, de
#' Donald Treiman. E uma regua de PRESTIGIO — o quanto uma ocupacao e
#' socialmente estimada —, distinta do ISEI, que mede posicao socioeconomica.
#'
#' @section Quando o pressuposto quebra:
#' A escala e a media de estudos de prestigio de cerca de 60 paises levantados
#' nos anos 1960 e 1970. Aplica-la a dado recente pressupoe que a ordem de
#' prestigio e invariante no tempo e no espaco — que e a tese estrutural de
#' Treiman (1977), e nao um fato dado. Ela quebra onde a ocupacao mudou de
#' posicao desde entao: bancario, professor, policial, ocupacoes de tecnologia.
#'
#' @section Sobre o nome:
#' Estas funcoes substituem `tse_para_siops()` e companhia. No Brasil a sigla
#' SIOPS designa o Sistema de Informacoes sobre Orcamentos Publicos em Saude, e
#' a colisao e certa num pacote em portugues. As formas antigas seguem
#' funcionando como alias depreciados.
#'
#' @inheritParams tse_para_isco
#' @return Vetor numerico com o escore SIOPS (Standard International Occupational Prestige Scale) de Treiman, na escala de 0 a 100 do ISMF: quanto maior, mais prestigiada a ocupacao na media dos estudos originais. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela.
#' @references Treiman, D. J. (1977). *Occupational Prestige in Comparative
#'   Perspective*. New York: Academic Press.
#' @examples
#' tse_para_prestigio(c(111, 169, 257))
#' @export
tse_para_prestigio <- function(cod, ano = NULL) {
  .busca(tse_para_isco(cod, ano), ocupacoesBR::isco88_medidas, "isco88",
         "siops88")
}

#' Prestigio de Treiman ancorado na ISCO-08, a partir do TSE
#'
#' @section O argumento `ano`, e por que ele chegou tarde aqui:
#' A versao 0.2.0 acrescentou `ano` as portas ancoradas na ISCO-08 e nomeou
#' tres delas: `tse_para_isco08()`, `tse_para_isei08()` e `tse_para_siops08()`.
#' Esta ficou de fora por descuido, de modo que o nome PREFERIDO da medida de
#' prestigio nao mascarava vigencia enquanto o seu proprio alias depreciado
#' mascarava. Quem montasse serie pela porta recomendada recebia, calado, o
#' escore do cadastro errado nos codigos reutilizados em 2002. Corrigido em
#' 0.3.0; a assinatura agora e a mesma de `tse_para_siops08()`.
#'
#' @inheritParams tse_para_isco
#' @return Vetor numerico com o escore SIOPS (Standard International Occupational Prestige Scale) de Treiman, na escala de 0 a 100 do ISMF: quanto maior, mais prestigiada a ocupacao na media dos estudos originais. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela.
#' @examples
#' tse_para_prestigio08(c(111, 169))
#' tse_para_prestigio08("215", ano = 2000)   # reutilizado: NA com aviso
#' @export
tse_para_prestigio08 <- function(cod, ano = NULL) {
  .busca(tse_para_isco08(cod, ano = ano), ocupacoesBR::isco08_medidas,
         "isco08", "siops08")
}

#' Prestigio de Treiman a partir do ISCO-88
#' @inheritParams isco88_para_isei
#' @return Vetor numerico com o escore SIOPS (Standard International Occupational Prestige Scale) de Treiman, na escala de 0 a 100 do ISMF: quanto maior, mais prestigiada a ocupacao na media dos estudos originais. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela.
#' @examples
#' isco88_para_prestigio("2221")
#' @export
isco88_para_prestigio <- function(isco88) isco88_para_siops(isco88)

#' Prestigio de Treiman a partir da CBO-2002
#' @inheritParams cbo2002_para_isco
#' @return Vetor numerico com o escore SIOPS (Standard International Occupational Prestige Scale) de Treiman, na escala de 0 a 100 do ISMF: quanto maior, mais prestigiada a ocupacao na media dos estudos originais. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela.
#' @examples
#' cbo2002_para_prestigio("225120")
#' @export
cbo2002_para_prestigio <- function(cbo, empate = c("na", "moda"),
                                   escada = FALSE) {
  .busca(cbo2002_para_isco(cbo, empate, escada), ocupacoesBR::isco88_medidas,
         "isco88", "siops88")
}

#' Prestigio de Treiman a partir da CBO-94
#' @inheritParams cbo94_para_isco
#' @return Vetor numerico com o escore SIOPS (Standard International
#'   Occupational Prestige Scale) de Treiman, na escala de 0 a 100 do ISMF:
#'   quanto maior, mais prestigiada a ocupacao na media dos estudos
#'   originais. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o
#'   codigo nao tem correspondencia na tabela.
#' @examples
#' cbo94_para_prestigio("2-11.20")
#' @export
cbo94_para_prestigio <- function(cbo94) cbo94_para_siops(cbo94)

#' Prestigio de Treiman ancorado na ISCO-08, a partir da CBO-2002
#'
#' A CBO-2002 aterrissa na ISCO-88, de modo que este escore atravessa a ponte
#' 88 -> 08 e herda a perda dela: onde a OIT define mais de um destino, usa-se o
#' codigo truncado. Veja [isco88_para_isco08()].
#'
#' @inheritParams cbo2002_para_isco
#' @return Vetor numerico com o escore SIOPS (Standard International Occupational Prestige Scale) de Treiman, na escala de 0 a 100 do ISMF: quanto maior, mais prestigiada a ocupacao na media dos estudos originais. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela.
#' @examples
#' cbo2002_para_prestigio08("225120")
#' @export
cbo2002_para_prestigio08 <- function(cbo, empate = c("na", "moda"),
                                     escada = FALSE) {
  cbo2002_para_siops08(cbo, empate, escada)
}
