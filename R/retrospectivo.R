# ---------------------------------------------------------------------------
# carregamento retrospectivo: a ocupação anterior da própria pessoa
# ---------------------------------------------------------------------------

#' Carrega o último escore conhecido da própria pessoa
#'
#' Registros administrativos repetidos — candidaturas do TSE, vínculos da RAIS,
#' prontuários — trazem a mesma pessoa várias vezes, e às vezes sem ocupação
#' classificável. Esta função preenche a lacuna com o **último escore observado
#' da própria pessoa**, e devolve junto a marca de herança e a defasagem, para
#' que a qualidade do preenchimento seja auditável em vez de invisível.
#'
#' @section Por que isto não é imputação estatística:
#' Nada é modelado nem estimado. Usa-se apenas a **história ocupacional da
#' própria pessoa**, jamais patrimônio, partido, escolaridade ou qualquer
#' covariável — de modo que o escore resultante continua independente das
#' variáveis com que se vai cruzá-lo. Uma imputação por covariável criaria
#' colinearidade por desenho; esta não cria.
#'
#' @section As três regras:
#' \describe{
#'   \item{só o passado}{usar aparições futuras descreveria a posição no momento
#'     do registro por uma ocupação que a pessoa ainda não tinha.}
#'   \item{`excluir` fica de fora}{há posições em que a recuperação pelo passado
#'     é mínima e o apelo estaria justamente no futuro que a primeira regra
#'     proíbe — estudante e estagiário são o caso típico.}
#'   \item{a herança é declarada}{`herdado` e `defasagem` saem no resultado. Um
#'     escore herdado de doze anos atrás não vale o mesmo que um de quatro, e
#'     quem analisa precisa poder condicionar ou excluir.}
#' }
#'
#' @section O que ele erra, medido:
#' O carregamento supõe que a ocupação da pessoa não mudou. Ela muda com
#' frequência. Entre os **684.179** pares de candidaturas consecutivas da mesma
#' pessoa em que o ISEI foi **observado nas duas pontas** — isto é, onde dá para
#' conferir:
#'
#' \describe{
#'   \item{52,2%}{mudam de código de ocupação.}
#'   \item{45,2%}{mudam de escore ISEI.}
#'   \item{18,9 pontos}{é a diferença absoluta média **quando** muda.}
#' }
#'
#' Ou seja: mesmo com defasagem zero, o escore herdado estaria errado em cerca
#' de 45% dos casos, e por uma margem grande. E a defasagem raramente é zero —
#' dos escores herdados, a mediana é de **4 anos**, **34,6%** vêm de 8 anos ou
#' mais, e o máximo observado é 26.
#'
#' Pior que o tamanho é a **direção**: o erro aponta sempre para o passado. Para
#' quem ascendeu — a trajetória típica de profissionalização política — o
#' carregamento puxa a posição para baixo. O viés não é ruído que se cancela na
#' média; ele é sistemático e corre contra justamente a quantidade que estudos
#' de recrutamento e oferta eleitoral querem medir.
#'
#' Por isso `herdado` e `defasagem` saem no resultado, e não como cortesia:
#' **relate quantos escores são herdados, e rode a sua análise também só com os
#' observados.** Se a conclusão depender dos herdados, ela depende de uma
#' suposição que este parágrafo mostra ser falsa em quase metade dos casos.
#'
#' @section O que ele resolve, medido:
#' Nas candidaturas ao TSE de 1998 a 2024, a cobertura do ISEI sobe de 68,5%
#' para 76,0% entre homens e de **52,9% para 58,8% entre mulheres**. A janela
#' para aqui de propósito, e não por desatualização: a medição exige o painel
#' por pessoa, que identifica a mesma candidatura em eleições diferentes, e a
#' safra de 2026 ainda não tem esse painel montado. O restante do pacote vai a
#' 2026; este número, não. O ganho é
#' maior entre elas porque o padrão de ausência é fortemente generificado: 14,7%
#' das candidatas declaram posição fora da PEA, contra 1,3% dos candidatos.
#'
#' @param escore Vetor numérico com a medida a carregar (ISEI, prestígio, o que
#'   for), com `NA` onde não há observação.
#' @param id Vetor identificador da pessoa, do mesmo comprimento.
#' @param tempo Vetor numérico ordenável — ano da eleição, data do vínculo.
#' @param cod Vetor opcional de códigos de ocupação, usado só por `excluir`.
#' @param excluir Códigos que **não** recebem carregamento. O padrão `NULL` não
#'   exclui nada; no dado do TSE, `"931"` (estudante e estagiário) é a escolha
#'   defensável.
#' @return `data.frame` com `escore` (o valor final), `herdado` (lógico) e
#'   `defasagem` (quantas unidades de `tempo` desde a observação de origem).
#' @examples
#' d <- data.frame(
#'   pessoa = c("A", "A", "A", "B", "B"),
#'   ano    = c(2012, 2016, 2020, 2016, 2020),
#'   isei   = c(70, NA, NA, NA, 45))
#' isei_retrospectivo(d$isei, d$pessoa, d$ano)
#' @export
isei_retrospectivo <- function(escore, id, tempo, cod = NULL, excluir = NULL) {
  .checa_vetor(escore, "escore")
  n <- length(escore)
  if (length(id) != n || length(tempo) != n)
    stop("`escore`, `id` e `tempo` devem ter o mesmo comprimento.",
         call. = FALSE)
  if (!is.null(cod) && length(cod) != n)
    stop("`cod` deve ter o mesmo comprimento de `escore`.", call. = FALSE)
  escore <- as.numeric(escore)
  tempo  <- as.numeric(tempo)

  o  <- order(id, tempo)
  v  <- escore[o]; g <- id[o]; t <- tempo[o]
  ok <- !is.na(v)

  # LOCF vetorizado, com corte na fronteira do grupo: `ult` aponta para a
  # última observação não-NA, e `ini` para o começo do grupo. Onde a última
  # observação vem de OUTRA pessoa, não há herança.
  ult <- cummax(ifelse(ok, seq_len(n), 0L))
  ini <- cummax(ifelse(c(TRUE, g[-1] != g[-n]), seq_len(n), 0L))
  ult[ult < ini] <- NA_integer_

  herda <- is.na(v) & !is.na(ult)
  if (!is.null(excluir)) herda <- herda & !(as.character(cod)[o] %in% excluir)

  final <- v
  final[herda] <- v[ult[herda]]
  defas <- rep(NA_real_, n)
  defas[herda] <- t[herda] - t[ult[herda]]

  out <- data.frame(escore = final, herdado = herda, defasagem = defas)
  out[order(o), ]                                  # devolve na ordem original
}
