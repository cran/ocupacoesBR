# Testes da posicao na ocupacao: o SEMPL que o TSE nao pergunta e a PNAD mede.

test_that("as duas marcas sao distintas, e conta_propria contem proprietario", {
  d <- ocupacoesBR::tse_isco
  expect_true(all(d$cod_tse[d$proprietario] %in% d$cod_tse[d$conta_propria]))
  # se voltarem a ser identicas, o desacoplamento foi desfeito sem querer
  expect_gt(sum(d$conta_propria), sum(d$proprietario))
  # o agricultor e o pescador: conta propria SEM ser classe proprietaria
  for (k in c("601", "604")) {
    expect_true(d$conta_propria[d$cod_tse == k])
    expect_false(d$proprietario[d$cod_tse == k])
    # a marca NAO vaza para o esquema de classes: os dois seguem em
    # "Trabalhadores rurais". Ver ?tse_para_classe sobre por que uma classe
    # propria foi criada e revertida em 29/07/2026.
    expect_equal(d$classe[d$cod_tse == k], "Trabalhadores rurais")
  }
})

test_that("o EGP separa quem opera a propria terra de quem e assalariado", {
  # 601/604 sobem a IVc; 606 (assalariado) e 207 (jardineiro) ficam em VIIb.
  # Marcar por ISCO em vez de por codigo arrastaria o jardineiro junto: ele
  # divide a ISCO 6100 com o agricultor.
  expect_match(tse_para_egp("601", avisar = FALSE), "IVc")
  expect_match(tse_para_egp("604", avisar = FALSE), "IVc")
  expect_match(tse_para_egp("606", avisar = FALSE), "VIIb")
  expect_match(tse_para_egp("207", avisar = FALSE), "VIIb")
  # A marca de conta propria NAO vaza para o esquema de classes. Em 29/07/2026
  # criou-se uma classe propria para 601/604 e ela foi revertida no mesmo dia:
  # o EGP so separa IVc de VIIb nas ONZE classes; nos colapsos de 5 e 3 ele os
  # FUNDE. Comparar o EGP de 11 classes com a particao em estratos e comparar
  # resolucoes diferentes. Ver ?tse_para_classe.
  expect_equal(tse_para_estrato("601"), "Classes populares")
  expect_equal(tse_para_estrato("604"), "Classes populares")
  expect_equal(tse_para_estrato("606"), "Classes populares")
  # o invariante que sustenta a reversao: nos colapsos canonicos, IVc e VIIb
  # caem na MESMA categoria, e e nessa resolucao que o estrato opera
  expect_equal(tse_para_egp("601", n_classes = 5, avisar = FALSE),
               tse_para_egp("606", n_classes = 5, avisar = FALSE))
  expect_equal(tse_para_egp("601", n_classes = 3, avisar = FALSE),
               tse_para_egp("606", n_classes = 3, avisar = FALSE))
  # e nas onze classes eles se separam, que e onde a distincao pertence
  expect_false(identical(tse_para_egp("601", n_classes = 11, avisar = FALSE),
                         tse_para_egp("606", n_classes = 11, avisar = FALSE)))
})

test_that("isco_posicao_br mede o que diz medir", {
  p <- ocupacoesBR::isco_posicao_br
  expect_gt(nrow(p), 250)
  expect_false(anyDuplicated(p$isco88) > 0)
  expect_true(all(nchar(p$isco88) == 4L))
  expect_true(all(p$pct_conta_propria >= 0 & p$pct_conta_propria <= 100))
  # n_pessoas < n_obs sempre: o painel reentrevista a mesma pessoa
  expect_true(all(p$n_pessoas <= p$n_obs))
  # o achado que motivou o desacoplamento: a 61 opera a propria terra, a 92 nao
  g <- function(x) unique(p$pct_conta_propria_grupo[p$grupo == x])
  expect_gt(g("61"), 60)
  expect_lt(g("92"), 25)
  # e a fonte da marca do pescador
  expect_gt(p$pct_conta_propria[p$isco88 == "6150"], 75)
})

test_that("as colunas de vinculo publico e de posicao militar sao coerentes", {
  p <- ocupacoesBR::isco_posicao_br
  novas <- c("pct_setor_publico", "pct_militar",
             "pct_setor_publico_grupo", "pct_militar_grupo")
  expect_true(all(novas %in% names(p)))
  for (k in novas) expect_true(all(p[[k]] >= 0 & p[[k]] <= 100))

  # V4012 vale 2, 4 ou {5,6}, nunca duas: as tres marcas sao disjuntas e a
  # soma nunca passa de 100. `pct_empregador` NAO entra — e subconjunto de
  # `pct_conta_propria` — e some-la contaria o empregador duas vezes.
  expect_true(all(p$pct_conta_propria + p$pct_setor_publico +
                    p$pct_militar <= 100 + 1e-9))
  expect_true(all(p$pct_empregador <= p$pct_conta_propria))
  expect_true(all(p$pct_conta_propria_grupo + p$pct_setor_publico_grupo +
                    p$pct_militar_grupo <= 100 + 1e-9))

  # o que a coluna existe para dizer: o vinculo publico e concentrado onde a
  # comparacao entre fontes mais dói — a docencia — e e ausente na agropecuaria
  g <- function(x) unique(p$pct_setor_publico_grupo[p$grupo == x])
  expect_gt(g("23"), 60)   # docentes (67,5% em 2025)
  expect_lt(g("61"), 3)    # agricolas qualificados (0,2%)

  # a armadilha documentada em ?isco_posicao_br: `pct_militar` NAO e o grande
  # grupo 0. Se fosse, nenhum codigo do grupo 51/52 teria posicao militar.
  # (5162 e policia; 71,6% dela declara POSICAO militar em 2025)
  expect_gt(p$pct_militar[p$isco88 == "5162"], 50)
  expect_gt(p$pct_militar[p$isco88 == "5161"], 50)
  # e o 0110 e integralmente militar por posicao, o que fecha o outro lado
  expect_equal(p$pct_militar[p$isco88 == "0110"], 100)
})

test_that("tse_codigos_autorrotulo e usavel e coerente", {
  a <- ocupacoesBR::tse_codigos_autorrotulo
  expect_type(a, "character")
  # todos existem no dicionario, senao o filtro do usuario nao pega nada
  expect_true(all(a %in% ocupacoesBR::tse_isco$cod_tse))
  # o caso que motivou o vetor
  expect_true("257" %in% a)
  # sao codigos de propriedade: nenhum e profissao com registro (OAB, CRM)
  expect_false(any(c("131", "111") %in% a))
  # o uso anunciado na documentacao funciona
  cod <- c("131", "257", "111")
  isei <- suppressWarnings(tse_para_isei(cod))
  ancorado <- ifelse(cod %in% a, NA, isei)
  expect_true(is.na(ancorado[2]))
  expect_false(any(is.na(ancorado[c(1, 3)])))
})

test_that("tse_autorrotulo_patrimonio sustenta o que a doc afirma sobre o 257", {
  # Auditoria de 05/09/2026: estes numeros viviam digitados em
  # `?tse_para_componente_alta` e sobreviveram errados (dobrados) a correcao do
  # patrimonio. Agora saem do objeto, e o teste trava a leitura.
  p <- tse_autorrotulo_patrimonio
  expect_true(all(c("cod_tse", "rotulo", "cargo", "ancorado",
                    "n", "p10", "mediana", "p90") %in% names(p)))
  expect_true(all(p$n >= attr(p, "n_min")))
  expect_true(all(p$p10 <= p$mediana & p$mediana <= p$p90))
  # "TODOS" e a linha agregada, e todo codigo da tabela tem a sua
  expect_setequal(p$cod_tse[p$cargo == "TODOS"], unique(p$cod_tse))
  # ela nao pode ser menor que qualquer celula de cargo do mesmo codigo
  for (k in unique(p$cod_tse)) {
    tot <- p$n[p$cod_tse == k & p$cargo == "TODOS"]
    expect_gte(tot, max(p$n[p$cod_tse == k & p$cargo != "TODOS"]))
  }
  # os dez autodeclarados sao os de tse_codigos_autorrotulo; o 131 e o ancorado
  expect_setequal(p$cod_tse[p$ancorado], "131")
  expect_true(all(p$cod_tse[!p$ancorado] %in% tse_codigos_autorrotulo))

  # a afirmacao substantiva: o gradiente por cargo dentro do 257
  m <- function(c_) p$mediana[p$cod_tse == "257" & p$cargo == c_]
  expect_lt(m("VEREADOR"), m("PREFEITO"))
  expect_lt(m("PREFEITO"), m("SENADOR"))
  expect_gt(m("SENADOR") / m("VEREADOR"), 20)
  # e a dispersao interna: o ancorado tem a menor razao p90/p10 da tabela
  a <- p[p$cargo == "TODOS", ]
  expect_identical(a$cod_tse[which.min(a$p90 / a$p10)], "131")
})
