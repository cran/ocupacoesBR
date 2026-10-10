# ---------------------------------------------------------------------------
# a história do cadastro de ocupações do TSE
# ---------------------------------------------------------------------------
# Um dicionário diz o que um código significa. Estas funções dizem o que ele
# significava EM CADA ELEIÇÃO — que é outra coisa, e é o que falta a quem monta
# série longa.

#' Rótulo da ocupação, como o TSE o escreveu
#'
#' @param cod Vetor de códigos de ocupação do TSE.
#' @param ano Vetor opcional de anos de eleição, do mesmo comprimento de `cod`.
#'   Com ele, devolve o rótulo vigente naquele ano; sem ele, o mais recente.
#' @return Vetor de texto com o rotulo da ocupacao tal como o TSE o escreveu naquele ano (ou o mais recente, se `ano` for omitido). Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem entrada no cadastro de rotulos.
#' @examples
#' tse_para_rotulo(c(215, 215), c(2000, 2020))
#' tse_para_rotulo(c(111, 169, 257))
#' @export
tse_para_rotulo <- function(cod, ano = NULL) {
  k <- .norm_tse(cod)
  r <- ocupacoesBR::tse_ocupacao_rotulos
  if (is.null(ano)) {
    ult <- r[!duplicated(r$cod_tse, fromLast = TRUE), ]
    return(ult$rotulo[match(k, ult$cod_tse)])
  }
  if (length(ano) != length(k))
    stop("`ano` deve ter o mesmo comprimento de `cod`.", call. = FALSE)
  ano <- suppressWarnings(as.integer(ano))
  i <- match(paste(k, ano), unlist(lapply(seq_len(nrow(r)), function(j)
    paste(r$cod_tse[j], r$de[j]:r$ate[j]))))
  cum <- rep(seq_len(nrow(r)), r$ate - r$de + 1L)
  r$rotulo[cum[i]]
}

#' Em que eleições cada código esteve em vigor, e com que nome
#'
#' Uma linha por **vigência**: um código que nunca mudou de nome tem uma; um que
#' mudou tem uma por período.
#'
#' @param cod Vetor opcional de códigos. Se omitido, devolve a tabela inteira.
#' @return `data.frame` com `cod_tse`, `de`, `ate`, `rotulo` e `n`.
#' @examples
#' tse_vigencia(215)
#' @export
tse_vigencia <- function(cod = NULL) {
  r <- ocupacoesBR::tse_ocupacao_rotulos
  if (is.null(cod)) return(r)
  k <- .norm_tse(cod)
  out <- r[r$cod_tse %in% k, ]
  .avisa_ausentes(unique(k), match(unique(k), r$cod_tse),
                  "tse_ocupacao_rotulos")
  rownames(out) <- NULL
  out
}

#' O que mudou no cadastro entre duas eleições
#'
#' Devolve os códigos **extintos**, os **criados** e os que **trocaram de
#' rótulo** entre dois anos. É a função que falta a quem monta série longa: a
#' reutilização de código é o problema mais citado, mas o mais frequente é a
#' troca de inventário. Entre 2000 e 2002 o TSE aposentou 21 códigos, criou 69 e
#' renomeou 36.
#'
#' @section O que conta como "em vigor":
#' A comparação usa a **vigência** registrada em [tse_ocupacao_rotulos], não a
#' presença de candidaturas naquela eleição específica. Um código que existe no
#' cadastro mas não teve candidato num ano continua em vigor — o contrário
#' faria uma ocupação rara "sumir e voltar" a cada eleição.
#'
#' Por isso os números diferem de uma contagem por período. Comparando *qualquer
#' ano até 2000* com *qualquer ano a partir de 2002*, são 13 códigos extintos
#' (12,4% das candidaturas do período antigo) e 122 criados (33,2% do novo).
#' Comparando as eleições de 2000 e 2002 uma com a outra, são 21 e 69. As duas
#' leituras estão certas e respondem a perguntas diferentes.
#'
#' @section Ausência não é revogação, e 2026 mostra isso:
#' `tse_diff_cadastro(2024, 2026)` devolve 46 códigos como **extintos** e
#' nenhum criado. Os 46 não foram extintos. A vigência desta tabela se
#' constrói do rótulo **observado**, de modo que um código sem nenhum
#' candidato numa eleição registra ausência — e ausência é o que se espera de
#' um código raro quando a safra é pequena. A de 2026 é pequena duas vezes:
#' é geral, sem prefeito nem vereador, e está **aberta**, com o Tribunal ainda
#' julgando registros. Trocar de par não resolve: `tse_diff_cadastro(2022, 2026)`,
#' que compara duas gerais, devolve 47 extintos, e não menos.
#'
#' A metade que se sustenta é a outra: **nenhum código criado**, nos dois
#' pares. Essa é robusta ao tamanho da safra, porque um código novo apareceria
#' ainda que uma vez só. Leia a contagem de extintos de uma safra aberta como
#' o que ela é — quem ainda não apareceu —, e refaça a comparação quando o
#' cadastro de 2026 fechar.
#'
#' @param ano1,ano2 Anos de eleição a comparar.
#' @return `data.frame` com `cod_tse`, `mudanca` (`extinto`, `criado` ou
#'   `rotulo`), e os rótulos dos dois anos.
#' @examples
#' d <- tse_diff_cadastro(2000, 2002)
#' table(d$mudanca)
#' @export
tse_diff_cadastro <- function(ano1, ano2) {
  r <- ocupacoesBR::tse_ocupacao_rotulos
  ano1 <- as.integer(ano1)[1]; ano2 <- as.integer(ano2)[1]
  em <- function(a) {
    i <- r$de <= a & r$ate >= a
    stats::setNames(r$rotulo[i], r$cod_tse[i])
  }
  a <- em(ano1); b <- em(ano2)
  if (!length(a) || !length(b))
    stop("sem cadastro registrado para ", if (!length(a)) ano1 else ano2,
         " \u2014 os anos cobertos v\u00e3o de ", min(r$de), " a ", max(r$ate),
         ".", call. = FALSE)
  ext <- setdiff(names(a), names(b))
  cri <- setdiff(names(b), names(a))
  com <- intersect(names(a), names(b))
  rot <- com[a[com] != b[com]]
  out <- data.frame(
    cod_tse = c(ext, cri, rot),
    mudanca = rep(c("extinto", "criado", "rotulo"),
                  c(length(ext), length(cri), length(rot))),
    rotulo_ano1 = c(a[ext], rep(NA_character_, length(cri)), a[rot]),
    rotulo_ano2 = c(rep(NA_character_, length(ext)), b[cri], b[rot]),
    stringsAsFactors = FALSE)
  rownames(out) <- NULL
  out[order(out$mudanca, out$cod_tse), ]
}

#' Encontra o código a partir do rótulo da ocupação
#'
#' Serve a quem recebe a ocupação como texto e não como código — o caso de quem
#' baixa `br_tse_eleicoes.candidatos` no `basedosdados`. A busca ignora caixa,
#' acento e pontuação.
#'
#' @param rotulo Vetor de rótulos de ocupação.
#' @param exato Se `TRUE` (padrão), só casa o rótulo inteiro; se `FALSE`, casa
#'   por conteúdo e pode devolver mais de um código por rótulo.
#' @return `data.frame` com `rotulo` (o que se procurou), `cod_tse` e o rótulo
#'   canônico encontrado. Sempre um `data.frame`, com zero linhas quando não há
#'   o que procurar — o tipo do retorno não depende do conteúdo do argumento.
#' @examples
#' tse_rotulo_para_cod("Agricultor")
#' tse_rotulo_para_cod("advogado", exato = FALSE)
#' @export
tse_rotulo_para_cod <- function(rotulo, exato = TRUE) {
  .checa_vetor(rotulo, "rotulo")
  r <- ocupacoesBR::tse_ocupacao_rotulos
  chave <- .norm_rotulo(as.character(rotulo))
  alvo  <- .norm_rotulo(r$rotulo)
  if (exato) {
    i <- match(chave, alvo)
    out <- data.frame(rotulo = as.character(rotulo), cod_tse = r$cod_tse[i],
                      rotulo_tse = r$rotulo[i], stringsAsFactors = FALSE)
  } else {
    out <- do.call(rbind, lapply(seq_along(chave), function(j) {
      if (is.na(chave[j])) return(NULL)
      i <- grep(chave[j], alvo, fixed = TRUE)
      if (!length(i)) i <- NA_integer_
      data.frame(rotulo = as.character(rotulo)[j], cod_tse = r$cod_tse[i],
                 rotulo_tse = r$rotulo[i], stringsAsFactors = FALSE)
    }))
    # `do.call(rbind, ...)` devolve NULL quando nada entra na lista — vetor
    # vazio, ou todo NA. Sem esta linha o tipo de retorno da funcao dependeria
    # do conteudo do argumento: `data.frame` quase sempre, `NULL` nesses dois
    # casos, de modo que `nrow()` devolveria NULL em vez de 0 e o acesso a
    # coluna erraria. O ramo `exato = TRUE` nunca teve esse problema, porque
    # `match()` preserva o comprimento.
    if (is.null(out))
      out <- data.frame(rotulo = character(0), cod_tse = character(0),
                        rotulo_tse = character(0), stringsAsFactors = FALSE)
  }
  out <- out[!duplicated(out[, c("rotulo", "cod_tse")]), ]
  rownames(out) <- NULL
  out
}

#' Normaliza rótulo para comparação
#' @noRd
.norm_rotulo <- function(x) {
  x <- toupper(iconv(x, to = "ASCII//TRANSLIT"))
  x <- gsub("[^A-Z0-9 ]", " ", x)
  trimws(gsub("\\s+", " ", x))
}

#' Posições cujo ano cai fora da vigência que o dicionário descreve
#'
#' O dicionário do pacote adota o cadastro pós-2002. Para um código que o TSE
#' **reutilizou**, uma candidatura anterior à reutilização está sob outra
#' ocupação, e traduzi-la pelo dicionário é erro — não aproximação.
#' @noRd
.fora_de_vigencia <- function(k, ano) {
  if (is.null(ano)) return(rep(FALSE, length(k)))
  if (length(ano) != length(k))
    stop("`ano` deve ter o mesmo comprimento de `cod`.", call. = FALSE)
  ano <- suppressWarnings(as.integer(ano))
  q <- ocupacoesBR::tse_quebra_2002
  q <- q[q$tipo == "reutilizado", ]
  i <- match(k, q$cod_tse)
  !is.na(k) & !is.na(ano) & !is.na(i) & ano < q$primeiro_ano_novo[i]
}

#' Anula as posicoes fora de vigencia e avisa uma vez
#' @noRd
.aplica_vigencia <- function(out, k, ano) {
  fora <- .fora_de_vigencia(k, ano)
  if (any(fora)) {
    cods <- sort(unique(k[fora]))
    .aviso(sprintf(paste0("%d candidatura(s) usam c\u00f3digo(s) que o TSE ",
                          "REUTILIZOU depois (%s): naquele ano designavam outra ",
                          "ocupa\u00e7\u00e3o, e voltam NA.\nVeja ?tse_vigencia."),
                   sum(fora), paste(cods, collapse = ", ")),
           "fora_de_vigencia")
    out[fora] <- NA
  }
  out
}
