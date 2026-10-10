# Trava as correções do passo TSE -> ISCO-08 introduzidas em 0.2.1.
# Duas coisas têm de valer ao mesmo tempo, e é a tensão entre elas que estes
# testes guardam: a PONTE `isco88_isco08` reproduz a OIT e não pode ser tocada;
# a ENTRADA pelo código do TSE tem informação a mais (a marca de proprietário e
# o rótulo) e por isso pode, e deve, chegar a outro destino.

test_that("a ponte ISCO-88 -> ISCO-08 continua sendo a da OIT", {
  # Quem entra pela ISCO-88 recebe o destino oficial, inclusive o 1311 -> 6130,
  # que é a realocação que a OIT determina ao abolir o grande grupo 13.
  expect_equal(isco88_para_isco08("1311"), "6130")
  expect_equal(isco88_para_isco08("7400"), "7540")
  expect_equal(isco88_para_isco08("2220"), "2200")
  expect_equal(isco88_para_isco08("3470"), "3430")
  expect_equal(isco88_para_isco08("2320"), "2330")
  # e a régua ISCO-88 do dicionário do TSE não foi tocada por nada disto
  expect_equal(tse_para_isco(c("234", "602", "901")), rep("1311", 3))
  expect_equal(tse_para_isco(c("713", "115", "164")),
               c("7400", "2220", "3470"))
  expect_equal(tse_para_isei(c("234", "713", "115", "164")),
               c(43, 33, 85, 52))
})

test_that("o proprietário rural não é rebaixado a trabalhador agrícola", {
  # iskopromo.sps: `do if (sempl eq 2). recode isko (6130=1311).`
  # A mesma regra que R/egp.R já aplicava no caminho do EGP.
  agrarios <- c("234", "602", "901")
  expect_equal(tse_para_isco08(agrarios), rep("1311", 3))
  expect_equal(tse_para_isei08(agrarios), rep(49.48, 3))
  # o EGP, a classe e o estrato continuam onde estavam: a correção é só do
  # destino na ISCO-08
  cw <- crosswalk_tse(agrarios)
  expect_equal(cw$isco88, rep("1311", 3))
  expect_equal(cw$isei88, rep(43, 3))
  expect_equal(unique(cw$egp), "IVc: proprietário rural")
  expect_equal(unique(cw$estrato), "Classe alta")
  expect_equal(unique(cw$componente_alta), "Alta proprietária")
  # e 901 volta para junto dos irmãos que o TSE construiu como série homogênea
  irmaos <- tse_para_isei08(c("902", "903", "904", "905"))
  expect_true(all(abs(irmaos - tse_para_isei08("901")) < 2))
})

test_that("a promoção é regra, não lista de exceções", {
  # Se um código novo do TSE entrar como proprietário com destino 6130, ele tem
  # de ser promovido também; e nenhum não-proprietário pode ser.
  d <- tse_isco[!is.na(tse_isco$isco88), ]
  ponte <- suppressWarnings(isco88_para_isco08(d$isco88))
  final <- suppressWarnings(tse_para_isco08(d$cod_tse))
  promovidos <- d$cod_tse[!is.na(ponte) & ponte == "6130" & final == "1311"]
  expect_setequal(promovidos, d$cod_tse[!is.na(ponte) & ponte == "6130" &
                                          d$proprietario])
  expect_false(any(final == "1311" & !d$proprietario, na.rm = TRUE))
})

test_that("os refinamentos por rótulo valem, um a um", {
  # Cada destino é o que isco8808.sps atribui ao ISCO-88 de 4 dígitos que o
  # rótulo do TSE nomeia. Se algum mudar, foi decisão, não acidente.
  esperado <- c(
    "713" = "7520", "228" = "7510", "710" = "7510", "591" = "7530",
    "705" = "7530", "188" = "7530", "241" = "7530", "186" = "7530",
    "149" = "7530", "715" = "7536", "250" = "7535",
    "115" = "2261", "112" = "2250", "117" = "2262", "235" = "2320",
    "164" = "2652", "163" = "2652", "165" = "2653")
  expect_equal(tse_para_isco08(names(esperado)), unname(esperado))
  # os escores que daí saem, lidos de isqoisei08.sps
  expect_equal(tse_para_isei08(c("713", "115", "164", "250")),
               c(23.65, 88.31, 64.44, 28.08))
  # e o ISCO-88 de origem continua o agregado: nada foi recodificado na régua
  expect_equal(tse_para_isco(names(esperado)),
               c(rep("7400", 11), rep("2220", 3), "2320", rep("3470", 3)))
})

test_that("nenhum código do TSE cai mais no residual 7540", {
  # 7540 ("other craft arw") é o grupo-menor residual da submajor 75; seu
  # ISEI-08 (43,19) destoa em ~19 pontos de toda a família (7500 = 23,97;
  # 7510 = 23,46; 7520 = 23,65; 7530 = 22,03). Era transposição de dígito do
  # agregado ISCO-88 7400, não escolha.
  cw <- crosswalk_tse()
  expect_false(any(cw$isco08 == "7540", na.rm = TRUE))
  artesanais <- cw$isei08[!is.na(cw$isco08) & substr(cw$isco08, 1, 2) == "75"]
  expect_true(all(artesanais < 30))
})

test_that("nenhuma linha da classe alta tem ISEI-08 de classe popular", {
  # O teste de consistência interna que isolou o caso agrário: antes da
  # correção, 234, 602 e 901 eram as únicas linhas em que "Classe alta"
  # convivia com ISEI-08 abaixo de 40.
  cw <- crosswalk_tse()
  alta <- cw[cw$estrato == "Classe alta" & !is.na(cw$isei08), ]
  expect_equal(nrow(alta[alta$isei08 < 40, ]), 0L)
  # e a recíproca continua valendo
  pop <- cw$isei08[cw$estrato == "Classes populares" & !is.na(cw$isei08)]
  expect_equal(sum(pop > 60), 0L)
})

test_that("a regra mora num lugar só: crosswalk e funções não divergem", {
  cw <- crosswalk_tse()
  expect_equal(cw$isco08, suppressWarnings(tse_para_isco08(cw$cod_tse)))
  expect_equal(cw$isei08, suppressWarnings(tse_para_isei08(cw$cod_tse)))
})

test_that("a correção não ressuscita código mascarado por vigência", {
  expect_warning(x <- tse_para_isco08("215", ano = 2000), "REUTILIZOU")
  expect_true(is.na(x))
  # e o data.frame de ambiguidade também sai corrigido
  r <- tse_para_isco08(c("234", "713"), com_ambiguidade = TRUE)
  expect_equal(r$isco08, c("1311", "7520"))
  expect_equal(r$isco88, c("1311", "7400"))
})

test_that("as outras portas de entrada ficaram intactas", {
  # A correção é do passo TSE -> ISCO-08; CBO e COD não passam por ela.
  cbo <- utils::head(cbo94_isco88$cbo94, 50)
  expect_equal(suppressWarnings(cbo94_para_isco08(cbo)),
               suppressWarnings(isco88_para_isco08(cbo94_para_isco(cbo))))
  # a ponte de volta (isco0888.sps) também é da OIT e também não muda: ela
  # devolve 6130 -> 6130 e 1311 -> 1221, e é justamente por a volta não ser
  # simétrica que a promoção precisa da marca de proprietário para acontecer.
  expect_equal(isco08_para_isco88(c("6130", "1311")), c("6130", "1221"))
})

test_that("a enfermagem ja era grupo 2 na ISCO-88: o que muda e a escala", {
  # Ate a auditoria de 07/09/2026 quatro paginas do site diziam que o salto de
  # 26 pontos do enfermeiro vinha de a ISCO-08 te-lo "promovido a profissao de
  # nivel superior, separando-o dos tecnicos". Nao vinha: a ISCO-88 ja o punha
  # em 2230, grande grupo 2, e ja o separava da enfermagem tecnica (3231). O
  # salto e reestimacao da escala. Este teste trava os dois fatos que desmentem
  # a versao antiga, para que ela nao volte por copia.
  expect_equal(tse_para_isco("113"), "2230")
  expect_equal(substr(tse_para_isco("113"), 1, 1), "2")   # profissionais, ja em 1988
  expect_equal(substr("3231", 1, 1), "3")                 # a tecnica, separada, no 3
  expect_lt(isco88_medidas$isei88[isco88_medidas$isco88 == "3231"],
            isco88_medidas$isei88[isco88_medidas$isco88 == "2230"])

  # e o escore de 1992 punha a profissao universitaria abaixo dos escriturarios
  expect_lt(isco88_medidas$isei88[isco88_medidas$isco88 == "2230"],
            isco88_medidas$isei88[isco88_medidas$isco88 == "4000"])

  # o salto existe e e da escala; o destino que o pacote usa e o agregado 2220
  expect_equal(tse_para_isco08("113"), "2220")
  expect_gt(tse_para_isei08("113") - tse_para_isei("113"), 20)
})

test_that("os casos de promocao 3 -> 2 de fato sao a fisioterapia e a nutricao", {
  # Sao estes os exemplos que o artigo de metodo usa, e que a aba de
  # classificacoes passou a usar no lugar da enfermagem.
  expect_equal(isco88_para_isco08("3226"), "2264")
  expect_equal(isco88_para_isco08("3223"), "2265")
  expect_equal(substr(c("3226", "3223"), 1, 1), c("3", "3"))
  expect_equal(substr(c("2264", "2265"), 1, 1), c("2", "2"))
})
