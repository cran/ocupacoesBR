# A história do cadastro do TSE: vigências, rótulos e a quebra de 2002.

test_that("as vigências cobrem o dicionário inteiro e não se sobrepõem", {
  r <- tse_ocupacao_rotulos
  expect_equal(nrow(r), 334L)
  expect_setequal(unique(r$cod_tse), tse_isco$cod_tse)   # 275 códigos
  expect_true(all(r$de <= r$ate))
  expect_true(all(r$de >= 1998 & r$ate <= 2026))
  # dentro de um código, as vigências são disjuntas e ordenadas
  for (g in split(r, r$cod_tse))
    if (nrow(g) > 1) {
      g <- g[order(g$de), ]
      expect_true(all(g$de[-1] > g$ate[-nrow(g)]), info = g$cod_tse[1])
    }
})

test_that("a safra de 2026 entrou, e não trouxe código novo", {
  r <- tse_ocupacao_rotulos
  # A tabela vai até 2026. Se alguém regerar os dados apontando para uma base
  # que pare antes, este teste é quem avisa.
  expect_equal(max(r$ate), 2026L)
  expect_gt(sum(r$ate == 2026L), 200L)

  # O ACHADO da safra: 2026 não criou nenhum código de ocupação. É a afirmação
  # forte da versão 0.3.0, e ela vale exatamente enquanto este teste passar.
  # `tse_diff_cadastro` compara os cadastros vigentes em dois anos; se o TSE
  # tivesse inventado um código em 2026, ele apareceria como criado — e o
  # dicionário precisaria de curadoria, que é o que `checa_cobertura()` cobra.
  d <- tse_diff_cadastro(2024, 2026)
  expect_equal(sum(d$mudanca == "criado"), 0L)

  # Todo código observado em 2026 tem entrada no dicionário. Esta é a
  # invariante que sustenta usar o pacote na eleição em curso.
  cods_2026 <- unique(r$cod_tse[r$ate == 2026L])
  expect_true(all(cods_2026 %in% tse_isco$cod_tse))
  expect_true(suppressMessages(checa_cobertura(cods_2026)))
})

test_that("o código 215 é o caso que a heurística de escolaridade não vê", {
  # Foi este que motivou reconstruir a tabela: "OCUPANTE DE CARGO DE DIREÇÃO E
  # ASSESSORAMENTO SUPERIOR" até 2000, "ARTISTA PLÁSTICO" a partir de 2006, com
  # variação de escolaridade de ~1 pp. Se este teste cair, ou o dado do TSE
  # mudou, ou alguém trocou a curadoria de `tipo` por uma fórmula.
  v <- tse_vigencia(215)
  expect_equal(nrow(v), 2L)
  expect_match(v$rotulo[1], "ASSESSORAMENTO SUPERIOR")
  expect_match(v$rotulo[2], "ARTISTA PL")
  q <- tse_quebra_2002[tse_quebra_2002$cod_tse == "215", ]
  expect_equal(q$tipo, "reutilizado")
  # e o sinal de escolaridade, sozinho, NÃO o denunciaria
  expect_gt(q$delta_vs_tendencia, -20)
})

test_that("renome não é reutilização", {
  # 601 "TRABALHADOR AGRÍCOLA" -> "AGRICULTOR": mesmo ofício, 50 mil
  # candidaturas. Marcá-lo como reutilizado mandaria descartá-las.
  q <- tse_quebra_2002
  expect_equal(q$tipo[q$cod_tse == "601"], "renomeado")
  expect_gt(q$n_ate_2000[q$cod_tse == "601"], 40000)
  for (cod in c("601", "602", "604", "295"))
    expect_equal(q$tipo[q$cod_tse == cod], "renomeado", info = cod)
  # checa_periodo e o argumento `ano` só reagem a reutilização de verdade
  expect_silent(r <- checa_periodo(c("601", "601"), c(1998, 2020)))
  expect_false(any(r))
  expect_silent(tse_para_classe("601", ano = 1998))
})

test_that("os três códigos da versão anterior continuam marcados", {
  q <- tse_quebra_2002
  for (cod in c("211", "214", "216"))
    expect_true(cod %in% q$cod_tse, info = cod)
  # e agora há mais: quatro das sete reutilizações são invisíveis ao sinal
  # de escolaridade, que era o único método antes
  reut <- q[q$tipo == "reutilizado", ]
  expect_gte(nrow(reut), 7L)
  invisiveis <- sum(is.na(reut$delta_vs_tendencia) |
                    reut$delta_vs_tendencia > -40)
  expect_gte(invisiveis, 4L)
})

test_that("`ano` anula o que estava sob outra ocupação, e só isso", {
  expect_warning(x <- tse_para_classe(c("215", "215"), ano = c(2000, 2020)),
                 "REUTILIZOU")
  expect_true(is.na(x[1]))
  expect_false(is.na(x[2]))
  # sem `ano`, o comportamento antigo é preservado
  expect_silent(y <- tse_para_classe(c("215", "215")))
  expect_false(any(is.na(y)))
  # o mesmo vale para as demais portas
  expect_warning(tse_para_isco("215", ano = 2000), "REUTILIZOU")
  expect_warning(tse_para_estrato("215", ano = 2000), "REUTILIZOU")
  expect_error(tse_para_isco(c("111", "215"), ano = 2000), "comprimento")
  # e para a porta ancorada na ISCO-08, que agora tambem aceita `ano`
  expect_warning(z <- tse_para_isei08(c("215", "215"), ano = c(2000, 2020)),
                 "REUTILIZOU")
  expect_true(is.na(z[1]))
  expect_false(is.na(z[2]))
  expect_silent(w <- tse_para_isei08(c("215", "215")))
  expect_false(any(is.na(w)))
  expect_warning(tse_para_isco08("215", ano = 2000), "REUTILIZOU")
})

test_that("tse_diff_cadastro descreve a troca de inventário de 2002", {
  d <- tse_diff_cadastro(2000, 2002)
  expect_setequal(unique(d$mudanca), c("extinto", "criado", "rotulo"))
  expect_gt(sum(d$mudanca == "criado"), sum(d$mudanca == "extinto"))
  # todo extinto tem rótulo do ano 1 e nenhum do ano 2, e vice-versa
  ext <- d[d$mudanca == "extinto", ]
  expect_true(all(!is.na(ext$rotulo_ano1) & is.na(ext$rotulo_ano2)))
  cri <- d[d$mudanca == "criado", ]
  expect_true(all(is.na(cri$rotulo_ano1) & !is.na(cri$rotulo_ano2)))
  expect_error(tse_diff_cadastro(1990, 2002), "sem cadastro")
})

test_that("nenhum rótulo normalizado aponta para dois códigos", {
  # `tse_rotulo_para_cod(exato = TRUE)` usa `match()`, que devolve o PRIMEIRO
  # código com aquele rótulo. Isso só é correto enquanto rótulo normalizado e
  # código forem um-para-um; uma safra futura pode quebrar isso em silêncio.
  r <- tse_ocupacao_rotulos
  chave <- .norm_rotulo(r$rotulo)
  por_rotulo <- tapply(r$cod_tse, chave, function(x) length(unique(x)))
  colide <- names(por_rotulo)[por_rotulo > 1]
  expect_length(colide, 0)
})

test_that("o rótulo entra no crosswalk e volta ao código", {
  cw <- crosswalk_tse()
  expect_true("rotulo" %in% names(cw))
  expect_false(any(is.na(cw$rotulo)))          # todas as 275 linhas
  expect_equal(cw$rotulo[cw$cod_tse == "169"], "COMERCIANTE")
  # ida e volta
  r <- tse_rotulo_para_cod("Comerciante")
  expect_equal(r$cod_tse, "169")
  expect_gt(nrow(tse_rotulo_para_cod("advogado", exato = FALSE)), 0L)
  expect_true(is.na(tse_rotulo_para_cod("ocupação que não existe")$cod_tse))
})

test_that("tse_para_rotulo respeita o ano", {
  expect_match(tse_para_rotulo(215, 2000), "ASSESSORAMENTO")
  expect_match(tse_para_rotulo(215, 2020), "ARTISTA")
  expect_match(tse_para_rotulo(215), "ARTISTA")       # sem ano: o mais recente
  expect_true(is.na(tse_para_rotulo(215, 2004)))      # fora de vigência
})

test_that("nenhum codigo reutilizado reaparece em 2002, e a vigencia concorda com a quebra", {
  # A prosa do site dizia, em tres paginas, que o 214 "a partir de 2002 e
  # escultor". Nao e: o cadastro foi reeditado em 2002, mas os sete reutilizados
  # so reaparecem com o rotulo novo em 2004, 2006 ou 2008 — e e esse ano, e nao
  # 2002, que o corte `ano < primeiro_ano_novo` usa. Uma candidatura de 2004 com
  # o codigo 214 tem de voltar NA.
  q <- tse_quebra_2002[tse_quebra_2002$tipo == "reutilizado", ]
  expect_gt(nrow(q), 0)
  expect_false(any(q$primeiro_ano_novo == 2002))
  expect_true(all(q$primeiro_ano_novo > 2002))

  # a vigencia e a quebra tem de contar a mesma historia
  for (k in q$cod_tse) {
    v <- tse_vigencia(k)
    expect_equal(v$de[nrow(v)],
                 q$primeiro_ano_novo[q$cod_tse == k],
                 info = k)
  }

  # e o corte de fato anula o ano intermediario
  expect_true(is.na(suppressWarnings(tse_para_isei("214", ano = 2004L))))
  expect_false(is.na(suppressWarnings(tse_para_isei("214", ano = 2026L))))
})
