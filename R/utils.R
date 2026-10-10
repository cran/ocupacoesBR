# ---------------------------------------------------------------------------
# utilitários internos: normalização de códigos e busca vetorizada
# ---------------------------------------------------------------------------
# Os três normalizadores trabalham sobre `unique()` e reexpandem por `match`:
# um vetor de milhões de candidaturas tem algumas centenas de códigos distintos,
# e normalizar cada elemento é desperdício puro.

#' Aplica `f` só aos valores distintos e reexpande
#' @noRd
.por_unico <- function(x, f) {
  u <- unique(x)
  f(u)[match(x, u)]
}

#' Emite um aviso COM CLASSE
#'
#' Todos os avisos do pacote eram `simpleWarning`. Duas consequencias reais:
#' quem processa 27 UFs num laco e quer calar o aviso rotineiro de codigo
#' ausente tinha de calar tambem o de EGP incompleto — que e o aviso mais
#' importante daqui —, e `options(warn = 2)`, comum em pipeline reprodutivel,
#' transformava o rotineiro em erro fatal.
#'
#' Com classe, `withCallingHandlers(ocupacoesBR_codigo_ausente = ...)` pega um
#' sem pegar os outros, e `suppressWarnings(classes = ...)` funciona por tipo.
#' @noRd
.aviso <- function(msg, classe) {
  warning(warningCondition(
    msg, class = c(paste0("ocupacoesBR_", classe), "ocupacoesBR_warning")))
}

#' Recusa um vetor binario com valores que nao sao 0/1
#'
#' `tse_para_isei(cod, ano)` aceita o ano na SEGUNDA posicao. Em
#' `tse_para_classe` a segunda e `superior`, e em `tse_para_egp` e
#' `conta_propria`. Quem escreve `tse_para_classe(cod, ano_vec)` por analogia
#' nao recebia erro nenhum: `as.logical(2000)` e TRUE, entao o ano virava a
#' marca LIGADA em toda linha, e a coluna saia errada calada. Era o unico lugar
#' do pacote onde um engano de chamada produzia numero plausivel em silencio.
#'
#' A guarda e de VALOR, nao de posicao: reordenar os argumentos quebraria
#' chamadas posicionais legitimas e o contrato ja documentado. O unico codigo
#' que passa a falhar e o que ja estava errado.
#' @noRd
.guarda_binaria <- function(x, nome) {
  if (is.null(x) || !is.numeric(x)) return(invisible(NULL))
  v <- x[!is.na(x)]
  if (!length(v) || all(v %in% c(0, 1))) return(invisible(NULL))
  u <- sort(unique(v))
  parece_ano <- all(u >= 1900 & u <= 2100 & u == trunc(u))
  stop("`", nome, "` deve ser l\u00f3gico (ou 0/1); recebeu ",
       paste(utils::head(u, 3), collapse = ", "),
       if (length(u) > 3) ", ..." else "", ".",
       if (parece_ano)
         paste0(" Isso parece ser o ano. Ele existe, mas em outra posi\u00e7",
                "\u00e3o: passe-o nomeado, `ano = `.")
       else "",
       call. = FALSE)
}

#' Recusa uma tabela onde se espera uma coluna
#'
#' `as.character()` de um `data.frame` faz *deparse por coluna*, de modo que um
#' quadro de três linhas vira um vetor de duas strings. O contrato "sai do
#' tamanho que entrou" quebra em silêncio, e o resultado — muitas vezes um único
#' `NA` — é reciclado pelo R por uma coluna inteira.
#'
#' `dados[, "cod"]` no data.table e `dplyr::select()` devolvem tabela, não
#' vetor. É o modo de erro mais fácil de cometer e o mais difícil de notar.
#' @noRd
.checa_vetor <- function(x, arg) {
  if (is.data.frame(x) || (!is.null(x) && is.list(x)))
    stop(sprintf(paste0("`%s` deve ser um vetor at\u00f4mico; recebeu um %s de ",
                        "%d coluna(s).\nPasse a COLUNA e n\u00e3o a tabela: ",
                        "`dados$%s` em vez de `dados[, \"%s\"]`."),
                 arg, class(x)[1L], length(x), arg, arg), call. = FALSE)
  invisible(NULL)
}

#' Reconhece os sentinelas de "ignorado" das bases administrativas
#'
#' O layout de vínculos da RAIS declara, literalmente: *"ao encontrar dados como
#' '-1', com ou sem zeros a esquerda, '{ñ class}' ou '{ñclass}', ou parte do
#' texto, considerar como ignorado"*. O Novo CAGED usa `999999` para "Não
#' Identificado".
#'
#' O reconhecimento tem de vir **antes** da limpeza. Se o código passar primeiro
#' por `gsub("\\D", "")`, o hífen de `000-1` desaparece e sobra `0001`, que é
#' uma família sintaticamente válida: o valor ausente vira, calado, uma
#' ocupação. O comportamento chegava a alternar entre abortar e corromper
#' conforme o número de zeros à esquerda — justamente a dimensão que a RAIS
#' avisa que varia.
#' @noRd
.e_sentinela <- function(u) {
  v <- trimws(u)
  !is.na(v) &
    (grepl("^0*-\\s*1$", v) |
     grepl("\u00f1\\s*class", v, ignore.case = TRUE) |
     v == "999999")
}

#' Erra só quando o vetor inteiro é inválido; senão avisa e devolve `NA`
#'
#' Abortar um vetor de milhões de vínculos por causa de um valor sujo é o
#' comportamento errado para dado administrativo — o valor sujo é a regra, não
#' a exceção. Mas se **nenhum** valor for válido, quase sempre é a coluna
#' errada, e aí o erro é o favor a fazer.
#' @noRd
.trata_invalidos <- function(x, mau, u, o_que, exigido) {
  if (!any(mau)) return(x)
  if (all(mau | is.na(x)))
    stop(sprintf(paste0("nenhum c\u00f3digo %s v\u00e1lido \u2014 %s.\nRecebido: %s.\n",
                        "Confira se a coluna \u00e9 a certa."),
                 o_que, exigido,
                 paste(utils::head(unique(u[mau]), 5), collapse = ", ")),
         call. = FALSE)
  .aviso(sprintf("%d c\u00f3digo(s) %s inv\u00e1lido(s), devolvidos como NA (%s): %s%s.",
                 sum(mau), o_que, exigido,
                 paste(utils::head(unique(u[mau]), 5), collapse = ", "),
                 if (length(unique(u[mau])) > 5) ", ..." else ""),
         "codigo_invalido")
  x[mau] <- NA_character_
  x
}

#' Normaliza um código de ocupação do TSE
#'
#' O `CD_OCUPACAO` do TSE é numérico, mas aparece nos microdados como inteiro e
#' como texto, com e sem zeros à esquerda. Tudo é tratado como texto sem zeros à
#' esquerda, que é a forma usada na tabela [tse_isco].
#' @noRd
.norm_tse <- function(cod) {
  .checa_vetor(cod, "cod")
  if (is.factor(cod)) cod <- as.character(cod)
  if (is.numeric(cod)) cod[!is.finite(cod)] <- NA
  cod <- as.character(cod)
  if (!length(cod)) return(character(0))
  .por_unico(cod, function(u) {
    u <- trimws(u)
    u[u == ""] <- NA_character_
    # remove zeros à esquerda sem destruir o código "0"
    sub("^0+(?=[0-9])", "", u, perl = TRUE)
  })
}

#' Normaliza um código ISCO para quatro dígitos
#'
#' As tabelas do ISMF contêm as formas "arredondadas" da hierarquia: o grande
#' grupo 24 aparece como 2400 e o subgrupo 242 como 2420. Um código de 2 ou 3
#' dígitos é, portanto, expandido com zeros à DIREITA — o que não é uma
#' aproximação nossa, e sim a própria chave que Ganzeboom publica.
#'
#' A exceção é o grande grupo 0 (forças armadas), que o ISMF escreve com zero à
#' ESQUERDA: `0110`, `0300`. Um código de 1 a 3 dígitos é ambíguo entre as duas
#' convenções — `110` tanto pode ser o subgrupo 11 (→ `1100`, legisladores)
#' quanto as forças armadas (`0110`). Antes esta função escolhia calada a
#' primeira leitura; agora ela avisa e exige desempate por quatro dígitos.
#' @noRd
.norm_isco <- function(isco, avisar_ambiguo = TRUE) {
  .checa_vetor(isco, "isco")
  if (is.factor(isco)) isco <- as.character(isco)
  if (is.numeric(isco)) isco[!is.finite(isco)] <- NA
  isco <- as.character(isco)
  if (!length(isco)) return(character(0))
  .por_unico(isco, function(u) {
    u <- trimws(u)
    u[u == ""] <- NA_character_
    # tolera zeros à esquerda excedentes vindos de campos de largura fixa
    largo <- !is.na(u) & nchar(u) > 4L & grepl("^0+", u)
    u[largo] <- sub("^0+(?=[0-9]{4}$)", "", u[largo], perl = TRUE)
    n <- nchar(u)
    fora <- !is.na(u) & (n < 1L | n > 4L | grepl("\\D", u))
    if (any(fora))
      stop("c\u00f3digo ISCO inv\u00e1lido: ",
           paste(utils::head(unique(u[fora]), 5), collapse = ", "),
           call. = FALSE)
    curto <- !is.na(u) & n < 4L
    out <- ifelse(is.na(u), NA_character_,
                  formatC(suppressWarnings(as.integer(u)) * 10L^(4L - n),
                          width = 4, flag = "0", format = "d"))
    # ambíguo = a leitura com zero à esquerda também existe nas tabelas
    if (avisar_ambiguo && any(curto)) {
      alt <- formatC(suppressWarnings(as.integer(u[curto])), width = 4,
                     flag = "0", format = "d")
      amb <- alt %in% ocupacoesBR::isco88_medidas$isco88 & alt != out[curto]
      if (any(amb))
        .aviso(paste0("c\u00f3digo ISCO com menos de 4 d\u00edgitos \u00e9 amb\u00edguo: ",
                      paste(unique(u[curto][amb]), collapse = ", "),
                      ". Lido como ", paste(unique(out[curto][amb]), collapse = ", "),
                      " (grupo hier\u00e1rquico); para as for\u00e7as armadas informe ",
                      paste(unique(alt[amb]), collapse = ", "), "."),
               "isco_ambiguo")
    }
    out
  })
}

#' Busca vetorizada com preservação de NA
#'
#' `tabela` pode ser omitida do aviso passando `o_que = NULL`.
#' @noRd
.busca <- function(chave, tabela, col_chave, col_valor, o_que = NULL) {
  i <- match(chave, tabela[[col_chave]])
  if (!is.null(o_que)) .avisa_ausentes(chave, i, o_que)
  tabela[[col_valor]][i]
}

#' Avisa uma única vez sobre códigos não encontrados
#' @noRd
.avisa_ausentes <- function(chave, encontrado, o_que) {
  faltam <- unique(chave[!is.na(chave) & is.na(encontrado)])
  if (length(faltam))
    .aviso(sprintf("%d c\u00f3digo(s) sem correspond\u00eancia em %s: %s%s",
                   length(faltam), o_que,
                   paste(utils::head(faltam, 10), collapse = ", "),
                   if (length(faltam) > 10) ", ..." else ""),
           "codigo_ausente")
  invisible(NULL)
}
