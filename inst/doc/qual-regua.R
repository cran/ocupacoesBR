## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ----setup--------------------------------------------------------------------
library(ocupacoesBR)

## ----echo = FALSE-------------------------------------------------------------
r <- reguas[match(c("ISEI-88", "Prestigio-88", "EGP", "Classe"), reguas$medida), ]
knitr::kable(
  data.frame(
    `se você quer saber…` = r$pergunta,
    use = paste0("`", r$funcao_tse, "()`"),
    # `tipo` e um token de filtro, sem acento de proposito; aqui ele e exibido
    `o que ela mede` = paste0(
      r$mede, ", ",
      c(continua = "contínua", categorica = "categórica",
        ordinal = "ordinal")[r$tipo]),
    check.names = FALSE),
  row.names = FALSE)

## ----eval = FALSE-------------------------------------------------------------
# reguas[, c("medida", "pergunta", "quando_nao_usar")]

## -----------------------------------------------------------------------------
cw <- crosswalk_tse()
ok <- !is.na(cw$isei88) & !is.na(cw$siops88)
round(cor(cw$isei88[ok], cw$siops88[ok]), 3)

## -----------------------------------------------------------------------------
cw$dif <- cw$siops88 - cw$isei88
d <- cw[ok, c("rotulo", "isei88", "siops88", "dif")]
rbind(head(d[order(d$dif), ], 3),
      head(d[order(-d$dif), ], 3))

## -----------------------------------------------------------------------------
sum(is.na(cw$isco88))

## ----eval = FALSE-------------------------------------------------------------
# # sempre, não às vezes
# tapply(isei, genero, function(x) c(media = mean(x, na.rm = TRUE),
#                                    cobertura = mean(!is.na(x))))

## -----------------------------------------------------------------------------
table(cw$classe[is.na(cw$isco88)])

## -----------------------------------------------------------------------------
table(cw$estrato)

## -----------------------------------------------------------------------------
tse_para_egp(c(111, 169, 601))

## ----marca-conta-propria------------------------------------------------------
c(conta_propria = sum(tse_isco$conta_propria, na.rm = TRUE),
  proprietario  = sum(tse_isco$proprietario,  na.rm = TRUE))

## -----------------------------------------------------------------------------
table(tse_para_egp(tse_isco$cod_tse, n_classes = 5, avisar = FALSE),
      useNA = "no")

## -----------------------------------------------------------------------------
q <- tse_quebra_2002[tse_quebra_2002$tipo == "reutilizado", ]
q[, c("cod_tse", "rotulo_ate_2000", "rotulo_apos_2002")]

## -----------------------------------------------------------------------------
tse_para_classe(c("215", "215"), ano = c(2000, 2020))

## -----------------------------------------------------------------------------
table(tse_diff_cadastro(2000, 2002)$mudanca)

## ----inventario---------------------------------------------------------------
r <- tse_ocupacao_rotulos
extintos <- setdiff(r$cod_tse[r$ate <= 2000], r$cod_tse[r$ate > 2000])
criados  <- setdiff(r$cod_tse[r$de  >= 2002], r$cod_tse[r$de  <  2002])
c(extintos = length(extintos), criados = length(criados))

## ----inventario-depois--------------------------------------------------------
for (p in list(c(2002, 2004), c(2004, 2006), c(2006, 2008))) {
  cat(p[1], "->", p[2], ": ")
  print(table(tse_diff_cadastro(p[1], p[2])$mudanca))
}

## -----------------------------------------------------------------------------
data.frame(
  cod    = c("111", "113", "411"),
  rotulo = tse_para_rotulo(c("111", "113", "411")),
  isei88 = tse_para_isei(c("111", "113", "411")),
  isei08 = round(tse_para_isei08(c("111", "113", "411")), 1))

## -----------------------------------------------------------------------------
checa_cobertura(c(111, 169, 257))
invisible(checa_periodo(c("215", "111"), c(2000, 2020)))

## -----------------------------------------------------------------------------
crosswalk_tse(c("131", "257"))[, c("cod_tse", "rotulo", "isei88", "componente_alta")]

## -----------------------------------------------------------------------------
p <- tse_autorrotulo_patrimonio
p[p$cod_tse == "257", c("cargo", "n", "p10", "mediana", "p90")]

## -----------------------------------------------------------------------------
todos <- p[p$cod_tse == "257" & p$cargo == "TODOS", ]
round(todos$p90 / todos$p10, 1)

## -----------------------------------------------------------------------------
a <- p[p$cod_tse %in% c("131", "257") & p$cargo == "TODOS", ]
data.frame(a["rotulo"], razao_p90_p10 = round(a$p90 / a$p10, 1))

## -----------------------------------------------------------------------------
d <- data.frame(cod = c("131", "257", "111", "265"))
d$isei <- tse_para_isei(d$cod)
d$isei_ancorado <- ifelse(d$cod %in% tse_codigos_autorrotulo, NA, d$isei)
d

