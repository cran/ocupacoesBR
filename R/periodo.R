# ---------------------------------------------------------------------------
# a quebra de cadastro do TSE em 2002
# ---------------------------------------------------------------------------

#' Verifica se o seu dado é atingido pela quebra de cadastro do TSE em 2002
#'
#' O dicionário deste pacote adota o cadastro de ocupações vigente a partir de
#' 2002. Entre 2000 e 2002 o TSE reeditou essa tabela e **reutilizou códigos**
#' para ocupações diferentes, de modo que aplicar o dicionário a candidaturas de
#' 1998 e 2000 classifica essas ocupações erradas. Esta função diz se, e quanto,
#' o seu dado é atingido.
#'
#' @section Como os casos foram identificados:
#' Não pelo rótulo, e sim pelo dado. Os rótulos existem e o pacote os
#' distribui ([tse_ocupacao_rotulos], [tse_para_rotulo()]), mas um rótulo novo
#' tanto pode ser a mesma ocupação rebatizada quanto outra ocupação no mesmo
#' código, e sozinho não distingue as duas coisas.
#' Para cada código presente nos dois períodos, comparou-se a proporção de
#' candidatos com ensino superior completo. A escolaridade sobe ao longo de todo
#' o período, então altas de 20 a 27 pontos são a tendência geral. Uma queda de
#' 60 a 85 pontos, não: a população sob o código passou a ser outra. Ver
#' [tse_quebra_2002].
#'
#' @section O que fazer:
#' Para análises restritas a 2002 ou depois, nada — a quebra não a atinge. Para
#' séries que cruzam 2000/2002, o mínimo é excluir os códigos afetados do
#' período antigo; o correto é obter os rótulos de ocupação do TSE de cada
#' eleição e construir um dicionário com chave `(código, ano)`.
#'
#' @param cod Vetor de códigos de ocupação do TSE.
#' @param ano Vetor de anos de eleição, do mesmo comprimento de `cod`.
#' @param avisar Se `TRUE` (padrão), emite aviso quando há casos atingidos.
#' @return Invisivelmente, um vetor lógico marcando as posições atingidas
#'   (código reutilizado **e** ano até 2000).
#' @examples
#' checa_periodo(c("211", "211", "111"), c(2000, 2012, 2000))
#' @export
checa_periodo <- function(cod, ano, avisar = TRUE) {
  k <- .norm_tse(cod)
  if (length(ano) != length(k))
    stop("`ano` deve ter o mesmo comprimento de `cod`.", call. = FALSE)
  ano <- suppressWarnings(as.integer(ano))
  # So `reutilizado` e erro. `renomeado` e a MESMA ocupacao com nome novo
  # (601 "TRABALHADOR AGRICOLA" -> "AGRICULTOR"), e marcá-lo aqui mandaria
  # descartar 52.090 candidaturas validas. Ver ?tse_quebra_2002.
  q <- ocupacoesBR::tse_quebra_2002
  q <- q[q$tipo == "reutilizado", ]
  i <- match(k, q$cod_tse)
  atingido <- !is.na(k) & !is.na(ano) & !is.na(i) & ano < q$primeiro_ano_novo[i]
  if (avisar && any(atingido)) {
    cods <- sort(unique(k[atingido]))
    .aviso(sprintf(paste0("%d candidatura(s) at\u00e9 2000 usam c\u00f3digo(s) que o ",
                          "TSE reutilizou em 2002 (%s). Elas est\u00e3o ",
                          "classificadas pelo cadastro NOVO e portanto ",
                          "erradas; veja ?checa_periodo."),
                   sum(atingido), paste(cods, collapse = ", ")),
           "quebra_2002")
  }
  invisible(atingido)
}
