# O teste anterior inspecionava `isco88_medidas` (a tábua do Ganzeboom, que
# nunca muda) e por isso NÃO podia detectar erro de mapeamento: sabotar 253 dos
# 275 códigos do dicionário deixava a suíte inteira passando. Estes testes
# olham para `tse_isco`, que é onde o erro moraria.

test_that("o dicionário do TSE não é uma tradução de primeiro dígito", {
  d <- tse_isco[!is.na(tse_isco$isco88), ]
  # Numa tradução por 1º dígito, o dígito do TSE determinaria o do ISCO.
  # No dicionário real a associação é fraca — cada grande grupo do TSE se
  # espalha por vários da ISCO.
  tab <- table(substr(d$cod_tse, 1, 1), substr(d$isco88, 1, 1))
  espalhamento <- mean(apply(tab, 1, function(r) sum(r > 0)))
  expect_gt(espalhamento, 2)
  # e nenhum grande grupo do TSE cai inteiro num único da ISCO
  expect_false(all(apply(tab, 1, function(r) sum(r > 0)) == 1))
})

test_that("os códigos que mais importam mantêm o destino auditado", {
  # Snapshot explícito: se qualquer um destes mudar, foi decisão, não acidente.
  # 111 vai a 2221 (medical doctors) e nao ao generico 2220; 114 a 3226 e 222 a
  # 3223 -- correcoes de precisao da rodada 5, ver R/classe_ocupacao.R
  esperado <- c("111" = "2221", "114" = "3226", "222" = "3223", "113" = "2230", "131" = "2421", "271" = "2422",
                "233" = "5162", "234" = "1311", "169" = "1300", "257" = "1200",
                "601" = "6100", "143" = "2330")
  obtido <- tse_para_isco(names(esperado))
  expect_equal(obtido, unname(esperado))
})

test_that("a hierarquia ISEI sobrevive: o grande grupo ISCO ordena o escore", {
  d <- crosswalk_tse()
  d <- d[!is.na(d$isei88), ]
  g <- tapply(d$isei88, substr(d$isco88, 1, 1), mean)
  # profissionais (2) acima de técnicos (3), acima de elementares (9)
  expect_gt(g[["2"]], g[["3"]])
  expect_gt(g[["3"]], g[["9"]])
  expect_gt(g[["1"]], g[["9"]])
})

test_that("o deslocamento de classe segue a OIT, e a lista é exaustiva", {
  # O critério declarado em ?tse_para_classe: um código só sai do que o primeiro
  # dígito da ISCO-88 manda quando a PRÓPRIA OIT o moveu de grande grupo entre a
  # ISCO-88 e a ISCO-08. Este teste verifica que a lista está completa — se uma
  # revisão futura da ponte mover outro código, ele falha e a decisão volta à
  # mesa em vez de passar despercebida.
  d <- tse_isco[!is.na(tse_isco$isco88), ]
  d$isco08 <- suppressWarnings(isco88_para_isco08(d$isco88))
  d <- d[!is.na(d$isco08), ]
  movidos <- d$cod_tse[substr(d$isco88, 1, 1) != substr(d$isco08, 1, 1)]
  expect_setequal(movidos, c("114", "222", "234", "602", "901"))

  # 114 e 222 passam pela régua do 1º dígito: a OIT os promoveu (3226 -> 2264,
  # 3223 -> 2265) e o pacote segue.
  expect_equal(tse_para_classe(c("114", "222")),
               rep("Profissionais de nível superior", 2))
  # 234, 602 e 901 NÃO passam por ela: o código já os nomeia proprietários,
  # e essa regra tem precedência sobre o dígito.
  expect_equal(tse_para_classe(c("234", "602", "901")),
               rep("Proprietários e empregadores", 3))
  # E desde 0.2.1 eles nem chegam a ser movidos de grande grupo: o teste acima
  # olha a PONTE crua (`isco88_para_isco08`), que é a da OIT e não muda; o passo
  # TSE -> ISCO-08 aplica `iskopromo.sps` e os devolve ao grupo 1. Ver
  # test-isco08-tse.R.
  agrarios <- c("234", "602", "901")
  expect_equal(tse_para_isco08(agrarios), rep("1311", 3))
  d$final <- suppressWarnings(tse_para_isco08(d$cod_tse))
  expect_setequal(d$cod_tse[substr(d$isco88, 1, 1) != substr(d$final, 1, 1)],
                  c("114", "222", "164", "163", "165"))
})

test_that("as duas réguas se separam: nenhuma classe média acima da mediana da alta", {
  # A afirmação substantiva de ?tse_para_estrato. Cruzamento entre as réguas é
  # esperado nas caudas (posição != status), mas as distribuições se separam.
  d <- crosswalk_tse()
  d <- d[!is.na(d$isei88), ]
  alta  <- d$isei88[d$estrato == "Classe alta"]
  media <- d$isei88[d$estrato == "Classe média"]
  expect_equal(sum(media > stats::median(alta)), 0L)
  # e a sobreposição inversa é pequena e nomeada (113, 234, 602, 901)
  expect_lte(sum(alta < stats::median(media)), 4L)
})

test_that("nenhuma classe alta tem ISEI baixo, e vice-versa", {
  d <- crosswalk_tse()
  alta <- d$isei88[d$estrato == "Classe alta" & !is.na(d$isei88)]
  pop  <- d$isei88[d$estrato == "Classes populares" & !is.na(d$isei88)]
  expect_gt(mean(alta), mean(pop) + 15)
  expect_gt(min(alta), 40)
})
