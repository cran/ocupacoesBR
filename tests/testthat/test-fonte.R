# Testes que amarram as tabelas do pacote às suas FONTES.
# Se alguém editar um valor à mão, é aqui que quebra.
#
# As fontes ficam em inst/extdata/fontes/ e VIAJAM com o pacote instalado —
# antes moravam em data-raw/, que o .Rbuildignore exclui do tarball, e por isso
# estes testes eram pulados justamente no `R CMD check`, que é o único lugar
# onde a garantia importa. Nada de `skip_if_not(file.exists(...))` aqui: um
# teste de proveniência que sabe pular é um teste que não existe.

fonte_sps <- function(nome) {
  p <- system.file("extdata", "fontes", "ganzeboom", nome,
                   package = "ocupacoesBR")
  expect_true(nzchar(p) && file.exists(p),
              info = paste("fonte ausente do pacote instalado:", nome))
  p
}

test_that("a tabela ISEI-88 bate com a sintaxe original de Ganzeboom", {
  l <- readLines(fonte_sps("iskoisei.sps"), warn = FALSE)
  m <- regmatches(l, regexec(
    "^\\s*recode\\s+@isko\\s*\\(\\s*([0-9]+)\\s*=\\s*([0-9.]+)\\s*\\)", l))
  ok <- lengths(m) == 3
  fonte <- data.frame(
    isco88 = sprintf("%04d", as.integer(sapply(m[ok], `[`, 2))),
    isei   = as.numeric(sapply(m[ok], `[`, 3)))
  fonte <- fonte[!duplicated(fonte$isco88), ]
  expect_gt(nrow(fonte), 500)
  i <- match(fonte$isco88, isco88_medidas$isco88)
  expect_false(any(is.na(i)))
  expect_equal(isco88_medidas$isei88[i], fonte$isei)
})

test_that("a ponte 88->08 bate com a sintaxe original, e trunca o decimal", {
  l <- readLines(fonte_sps("isco8808.sps"), warn = FALSE)
  m <- regmatches(l, regexec(
    "^\\s*recode\\s+@isko\\s*\\(\\s*([0-9]+)\\s*=\\s*([0-9]+)(?:\\.([0-9]+))?\\s*\\)", l))
  ok <- lengths(m) >= 3
  fonte <- data.frame(
    isco88 = sprintf("%04d", as.integer(sapply(m[ok], `[`, 2))),
    isco08 = sprintf("%04d", as.integer(sapply(m[ok], `[`, 3))),
    stringsAsFactors = FALSE)
  fonte <- fonte[!duplicated(fonte$isco88), ]
  expect_gt(nrow(fonte), 400)
  i <- match(fonte$isco88, isco88_isco08$isco88)
  expect_false(any(is.na(i)))
  expect_equal(isco88_isco08$isco08[i], fonte$isco08)
})

test_that("a ambiguidade da OIT foi preservada, nao descartada", {
  expect_true(any(isco88_isco08$n_alternativas > 1))
  expect_true(all(isco88_isco08$n_alternativas >= 1))
})

test_that("as fontes ainda sao as que geraram os dados (sha256)", {
  # Um pacote que gera tudo por script depende de as fontes nao mudarem por
  # baixo. Sem este teste, o MTE republicar a tabua ou alguem editar um .sps a
  # mao muda resultado de artigo publicado sem sinal nenhum.
  yml <- system.file("extdata", "PROVENIENCIA.yml", package = "ocupacoesBR")
  expect_true(nzchar(yml) && file.exists(yml))
  l <- readLines(yml, warn = FALSE, encoding = "UTF-8")
  campo <- function(chave) {
    pad <- sprintf("^\\s*(-\\s*)?%s:\\s*", chave)
    trimws(sub(pad, "", grep(pad, l, value = TRUE)))
  }
  arq <- campo("arquivo"); sha <- campo("sha256")
  expect_gt(length(arq), 15)
  expect_equal(length(arq), length(sha))
  base <- system.file("extdata", "fontes", package = "ocupacoesBR")
  atual <- vapply(file.path(base, arq), function(p)
    if (file.exists(p)) as.character(tools::sha256sum(p)) else NA_character_,
    character(1), USE.NAMES = FALSE)
  expect_false(any(is.na(atual)), info = "fonte declarada e ausente do pacote")
  expect_equal(atual, sha)
})

test_that("a medida se sustenta contra um criterio EXTERNO a ela", {
  # I9: o unico invariante que amarra o pacote a algo de fora dele mesmo.
  # Patrimonio e escolaridade nao entram na construcao do ISEI em momento
  # nenhum — se estas correlacoes desabarem, e a medida que quebrou, e nao o
  # teste.
  v <- tse_validacao
  isei <- isco88_para_isei(tse_isco$isco88[match(v$cod_tse, tse_isco$cod_tse)])
  # DOIS crivos: a escolaridade esta medida em toda linha do conjunto; a mediana
  # de patrimonio, so onde houve declaracoes de bens bastantes (ver
  # ?tse_validacao, secao sobre o piso). Um crivo so devolvia NA aqui.
  ok_esc <- !is.na(isei)
  ok_pat <- ok_esc & !is.na(v$mediana_patrimonio)
  expect_gt(sum(ok_esc), 150L)
  expect_gt(sum(ok_pat), 150L)
  expect_gt(cor(isei[ok_esc], v$pct_superior[ok_esc]), 0.70)
  expect_gt(cor(isei[ok_pat], log(v$mediana_patrimonio[ok_pat])), 0.60)
  expect_gt(cor(isei[ok_esc], v$pct_superior[ok_esc], method = "spearman"), 0.75)
  # a mediana e NA exatamente onde o piso de declaracoes nao foi atingido
  expect_identical(is.na(v$mediana_patrimonio), v$n_com_bens < 200L)
})

test_that("a dispersao individual reproduz o 0,207 sem microdado", {
  # A tabela publica somatorios justamente para que este numero — o unico do
  # artigo que dependia da microbase — seja recalculavel por quem so instalou
  # o pacote. Se a identidade abaixo falhar, a tabela deixou de servir ao que
  # existe para servir.
  d <- tse_dispersao_patrimonio
  expect_true(all(d$n > 0))
  expect_gt(sum(d$n), 1e6)
  expect_false(is.unsorted(d$isei88))
  N <- sum(d$n); sx <- sum(d$isei88 * d$n); sy <- sum(d$soma_log)
  sxx <- sum(d$isei88^2 * d$n); syy <- sum(d$soma_log2)
  sxy <- sum(d$isei88 * d$soma_log)
  r <- (N * sxy - sx * sy) / sqrt((N * sxx - sx^2) * (N * syy - sy^2))
  expect_equal(round(r, 3), 0.207)
  # os somatorios tem de ser consistentes com as colunas de conveniencia
  expect_equal(d$media_log, round(d$soma_log / d$n, 4))
  # o contraste com o nivel da ocupacao e o resultado, e e grande
  v <- tse_validacao
  v$isei <- tse_para_isei(v$cod_tse)
  b <- v[!is.na(v$isei) & !is.na(v$mediana_patrimonio), ]
  expect_gt(cor(b$isei, log(b$mediana_patrimonio)) - r, 0.4)
  # dispersao DENTRO do nivel de status: uma ordem de grandeza, nao ruido
  expect_gt(stats::median(d$sd_log), 1)
})

test_that("a regressao de genero de ?tse_para_isei reproduz a partir do dado publicado", {
  # Ate 29/07/2026 nao reproduzia: o piso de declaracoes de bens descartava a
  # linha inteira e amputava ocupacoes com escolaridade e genero medidos,
  # deixando 157 codigos onde a ajuda afirmava 170. Este teste trava a correcao.
  # Em 05/09/2026 o total caiu de 170 para 168, porque `tse_validacao` passou a
  # respeitar a vigencia dos codigos reutilizados: um saiu do conjunto e outros
  # perderam as candidaturas da ocupacao ANTERIOR, que nunca deveriam contar.
  v <- tse_validacao
  v$isei <- tse_para_isei(v$cod_tse)
  w <- v[!is.na(v$isei) & v$n > 500, ]
  w$fem <- w$pct_mulher > 50
  expect_equal(nrow(w), 168L)
  expect_equal(sum(w$fem), 28L)
  co <- summary(stats::lm(isei ~ pct_superior + fem, data = w, weights = w$n))$coefficients
  expect_equal(unname(co["femTRUE", "Estimate"]), -6.17, tolerance = 0.01)
  expect_lt(co["femTRUE", "Pr(>|t|)"], 0.05)
  # o achado substantivo: mais credencial e menos status
  expect_gt(mean(w$pct_superior[w$fem]), mean(w$pct_superior[!w$fem]))
  expect_lt(mean(w$isei[w$fem]), mean(w$isei[!w$fem]))
})

test_that("o carregamento retrospectivo so olha para tras", {
  d <- data.frame(p = c("A", "A", "A"), t = c(1, 2, 3), v = c(NA, 50, NA))
  r <- isei_retrospectivo(d$v, d$p, d$t)
  expect_true(is.na(r$escore[1]))     # nao herda do FUTURO
  expect_equal(r$escore[3], 50)       # herda do passado
  expect_equal(r$defasagem[3], 1)
  expect_true(r$herdado[3] && !r$herdado[2])
  # nao atravessa a fronteira da pessoa
  d2 <- data.frame(p = c("A", "B"), t = c(1, 2), v = c(70, NA))
  expect_true(is.na(isei_retrospectivo(d2$v, d2$p, d2$t)$escore[2]))
  # `excluir` bloqueia o carregamento onde ele nao e defensavel
  d3 <- data.frame(p = c("A", "A"), t = c(1, 2), v = c(70, NA), c = c("101", "931"))
  expect_true(is.na(isei_retrospectivo(d3$v, d3$p, d3$t, d3$c, excluir = "931")$escore[2]))
  expect_equal(isei_retrospectivo(d3$v, d3$p, d3$t, d3$c)$escore[2], 70)
  # a ordem de entrada e preservada
  d4 <- data.frame(p = c("B", "A", "B", "A"), t = c(2, 2, 1, 1), v = c(NA, NA, 30, 60))
  expect_equal(isei_retrospectivo(d4$v, d4$p, d4$t)$escore, c(30, 60, 30, 60))
})
