test_that("os tres formatos de codigo da CBO-2002 sao equivalentes", {
  a <- cbo2002_para_isco("1111-05")
  expect_equal(cbo2002_para_isco("111105"), a)
  expect_equal(cbo2002_para_isco(111105), a)
  expect_false(is.na(a))
})

test_that("codigo da CBO-2002 com tamanho invalido falha em voz alta", {
  expect_error(cbo2002_para_isco("111"), "4 \\(fam")
  expect_error(cbo2002_para_isco("12345"), "4 \\(fam")
})

test_that("todo ISCO vindo da CBO existe na tabela de medidas", {
  expect_true(all(cbo2002_isco88$isco88 %in% isco88_medidas$isco88))
  expect_true(all(cbo94_isco88$isco88 %in% isco88_medidas$isco88))
  expect_true(all(cbo2002_familia_isco88$isco88 %in% isco88_medidas$isco88))
  expect_false(any(is.na(cbo2002_para_isei(cbo2002_isco88$cbo2002))))
})

test_that("a familia devolve o ISCO majoritario e a concordancia bate", {
  f <- cbo2002_familia_isco88$familia[1]
  expect_equal(cbo2002_para_isco(f),
               cbo2002_familia_isco88$isco88[1])
  cc <- cbo2002_concordancia(f)
  expect_equal(cc$familia, f)
  expect_true(cc$concordancia > 0 && cc$concordancia <= 1)
  # a concordancia recalculada do zero tem de bater com a guardada
  oc <- cbo2002_isco88$isco88[cbo2002_isco88$familia == f]
  expect_equal(cc$concordancia, round(max(table(oc)) / length(oc), 3))
})

test_that("a ocupacao e reduzida a familia em cbo2002_concordancia", {
  oc <- cbo2002_isco88$cbo2002[1]
  expect_equal(cbo2002_concordancia(oc)$familia, substr(oc, 1, 4))
})

test_that("codigo sem correspondencia oficial volta NA com aviso, nao um chute", {
  # grande grupo 0 (forcas armadas) nao esta na tabua CBO2002-CBO94-CIUO88.
  # A perna CBO antes devolvia NA em SILENCIO -- o mesmo modo de falha que
  # checa_cobertura existe para combater na perna do TSE.
  expect_warning(r <- cbo2002_para_isco("010105"), "sem correspond")
  expect_true(is.na(r))
  expect_warning(r2 <- cbo2002_para_isei("010105"), "sem correspond")
  expect_true(is.na(r2))
})

test_that("a CBO-94 traduz para o mesmo ISCO que o par da CBO-2002", {
  # A tabua e 1:1, entao isto verifica a leitura da coluna, nao uma agregacao.
  d <- cbo2002_isco88[cbo2002_isco88$cbo94 != "", ][1:50, ]
  expect_equal(cbo94_para_isco(d$cbo94), d$isco88)
  expect_false("concordancia" %in% names(cbo94_isco88))  # coluna sem conteudo
})

test_that("familias com empate na moda estao marcadas", {
  f <- cbo2002_familia_isco88
  expect_true("empate" %in% names(f))
  emp <- f[f$empate, ]
  expect_gt(nrow(emp), 0)
  # todo empate tem concordancia <= 0.5 e mais de um ISCO.
  # Le `concordancia_vista`, e nao `concordancia`: esta ultima e NA por desenho
  # quando a familia foi vista so em parte, para nao afirmar homogeneidade sobre
  # evidencia parcial. A proporcao entre as ocupacoes VISTAS e o que este
  # invariante sempre quis dizer.
  expect_true(all(emp$n_isco_distintos > 1))
  expect_true(all(emp$concordancia_vista <= 0.5))
})

test_that("concordancia so e afirmada sobre familia vista INTEIRA", {
  f <- cbo2002_familia_isco88
  expect_true(all(c("n_ocupacoes_cbo", "cobertura_familia",
                    "concordancia_vista") %in% names(f)))
  # o denominador e o dominio oficial do Novo CAGED, nao o que a tabua cobre
  expect_true(all(f$n_ocupacoes <= f$n_ocupacoes_cbo, na.rm = TRUE))
  # concordancia preenchida <=> familia vista por inteiro
  expect_equal(!is.na(f$concordancia), f$cobertura_familia >= 1 &
                                       !is.na(f$cobertura_familia))
  # o achado que motivou isto: familias vistas por UMA ocupacao nao podem mais
  # reportar concordancia 1 quando a familia real tem mais de uma
  parcial <- f$n_ocupacoes == 1L & f$n_ocupacoes_cbo > 1L
  expect_gt(sum(parcial, na.rm = TRUE), 50)
  expect_true(all(is.na(f$concordancia[which(parcial)])))
})

test_that("familia empatada devolve NA por padrao, e moda sob pedido", {
  emp <- cbo2002_familia_isco88$familia[cbo2002_familia_isco88$empate][1]
  expect_warning(r <- cbo2002_para_isco(emp), "majorit")
  expect_true(is.na(r))
  expect_false(is.na(cbo2002_para_isco(emp, empate = "moda")))
  # familia homogenea nao e afetada por nenhum dos dois modos
  hom <- cbo2002_familia_isco88$familia[!cbo2002_familia_isco88$empate][1]
  expect_equal(cbo2002_para_isco(hom), cbo2002_para_isco(hom, empate = "moda"))
})

test_that("cbo2002_concordancia avisa em vez de devolver linha de NA calada", {
  expect_warning(cbo2002_concordancia("9999"), "sem correspond")
})

test_that("crosswalk_cbo2002 aceita familia, como cbo2002_para_isco", {
  fam <- cbo2002_familia_isco88$familia[1]
  cw <- crosswalk_cbo2002(fam)
  expect_equal(cw$isco88, cbo2002_para_isco(fam))
  expect_true(cw$agregado)
  expect_false(is.na(cw$isei88))
})

test_that("crosswalk_cbo2002 nao devolve o que cbo2002_para_isco recusa", {
  # familia empatada: a porta devolve NA por padrao, e a tabela auditavel
  # devolvia o vencedor do desempate lexicografico sem dizer nada
  emp <- cbo2002_familia_isco88$familia[cbo2002_familia_isco88$empate %in% TRUE]
  expect_gt(length(emp), 0)
  f <- emp[1]
  cw <- crosswalk_cbo2002(f)
  expect_true(cw$empate)
  expect_true(is.na(cw$isco88))
  expect_true(is.na(cw$isei88))
  expect_equal(cw$isco88, suppressWarnings(cbo2002_para_isco(f)))
  cm <- crosswalk_cbo2002(f, empate = "moda")
  expect_true(cm$empate)
  expect_equal(cm$isco88, cbo2002_para_isco(f, empate = "moda"))
  # ocupacao de seis digitos e familia nao empatada nunca sao marcadas
  expect_false(crosswalk_cbo2002("1111-05")$empate)
  expect_false(any(crosswalk_cbo2002()$empate))
})

test_that("checa_cobertura_cbo2002 recusa vazio e avisa sobre sem-correspondencia", {
  expect_error(checa_cobertura_cbo2002(NULL), "NULL")
  expect_warning(checa_cobertura_cbo2002(c("010105", "111105"), silencioso = TRUE),
                 "sem correspond")
})

test_that("as medidas encadeiam a partir da CBO", {
  cbo <- cbo2002_isco88$cbo2002[1:20]
  expect_equal(cbo2002_para_isei(cbo),
               .busca(cbo2002_para_isco(cbo), isco88_medidas, "isco88", "isei88"))
  expect_equal(cbo2002_para_egp(cbo, avisar = FALSE),
               isco88_para_egp(cbo2002_para_isco(cbo), avisar = FALSE))
})

test_that("crosswalk_cbo2002 e consistente", {
  cw <- crosswalk_cbo2002()
  expect_equal(nrow(cw), nrow(cbo2002_isco88))
  expect_equal(cw$isei88, cbo2002_para_isei(cbo2002_isco88$cbo2002))
  expect_false(any(is.na(cw$isco88)))
  sub <- crosswalk_cbo2002(c("1111-05", "111110"))
  expect_equal(nrow(sub), 2)
})

test_that("NA entra e NA sai", {
  expect_true(is.na(cbo2002_para_isco(NA)))
  expect_true(is.na(cbo94_para_isco(NA)))
})

test_that("a escada e a consulta por familia divergem em oito familias, e isso e declarado", {
  # A vinheta `percursos` afirmava que os NA que sobram da escada continuam NA
  # "porque nem o prefixo de dois digitos esta na tabua". Nao e a razao: a
  # familia 1423 ESTA na tabua. O que falta e ancestral comum na ISCO, porque as
  # ocupacoes dela caem em 1233, 1234, 1239 e 2419.
  expect_equal(suppressWarnings(cbo2002_para_isco("1423")), "2419")
  expect_true(is.na(suppressWarnings(cbo2002_para_isco("142399", escada = TRUE))))

  fam <- cbo2002_familia_isco88$familia
  por_familia <- suppressWarnings(cbo2002_para_isco(fam))
  por_escada  <- suppressWarnings(
    cbo2002_para_isco(paste0(fam, "99"), escada = TRUE))
  divergem <- fam[!is.na(por_familia) & is.na(por_escada)]

  # Se esta lista mudar, a tabua se moveu e a secao "A escada hierarquica" de
  # ?cbo2002_para_isco e a vinheta `percursos` precisam ser reexaminadas: as
  # duas afirmam OITO, e afirmam quais.
  expect_equal(sort(divergem),
               c("1423", "2531", "3123", "3227", "5101", "5199", "7612", "8421"))
})
