# ---------------------------------------------------------------------------
# ponte ISCO-88 -> ISCO-08 e as medidas ancoradas na ISCO-08
# ---------------------------------------------------------------------------

#' Converte ISCO-88 em ISCO-08
#'
#' Aplica a conversão publicada no módulo `isco8808.sps` do ISMF, derivada da
#' correspondência oficial da Organização Internacional do Trabalho.
#'
#' @section A ponte é ambígua e a ambiguidade importa:
#' A OIT define, para muitos códigos da ISCO-88, mais de um destino possível na
#' ISCO-08. A sintaxe original guarda esse número na parte decimal e instrui a
#' truncá-lo quando não houver informação adicional. O pacote trunca, como
#' manda, mas **preserva a contagem** em `n_alternativas` na tabela
#' [isco88_isco08], e [tse_para_isco08()] pode devolvê-la. Cerca de um terço dos
#' pares tem mais de uma alternativa: a conversão é uma escolha razoável, não um
#' equivalente exato.
#'
#' @param isco88 Vetor de códigos ISCO-88.
#' @param com_ambiguidade Se `TRUE`, devolve um `data.frame` com o código e o
#'   número de alternativas da OIT em vez de só o código.
#' @return Vetor de texto com o ISCO-08, ou um `data.frame` se
#'   `com_ambiguidade = TRUE`.
#' @examples
#' isco88_para_isco08(c("2211", "1300"))
#' isco88_para_isco08(c("2211", "1300"), com_ambiguidade = TRUE)
#' @export
isco88_para_isco08 <- function(isco88, com_ambiguidade = FALSE) {
  k <- .norm_isco(isco88)
  i <- match(k, ocupacoesBR::isco88_isco08$isco88)
  .avisa_ausentes(k, i, "isco88_isco08")
  if (!com_ambiguidade) return(ocupacoesBR::isco88_isco08$isco08[i])
  data.frame(isco88 = k,
             isco08 = ocupacoesBR::isco88_isco08$isco08[i],
             n_alternativas = ocupacoesBR::isco88_isco08$n_alternativas[i],
             stringsAsFactors = FALSE)
}

# ---------------------------------------------------------------------------
# correções da ponte aplicadas no nível do código do TSE
# ---------------------------------------------------------------------------
# Nada aqui altera a ponte `isco88_isco08`: ela reproduz a correspondência
# oficial da OIT e continua devolvendo o que a OIT manda para quem entra pela
# ISCO-88. O que se corrige aqui é a perda de informação que a ponte causa
# QUANDO A ENTRADA É O CÓDIGO DO TSE, que carrega duas informações que a ponte
# genérica não pode ver: a marca de proprietário e o rótulo em português, mais
# fino do que o código ISCO-88 agregado a que o dicionário o associa.

#' Destino ISCO-08 refinado por rótulo do TSE
#'
#' O dicionário associa vários códigos do TSE a um ISCO-88 **agregado** (7400,
#' 2220, 2320, 3470). A ponte traduz esse agregado por um único destino, e em
#' três famílias esse destino é pior do que o rótulo do TSE permitiria:
#'
#' * **ISCO-88 7400** (*other craft and related trades workers*) cai em ISCO-08
#'   **7540**, que é o grupo-menor RESIDUAL da submajor 75 ("other craft"),
#'   habitado por mergulhadores, dinamitadores e classificadores de produtos.
#'   Seu ISEI-08 (43,19) destoa em ~19 pontos de toda a sua própria família
#'   (7500 = 23,97; 7510 = 23,46; 7520 = 23,65; 7530 = 22,03). Que 7540 seja
#'   transposição de dígito, e não escolha, prova-se no próprio `isco8808.sps`:
#'   ele manda cada ramo filho ao lugar certo — `7410=7510`, `7420=7520`,
#'   `7430=7530`, `7440=7536`, `7441=7535` — e só o agregado ao residual.
#' * **ISCO-88 2220** (*health professionals except nursing*) cai no agregado
#'   ISCO-08 2200, média de todos os profissionais de saúde. Os rótulos do TSE
#'   nomeiam a ocupação exata, e a OIT dá destino ÚNICO para cada uma:
#'   `2222=2261` (dentistas), `2223=2250` (veterinários), `2224=2262`
#'   (farmacêuticos).
#' * **ISCO-88 3470** (*artistic and cultural associate professionals*) cai em
#'   3430, que pressupõe nível técnico. Os rótulos 163/164/165 reproduzem
#'   literalmente os títulos de ISCO-88 2453 e 2454, de nível profissional, cujos
#'   destinos são únicos: `2453=2652`, `2454=2653`.
#' * **ISCO-88 2320** tem exatamente dois destinos na OIT: 2320 (*vocational
#'   education teachers*) e 2330 (*secondary education teachers*). A ponte trunca
#'   para 2330 nos dois; o código 235 diz "formação profissional" e é o 2320.
#'
#' Cada destino abaixo é o que `isco8808.sps` atribui ao código ISCO-88 de
#' quatro dígitos correspondente ao rótulo do TSE. O ISCO-88 do dicionário
#' **não muda** — muda só o destino na ISCO-08, e por isso ISEI-88, EGP, classe
#' e estrato ficam exatamente como estavam.
#' @noRd
.ISCO08_REFINADO_TSE <- c(
  # --- ISCO-88 7400 -> submajor 75, no ramo que o rótulo nomeia -------------
  "713" = "7520",  # CARPINTEIRO, MARCENEIRO (7422 marceneiros -> 7520)
  "228" = "7510",  # PADEIRO, CONFEITEIRO (7412 -> 7510)
  "710" = "7510",  # TRAB. DE FABRICAÇÃO DE ALIMENTOS E BEBIDAS (7410 -> 7510)
  "591" = "7530",  # ALFAIATE E COSTUREIRO (7433/7436 -> submajor 753)
  "705" = "7530",  # TRAB. DE FABRICAÇÃO DE ROUPAS (7430 -> 7530)
  "188" = "7530",  # FIANDEIRO, TECELÃO, TINGIDOR (743 -> 7530)
  "241" = "7530",  # TAPECEIRO (7437 estofadores -> 7534, em 753)
  "186" = "7530",  # ESTOFADOR (7437 -> 7534, em 753)
  "149" = "7530",  # CHAPELEIRO (7433 chapeleiros -> 7531, em 753)
  "715" = "7536",  # CALÇADOS E ARTEFATOS DE COURO (7442 -> 7536, único)
  "250" = "7535",  # CURTIMENTO (7441 curtidores -> 7535, único)
  # --- ISCO-88 2220 -> a profissão de saúde que o rótulo nomeia -------------
  "115" = "2261",  # ODONTÓLOGO (2222 -> 2261, único)
  "112" = "2250",  # VETERINÁRIO (2223 -> 2250, único)
  "117" = "2262",  # FARMACÊUTICO (2224 -> 2262, único)
  # --- ISCO-88 2320: dos dois destinos da OIT, o que o rótulo diz -----------
  "235" = "2320",  # PROFESSOR E INSTRUTOR DE FORMAÇÃO PROFISSIONAL
  # --- ISCO-88 3470 -> nível profissional, não técnico ----------------------
  "164" = "2652",  # MÚSICO (2453 -> 2652, único)
  "163" = "2652",  # CANTOR E COMPOSITOR (2453 -> 2652, único)
  "165" = "2653"   # COREÓGRAFO E BAILARINO (2454 -> 2653, único)
)

#' Aplica, na ISCO-08, as correções que dependem do código do TSE
#'
#' São duas, e a segunda é a que importa.
#'
#' **1. Refinamento por rótulo** (`.ISCO08_REFINADO_TSE`, veja lá).
#'
#' **2. Promoção do proprietário — `iskopromo.sps`.** A ISCO-08 aboliu o grande
#' grupo 13 da ISCO-88 ("general managers", o proprietário-dirigente de empresa
#' pequena) e devolveu essas pessoas à ocupação que de fato exercem: a tabela da
#' OIT manda ISCO-88 1311 para onze destinos, todos no grande grupo 6, e o
#' pacote reproduz isso fielmente (`isco88_para_isco08("1311")` continua 6130).
#' Só que o dado do TSE **sabe** que aquela pessoa é proprietária — é o `SEMPL`
#' do ISMF, guardado em `tse_isco$proprietario` —, e é exatamente para esse caso
#' que Ganzeboom publica `iskopromo.sps`, cuja primeira regra é:
#'
#' ```
#' do if (sss eq 2).       /* sempl = 2: conta própria com empregados */
#' . recode iii (6130=1311).
#' end if.
#' ```
#'
#' O pacote já aplicava essa mesma linha no caminho do EGP (veja `R/egp.R`);
#' faltava aplicá-la no caminho da ISCO-08. Sem ela o crosswalk se contradizia:
#' 234, 602 e 901 recebiam EGP `IVc: proprietário rural`, estrato "Classe alta"
#' e componente "Alta proprietária" **e** o ISEI-08 de trabalhador agrícola
#' (17,79) — as únicas três linhas da tabela em que "Classe alta" convivia com
#' ISEI-08 abaixo de 40. Com a promoção, ISCO-08 1311 (*agricultural and
#' forestry production managers*), ISEI-08 49,48, ao lado dos irmãos 902–905
#' (51,01), que o TSE construiu como série homogênea.
#' @noRd
.corrige_isco08_tse <- function(cod, isco08) {
  if (!length(isco08)) return(isco08)
  # (1) refinamento por rótulo; NA de vigência ou de código desconhecido fica NA
  j  <- match(cod, names(.ISCO08_REFINADO_TSE))
  ok <- !is.na(isco08) & !is.na(j)
  isco08[ok] <- unname(.ISCO08_REFINADO_TSE[j[ok]])
  # (2) iskopromo.sps: sempl == 2 & isco == 6130 -> 1311
  prop  <- ocupacoesBR::tse_isco$proprietario[match(cod, ocupacoesBR::tse_isco$cod_tse)]
  promo <- !is.na(isco08) & isco08 == "6130" & !is.na(prop) & prop
  isco08[promo] <- "1311"
  isco08
}

#' ISCO-08 da ocupação declarada ao TSE
#'
#' @section Não é a mera composição das duas etapas:
#' Em 21 dos 275 códigos o resultado difere de
#' `isco88_para_isco08(tse_para_isco(cod))`, porque o código do TSE carrega
#' informação que a ponte genérica não vê: a marca de proprietário — o `SEMPL`
#' do ISMF, que aciona a promoção de `iskopromo.sps` — e um rótulo mais fino do
#' que o código ISCO-88 agregado a que o dicionário o associa. A ponte
#' [isco88_para_isco08()] permanece intacta e continua devolvendo o destino
#' oficial da OIT para quem entra pela ISCO-88. Veja `NEWS.md` da versão 0.2.1
#' para a lista dos 21, com valor antigo, valor novo e fonte de cada um.
#'
#' @inheritParams tse_para_isco
#' @inheritParams isco88_para_isco08
#' @return Vetor de texto, ou um `data.frame` se `com_ambiguidade = TRUE`.
#' @examples
#' tse_para_isco08(c(111, 169))
#' # o proprietário rural não é rebaixado a trabalhador agrícola:
#' tse_para_isco08(234)
#' isco88_para_isco08("1311")
#' @export
tse_para_isco08 <- function(cod, com_ambiguidade = FALSE, ano = NULL) {
  k <- .norm_tse(cod)
  r <- isco88_para_isco08(tse_para_isco(k, ano), com_ambiguidade)
  if (!com_ambiguidade) return(.corrige_isco08_tse(k, r))
  # `n_alternativas` continua descrevendo a ponte ISCO-88 -> ISCO-08, que é o
  # que a coluna promete; a correção acima é do passo TSE -> ISCO-08.
  r$isco08 <- .corrige_isco08_tse(k, r$isco08)
  r
}

#' ISEI-08 da ocupação declarada ao TSE
#'
#' Escore ISEI ancorado na ISCO-08, obtido pela ponte a partir do ISCO-88.
#'
#' @section Quando *não* usar:
#' Para comparar candidaturas entre si, prefira [tse_para_isei()], na ISCO-88:
#' o pacote é ancorado nela e a ponte introduz erro. O ISEI-08 serve para juntar
#' o dado eleitoral a fontes que já classificam por ISCO-08 — a PNAD Contínua,
#' via COD, é o caso típico. As duas réguas correlacionam-se fortemente no
#' agregado (`isei08 = 1,266 x isei88 - 12,72`, r = 0,97, n = 258), e a maior
#' parte das diferenças de 5 a 15 pontos é o próprio reescalonamento, não erro.
#' Esses coeficientes valem para a ponte **corrigida** por
#' `.corrige_isco08_tse()`; sem ela, seriam 1,212 e -9,80, e foram esses os que
#' esta seção publicou até a auditoria de 05/09/2026. Mas alguns
#' deslocamentos individuais são grandes **e reais**: o enfermeiro (código 113)
#' sobe 26 pontos, de 43 para 68,7 — não por reclassificação, já que a ISCO-88 o
#' punha em 2230, no grande grupo dos profissionais, e o pacote o leva ao
#' agregado 2220 da ISCO-08, mas porque o ISEI-08 foi reestimado sobre o ISSP de
#' 2002-2007, com os dois sexos, e reavalia as ocupações de cuidado; o
#' vendedor e o comerciário (411, 170) caem 13, de 43 para 29,7, porque a
#' revisão reavaliou o grupo 52 inteiro. Uma série que troque de âncora no meio
#' mede essas duas coisas como se fossem mobilidade.
#'
#' @inheritParams tse_para_isco
#' @return Vetor numerico com o escore ISEI-08, na escala de Ganzeboom e Treiman reestimada sobre o ISSP de 2002-2007 (de 11 a 89 neste dicionario). Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela [isco08_medidas].
#' @examples
#' data.frame(cod = c(111, 113), isei88 = tse_para_isei(c(111, 113)),
#'            isei08 = tse_para_isei08(c(111, 113)))
#' @export
tse_para_isei08 <- function(cod, ano = NULL) {
  .busca(tse_para_isco08(cod, ano = ano), ocupacoesBR::isco08_medidas, "isco08", "isei08")
}

#' SIOPS-08 da ocupação declarada ao TSE
#'
#' @inheritParams tse_para_isco
#' @return Vetor numerico com o escore SIOPS (Standard International Occupational Prestige Scale) de Treiman, na escala de 0 a 100 do ISMF: quanto maior, mais prestigiada a ocupacao na media dos estudos originais. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela.
#' @examples
#' tse_para_siops08(c(111, 169))
#' @export
tse_para_siops08 <- function(cod, ano = NULL) {
  .busca(tse_para_isco08(cod, ano = ano), ocupacoesBR::isco08_medidas, "isco08", "siops08")
}
