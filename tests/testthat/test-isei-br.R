# Testes do ISEI-BR: a regua de status estimada na PNAD Continua, e nao
# importada. O que estes testes protegem e a integridade da tabela, a
# propagacao pelas quatro portas, e a validade de face dos escores.

test_that("a tabela cobre as mesmas chaves de isco08_medidas, sem buraco", {
  d <- ocupacoesBR::isco08_isei_br
  expect_equal(nrow(d), nrow(ocupacoesBR::isco08_medidas))
  expect_setequal(d$isco08, ocupacoesBR::isco08_medidas$isco08)
  expect_false(anyNA(d$isei_br))
  expect_true(all(d$isei_br >= 10 & d$isei_br <= 90))
  expect_false(anyDuplicated(d$isco08) > 0)
})

test_that("as colunas de precisao sao coerentes entre si", {
  d <- ocupacoesBR::isco08_isei_br
  expect_true(all(d$n_pessoas <= d$n_obs))
  expect_true(all(d$nivel %in% 1:4))
  # nivel 4 so existe onde houve amostra bastante para estimar de verdade
  expect_true(all(d$n_pessoas[d$nivel == 4L] >= 30))
  # quem herdou herdou de alguem: a celula que forneceu tambem tem gente
  expect_true(all(d$n_pessoas[d$nivel < 4L] >= 30))
})

test_that("os parametros da estimacao viajam com a tabela", {
  d <- ocupacoesBR::isco08_isei_br
  for (a in c("theta", "beta_direto", "beta_total", "parcela_mediada"))
    expect_true(is.numeric(attr(d, a)) && length(attr(d, a)) == 1L)
  # o angulo tem de ser interior: peso positivo na escolaridade E na renda
  expect_gt(attr(d, "theta"), 0)
  expect_lt(attr(d, "theta"), pi / 2)
  # a mediacao e parcial no Brasil, e a tabela nao pode fingir que e completa
  expect_gt(attr(d, "parcela_mediada"), 0)
  expect_lt(attr(d, "parcela_mediada"), 100)
})

test_that("codigo da ISCO-08 em que nenhuma COD aterrissa vem herdado", {
  d <- ocupacoesBR::isco08_isei_br
  proprios <- d$isco08[sub("0+$", "", d$isco08) == d$isco08]
  orfaos   <- setdiff(proprios, unique(ocupacoesBR::cod_isco08$isco08))
  # a lista se calcula da tabua, e nao se digita: ela muda quando a tabua muda
  expect_gt(length(orfaos), 0)
  expect_true(all(d$nivel[d$isco08 %in% orfaos] < 4L))
})

test_that("a regua propaga pelas quatro portas, e falha onde a irma falha", {
  # o criterio nao e "nao ter NA": e ter NA exatamente onde o ISEI-08 tambem
  # tem, porque as duas passam pela mesma traducao ate a ISCO-08.
  k <- ocupacoesBR::tse_isco$cod_tse
  expect_equal(is.na(tse_para_isei_br(k)), is.na(tse_para_isei08(k)))
  cd <- ocupacoesBR::cod_isco08$cod
  expect_equal(is.na(cod_para_isei_br(cd)), is.na(cod_para_isei08(cd)))
  expect_equal(is.na(cbo2002_para_isei_br("225120")),
               is.na(cbo2002_para_isei08("225120")))
  expect_false(is.na(isco08_para_isei_br("2211")))
})

test_that("a vigencia do codigo do TSE vale para a regua nova tambem", {
  # 215 e posterior a 2002: pedir em 2000 tem de devolver NA, como nas irmas
  expect_equal(suppressWarnings(is.na(tse_para_isei_br("215", ano = 2000))),
               suppressWarnings(is.na(tse_para_isei08("215", ano = 2000))))
})

test_that("as tabelas auditaveis ganharam a coluna sem perder as antigas", {
  ct <- crosswalk_tse()
  expect_true("isei_br" %in% names(ct))
  expect_true(all(c("isei08", "isei88", "egp") %in% names(ct)))
  expect_equal(is.na(ct$isei_br), is.na(ct$isco08))
  cc <- crosswalk_cod()
  expect_true("isei_br" %in% names(cc))
  expect_false(anyNA(cc$isei_br))
})

test_that("os escores ordenam o que qualquer leitor esperaria", {
  # desigualdades folgadas, nunca igualdade: o valor exato muda com a safra
  expect_gt(isco08_para_isei_br("2211"), isco08_para_isei_br("9211"))
  expect_gt(isco08_para_isei_br("1120"), isco08_para_isei_br("5223"))
  expect_gt(isco08_para_isei_br("2310"), isco08_para_isei_br("9112"))
  expect_gt(tse_para_isei_br("111"), tse_para_isei_br("601"))
})

test_that("concorda com a ancora internacional sem ser copia dela", {
  d <- ocupacoesBR::isco08_isei_br
  f <- d[d$nivel == 4L, ]
  i <- ocupacoesBR::isco08_medidas$isei08[
         match(f$isco08, ocupacoesBR::isco08_medidas$isco08)]
  ok <- !is.na(i)
  # concorda: se cair abaixo disso, alguma coisa se quebrou na traducao
  expect_gt(stats::cor(f$isei_br[ok], i[ok], method = "spearman"), 0.75)
  # nao e copia: se subir demais, a estimacao virou reimportacao do ISEI-08
  expect_lt(stats::cor(f$isei_br[ok], i[ok], method = "spearman"), 0.99)
  # e discorda o bastante para valer a pena existir
  expect_gt(mean(abs(f$isei_br[ok] - i[ok])), 3)
})

test_that("a lista de quem sobe e desce nao depende do criterio usado", {
  # `vignette("validacao")` le a relocacao sobre a diferenca PADRONIZADA, e ate
  # 07/09/2026 justificava isso dizendo que assim "a correlacao com o ponto de
  # partida some". Ela nao some: para dois vetores padronizados com correlacao
  # r, cor(z1 - z2, z2) = -sqrt((1 - r)/2), que e aritmetica e nunca e zero.
  # O que de fato autoriza a leitura e esta concordancia com o residuo da
  # regressao, que E ortogonal ao ponto de partida por construcao. Se ela
  # deixar de valer, a secao precisa ser reescrita.
  v <- tse_validacao
  v$rotulo  <- tse_para_rotulo(v$cod_tse)
  v$isei    <- suppressWarnings(tse_para_isei(v$cod_tse))
  v$isei08  <- suppressWarnings(tse_para_isei08(v$cod_tse))
  v$isei_br <- suppressWarnings(tse_para_isei_br(v$cod_tse))
  w <- v[stats::complete.cases(
    v[, c("isei", "isei08", "isei_br", "pct_superior", "mediana_patrimonio")]), ]

  z <- function(x) (x - mean(x)) / sd(x)
  d <- z(w$isei_br) - z(w$isei08)
  resid <- stats::residuals(stats::lm(isei_br ~ isei08, data = w))

  expect_identical(head(w$rotulo[order(-d)], 6), head(w$rotulo[order(-resid)], 6))
  expect_setequal(head(w$rotulo[order(d)], 6), head(w$rotulo[order(resid)], 6))

  # e a identidade, para que ninguem volte a ler o residual como "artefato que sobrou"
  r <- stats::cor(w$isei_br, w$isei08)
  expect_equal(stats::cor(d, w$isei08), -sqrt((1 - r) / 2), tolerance = 1e-12)
})
