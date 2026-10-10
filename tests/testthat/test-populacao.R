# Testes de `cod_populacao_br`: o denominador populacional.
# O risco desta tabela nao e a traducao — e o USUARIO ler uma proporcao sobre
# um universo que nao e o que ele pensa. Os testes travam as propriedades que
# tornam o universo declarado no proprio objeto.

test_that("cod_populacao_br e um universo: fecha em 100 por (piso, sexo)", {
  p <- ocupacoesBR::cod_populacao_br
  expect_true(all(c("piso", "sexo", "isco88", "situacao", "pop",
                    "n_pessoas", "pct") %in% names(p)))
  soma <- tapply(p$pct, list(p$piso, p$sexo), sum)
  expect_true(all(abs(soma - 100) < 0.02))
  expect_setequal(p$piso, c(18L, 21L, 30L, 35L))
  expect_setequal(p$sexo, c("Homem", "Mulher", "Todos"))
  expect_setequal(p$situacao, c("Ocupado", "Não ocupado",
                                "Ocupado sem endereço na ISCO-88"))
})

test_that("a chave e unica e o isco88 so existe onde ha ocupacao", {
  p <- ocupacoesBR::cod_populacao_br
  expect_equal(anyDuplicated(p[, c("piso", "sexo", "isco88", "situacao")]), 0L)
  expect_true(all(is.na(p$isco88[p$situacao != "Ocupado"])))
  expect_true(all(!is.na(p$isco88[p$situacao == "Ocupado"])))
  expect_true(all(nchar(stats::na.omit(p$isco88)) == 4L))
  # todo codigo da tabela e traduzivel pelo pacote — se algum nao fosse, a
  # ponte reversa teria deixado passar lixo
  expect_true(all(stats::na.omit(p$isco88) %in%
                    ocupacoesBR::isco88_medidas$isco88))
})

test_that("os pisos sao pisos, e nao faixas", {
  p <- ocupacoesBR::cod_populacao_br
  t <- p[p$sexo == "Todos", ]
  pop <- tapply(t$pop, t$piso, sum)
  # populacao monotonicamente decrescente no piso: 18 >= 21 >= 30 >= 35.
  # Se alguem trocar piso por faixa etaria, isto quebra.
  expect_true(all(diff(pop[order(as.integer(names(pop)))]) < 0))
  # e a linha "Todos" e a soma dos dois sexos, dentro do arredondamento
  for (k in c(18L, 21L, 30L, 35L)) {
    tt <- sum(p$pop[p$piso == k & p$sexo == "Todos"])
    hm <- sum(p$pop[p$piso == k & p$sexo != "Todos"])
    expect_lt(abs(tt - hm) / tt, 1e-4)
  }
})

test_that("o que ?cod_populacao_br afirma sobre o denominador continua verdadeiro", {
  p <- ocupacoesBR::cod_populacao_br
  nao <- p[p$situacao == "Não ocupado", ]
  f <- function(pi, sx) nao$pct[nao$piso == pi & nao$sexo == sx]
  # medido em 08/09/2026, PNAD Continua 2025
  expect_gt(f(18, "Todos"), 35); expect_lt(f(18, "Todos"), 41)
  # o piso move o denominador, e a direcao e essa
  expect_gt(f(35, "Todos"), f(18, "Todos"))
  # e a diferenca entre os sexos e de mais de vinte pontos, em todo piso
  for (k in c(18L, 21L, 30L, 35L))
    expect_gt(f(k, "Mulher") - f(k, "Homem"), 20)
})

test_that("as duas fontes perdem quase a mesma gente, por motivos opostos", {
  p <- ocupacoesBR::cod_populacao_br
  o <- p[p$piso == 18 & p$sexo == "Todos", ]
  isei <- suppressWarnings(ocupacoesBR::isco88_para_isei(o$isco88))
  cob_pop <- sum(o$pct[!is.na(isei)])

  u <- ocupacoesBR::tse_universo
  cob_tse <- u$pct[u$ano == 2024 & u$sexo == "Todos" &
                     u$rubrica == "Com escore"]

  # o par que sustenta a decisao D5 do artigo `comparar-fontes`: 61,8% contra
  # 62,0%, quase iguais e por razoes que nao tem nada em comum. Se a distancia
  # entre os dois abrir, o argumento do artigo muda e o texto tem de mudar
  # junto — e para isso que este teste existe.
  expect_lt(abs(cob_pop - cob_tse), 3)
  expect_gt(cob_pop, 55); expect_lt(cob_pop, 68)
})

test_that("a celula fina existe e vem com a amostra a vista", {
  p <- ocupacoesBR::cod_populacao_br
  # o 5162 e o 5161 sao a razao de a tabela guardar quatro digitos: e onde
  # cod_para_isco() desfaz a adaptacao da COD, e onde os codigos 232, 233,
  # 258 e 145 do TSE aterrissam.
  pm <- p[p$isco88 %in% c("5161", "5162") & p$piso == 18 & p$sexo == "Todos", ]
  expect_equal(nrow(pm), 2L)
  expect_true(all(pm$n_pessoas > 100))
  # e o aviso da ajuda tem de continuar verdadeiro: ha celula fina, e por isso
  # `n_pessoas` nao pode sumir da tabela
  expect_gt(sum(p$n_pessoas < 30), 0)
  expect_true(all(p$n_pessoas > 0))
})
