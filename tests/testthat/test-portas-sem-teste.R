# Quatro portas exportadas que a suite nunca chamava. Nao ha nada de errado com
# elas; o problema e nao haver quem perceba se passar a haver. Uma auditoria de
# cobertura em 17/08/2026 encontrou `R/prestigio.R` inteiro sem execucao (ver
# `test-prestigio.R`) e estas quatro alem dele.
#
# O criterio adotado: toda funcao exportada tem de ser exercitada ao menos uma
# vez, e o teste tem de checar o CONTRATO da funcao, nao a sua mera existencia.

test_that("crosswalk_cbo94() devolve a tabua inteira, com as medidas ligadas", {
  cw <- crosswalk_cbo94()
  expect_s3_class(cw, "data.frame")
  expect_identical(nrow(cw), nrow(cbo94_isco88))
  expect_named(cw, c("cbo94", "isco88", "isco08", "isei88", "siops88", "egp"))
  expect_setequal(cw$cbo94, cbo94_isco88$cbo94)
  # o ISCO-88 da tabela e o da tabua, e nao uma reinterpretacao
  expect_identical(cw$isco88, cbo94_isco88$isco88[match(cw$cbo94, cbo94_isco88$cbo94)])
  # a coluna de medida tem de estar de fato preenchida onde ha ISCO
  expect_gt(mean(!is.na(cw$isei88[!is.na(cw$isco88)])), 0.9)

  # com argumento, devolve so o pedido, na ordem pedida
  sub <- crosswalk_cbo94(c("2-11.20", "2-11.20"))
  expect_identical(nrow(sub), 2L)
  expect_identical(sub$isco88[1], sub$isco88[2])
})

test_that("crosswalk_cbo94() concorda com as portas avulsas", {
  k <- utils::head(cbo94_isco88$cbo94, 50)
  cw <- crosswalk_cbo94(k)
  expect_identical(cw$isco88, cbo94_para_isco(k))
  expect_identical(cw$isei88, cbo94_para_isei(k))
  expect_identical(cw$siops88, cbo94_para_prestigio(k))
})

test_that("checa_cobertura_cbo94() erra em voz alta e avisa o que falta", {
  expect_message(expect_true(checa_cobertura_cbo94("2-11.20")), "cobertura CBO-94")
  expect_silent(checa_cobertura_cbo94("2-11.20", silencioso = TRUE))
  # codigo fora da tabua do MTE: aviso classificado, nao erro
  expect_warning(checa_cobertura_cbo94(c("2-11.20", "9-99.99"), silencioso = TRUE),
                 class = "ocupacoesBR_sem_correspondencia")
  # vetor sem nenhum codigo valido: erro duro, com a causa nomeada
  expect_error(checa_cobertura_cbo94(NULL), "NULL")
  expect_error(checa_cobertura_cbo94(character(0)), "vazio")
  expect_error(checa_cobertura_cbo94(NA_character_), "NA")
})

test_that("cod_para_isei() e cod_para_egp() delegam sem perder o caminho", {
  k <- c("2211", "9629", "1120")
  expect_identical(cod_para_isei(k),
                   isco88_para_isei(cod_para_isco(k)))
  expect_identical(cod_para_egp(k, avisar = FALSE),
                   isco88_para_egp(cod_para_isco(k), avisar = FALSE))
  expect_length(cod_para_isei(k), 3L)
  expect_true(is.numeric(cod_para_isei(k)))
  # medico (2211) tem de pontuar alto; ocupacao elementar (9629), baixo
  expect_gt(cod_para_isei("2211"), cod_para_isei("9629"))
  # os argumentos do EGP atravessam a delegacao
  expect_type(cod_para_egp("2211", n_classes = 7, avisar = FALSE), "character")
  expect_false(identical(cod_para_egp("2211", rotulo = FALSE, avisar = FALSE),
                         cod_para_egp("2211", rotulo = TRUE,  avisar = FALSE)))
})
