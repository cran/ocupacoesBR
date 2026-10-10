# O guia para agentes e prosa condensada: o risco dele e prometer uma funcao que
# nao existe, ou envelhecer quando o pacote muda de forma. Os testes abaixo
# amarram as afirmacoes verificaveis do guia ao pacote real.

CONTRAEXEMPLO <- "cbo94_para_isei_br"

caminho_guia <- function() {
  p <- system.file("llm", "GUIA_AGENTE.md", package = "ocupacoesBR")
  if (!nzchar(p)) p <- testthat::test_path("..", "..", "inst", "llm", "GUIA_AGENTE.md")
  p
}

test_that("o guia viaja com o pacote", {
  p <- caminho_guia()
  expect_true(file.exists(p))
  expect_gt(file.size(p), 3000)
})

test_that("toda funcao citada no guia existe", {
  txt <- readLines(caminho_guia(), warn = FALSE)
  # nomes seguidos de "(" em qualquer lugar do texto, inclusive dentro de blocos
  citadas <- unlist(regmatches(txt, gregexpr("[a-z][a-z0-9_]+(?=\\()", txt, perl = TRUE)))
  # so as que parecem deste pacote: prefixo de porta, ou os verbos proprios
  nossas <- grep("^(tse|cbo2002|cbo94|cod|isco88|isco08|crosswalk|checa|isei)_",
                 unique(citadas), value = TRUE)
  # O guia cita de proposito UM nome que nao existe, como exemplo de que a
  # gramatica nao autoriza toda combinacao. Ele e conferido no teste seguinte.
  nossas <- setdiff(nossas, CONTRAEXEMPLO)
  expect_gt(length(nossas), 10)
  expect_true(all(nossas %in% getNamespaceExports("ocupacoesBR")),
              info = paste(setdiff(nossas, getNamespaceExports("ocupacoesBR")),
                           collapse = ", "))
})

test_that("o contraexemplo do guia continua sendo um contraexemplo", {
  # Se esta porta um dia existir, a secao 1 do guia passa a mentir.
  expect_false(CONTRAEXEMPLO %in% getNamespaceExports("ocupacoesBR"))
  txt <- paste(readLines(caminho_guia(), warn = FALSE), collapse = "\n")
  expect_match(txt, CONTRAEXEMPLO, fixed = TRUE)
})

test_that("as contagens do guia batem com o pacote", {
  txt <- paste(readLines(caminho_guia(), warn = FALSE), collapse = "\n")
  ex <- getNamespaceExports("ocupacoesBR")

  expect_match(txt, sprintf("São %d funções exportadas", length(ex)))
  expect_match(txt, sprintf("%d delas seguem um padrão", sum(grepl("_para_", ex))))
  # o guia escreve o numero por extenso; confere-se o fato e a palavra
  expect_equal(sum(grepl("siops", ex)), 6L)
  expect_match(txt, "Seis exports contêm `siops`")
  expect_match(txt, sprintf("Dezessete dos %d códigos", nrow(tse_isco)))
  expect_equal(sum(is.na(tse_isco$isco88)), 17L)
  expect_equal(sum(tse_quebra_2002$tipo == "reutilizado"), 7L)
})

test_that("o guia aponta para a tabela reguas, e nao a repete", {
  txt <- paste(readLines(caminho_guia(), warn = FALSE), collapse = "\n")
  expect_match(txt, "reguas\\[")
  expect_match(txt, "\\?reguas")
  # cada medida da tabela NAO precisa aparecer no guia; o guia remete a ela.
  # O que precisa e que a remissao esteja la.
  expect_match(txt, "quando_nao_usar")
})

test_that("os numeros de ISEI e prestigio citados batem com as tabelas", {
  cw <- crosswalk_tse()
  mag <- cw[cw$cod_tse == "271", ]
  enf <- cw[cw$cod_tse == "113", ]
  expect_equal(c(mag$isei88, mag$siops88), c(90, 76))
  expect_equal(c(enf$isei88, enf$siops88), c(43, 54))
})

test_that("so a porta do TSE aceita `ano`, e todas as traducoes dela aceitam", {
  # A aba de classificacoes e a vinheta robustez diziam que "toda funcao de
  # traducao deste pacote aceita ano". So as do TSE aceitam — a quebra e do
  # cadastro eleitoral. Este teste guarda a afirmacao corrigida nas duas
  # direcoes, de modo que uma porta nova sem `ano` reprove.
  ex <- getNamespaceExports("ocupacoesBR")
  tem_ano <- function(f) "ano" %in% names(formals(get(f, envir = asNamespace("ocupacoesBR"))))

  traducoes_tse <- grep("^tse_para_", ex, value = TRUE)
  expect_gt(length(traducoes_tse), 10)
  for (f in traducoes_tse) expect_true(tem_ano(f), info = f)

  outras_portas <- grep("^(cbo2002|cbo94|cod|isco88|isco08)_para_", ex, value = TRUE)
  expect_gt(length(outras_portas), 10)
  for (f in outras_portas) expect_false(tem_ano(f), info = f)
})
