# Numeros digitados na ajuda envelhecem calados.
#
# O pacote tem a regra de nao publicar valor que nao tenha saido de execucao
# propria, e ela ja pegou varios erros. O que ela nao cobre e o DEPOIS: um numero
# correto no dia em que foi escrito continua na pagina de ajuda quando a tabela
# de onde ele saiu muda. Foi assim que "80 vezes (p90/p10) entre os que declaram
# empresario" sobreviveu a correcao do patrimonio dobrado de 09/2026 — a
# agregacao antiga somava cada bem duas vezes, o valor certo e 76, e nada
# reprovava.
#
# Estes testes recomputam da tabela e conferem contra o texto da ajuda. Nao
# travam o valor: travam a IDENTIDADE entre o que a ajuda diz e o que o dado
# produz. Se a tabela mudar de novo, aqui reprova, e e para reprovar.

texto_rd <- function(nome) {
  f <- testthat::test_path("..", "..", "man", paste0(nome, ".Rd"))
  if (file.exists(f)) {
    return(paste(readLines(f, warn = FALSE, encoding = "UTF-8"), collapse = " "))
  }
  # no `R CMD check` o pacote esta instalado e a fonte nao acompanha
  db <- tools::Rd_db("ocupacoesBR")
  chave <- paste0(nome, ".Rd")
  expect_true(chave %in% names(db),
              info = paste("pagina de ajuda ausente:", nome))
  paste(utils::capture.output(tools::Rd2txt(db[[chave]])), collapse = " ")
}

# vírgula decimal, como o texto em português escreve
num_br <- function(x, casas = 0) {
  formatC(round(x, casas), format = "f", digits = casas, decimal.mark = ",")
}

test_that("a dispersao por autorrotulo na ajuda e a que a tabela produz", {
  a <- tse_autorrotulo_patrimonio
  a <- a[a$cargo == "TODOS", ]
  razao <- function(cod) {
    l <- a[a$cod_tse == cod, ]
    expect_equal(nrow(l), 1L, info = cod)
    l$p90 / l$p10
  }
  emp <- razao("257"); com <- razao("169"); adv <- razao("131")

  # o argumento da ajuda depende desta ordem: o comerciante, que e autorrotulo,
  # fica ENTRE o advogado (ancorado) e o empresario. Se a ordem inverter, o
  # paragrafo passa a afirmar o contrario do que o dado mostra.
  expect_lt(adv, com)
  expect_lt(com, emp)

  txt <- texto_rd("tse_codigos_autorrotulo")
  expect_match(txt, paste0(num_br(emp), " vezes"), fixed = TRUE)
  expect_match(txt, paste0("de ", num_br(com), "\n?"), fixed = FALSE)
  expect_match(txt, paste0("de ", num_br(adv), " entre os advogados"), fixed = TRUE)

  # e o 131 nao pode entrar na lista de autorrotulos sem que o texto mude
  expect_false("131" %in% tse_codigos_autorrotulo)
  expect_true(all(c("169", "257") %in% tse_codigos_autorrotulo))
})

test_that("os quantis do 257 na ajuda sao os da tabela", {
  a <- tse_autorrotulo_patrimonio
  l <- a[a$cargo == "TODOS" & a$cod_tse == "257", ]
  txt <- texto_rd("tse_para_componente_alta")
  expect_match(txt, paste0(num_br(l$p90 / l$p10), " vezes"), fixed = TRUE)
})

test_that("a regressao de genero citada em ?tse_para_isei e a que roda", {
  v <- tse_validacao
  v$isei <- tse_para_isei(v$cod_tse)
  w <- v[!is.na(v$isei) & v$n > 500, ]
  w$fem <- w$pct_mulher > 50
  co <- summary(stats::lm(isei ~ pct_superior + fem, data = w,
                          weights = w$n))$coefficients

  txt <- texto_rd("tse_para_isei")
  expect_match(txt, paste0(nrow(w), " "), fixed = TRUE)
  expect_match(txt, num_br(abs(co["femTRUE", "Estimate"]), 2), fixed = TRUE)
  expect_match(txt, num_br(mean(w$isei[w$fem]), 1), fixed = TRUE)
  expect_match(txt, num_br(mean(w$isei[!w$fem]), 1), fixed = TRUE)
})

test_that("a parcela mediada citada em ?isco08_isei_br e a do atributo", {
  pm <- attr(isco08_isei_br, "parcela_mediada")
  expect_true(is.numeric(pm) && length(pm) == 1)
  txt <- texto_rd("isco08_isei_br")
  expect_match(txt, num_br(pm, 1), fixed = TRUE)
})

test_that("os numeros de ?cod_populacao_br saem da propria tabela", {
  p <- cod_populacao_br
  txt <- texto_rd("cod_populacao_br")

  # a tabela de nao ocupados por piso e sexo, celula a celula
  nao <- p[p$situacao == "Não ocupado", ]
  for (k in c(18L, 21L, 30L, 35L))
    for (s in c("Homem", "Mulher", "Todos"))
      expect_match(txt, num_br(nao$pct[nao$piso == k & nao$sexo == s], 1),
                   fixed = TRUE)

  # a cobertura do ISEI sobre a populacao de 18+, que e o par que o artigo usa
  o <- p[p$piso == 18 & p$sexo == "Todos", ]
  cob <- sum(o$pct[!is.na(suppressWarnings(isco88_para_isei(o$isco88)))])
  expect_match(txt, num_br(cob, 1), fixed = TRUE)

  # e o outro lado do par, que vem da OUTRA tabela: se as duas se afastarem, a
  # afirmacao de que "as duas fontes perdem quase a mesma gente" morre, e o
  # artigo `comparar-fontes` inteiro se apoia nela
  u <- tse_universo
  cob_tse <- u$pct[u$ano == 2024 & u$sexo == "Todos" & u$rubrica == "Com escore"]
  expect_match(txt, num_br(cob_tse, 1), fixed = TRUE)

  # o numero de celulas finas, que a ajuda usa como aviso
  expect_match(txt, paste0(sum(p$n_pessoas < 30), " das"), fixed = TRUE)
})

test_that("os numeros de ?isco_posicao_br se reconstroem das tabelas publicadas", {
  # Estes valores foram apurados no microdado da PNAD Continua, que nao viaja
  # com o pacote. A reconstrucao usa `cod_populacao_br` como peso populacional
  # por endereco da ISCO — e por isso NAO reproduz exatamente: o script 07 mede
  # todos os ocupados e `cod_populacao_br` corta em 18 anos. A tolerancia de
  # um ponto e o tamanho desse corte, e nao folga arbitraria.
  i <- isco_posicao_br
  p <- cod_populacao_br[cod_populacao_br$piso == 18 &
                          cod_populacao_br$sexo == "Todos" &
                          cod_populacao_br$situacao == "Ocupado", ]
  p$pub <- i$pct_setor_publico[match(p$isco88, i$isco88)]
  p$mil <- i$pct_militar[match(p$isco88, i$isco88)]
  expect_false(anyNA(p$pub))          # as duas tabelas cobrem a mesma chave
  p$g <- substr(p$isco88, 1, 1)

  txt <- texto_rd("isco_posicao_br")

  # o setor publico como % dos ocupados, e a sua distribuicao pelo grande grupo
  pub <- p$pop * p$pub / 100
  expect_match(txt, num_br(100 * sum(pub) / sum(p$pop), 1), fixed = TRUE)
  dist <- 100 * tapply(pub, p$g, sum) / sum(pub)
  expect_lt(abs(dist[["2"]] - 37.9), 1)   # o valor que a tabela da ajuda traz
  expect_identical(names(which.max(dist)), "2")   # e o digito 2 continua o maior

  # a discordancia entre a pergunta de posicao e a de ocupacao: se ela sumir,
  # a secao "Militar e duas coisas" deixa de ter objeto
  mil <- p$pop * p$mil / 100
  dm <- 100 * tapply(mil, p$g, sum) / sum(mil)
  expect_match(txt, num_br(dm[["0"]], 1), fixed = TRUE)
  expect_match(txt, num_br(dm[["5"]], 1), fixed = TRUE)
  expect_gt(dm[["5"]], dm[["0"]])
})
