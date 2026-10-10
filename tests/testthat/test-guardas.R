# As guardas do pacote — os pontos em que ele decide FALHAR em vez de devolver
# um resultado plausivel e errado. Sao a promessa central do README ("falha com
# erro, em voz alta"), e ate 17/08/2026 boa parte delas nunca era executada pela
# suite: uma guarda sem teste e uma guarda que pode ter parado de disparar.
#
# Inclui tambem o caminho rapido do EGP, que nao e guarda mas corre o mesmo
# risco: e uma otimizacao que promete resultado `identical()` ao caminho lento,
# e uma promessa dessas so vale enquanto alguem a verifica.

test_that("passar a tabela em vez da coluna falha com a instrucao do conserto", {
  d <- data.frame(cod = c("111", "169"), stringsAsFactors = FALSE)
  expect_error(tse_para_isco(d), "vetor atômico")
  expect_error(tse_para_isco(d), "dados\\$cod")          # diz COMO consertar
  expect_error(isco88_para_isei(d), "vetor atômico")
  expect_error(cod_para_isco(d), "vetor atômico")
  expect_error(isei_retrospectivo(d, 1, 1), "vetor atômico")
  # lista tambem, que e o caso do `lapply()` esquecido
  expect_error(tse_para_isco(list("111", "169")), "vetor atômico")
})

test_that("ISCO malformado erra, e ISCO curto ambiguo avisa", {
  expect_error(isco88_para_isei("22A1"), "ISCO inválido")
  expect_error(isco88_para_isei("12345"), "ISCO inválido")
  # "110" lido como grupo hierarquico 1100; "0110" (forcas armadas) tambem
  # existe nas tabelas, e por isso a leitura curta e ambigua e tem de avisar
  expect_warning(isco88_para_isei("110"), class = "ocupacoesBR_isco_ambiguo")
  # zeros a esquerda excedentes de campo de largura fixa sao tolerados
  expect_identical(isco88_para_isei("02221"), isco88_para_isei("2221"))
})

test_that("as tres checagens de cobertura falam quando nao silenciadas", {
  expect_message(checa_cobertura("111"), "cobertura ok")
  expect_message(checa_cobertura_cbo2002("225120"), "cobertura CBO-2002")
  expect_message(checa_cobertura_cod("2211"), "cobertura COD")
  expect_silent(checa_cobertura("111", silencioso = TRUE))
  expect_silent(checa_cobertura_cbo2002("225120", silencioso = TRUE))
  expect_silent(checa_cobertura_cod("2211", silencioso = TRUE))
  # as duas recusas da COD: forma errada e codigo inexistente, cada uma com a
  # sua mensagem — a segunda ensina o erro mais provavel do usuario
  expect_error(checa_cobertura_cod("22"), "4 digitos")
  expect_error(checa_cobertura_cod("9999"), "grupo de ")
})

test_that("o EGP recusa factor em n_supervisionados, e diz por que", {
  # as.numeric(factor(c("0","5","20"))) devolve 1 3 2: os indices dos niveis.
  # Aceitar isso calado poria a tabela de classe inteira errada.
  expect_error(isco88_para_egp("2221", n_supervisionados = factor(c("5")),
                               avisar = FALSE), "factor")
  expect_error(isco88_para_egp("2221", n_supervisionados = factor(c("5")),
                               avisar = FALSE), "as.numeric\\(as.character")
  expect_error(isco88_para_egp("2221", n_supervisionados = as.Date("2026-01-01"),
                               avisar = FALSE), "numérico")
})

test_that("o EGP exige comprimentos casados e avisa supervisao nao numerica", {
  expect_error(isco88_para_egp(c("2221", "9330"), conta_propria = TRUE,
                               avisar = FALSE),
               "comprimento")
  expect_error(isco88_para_egp(c("2221", "9330"),
                               n_supervisionados = c(1, 2, 3), avisar = FALSE),
               "comprimento")
  expect_warning(isco88_para_egp("1210", n_supervisionados = "muitos",
                                 avisar = FALSE),
                 class = "ocupacoesBR_supervisao_invalida")
})

test_that("o caminho rapido do EGP devolve o mesmo que o caminho lento", {
  # A otimizacao so liga acima de 512 elementos E com poucas combinacoes
  # distintas. Montamos os dois regimes e exigimos identidade com o resultado
  # obtido elemento a elemento, que e o que a otimizacao substitui.
  set.seed(1)
  base <- c("2221", "9330", "1210", "7412", "5122", "6111")
  isco <- rep(base, length.out = 3000)
  cp   <- rep(c(TRUE, FALSE), length.out = 3000)
  ns   <- rep(c(0L, 3L, 40L), length.out = 3000)

  rapido <- isco88_para_egp(isco, cp, ns, avisar = FALSE)
  lento  <- vapply(seq_along(isco), function(j)
    isco88_para_egp(isco[j], cp[j], ns[j], avisar = FALSE), character(1))
  expect_identical(rapido, lento)
  expect_length(rapido, 3000L)

  # e sem os argumentos opcionais, que percorre outro ramo da chave
  expect_identical(isco88_para_egp(isco, avisar = FALSE),
                   rep(isco88_para_egp(base, avisar = FALSE), length.out = 3000))
})

test_that("a escada da CBO-2002 sobe de nivel e so entao encontra endereco", {
  # A escada nao aparece em `crosswalk_cbo2002()`: aquela tabela so contem
  # codigos que ja casam direto, e por isso `nivel_usado` e 6 em todas as
  # linhas. Ela serve ao caso real da RAIS — um codigo de seis digitos que a
  # tabua nao lista, mas cujo subgrupo lista. Testar na tabela seria testar
  # o ramo que nunca dispara.
  prefixos <- utils::head(cbo2002_escada$prefixo[cbo2002_escada$nivel == 4], 40)
  fora <- paste0(prefixos, "99")
  fora <- fora[!fora %in% cbo2002_isco88$cbo2002]
  expect_gt(length(fora), 10L)

  sem <- suppressWarnings(cbo2002_para_isco(fora, escada = FALSE))
  com <- suppressWarnings(cbo2002_para_isco(fora, escada = TRUE))
  expect_true(all(is.na(sem)))          # sem escada, nada casa
  expect_true(all(!is.na(com)))         # com escada, tudo casa
  expect_true(all(nchar(com) == 4L))

  # a escada nunca PERDE traducao: e monotona em relacao ao modo desligado
  k <- c(utils::head(cbo2002_isco88$cbo2002, 200), fora)
  expect_gte(sum(!is.na(suppressWarnings(cbo2002_para_isco(k, escada = TRUE)))),
             sum(!is.na(suppressWarnings(cbo2002_para_isco(k, escada = FALSE)))))
  # e nao altera quem ja casava exato
  ok <- utils::head(cbo2002_isco88$cbo2002, 200)
  expect_identical(cbo2002_para_isco(ok, escada = TRUE),
                   cbo2002_para_isco(ok, escada = FALSE))

  # a medida atravessa a escada junto com o codigo
  expect_true(all(!is.na(suppressWarnings(cbo2002_para_isei(fora, escada = TRUE)))))
})

test_that("as portas de rotulo cobrem os ramos sem argumento e por texto", {
  expect_identical(tse_vigencia(), tse_ocupacao_rotulos)   # NULL = tabela inteira
  expect_error(tse_para_rotulo(c("111", "169"), ano = 2020),
               "mesmo comprimento")
  # busca por texto: exata e por correspondencia parcial
  exata <- tse_rotulo_para_cod("MEDICO", exato = TRUE)
  expect_s3_class(exata, "data.frame")
  parcial <- tse_rotulo_para_cod("PROFESSOR", exato = FALSE)
  expect_gt(nrow(parcial), 1L)
  expect_true(all(grepl("PROFESSOR", toupper(parcial$rotulo_tse))))
})

test_that("isei_retrospectivo recusa vetores de comprimentos distintos", {
  expect_error(isei_retrospectivo(c(1, 2), id = 1, tempo = c(1, 2)),
               "mesmo comprimento")
  expect_error(isei_retrospectivo(c(1, 2), id = c(1, 2), tempo = 1),
               "mesmo comprimento")
  expect_error(isei_retrospectivo(c(1, 2), id = c(1, 2), tempo = c(1, 2),
                                  cod = "111"),
               "mesmo comprimento")
})

test_that("codigo invalido no meio de codigos validos avisa e vira NA", {
  # `.trata_invalidos()` tem dois regimes e so o duro estava testado: quando
  # TUDO e invalido, erra; quando parte e invalida, avisa e devolve NA so
  # naquelas posicoes. O segundo e o caso real de dado administrativo sujo, e
  # e o que precisa preservar o comprimento do vetor.
  expect_warning(r <- cbo2002_para_isco(c("225120", "abc", "225120")),
                 class = "ocupacoesBR_codigo_invalido")
  expect_length(r, 3L)
  expect_true(is.na(r[2]))
  expect_false(any(is.na(r[c(1, 3)])))
  expect_identical(r[1], r[3])

  expect_warning(cod_para_isco(c("2211", "xx")),
                 class = "ocupacoesBR_codigo_invalido")
  # e o regime duro: nenhum valido
  expect_error(cbo2002_para_isco(c("abc", "def")), "nenhum código")
})

test_that("factor entra pelas portas sem virar indice de nivel", {
  # as.character() de um factor devolve o rotulo; as.integer() devolveria o
  # indice. Toda porta normaliza antes de usar, e este teste garante que
  # continua sendo assim nas tres familias.
  expect_identical(tse_para_isco(factor(c("111", "169"))),
                   tse_para_isco(c("111", "169")))
  expect_identical(cod_para_isco(factor(c("2211", "9629"))),
                   cod_para_isco(c("2211", "9629")))
  expect_identical(isco88_para_isei(factor(c("2221", "9330"))),
                   isco88_para_isei(c("2221", "9330")))
})

test_that("o caminho rapido do EGP tambem valida comprimentos", {
  # As guardas de comprimento existem duas vezes: antes da deduplicacao e
  # depois. Acima de 512 elementos e a primeira que responde, e ela so e
  # alcancavel com um vetor grande.
  grande <- rep(c("2221", "9330"), length.out = 600)
  expect_error(isco88_para_egp(grande, conta_propria = c(TRUE, FALSE),
                               avisar = FALSE), "comprimento")
  expect_error(isco88_para_egp(grande, n_supervisionados = c(1, 2),
                               avisar = FALSE), "comprimento")
})

test_that("crosswalk_cbo2002(escada = TRUE) troca o nivel usado", {
  # o ramo `if (isTRUE(escada))` de `crosswalk_cbo2002()`, que ate aqui so era
  # exercitado pela porta avulsa `cbo2002_para_isco()`
  a <- crosswalk_cbo2002(escada = TRUE)
  b <- crosswalk_cbo2002(escada = FALSE)
  expect_identical(nrow(a), nrow(b))
  expect_true(all(c("isco88", "nivel_usado", "agregado") %in% names(a)))
  expect_gte(sum(!is.na(a$isco88)), sum(!is.na(b$isco88)))
})

test_that("a busca de rotulo por texto devolve uma linha por termo procurado", {
  # o ramo `exato = FALSE` monta o resultado linha a linha com do.call(rbind),
  # e precisa aguentar termo sem correspondencia e vetor com NA
  r <- tse_rotulo_para_cod(c("MEDICO", "TERMOQUENAOEXISTE"), exato = FALSE)
  expect_s3_class(r, "data.frame")
  expect_true(any(is.na(r$cod_tse)))
  expect_true(any(!is.na(r$cod_tse)))
  # o tipo do retorno nao pode depender do conteudo do argumento: sem nada a
  # procurar, sai um data.frame de zero linhas, e nao NULL
  for (e in c(TRUE, FALSE)) {
    expect_s3_class(tse_rotulo_para_cod(NA_character_, exato = e), "data.frame")
    expect_s3_class(tse_rotulo_para_cod(character(0), exato = e), "data.frame")
    expect_identical(nrow(tse_rotulo_para_cod(character(0), exato = e)), 0L)
    expect_named(tse_rotulo_para_cod(character(0), exato = e),
                 c("rotulo", "cod_tse", "rotulo_tse"))
  }
})

test_that("CBO-2002 numerica nao derruba a chamada quando dois codigos sao curtos", {
  # `formatC` nao vetoriza `width`. Enquanto `.norm_cbo2002` derivava o width
  # por `ifelse`, qualquer vetor NUMERICO com dois ou mais codigos distintos de
  # 3 ou 5 digitos morria em "the condition has length > 1" — e ler a RAIS com
  # read.csv produz exatamente uma coluna numerica. O caso de UM codigo curto
  # passava, o que escondia o defeito.
  curtos <- list(c(10105L, 52305L),   # 5 e 5
                 c(10105L, 111L),     # 5 e 3
                 c(111L, 222L),       # 3 e 3
                 c(252105L, 10105L),  # 6 e 5
                 c(NA_integer_, 111L, 222L))
  for (x in curtos) {
    r <- suppressWarnings(cbo2002_para_isco(x))
    expect_length(r, length(x))
    expect_type(r, "character")
  }

  # o codigo bom no meio dos curtos continua traduzido: o vetor inteiro nao
  # pode cair por causa dos vizinhos
  expect_equal(suppressWarnings(cbo2002_para_isco(c(10105L, 52305L, 252105L))),
               c(NA, NA, "2419"))

  # e todas as portas da CBO-2002 passam pelo mesmo normalizador
  for (f in c(cbo2002_para_isei, cbo2002_para_prestigio, cbo2002_para_egp,
              cbo2002_para_isco08, cbo2002_para_isei08, cbo2002_concordancia,
              crosswalk_cbo2002, checa_cobertura_cbo2002))
    expect_no_error(suppressWarnings(suppressMessages(f(c(111L, 222L)))))
})

test_that("a CBO-2002 nao tem codigo com zero a esquerda, e a CBO-94 tem", {
  # e por isso que a padronizacao numerica so recupera codigo de fato na
  # CBO-94. Se uma tabua futura trouxer codigo iniciado em zero na CBO-2002,
  # este teste quebra e a assimetria precisa ser reexaminada.
  expect_equal(sum(substr(cbo2002_isco88$cbo2002, 1, 1) == "0"), 0L)
  expect_equal(sum(substr(cbo2002_familia_isco88$familia, 1, 1) == "0"), 0L)
  expect_gt(sum(substr(cbo94_isco88$cbo94, 1, 1) == "0"), 0L)

  # na CBO-94 a leitura numerica e recuperavel, e precisa continuar sendo
  z <- cbo94_isco88$cbo94[substr(cbo94_isco88$cbo94, 1, 1) == "0"][1:3]
  expect_equal(cbo94_para_isco(as.integer(z)), cbo94_para_isco(z))
})

test_that("o ano na posicao de `superior` ou `conta_propria` falha, e nao passa calado", {
  # `tse_para_isei(cod, ano)` aceita o ano na SEGUNDA posicao; em
  # `tse_para_classe` a segunda e `superior`, e em `tse_para_egp` e
  # `conta_propria`. Ate 07/09/2026 `as.logical(2000)` era TRUE e o ano virava a
  # marca ligada em toda linha — o unico engano de chamada do pacote que
  # produzia numero plausivel em silencio. A vinheta `comece-aqui` chegava a
  # dizer que bastava trocar o nome da funcao "e o comportamento e o mesmo".
  expect_error(tse_para_classe(c(298, 298), c(2000, 2020)), "ano")
  expect_error(tse_para_egp(c(111, 169), c(2000, 2020)), "ano")

  # a mensagem tem de ensinar a saida, nao so recusar
  expect_error(tse_para_classe(c(298, 298), c(2000, 2020)), "ano = ", fixed = TRUE)

  # sem cara de ano, recusa do mesmo jeito, mas sem sugerir o que nao cabe
  e <- tryCatch(tse_para_classe(c(291, 291), c(3, 7)), error = function(e) e)
  expect_s3_class(e, "error")
  expect_false(grepl("ano", conditionMessage(e)))
})

test_that("a guarda de valor nao estorva o uso legitimo", {
  # 0/1, logico e NA continuam valendo: a guarda e de VALOR, e o unico codigo
  # que passa a falhar e o que ja estava errado.
  expect_identical(tse_para_classe(c(291, 291), superior = c(1, 0)),
                   tse_para_classe(c(291, 291), superior = c(TRUE, FALSE)))
  expect_identical(tse_para_egp(169, conta_propria = 0, avisar = FALSE),
                   tse_para_egp(169, conta_propria = FALSE, avisar = FALSE))
  # `superior = NA` segue sem virar "medio ou menos"
  expect_equal(tse_para_classe(c(291, 291), superior = c(NA, 1))[1],
               tse_para_classe(291))
  # e o ano, no lugar dele, funciona
  expect_length(tse_para_classe(c(298, 298), ano = c(2000, 2020)), 2L)
})

test_that("checa_cobertura devolve TRUE invisivel, ou falha — nunca FALSE", {
  # `vignette("comece-aqui")` dizia que a funcao "devolve TRUE ou FALSE". Nao
  # devolve FALSE nunca: ou o vetor tem codigo valido e ela volta TRUE
  # invisivelmente, ou nao tem e ela para. E deliberado — cobertura zero quase
  # nunca e achado sobre a populacao, e quase sempre e a coluna errada; um FALSE
  # seguiria adiante no pipeline.
  r <- withVisible(checa_cobertura("111", silencioso = TRUE))
  expect_true(r$value)
  expect_false(r$visible)

  expect_error(checa_cobertura(character(0), silencioso = TRUE), "vazio")
  expect_error(checa_cobertura(NULL, silencioso = TRUE), "NULL")
})
