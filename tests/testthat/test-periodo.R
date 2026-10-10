test_that("checa_periodo marca so os codigos reutilizados em anos antigos", {
  r <- suppressWarnings(checa_periodo(c("211", "211", "111", "214"),
                                      c(2000, 2012, 2000, 1998)))
  expect_equal(r, c(TRUE, FALSE, FALSE, TRUE))
})

test_that("checa_periodo avisa quando ha casos atingidos, e cala quando nao ha", {
  expect_warning(checa_periodo(c("211"), 2000), "reutilizou")
  expect_silent(checa_periodo(c("211"), 2012))
  expect_silent(checa_periodo(c("111"), 1998))
})

test_that("a tabela da quebra e coerente", {
  q <- tse_quebra_2002
  expect_true(all(q$cod_tse %in% tse_isco$cod_tse))
  expect_false(anyDuplicated(q$cod_tse) > 0)
  expect_setequal(unique(q$tipo),
                  c("reutilizado", "renomeado", "redefinido", "refinado"))
  # Toda reutilizacao tem de dizer a partir de QUANDO vale, senao checa_periodo
  # nao sabe onde cortar.
  reut <- q[q$tipo == "reutilizado", ]
  expect_true(all(!is.na(reut$primeiro_ano_novo)))
  expect_true(all(reut$primeiro_ano_novo > reut$ultimo_ano_antigo))
  # A versao anterior exigia aqui `all(delta_pp < -50)` — "so quedas
  # inequivocas". Aquilo era o METODO antigo virado invariante, e e falso: o
  # codigo 215 e reutilizacao inequivoca (DAS superior -> artista plastico) e
  # SOBE 6,5 pp, porque os dois perfis tem diploma parecido. Exigir a queda
  # excluiria justamente os casos que a heuristica de escolaridade nao ve —
  # que sao quatro dos sete.
  expect_true(any(reut$delta_vs_tendencia > -40 |
                  is.na(reut$delta_vs_tendencia)))
  # O que continua valendo, e agora e o invariante de verdade: onde HA colapso
  # de escolaridade, e reutilizacao.
  colapso <- q[!is.na(q$delta_vs_tendencia) & q$delta_vs_tendencia < -40, ]
  expect_true(all(colapso$tipo == "reutilizado"))
})

test_that("checa_periodo exige comprimentos iguais", {
  expect_error(checa_periodo(c("211", "111"), 2000), "comprimento")
})
