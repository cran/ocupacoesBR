# Testes de `tse_universo`: a decomposicao do residuo das candidaturas.
# O que se trava aqui nao e o valor de cada celula — e que a tabela continue
# sendo um UNIVERSO (fecha em 100), que as rubricas continuem distintas, e que
# as duas afirmacoes que a documentacao faz sobre ela sigam verdadeiras.

test_that("tse_universo e um universo: fecha em 100 por (ano, sexo)", {
  u <- ocupacoesBR::tse_universo
  expect_true(all(c("ano", "sexo", "rubrica", "n", "pct") %in% names(u)))
  expect_setequal(u$sexo, c("Homem", "Mulher", "Todos"))
  soma <- tapply(u$pct, list(u$ano, u$sexo), sum)
  expect_true(all(abs(soma - 100) < 0.02))
  # a grade e completa: toda combinacao existe, inclusive com n = 0
  expect_equal(nrow(u),
               length(unique(u$ano)) * 3L * length(unique(u$rubrica)))
  expect_true(all(u$n >= 0))
})

test_that("a linha 'Todos' contem os dois sexos", {
  u <- ocupacoesBR::tse_universo
  t <- tapply(u$n[u$sexo == "Todos"], u$ano[u$sexo == "Todos"], sum)
  h <- tapply(u$n[u$sexo != "Todos"], u$ano[u$sexo != "Todos"], sum)
  expect_true(all(t >= h))
})

test_that("as sete rubricas sao as sete, e a residual nao virou uma so", {
  u <- ocupacoesBR::tse_universo
  expect_setequal(unique(u$rubrica),
                  c("Com escore", "Ocupação sem escore", "Vínculo público",
                    "Fora da força de trabalho", "Inativo com trajetória",
                    "Outros (999)", "Não informada"))
  # `999` e `Nao informada` sao coisas diferentes e nao podem ser fundidas: e
  # a distincao entre recusa de nomear e ausencia de registro, e e ela que
  # torna visivel que o campo passou a ser obrigatorio.
  n999 <- u$pct[u$sexo == "Todos" & u$rubrica == "Outros (999)"]
  ninf <- u$pct[u$sexo == "Todos" & u$rubrica == "Não informada"]
  expect_true(any(n999 > 0) && any(ninf > 0))
})

test_that("o que ?tse_universo afirma sobre o tempo continua verdadeiro", {
  u <- ocupacoesBR::tse_universo
  t <- u[u$sexo == "Todos", ]
  ninf <- t[t$rubrica == "Não informada", ]
  # a nao declaracao vai a zero a partir de 2006 (campo obrigatorio)
  expect_true(all(ninf$pct[ninf$ano >= 2006] == 0))
  expect_true(any(ninf$pct[ninf$ano <= 2004] > 1))
  # e a recusa de nomear assume o lugar: 1998 abaixo de 2024
  n999 <- t[t$rubrica == "Outros (999)", ]
  expect_lt(n999$pct[n999$ano == 1998], n999$pct[n999$ano == 2024])
})

test_that("a diferenca de cobertura entre os sexos esta na forca de trabalho", {
  u <- ocupacoesBR::tse_universo
  d <- u[u$ano >= 2004 & u$sexo != "Todos", ]
  tot <- tapply(d$n, d$sexo, sum)
  fora <- d[d$rubrica == "Fora da força de trabalho", ]
  pct <- tapply(fora$n, fora$sexo, sum) / tot * 100
  # medido em 08/09/2026: 1,2% dos homens contra 14,6% das mulheres
  expect_lt(pct[["Homem"]], 3)
  expect_gt(pct[["Mulher"]], 10)
  # e a consequencia: a cobertura do escore e menor entre as mulheres em
  # TODAS as safras, o que e o motivo de nao se descartar o residuo sem dizer
  cob <- u[u$rubrica == "Com escore" & u$sexo != "Todos", ]
  h <- cob$pct[cob$sexo == "Homem"][order(cob$ano[cob$sexo == "Homem"])]
  m <- cob$pct[cob$sexo == "Mulher"][order(cob$ano[cob$sexo == "Mulher"])]
  expect_true(all(h > m))
})

test_that("o vinculo publico tem o tamanho que a comparacao com a populacao exige", {
  u <- ocupacoesBR::tse_universo
  d <- u[u$ano >= 2004 & u$sexo == "Todos", ]
  vp <- sum(d$n[d$rubrica == "Vínculo público"]) / sum(d$n) * 100
  # 8,8% de 2004 em diante; do lado da populacao, `isco_posicao_br` mede
  # 11,7% de setor publico entre os ocupados. As duas fontes NAO tratam as
  # mesmas pessoas do mesmo jeito, e e esse o ponto.
  expect_gt(vp, 7)
  expect_lt(vp, 11)
  expect_gt(mean(ocupacoesBR::isco_posicao_br$pct_setor_publico), 0)
})
