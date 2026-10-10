# A familia `*_prestigio()` e o nome preferido; `*_siops()` sao alias
# depreciados que nunca foram removidos. O risco desta dupla nomeacao nao e
# teorico: METADE das funcoes de prestigio nao delega ao alias, e sim repete a
# chamada a `.busca()` com os mesmos argumentos. Quem corrigir um lado e
# esquecer o outro produz duas portas para a mesma medida devolvendo coisas
# diferentes, sem erro e sem aviso.
#
# Este arquivo trava a equivalencia par a par. Ele existe porque a suite nao
# exercitava `R/prestigio.R` em nenhuma linha (cobertura 0%), embora as oito
# funcoes estejam exportadas e o prestigio seja uma das quatro medidas que o
# pacote anuncia.

CODS <- c("111", "169", "257", "601", "131", "291", "215", "999")

test_that("prestigio e siops sao a mesma medida em toda porta", {
  expect_identical(tse_para_prestigio(CODS),      tse_para_siops(CODS))
  expect_identical(tse_para_prestigio08(CODS),    tse_para_siops08(CODS))
  expect_identical(isco88_para_prestigio("2221"), isco88_para_siops("2221"))
  expect_identical(cbo2002_para_prestigio("225120"),   cbo2002_para_siops("225120"))
  expect_identical(cbo2002_para_prestigio08("225120"), cbo2002_para_siops08("225120"))
  expect_identical(cbo94_para_prestigio("2-11.20"),    cbo94_para_siops("2-11.20"))
})

test_that("a equivalencia vale sobre o dicionario inteiro, e nao so na amostra", {
  todos <- tse_isco$cod_tse
  expect_identical(tse_para_prestigio(todos),   tse_para_siops(todos))
  expect_identical(tse_para_prestigio08(todos), tse_para_siops08(todos))
})

test_that("o argumento ano atravessa ate o prestigio", {
  # O 215 e reutilizado: ate 2000 designa cargo de direcao, depois artista
  # plastico. Se `ano` nao chegasse a `.busca()`, os dois anos dariam o mesmo
  # escore -- que e o modo silencioso de errar uma serie.
  a <- suppressWarnings(tse_para_prestigio("215", ano = 2000))
  b <- tse_para_prestigio("215", ano = 2020)
  expect_true(is.na(a))
  expect_false(is.na(b))
  expect_identical(a, suppressWarnings(tse_para_siops("215", ano = 2000)))
  expect_identical(b, tse_para_siops("215", ano = 2020))
})

test_that("o escore devolvido e mesmo o de Treiman, e nao o ISEI", {
  # Ancora externa: o valor tem de sair de `isco88_medidas$siops88`, e nao da
  # coluna vizinha. Um erro de coluna em `.busca()` passaria por todos os
  # testes de equivalencia acima, porque atingiria as duas portas ao mesmo tempo.
  med <- isco88_medidas[isco88_medidas$isco88 == "2221", ]
  expect_equal(isco88_para_prestigio("2221"), med$siops88)
  expect_equal(tse_para_prestigio("111"), med$siops88)   # 111 = MEDICO -> 2221
  expect_false(isTRUE(all.equal(tse_para_prestigio("111"), tse_para_isei("111"))))
})

test_that("codigo desconhecido devolve NA com aviso, e o comprimento se preserva", {
  expect_warning(r <- tse_para_prestigio(c("111", "99999")),
                 class = "ocupacoesBR_codigo_ausente")
  expect_length(r, 2L)
  expect_false(is.na(r[1]))
  expect_true(is.na(r[2]))
  expect_length(tse_para_prestigio(character(0)), 0L)
  expect_true(is.na(tse_para_prestigio(NA_character_)))
})

test_that("as portas da COD tambem entregam prestigio", {
  cods <- utils::head(cod_isco08$cod, 20)
  expect_length(cod_para_prestigio(cods), length(cods))
  expect_length(cod_para_prestigio08(cods), length(cods))
  expect_true(any(!is.na(cod_para_prestigio08(cods))))
})

test_that("prestigio e siops tem a MESMA assinatura, porta a porta", {
  # Este teste existe por causa de um defeito real. A versao 0.2.0 acrescentou
  # `ano` as portas da ISCO-08 e passou por `tse_para_siops08()` sem passar por
  # `tse_para_prestigio08()`, que e o nome preferido. Durante duas versoes o
  # alias depreciado mascarava vigencia e o nome recomendado nao — quem montasse
  # serie pela porta certa recebia o escore do cadastro errado nos codigos
  # reutilizados em 2002, sem aviso. Assinatura divergente entre dois nomes da
  # mesma medida e sempre um desses defeitos esperando para acontecer.
  pares <- list(
    c("tse_para_prestigio",       "tse_para_siops"),
    c("tse_para_prestigio08",     "tse_para_siops08"),
    c("isco88_para_prestigio",    "isco88_para_siops"),
    c("cbo2002_para_prestigio",   "cbo2002_para_siops"),
    c("cbo2002_para_prestigio08", "cbo2002_para_siops08"),
    c("cbo94_para_prestigio",     "cbo94_para_siops"))
  for (p in pares) {
    a <- names(formals(get(p[1], envir = asNamespace("ocupacoesBR"))))
    b <- names(formals(get(p[2], envir = asNamespace("ocupacoesBR"))))
    expect_identical(a, b, info = paste(p, collapse = " vs "))
  }
})

test_that("o ano atravessa tambem a porta da ISCO-08", {
  # o que o defeito de 0.2.0 deixava passar
  expect_true(is.na(suppressWarnings(tse_para_prestigio08("215", ano = 2000))))
  expect_false(is.na(tse_para_prestigio08("215", ano = 2020)))
  expect_identical(suppressWarnings(tse_para_prestigio08("215", ano = 2000)),
                   suppressWarnings(tse_para_siops08("215", ano = 2000)))
  expect_warning(tse_para_prestigio08("215", ano = 2000),
                 class = "ocupacoesBR_fora_de_vigencia")
})

test_that("a familia da CBO-2002 aceita empate e escada de ponta a ponta", {
  # `cbo2002_para_isei()` e `cbo2002_para_siops()` nao tinham os dois
  # argumentos que as demais portas da mesma familia ja tinham; um usuario que
  # ligasse a escada para o ISCO e a perdesse no ISEI teria duas colunas
  # calculadas sobre universos distintos, sem sinal de erro.
  fam <- c("cbo2002_para_isco", "cbo2002_para_isei", "cbo2002_para_isei08",
           "cbo2002_para_siops", "cbo2002_para_siops08",
           "cbo2002_para_prestigio", "cbo2002_para_prestigio08")
  for (f in fam) {
    arg <- names(formals(get(f, envir = asNamespace("ocupacoesBR"))))
    expect_true(all(c("empate", "escada") %in% arg), info = f)
  }
  prefixos <- utils::head(cbo2002_escada$prefixo[cbo2002_escada$nivel == 4], 20)
  fora <- paste0(prefixos, "99")
  fora <- fora[!fora %in% cbo2002_isco88$cbo2002]
  expect_true(all(is.na(suppressWarnings(cbo2002_para_isei(fora)))))
  expect_true(all(!is.na(suppressWarnings(cbo2002_para_isei(fora, escada = TRUE)))))
  expect_identical(suppressWarnings(cbo2002_para_siops(fora, escada = TRUE)),
                   suppressWarnings(cbo2002_para_prestigio(fora, escada = TRUE)))
})
