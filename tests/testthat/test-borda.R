# Contrato de tipo e comprimento para toda função exportada de vetor.

FUNS <- list(
  tse_para_isco = "character", tse_para_isei = "double",
  tse_para_siops = "double", tse_para_classe = "character",
  tse_para_estrato = "character", tse_para_componente_alta = "character",
  tse_para_politico = "logical", tse_para_isco08 = "character",
  tse_para_isei08 = "double", tse_para_siops08 = "double")

test_that("as funções do TSE preservam comprimento e tipo em entradas difíceis", {
  entradas <- list(character(0), integer(0), NA, NA_character_, c(NA, NA),
                   NaN, Inf, factor("111"), TRUE, " 111 ", "0111", 1.11e5,
                   c("111", "111"), "")
  for (nm in names(FUNS)) {
    f <- get(nm)
    for (x in entradas) {
      r <- suppressWarnings(f(x))
      expect_length(r, length(x))
      expect_false(is.factor(r))
      if (length(x)) expect_equal(typeof(r), FUNS[[nm]], info = paste(nm, class(x)))
    }
  }
})

test_that("as funções da CBO preservam comprimento e tipo", {
  # Esta lista tinha TRES entradas enquanto a do TSE tinha catorze. Foi essa
  # assimetria que deixou passar o sentinela "-1" da RAIS abortando o vetor
  # inteiro e o "000-1" virando a família "0001" em silêncio. A entrada suja da
  # CBO é mais provável que a do TSE, não menos: dado administrativo é sujo por
  # natureza, e o layout da RAIS até declara a forma do lixo.
  entradas <- list(character(0), integer(0), NA, NA_character_, c(NA, NA),
                   NaN, Inf, factor("225120"), " 225120 ", "225120",
                   c("225120", "225120"), "",
                   # os sentinelas que os layouts oficiais declaram
                   "-1", "0-1", "00-1", "000-1", "0000-1", "{ñ class}",
                   "{ñclass}", "999999",
                   # a CBO gravada como número, que come o zero à esquerda
                   225120L, 10105L)
  for (nm in c("cbo2002_para_isco", "cbo2002_para_isei", "cbo2002_para_siops",
               "cbo2002_para_isco08", "cbo2002_para_isei08",
               "cbo2002_para_siops08")) {
    f <- get(nm)
    for (x in entradas) {
      r <- suppressWarnings(f(x))
      expect_length(r, length(x))
      expect_false(is.factor(r), info = paste(nm, class(x)))
    }
  }
  # a CBO-94 tem CINCO dígitos: a lista da CBO-2002 não serve tal e qual
  entradas94 <- list(character(0), integer(0), NA, NA_character_, c(NA, NA),
                     NaN, Inf, factor("21130"), " 21130 ", "21130",
                     c("21130", "21130"), "", "2-11.20",
                     "-1", "0-1", "0000-1", "{ñ class}", "999999",
                     21130L, 1105L)
  for (nm in c("cbo94_para_isco", "cbo94_para_isei", "cbo94_para_siops",
               "cbo94_para_isco08", "cbo94_para_egp")) {
    f <- get(nm)
    for (x in entradas94) {
      r <- suppressWarnings(if (nm == "cbo94_para_egp") f(x, avisar = FALSE) else f(x))
      expect_length(r, length(x))
      expect_false(is.factor(r), info = paste(nm, class(x)))
    }
  }
})

test_that("sentinela declarado da RAIS vira NA, e nunca um código válido", {
  # O layout de vínculos da RAIS: "ao encontrar dados como '-1', com ou sem
  # zeros a esquerda, '{ñ class}' ou '{ñclass}' [...] considerar como ignorado".
  for (v in c("-1", "0-1", "00-1", "000-1", "0000-1", "00000-1", "000000-1",
              "{ñ class}", "{ñclass}", "999999")) {
    expect_true(is.na(suppressWarnings(cbo2002_para_isco(v))),
                info = paste("sentinela", v))
    expect_true(is.na(suppressWarnings(cbo94_para_isco(v))),
                info = paste("sentinela", v))
  }
  # um sujo no meio de um vetor bom NÃO derruba os demais
  r <- suppressWarnings(cbo2002_para_isco(c("225120", "-1", "223505")))
  expect_length(r, 3L)
  expect_false(any(is.na(r[c(1, 3)])))
  expect_true(is.na(r[2]))
  # mas se NENHUM valor é válido, aí sim é a coluna errada e o erro é o favor
  expect_error(cbo2002_para_isco(c("xx", "yy")), "nenhum")
})

test_that("leitura numérica recompõe o zero à esquerda, e só ela", {
  # o Novo CAGED grava a CBO como número: 010105 chega como 10105
  expect_equal(suppressWarnings(cbo2002_para_isco(225120L)),
               suppressWarnings(cbo2002_para_isco("225120")))
  expect_silent(x <- .norm_cbo2002(10105L))
  expect_equal(x, "010105")
  expect_equal(.norm_cbo94(1105L), "01105")
  # texto de tamanho errado continua sendo erro: "111" é código malformado,
  # não a família "0111"
  expect_error(cbo2002_para_isco("111"), "4 \\(fam")
  expect_error(cbo2002_para_isco("12345"), "4 \\(fam")
})

test_that("isco88_para_isco08(character(0)) devolve colunas de texto", {
  r <- isco88_para_isco08(character(0), com_ambiguidade = TRUE)
  expect_type(r$isco88, "character")
  expect_type(r$isco08, "character")
})

test_that("NaN e Inf viram NA nas duas pernas, sem abortar", {
  expect_true(is.na(suppressWarnings(isco88_para_egp(NaN, avisar = FALSE))))
  expect_true(is.na(suppressWarnings(isco88_para_egp(Inf, avisar = FALSE))))
  expect_true(is.na(suppressWarnings(tse_para_isco(NaN))))
})

test_that("erros de argumento nomeiam o argumento", {
  expect_error(isco88_para_egp("2211", n_classes = c(11, 7)), "n_classes")
  expect_error(isco88_para_egp("5220", conta_propria = "sim", avisar = FALSE),
               "conta_propria")
  expect_error(tse_para_classe("291", superior = factor("TRUE")), "superior")
  expect_error(cbo94_para_isco("123"), "5 digitos")
})
