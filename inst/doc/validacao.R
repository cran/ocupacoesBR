## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", fig.width = 6,
                      fig.height = 3.6, dpi = 110)

## ----setup--------------------------------------------------------------------
library(ocupacoesBR)

v <- tse_validacao
v$isei   <- isco88_para_isei(tse_isco$isco88[match(v$cod_tse, tse_isco$cod_tse)])
v$rotulo <- tse_para_rotulo(v$cod_tse)
v <- v[!is.na(v$isei), ]

# A mediana de patrimonio e NA onde faltam declaracoes de bens suficientes (ver
# ?tse_validacao). A escolaridade esta medida em todas as linhas; o patrimonio,
# so nestas.
vb <- v[!is.na(v$mediana_patrimonio), ]
c(com_escolaridade = nrow(v), com_patrimonio = nrow(vb))

## -----------------------------------------------------------------------------
r <- function(x, y, m = "pearson") round(cor(x, y, method = m), 3)

# A correlação no nível do INDIVÍDUO sai dos somatórios publicados em
# `tse_dispersao_patrimonio`, sem microdado: veja `?tse_dispersao_patrimonio`.
d <- tse_dispersao_patrimonio
N <- sum(d$n); sx <- sum(d$isei88 * d$n); sy <- sum(d$soma_log)
sxx <- sum(d$isei88^2 * d$n); syy <- sum(d$soma_log2)
sxy <- sum(d$isei88 * d$soma_log)
r_individual <- (N * sxy - sx * sy) / sqrt((N * sxx - sx^2) * (N * syy - sy^2))

data.frame(
  criterio = c("% com ensino superior", "log da mediana de patrimonio"),
  n        = c(nrow(v), nrow(vb)),
  pearson  = c(r(v$isei, v$pct_superior),
               r(vb$isei, log(vb$mediana_patrimonio))),
  spearman = c(r(v$isei, v$pct_superior, "spearman"),
               r(vb$isei, log(vb$mediana_patrimonio), "spearman")))

## ----echo = FALSE, fig.alt = "ISEI contra patrimonio mediano e escolaridade"----
op <- par(mfrow = c(1, 2), mar = c(4, 4, 2, 1), cex = 0.8)
plot(vb$isei, log10(vb$mediana_patrimonio), pch = 19, col = "#00000055",
     xlab = "ISEI-88", ylab = "log10 do patrimonio mediano (R$)",
     main = "Patrimonio")
abline(lm(log10(mediana_patrimonio) ~ isei, vb), col = "#C0392B", lwd = 2)
plot(v$isei, v$pct_superior, pch = 19, col = "#00000055",
     xlab = "ISEI-88", ylab = "% com ensino superior", main = "Escolaridade")
abline(lm(pct_superior ~ isei, v), col = "#C0392B", lwd = 2)
par(op)

## ----eta2---------------------------------------------------------------------
d <- tse_dispersao_patrimonio
N <- sum(d$n); mu <- sum(d$soma_log) / N
eta2 <- sum(d$n * (d$media_log - mu)^2) / (sum(d$soma_log2) - N * mu^2)
c(eta2 = eta2, r2_linear = r_individual^2)

## ----ecologica----------------------------------------------------------------
stats::cov.wt(cbind(d$isei88, d$media_log), wt = d$n, cor = TRUE)$cor[1, 2]

## -----------------------------------------------------------------------------
alvo <- c("169", "257", "111", "265", "113", "601")
d <- vb[vb$cod_tse %in% alvo, c("rotulo", "isei", "pct_superior",
                                "mediana_patrimonio")]
d[order(-d$isei), ]

## -----------------------------------------------------------------------------
data.frame(
  regua = c("ISEI-88", "ISEI-08"),
  enfermagem = c(tse_para_isei("113"), round(tse_para_isei08("113"), 1)))

v$pct_superior[v$cod_tse == "113"]

## ----genero-------------------------------------------------------------------
# o mesmo recorte de ?tse_para_isei: codigos com mais de 500 candidaturas, onde
# a proporcao de mulheres e estimada com precisao suficiente para dicotomizar
g <- v[v$n > 500, ]
fem <- g$pct_mulher > 50
c(codigos = nrow(g), femininos = sum(fem))
round(c(feminina = mean(g$isei[fem]), masculina = mean(g$isei[!fem])), 1)
round(c(feminina = mean(g$pct_superior[fem]),
        masculina = mean(g$pct_superior[!fem])), 1)

## -----------------------------------------------------------------------------
v$isei08  <- tse_para_isei08(v$cod_tse)
v$isei_br <- tse_para_isei_br(v$cod_tse)

ok <- stats::complete.cases(
  v[, c("isei", "isei08", "isei_br", "pct_superior", "mediana_patrimonio")])
w  <- v[ok, ]

r <- function(x, y, m = "pearson") round(stats::cor(x, y, method = m), 3)
data.frame(
  regua        = c("ISEI-88", "ISEI-08", "ISEI-BR"),
  escolaridade = sapply(w[c("isei", "isei08", "isei_br")], r, w$pct_superior),
  patrimonio   = sapply(w[c("isei", "isei08", "isei_br")], r,
                        log(w$mediana_patrimonio)),
  patrimonio_rho = sapply(w[c("isei", "isei08", "isei_br")], r,
                          log(w$mediana_patrimonio), m = "spearman"),
  row.names = NULL)

## ----isei-br, fig.height = 4--------------------------------------------------
d <- w[order(-abs(w$isei_br - w$isei08)), ]
plot(w$isei08, w$isei_br, pch = 19, col = "#00000055",
     xlab = "ISEI-08 (importado)", ylab = "ISEI-BR (PNAD Contínua)",
     xlim = c(10, 90), ylim = c(10, 90))
# a diagonal marca a igualdade de ESCORE, nao a de posicao: as duas escalas
# tem dispersoes diferentes, e a leitura correta vem logo abaixo
abline(0, 1, col = "#C0392B", lty = 2)
text(d$isei08[1:6], d$isei_br[1:6], substr(d$rotulo[1:6], 1, 22),
     pos = 4, cex = 0.65, col = "#1B4F72", xpd = NA)

## ----escalas------------------------------------------------------------------
c(isei08 = sd(w$isei08), isei_br = sd(w$isei_br))

## ----artefato-----------------------------------------------------------------
z <- function(x) (x - mean(x)) / sd(x)
r <- cor(w$isei_br, w$isei08)
c(bruta         = cor(w$isei_br - w$isei08, w$isei08),
  padronizada   = cor(z(w$isei_br) - z(w$isei08), w$isei08),
  forcada_por_r = -sqrt((1 - r) / 2))

## ----sobe-desce---------------------------------------------------------------
w$d <- z(w$isei_br) - z(w$isei08)
sobem  <- head(w[order(-w$d), c("rotulo", "isei08", "isei_br")], 6)
descem <- head(w[order(w$d),  c("rotulo", "isei08", "isei_br")], 6)
rbind(sobem, descem)

## ----sobe-desce-residuo-------------------------------------------------------
w$resid <- residuals(lm(isei_br ~ isei08, data = w))
c(sobem_iguais  = identical(head(w$rotulo[order(-w$d)], 6),
                            head(w$rotulo[order(-w$resid)], 6)),
  descem_mesmas = setequal(head(w$rotulo[order(w$d)], 6),
                           head(w$rotulo[order(w$resid)], 6)))

