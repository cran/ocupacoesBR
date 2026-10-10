# ---------------------------------------------------------------------------
# EGP — porte fiel de iskopromo.sps + iskoegp.sps (ISMF, Ganzeboom & Treiman)
# ---------------------------------------------------------------------------

#' Rótulos das onze classes do EGP
#' @noRd
.EGP11 <- c("I: dirigentes e profissionais superiores",
            "II: dirigentes e profissionais inferiores",
            "IIIa: n\u00e3o manual de rotina",
            "IIIb: vendas e servi\u00e7os de baixa qualifica\u00e7\u00e3o",
            "IVa: conta pr\u00f3pria com empregados",
            "IVb: conta pr\u00f3pria sem empregados",
            "V: t\u00e9cnicos de n\u00edvel inferior e supervisores manuais",
            "VI: trabalhador manual qualificado",
            "VIIa: trabalhador manual n\u00e3o qualificado",
            "VIIb: trabalhador agr\u00edcola",
            "IVc: propriet\u00e1rio rural")

# ---------------------------------------------------------------------------
# Colapsos do EGP-11.
# FONTE: Erikson, R. & Goldthorpe, J. H. (1992). "The class schema", em
# *The Constant Flux: A Study of Class Mobility in Industrial Societies*.
# Oxford: Clarendon Press, pp. 38-39 — a tabela "The class schema", coluna
# "Collapsed versions".
#
# A ordem dos índices aqui é a do ISMF (1=I, 2=II, 3=IIIa, 4=IIIb, 5=IVa,
# 6=IVb, 7=V, 8=VI, 9=VIIa, 10=VIIb, 11=IVc). Atenção ao comparar com outras
# implementações: várias numeram IVc na sétima posição, logo depois de IVb, e
# os vetores parecem divergir quando na verdade concordam.
#
#   7 classes: I+II | IIIa+IIIb | IVa+IVb | IVc | V+VI | VIIa | VIIb
#   5 classes: I..IIIb | IVa+IVb | IVc+VIIb | V+VI | VIIa
#   3 classes: não manual (I..IVb) | manual (V,VI,VIIa) | agrícola (IVc,VIIb)
# ---------------------------------------------------------------------------
#            I  II IIIa IIIb IVa IVb  V  VI VIIa VIIb IVc
.EGP7 <- c(  1,  1,   2,   2,  3,  3,  5,  5,   6,   7,  4)
.EGP5 <- c(  1,  1,   1,   1,  2,  2,  4,  4,   5,   3,  3)
.EGP3 <- c(  1,  1,   1,   1,  1,  1,  2,  2,   2,   3,  3)

.EGP7L <- c("I+II: classe de servi\u00e7o",
            "III: n\u00e3o manual de rotina",
            "IVab: pequena burguesia",
            "IVc: agricultores por conta pr\u00f3pria",
            "V+VI: trabalhadores qualificados",
            "VIIa: trabalhadores n\u00e3o qualificados",
            "VIIb: trabalhadores agr\u00edcolas")
.EGP5L <- c("I-III: colarinho branco",
            "IVab: pequena burguesia",
            "IVc+VIIb: agr\u00edcolas",
            "V+VI: trabalhadores qualificados",
            "VIIa: trabalhadores n\u00e3o qualificados")
.EGP3L <- c("N\u00e3o manuais", "Manuais", "Agr\u00edcolas")

#' Traduz ISCO-88 no esquema de classes EGP
#'
#' Implementação das sintaxes `iskopromo.sps` e `iskoegp.sps` do International
#' Stratification and Mobility File, de Ganzeboom e Treiman.
#'
#' @section O que o EGP exige e o TSE não tem:
#' O EGP não é uma função só da ocupação. As suas regras usam duas variáveis
#' adicionais: a posição na ocupação (`conta_propria`) e o número de pessoas
#' supervisionadas (`n_supervisionados`). Sem elas, **IVa e IVb — a pequena
#' burguesia — ficam estruturalmente vazias**, e V (técnicos de nível inferior e
#' supervisores manuais) sai
#' fortemente subestimada, porque só dois códigos ISCO a produzem sem a
#' variável de supervisão. Como o formulário do TSE pergunta apenas a ocupação,
#' quem parte dele obtém uma versão degradada do esquema, e a função avisa
#' quando é esse o caso.
#'
#' Partindo só da ocupação, o resultado **não deve ser publicado como uma
#' tabela EGP de onze classes**. Os colapsos de 5 e 3 classes, em que IVa e IVb
#' se fundem a categorias que existem, são o uso defensável.
#'
#' Essa não é uma limitação do pacote, e sim do dado: é exatamente o ponto que
#' Carvalhaes (2015) levanta ao avaliar o EGP no Brasil, onde a categoria de
#' conta própria é a que o esquema melhor capta — e é justamente a que se perde.
#'
#' @param isco Vetor de códigos ISCO-88, preferencialmente com quatro dígitos.
#'   Códigos de 2 ou 3 dígitos são expandidos com zeros à DIREITA, para as
#'   formas arredondadas que as tabelas do ISMF já contêm (24 vira 2400). O
#'   grande grupo 0 (forças armadas) é a exceção: o ISMF o escreve com zero à
#'   ESQUERDA (`0110`), de modo que `110` é ambíguo. Nesses casos a função lê a
#'   forma hierárquica e **avisa**; informe quatro dígitos para desempatar.
#' @param conta_propria Vetor lógico opcional: a pessoa trabalha por conta
#'   própria ou é empregadora (`TRUE`) ou é empregada (`FALSE`).
#' @param n_supervisionados Vetor numérico opcional com o número de pessoas
#'   supervisionadas.
#' @param n_classes Número de classes do resultado: 11 (padrão), 7, 5 ou 3.
#' @param rotulo Se `TRUE` (padrão), devolve rótulos — em todas as versões,
#'   inclusive nas colapsadas; se `FALSE`, os códigos inteiros.
#' @param avisar Se `TRUE` (padrão), avisa quando `conta_propria` ou
#'   `n_supervisionados` não são fornecidos.
#' @return Vetor de texto (ou inteiro, se `rotulo = FALSE`).
#' @section Os colapsos de 7, 5 e 3 classes:
#' Vêm da tabela "The class schema" de Erikson e Goldthorpe (1992), pp. 38--39.
#' Cuidado ao comparar com outras implementações: várias numeram IVc na sétima
#' posição, e os vetores parecem divergir quando na verdade concordam.
#' @references
#' Erikson, R.; Goldthorpe, J. H. (1992). "The class schema", em
#' *The Constant Flux: A Study of Class Mobility in Industrial Societies*.
#' Oxford: Clarendon Press, pp. 38--39.
#'
#' Ganzeboom, H. B. G.; Treiman, D. J. (1996). Internationally comparable
#' measures of occupational status for the 1988 International Standard
#' Classification of Occupations. *Social Science Research*, 25(3), 201--239.
#'
#' Carvalhaes, F. (2015). A tipologia ocupacional
#' Erikson-Goldthorpe-Portocarero (EGP): uma avaliação analítica e empírica.
#' *Sociedade e Estado*, 30(3), 673--703.
#' @return Se `rotulo = TRUE` (padrão), vetor de texto com o rótulo da classe
#'   EGP (por exemplo "I: dirigentes e profissionais superiores"); se
#'   `rotulo = FALSE`, o código inteiro da classe (1 a 11, ou menos nas
#'   versões colapsadas, conforme `n_classes`). Mesmo comprimento e ordem do
#'   vetor de entrada; `NA` onde o código ISCO-88 não tem correspondência.
#' @examples
#' isco88_para_egp(c("2211", "1300", "6100"), avisar = FALSE)
#'
#' # com as variáveis que o esquema realmente pede, a pequena burguesia aparece
#' isco88_para_egp(c("5220", "5220"),
#'                 conta_propria = c(TRUE, TRUE),
#'                 n_supervisionados = c(0, 5))
#' @export
isco88_para_egp <- function(isco, conta_propria = NULL,
                            n_supervisionados = NULL, n_classes = 11,
                            rotulo = TRUE, avisar = TRUE) {
  if (length(n_classes) != 1L || !isTRUE(n_classes %in% c(11, 7, 5, 3)))
    stop("`n_classes` deve ser um \u00fanico valor: 11, 7, 5 ou 3.", call. = FALSE)
  n <- length(isco)
  # A guarda de valor vem ANTES do aviso: quem passou o ano na posicao de
  # `conta_propria` nao precisa ouvir que o EGP saiu incompleto — precisa saber
  # que a chamada esta errada. Avisar primeiro e falhar depois deixa no console
  # um aviso que descreve um calculo que nunca aconteceu.
  .guarda_binaria(conta_propria, "conta_propria")
  # O aviso diz exatamente o que falta. Com `conta_propria` informada — e
  # tse_para_egp() a informa a partir da marca `conta_propria` — IVb deixa de ser
  # vazia, e repetir "IVa e IVb ficam VAZIAS" seria mentir na direcao oposta.
  if (avisar) {
    sem_cp <- is.null(conta_propria)
    sem_sv <- is.null(n_supervisionados)
    if (sem_cp || sem_sv) {
      falta <- paste(c(if (sem_cp) "`conta_propria`",
                       if (sem_sv) "`n_supervisionados`"), collapse = " e ")
      dano <- if (sem_cp)
        "As classes IVa e IVb (conta pr\u00f3pria) ficam VAZIAS e V fica subestimada"
      else
        paste0("A divis\u00e3o entre IVa (com empregados) e IVb (sem) fica ",
               "indeterminada \u2014 todos caem em IVb \u2014 e V fica ",
               "subestimada; para publicar prefira n_classes = 7 ou 5")
      .aviso(paste0("EGP calculado sem ", falta, ". ", dano,
                    "; veja ?isco88_para_egp."), "egp_incompleto")
    }
  }
  if (!is.null(conta_propria) && !is.logical(conta_propria) &&
      !is.numeric(conta_propria))
    stop("`conta_propria` deve ser l\u00f3gico (ou 0/1).", call. = FALSE)
  # `factor` E' numerico para as.numeric() e NAO e' para is.numeric(): sem esta
  # guarda, as.numeric(factor(c("0","5","20"))) devolve 1 3 2 — os indices dos
  # niveis — e a tabela de classe sai errada, calada. `conta_propria` tinha
  # guarda de tipo desde sempre; esta faltava, e read.csv(stringsAsFactors=TRUE)
  # ou haven::read_sav produzem exatamente o caso.
  if (is.factor(n_supervisionados))
    stop("`n_supervisionados` \u00e9 um factor; os n\u00edveis seriam lidos ",
         "como \u00edndices, n\u00e3o como contagens. Use ",
         "as.numeric(as.character(x)).", call. = FALSE)
  if (!is.null(n_supervisionados) && !is.numeric(n_supervisionados) &&
      !is.character(n_supervisionados) && !is.logical(n_supervisionados))
    stop("`n_supervisionados` deve ser num\u00e9rico; recebido: ",
         class(n_supervisionados)[1], ".", call. = FALSE)
  # --- deduplicacao --------------------------------------------------------
  # Esta era a unica funcao vetorial do pacote que nao passava por .por_unico():
  # ~20 ifelse() sobre o vetor inteiro, cada um alocando copia completa. Um
  # vetor de 8 milhoes de vinculos tem algumas centenas de combinacoes
  # distintas de (isco, posicao, supervisao). Medido: 6,2 s -> 0,25 s e
  # 955 Mb -> 434 Mb, com resultado identical().
  #
  # A recursao vem DEPOIS das validacoes e dos avisos, e com avisar = FALSE,
  # para que o aviso de EGP incompleto saia uma vez e nao zero.
  if (length(isco) > 512L) {
    if (!is.null(conta_propria) && length(conta_propria) != length(isco))
      stop("`conta_propria` deve ter o comprimento de `isco`.", call. = FALSE)
    if (!is.null(n_supervisionados) &&
        length(n_supervisionados) != length(isco))
      stop("`n_supervisionados` deve ter o comprimento de `isco`.",
           call. = FALSE)
    chave <- paste(as.character(isco),
                   if (is.null(conta_propria)) "" else as.character(conta_propria),
                   if (is.null(n_supervisionados)) "" else
                     as.character(n_supervisionados),
                   sep = "\r")
    u <- !duplicated(chave)
    if (sum(u) < length(isco) / 4L)
      return(isco88_para_egp(
        isco[u],
        if (is.null(conta_propria)) NULL else conta_propria[u],
        if (is.null(n_supervisionados)) NULL else n_supervisionados[u],
        n_classes, rotulo, avisar = FALSE)[match(chave, chave[u])])
  }

  # SEMPL do ISMF: 1 = empregado, 2 = conta própria/empregador
  s  <- if (is.null(conta_propria)) rep(1L, n) else
          ifelse(!is.na(conta_propria) & conta_propria, 2L, 1L)
  # `n_supervisionados` inválido NÃO vira 0: imputar "não supervisiona ninguém"
  # é decisão substantiva, que empurra o caso para fora de V e de IVa.
  sv_na <- rep(FALSE, n)
  sv <- if (is.null(n_supervisionados)) rep(0L, n) else {
          v <- suppressWarnings(as.numeric(n_supervisionados))
          ruim <- is.na(v) & !is.na(n_supervisionados)
          if (any(ruim))
            .aviso(paste0("`n_supervisionados` n\u00e3o num\u00e9rico em ", sum(ruim),
                          " caso(s); esses casos voltam NA."),
                   "supervisao_invalida")
          sv_na <- is.na(v)
          ifelse(sv_na, 0L, as.integer(v))
        }
  if (length(s) != n || length(sv) != n)
    stop("`conta_propria` e `n_supervisionados` devem ter o comprimento de `isco`.",
         call. = FALSE)

  # o `suppressWarnings` envolvia `.norm_isco()` inteiro e engolia o aviso de
  # ISCO ambíguo que a documentação desta função promete por escrito — quem
  # passasse "110" querendo forças armadas recebia, calado, a classe I. Era
  # desnecessário: `.norm_isco` já deu stop() em tudo que não é dígito, então
  # `as.integer` sobre o que ela devolve nunca avisa.
  x  <- as.integer(.norm_isco(isco))
  na <- is.na(x)
  x[na] <- 0L

  # ---- iskopromo.sps: ajusta o próprio ISCO antes de classificar ------------
  x  <- ifelse(s == 2L & x == 6130L, 1311L, x)
  sv <- ifelse(x == 7510L & sv <= 0L, 5L, sv)
  x  <- ifelse(x >= 6100L & x <= 6133L & sv >= 1L, 1311L, x)
  x  <- ifelse(x >= 9200L & x <= 9213L & sv >  1L, 6132L, x)

  de   <- c(1311L, 1312L, 1313L, 1314L, 1315L, 1316L, 1317L, 1318L, 1319L)
  para <- c(1221L, 1222L, 1223L, 1224L, 1225L, 1226L, 1227L, 1228L, 1229L)
  alto <- sv >= 11L
  if (any(alto)) {
    j <- match(x, de); m <- alto & !is.na(j)
    x[m] <- para[j[m]]
    x <- ifelse(alto & x %in% c(1300L, 1310L), 1220L, x)
  }
  medio <- sv >= 1L & sv <= 10L
  if (any(medio)) {
    j <- match(x, para); m <- medio & !is.na(j)
    x[m] <- de[j[m]]
    x <- ifelse(medio & x %in% c(1200L, 1210L, 1220L), 1310L, x)
  }
  x <- ifelse((x == 1220L | (x >= 1222L & x <= 1229L)) & s == 2L & sv >= 11L,
              1210L, x)

  # ---- tabela-base iskoroot.sps --------------------------------------------
  e <- .busca(formatC(x, width = 4, flag = "0", format = "d"),
              ocupacoesBR::isco88_medidas, "isco88", "egp")

  # ---- iskoegp.sps: regras finais, na ordem original ------------------------
  p <- x >= 1000L & x <= 9299L                                  # "promotable"
  d <- (x >= 1300L & x <= 1319L) | (x >= 3400L & x <= 3439L) |
       (x >= 4000L & x <= 5230L)                                # "degradable"
  # Cada regra roda sobre o vetor inteiro; `%in% TRUE` descarta os NA sem
  # recorrer a subconjuntos de comprimentos diferentes.
  aplica <- function(cond, valor) {
    sel <- !is.na(e) & (cond %in% TRUE)
    e[sel] <<- valor
  }
  aplica(e == 3L & sv >= 1L, 2L)
  aplica((e == 3L | e == 2L) & s == 2L & d, 4L)
  aplica(e >= 7L & e <= 9L & s == 2L & p, 5L)
  aplica(e == 8L & sv >= 1L, 7L)
  aplica(e == 10L & s == 2L, 11L)
  aplica(e == 4L & sv <  1L, 5L)
  aplica(e == 5L & sv >= 1L, 4L)
  aplica((e >= 2L & e <= 4L) & sv >= 10L, 1L)
  # `recode (4=5)(5=6)` do SPSS é simultâneo, não sequencial
  e <- ifelse(is.na(e), NA_integer_, c(1, 2, 3, 5, 6, 6, 7, 8, 9, 10, 11)[e])
  # separação IIIa/IIIb (fix de maio de 2001)
  iiib <- !is.na(e) & e == 3L &
          (x == 4142L | x == 4190L | (x >= 4200L & x <= 4215L) |
           (x >= 5000L & x <= 5239L))
  e[iiib] <- 4L

  e[na | sv_na] <- NA_integer_
  rot <- .EGP11
  if (n_classes == 7)      { e <- .EGP7[e]; rot <- .EGP7L }
  else if (n_classes == 5) { e <- .EGP5[e]; rot <- .EGP5L }
  else if (n_classes == 3) { e <- .EGP3[e]; rot <- .EGP3L }
  if (!rotulo) return(as.integer(e))
  rot[e]
}

#' Classe EGP da ocupação declarada ao TSE
#'
#' Atalho de [tse_para_isco()] seguido de [isco88_para_egp()]. Leia
#' [isco88_para_egp()] antes de usar: partindo só do TSE, o EGP sai incompleto,
#' porque o formulário não pergunta supervisão.
#'
#' @section A posição no emprego que o dicionário conhece:
#' O TSE não pergunta posição na ocupação, mas alguns dos seus códigos
#' **nomeiam** no próprio rótulo quem trabalha por conta própria — comerciante,
#' empresário, pecuarista, proprietário de estabelecimento, e também o
#' agricultor e o pescador. O dicionário marca essa condição em
#' `tse_isco$conta_propria`, e é ela, não `proprietario`, que corresponde ao
#' `SEMPL = 2` das sintaxes do ISMF. As duas marcas são distintas desde
#' 07/2026: `proprietario` é o subconjunto que pertence à classe proprietária,
#' e o agricultor (601) e o pescador (604) estão fora dele sem deixarem de
#' trabalhar por conta própria. Enquanto eram uma coisa só, os dois caíam em
#' VIIb, o fundo do esquema, ao lado do assalariado rural.
#'
#' Por padrão (`usa_proprietario = TRUE` — o nome do argumento é anterior à
#' separação das duas marcas e foi mantido por compatibilidade) a função a
#' utiliza. São doze os códigos marcados, e sete deles mudam de classe por
#' causa dela. Cinco — 169, 902, 903, 904 e 905 — sairiam em II, a classe de
#' serviço assalariada, o que é uma inversão: a pequena burguesia contada como
#' classe de serviço. Os outros dois — 601 e 604 — sairiam em VIIb, ao lado do
#' assalariado rural.
#'
#' O que **continua** indeterminado é a divisão entre IVa (conta própria com
#' empregados) e IVb (sem), que exige o número de subordinados. Todos caem em
#' IVb. Para publicar, prefira `n_classes = 7` ou `5`, onde as duas se fundem
#' em IVab.
#'
#' @inheritParams tse_para_isco
#' @inheritParams isco88_para_egp
#' @param usa_proprietario Se `TRUE` (padrão) e `conta_propria` não for
#'   informado, usa a marca `proprietario` do dicionário como posição no
#'   emprego. Informar `conta_propria` explicitamente tem precedência.
#' @return Se `rotulo = TRUE` (padrao), vetor de texto com o rotulo da classe EGP (por exemplo "I: dirigentes e profissionais superiores"); se `rotulo = FALSE`, o codigo inteiro da classe (1 a 11, ou menos nas versoes colapsadas). Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo de origem nao tem correspondencia.
#' @examples
#' # 169 é COMERCIANTE: pequena burguesia, não classe de serviço
#' tse_para_egp(c(111, 169, 601), avisar = FALSE)
#' tse_para_egp(169, usa_proprietario = FALSE, avisar = FALSE)
#' @export
tse_para_egp <- function(cod, conta_propria = NULL, n_supervisionados = NULL,
                         n_classes = 11, rotulo = TRUE, avisar = TRUE,
                         usa_proprietario = TRUE, ano = NULL) {
  if (is.null(conta_propria) && isTRUE(usa_proprietario)) {
    i <- match(.norm_tse(cod), ocupacoesBR::tse_isco$cod_tse)
    # `conta_propria` e nao `proprietario`: sao marcas distintas desde 07/2026.
    # O agricultor (601) e o pescador (604) trabalham por conta propria — o
    # SEMPL = 2 que o EGP exige para chegar a IVc — sem pertencerem a classe
    # proprietaria do esquema. Enquanto as duas eram uma so, eles caiam em
    # VIIb, o fundo do esquema, ao lado do assalariado rural.
    conta_propria <- ocupacoesBR::tse_isco$conta_propria[i]
    conta_propria[is.na(conta_propria)] <- FALSE
  }
  isco88_para_egp(tse_para_isco(cod, ano), conta_propria, n_supervisionados,
                  n_classes, rotulo, avisar)
}
