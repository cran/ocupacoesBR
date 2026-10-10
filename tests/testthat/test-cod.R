test_that("a COD e quase toda identidade com a ISCO-08", {
  d <- cod_isco08
  expect_equal(nrow(d), 434L)
  expect_false(anyDuplicated(d$cod) > 0)
  expect_true(all(nchar(d$cod) == 4L))
  expect_setequal(unique(d$correspondencia),
                  c("identidade", "adaptacao", "agregacao"))
  # o argumento central da perna: quase nada precisa de traducao
  expect_gte(sum(d$correspondencia == "identidade"), 425L)
  expect_true(all(d$isco08[d$correspondencia == "identidade"] ==
                  d$cod[d$correspondencia == "identidade"]))
  # e TODO destino tem medida — senao o degrau nao serve de nada
  expect_true(all(d$isco08 %in% isco08_medidas$isco08))
})

test_that("as seis adaptacoes brasileiras estao onde foram decididas", {
  d <- cod_isco08
  esperado <- c("0411" = "5412", "0412" = "5412",   # policia militar
                "0511" = "5411", "0512" = "5411",   # bombeiro militar
                "5168" = "5169",                    # trabalhadores do sexo
                "6225" = "6220")                    # pescadores: o subgrupo
  for (k in names(esperado))
    expect_equal(d$isco08[d$cod == k], unname(esperado[k]), info = k)
  # a PM vai para servico protetivo (grande grupo 5), NAO para forcas armadas
  expect_false(any(substr(d$isco08[d$cod %in% c("0411","0412","0511","0512")],
                          1, 1) == "0"))
})

test_that("a COD alcanca todas as medidas, menos onde a FONTE nao pontua", {
  d <- cod_isco08
  # a traducao em si e completa: 100% chegam a ISCO-08 e a ISCO-88
  expect_false(any(is.na(cod_para_isco08(d$cod))))
  expect_false(any(is.na(suppressWarnings(cod_para_isco(d$cod)))))
  expect_false(any(is.na(cod_para_isei08(d$cod))))

  cw <- crosswalk_cod()
  expect_equal(nrow(cw), 434L)
  # As FORCAS ARMADAS sao a unica excecao, e ela vem da fonte: o ISMF deixa o
  # ISCO-88 0110 sem ISEI, sem prestigio e sem EGP. Nao ha o que consertar aqui
  # — inventar um escore seria pior que o NA. Sao 2 dos 434 grupos de base.
  sem <- cw[is.na(cw$egp), ]
  expect_equal(nrow(sem), 2L)
  expect_setequal(sem$cod, c("0110", "0210"))
  expect_true(all(sem$isco88 == "0110"))
  expect_true(all(is.na(isco88_medidas$isei88[isco88_medidas$isco88 == "0110"])))
  # fora delas, tudo tem EGP e ISEI-88
  expect_false(any(is.na(cw$egp[!cw$cod %in% sem$cod])))
  expect_false(any(is.na(cw$isei88[!cw$cod %in% sem$cod])))
})

test_that("a ponte reversa nao finge ser o inverso da de ida", {
  # 69% e propriedade da concordancia da OIT, nao bug. Se este numero SUBIR
  # muito, alguem "consertou" a ponte inventando volta onde nao ha.
  # o aviso e legitimo: nem todo destino da ponte de ida tem entrada na de
  # volta, e isso tambem e propriedade da concordancia, nao defeito
  expect_warning(volta <- isco08_para_isco88(isco88_isco08$isco08),
                 "sem correspond")
  ok <- !is.na(volta)
  expect_gt(mean(ok), 0.95)          # a grande maioria tem volta definida
  fecha <- mean(volta[ok] == isco88_isco08$isco88[ok])
  expect_gt(fecha, 0.60)
  expect_lt(fecha, 0.80)
})

test_that("a COD aguenta entrada suja e numerica", {
  # 0411 lido como numero chega como 411
  expect_equal(cod_para_isco08(411L), cod_para_isco08("0411"))
  expect_equal(suppressWarnings(.norm_cod(411L)), "0411")
  # texto de tamanho errado continua sendo erro
  expect_error(cod_para_isco08("41"), "4 digitos")
  for (v in c("-1", "0000-1", "999999")) {
    r <- suppressWarnings(cod_para_isco08(c("2211", v)))
    expect_length(r, 2L)
    expect_true(is.na(r[2]), info = v)
  }
  expect_length(cod_para_isco08(character(0)), 0L)
  expect_error(checa_cobertura_cod(NULL), "NULL")
  expect_error(checa_cobertura_cod("9999"), "sem entrada")
})
