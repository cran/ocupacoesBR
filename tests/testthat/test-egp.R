test_that("o EGP avisa quando lhe faltam as variáveis que ele exige", {
  expect_warning(isco88_para_egp("2211"), "IVa e IVb")
  expect_silent(isco88_para_egp("2211", avisar = FALSE))
})

test_that("sem posição na ocupação, a pequena burguesia fica vazia", {
  # É o ponto central da documentação: partindo só da ocupação, IVa e IVb são
  # inalcançáveis. Se este teste passar a falhar, a promessa da doc mudou.
  e <- isco88_para_egp(isco88_medidas$isco88, avisar = FALSE)
  expect_false(any(grepl("^IVa", e), na.rm = TRUE))
  expect_false(any(grepl("^IVb", e), na.rm = TRUE))
})

test_that("com posição na ocupação, a pequena burguesia aparece", {
  # 5220 (comércio) por conta própria: sem empregados vira IVb, com 5, IVa.
  e <- isco88_para_egp(c("5220", "5220"),
                       conta_propria = c(TRUE, TRUE),
                       n_supervisionados = c(0, 5))
  expect_match(e[1], "^IVb")
  expect_match(e[2], "^IVa")
})

test_that("as regras que dependem de supervisão funcionam", {
  # IIIa com subordinados sobe para II (regra: E=3 & SV>=1 -> E=2)
  expect_match(isco88_para_egp("4110", n_supervisionados = 3, avisar = FALSE),
               "^II:")
  # trabalhador qualificado com subordinados vira supervisor manual (E=8 -> 7)
  expect_match(isco88_para_egp("7200", n_supervisionados = 2, avisar = FALSE),
               "^V:")
  # trabalhador agrícola por conta própria vira proprietário rural (E=10 -> 11)
  expect_match(isco88_para_egp("9200", conta_propria = TRUE, avisar = FALSE),
               "^IVc")
})

test_that("a separação IIIa/IIIb de 2001 está aplicada", {
  expect_match(isco88_para_egp("5220", avisar = FALSE), "^IIIb")
  expect_match(isco88_para_egp("4110", avisar = FALSE), "^IIIa")
})

test_that("os colapsos do EGP batem com Erikson & Goldthorpe 1992, pp. 38-39", {
  # Trava os tres vetores contra a fonte citada. A versao anterior destes
  # vetores foi escrita sem consultar fonte alguma e os tres estavam errados;
  # o teste de entao so checava min>=1 e max<=k, e passava com qualquer
  # permutacao. Ordem: I II IIIa IIIb IVa IVb V VI VIIa VIIb IVc
  expect_equal(ocupacoesBR:::.EGP7, c(1,1,2,2,3,3,5,5,6,7,4))
  expect_equal(ocupacoesBR:::.EGP5, c(1,1,1,1,2,2,4,4,5,3,3))
  expect_equal(ocupacoesBR:::.EGP3, c(1,1,1,1,1,1,2,2,2,3,3))
  # I+II juntos no de 7; IVc com VIIb no de 5; IVab com nao-manuais no de 3
  expect_equal(ocupacoesBR:::.EGP7[1], ocupacoesBR:::.EGP7[2])
  expect_equal(ocupacoesBR:::.EGP5[11], ocupacoesBR:::.EGP5[10])
  expect_equal(ocupacoesBR:::.EGP3[5], ocupacoesBR:::.EGP3[1])
  isco <- isco88_medidas$isco88
  for (k in c(11, 7, 5, 3)) {
    e <- isco88_para_egp(isco, n_classes = k, rotulo = FALSE, avisar = FALSE)
    expect_lte(max(e, na.rm = TRUE), k)
    expect_gte(min(e, na.rm = TRUE), 1)
    # rotulo = TRUE devolve TEXTO em todas as versoes, nao so na de 11
    expect_type(isco88_para_egp(isco[1:5], n_classes = k, avisar = FALSE),
                "character")
  }
  expect_error(isco88_para_egp("2211", n_classes = 9), "11, 7, 5 ou 3")
})

test_that("códigos de 2 e 3 dígitos entram pelas formas arredondadas", {
  expect_equal(isco88_para_egp("24",   avisar = FALSE),
               isco88_para_egp("2400", avisar = FALSE))
  expect_equal(isco88_para_egp("242",  avisar = FALSE),
               isco88_para_egp("2420", avisar = FALSE))
})

test_that("NA entra e NA sai", {
  expect_true(is.na(isco88_para_egp(NA_character_, avisar = FALSE)))
  expect_true(is.na(tse_para_egp(0, avisar = FALSE)))
})

test_that("sem supervisao nenhuma porta produz V, e sem posicao nao produz IVa nem IVb", {
  # A ajuda de cbo94_para_egp afirmava que "a RAIS TEM essas variaveis no
  # vinculo". Nao tem: e registro de vinculo empregaticio, toda linha e um
  # empregado. E a de cod_para_egp e a vinheta `qual-regua` diziam que com a
  # PNAD "o esquema funciona por inteiro" — ela separa IVa de IVb, mas nao traz
  # a supervisao que define V. Este teste guarda o que de fato sai por cada
  # porta quando as variaveis nao sao passadas, que e o caso da RAIS sempre.
  so_ocupacao <- function(x) unique(stats::na.omit(x))

  cbo <- so_ocupacao(cbo2002_para_egp(cbo2002_isco88$cbo2002, avisar = FALSE))
  cod <- so_ocupacao(cod_para_egp(cod_isco08$cod, avisar = FALSE))
  expect_false(any(grepl("^V:",   cbo)))
  expect_false(any(grepl("^IVa:", cbo)))
  expect_false(any(grepl("^V:",   cod)))
  expect_false(any(grepl("^IVa:", cod)))

  # a marca que o TSE carrega recupera IVc, e e `conta_propria`, nao `proprietario`
  expect_gt(sum(tse_isco$conta_propria, na.rm = TRUE),
            sum(tse_isco$proprietario,  na.rm = TRUE))
  tse <- so_ocupacao(tse_para_egp(tse_isco$cod_tse, avisar = FALSE))
  expect_true(any(grepl("^IVc:", tse)))
  # mas nem pelo TSE se separa IVa, que exige subordinados
  expect_false(any(grepl("^IVa:", tse)))
})
