# ---------------------------------------------------------------------------
# a perna do IBGE: COD -> ISCO-08 -> tudo
# ---------------------------------------------------------------------------
# A COD (Classificacao de Ocupacoes para Pesquisas Domiciliares) e a
# classificacao da PNAD Continua e do Censo. Ela e construida SOBRE a ISCO-08,
# de modo que a correspondencia e quase toda identidade — o que faz desta a
# porta de entrada mais barata e menos lossy do pacote, e nao a mais cara.

#' Normaliza um codigo da COD (quatro digitos)
#' @noRd
.norm_cod <- function(cod) {
  .checa_vetor(cod, "cod")
  if (is.factor(cod)) cod <- as.character(cod)
  num <- is.numeric(cod)
  if (num) cod[!is.finite(cod)] <- NA
  cod <- as.character(cod)
  if (!length(cod)) return(character(0))
  .por_unico(cod, function(u) {
    x <- trimws(u)
    x[is.na(x) | x == ""] <- NA_character_
    x[.e_sentinela(x)] <- NA_character_
    lim <- gsub("[-.[:space:]]", "", x)
    sujo <- !is.na(lim) & grepl("\\D", lim)
    lim[sujo] <- NA_character_
    # a leitura numerica come o zero a esquerda: 0411 (policia militar) chega
    # como 411. So a origem numerica pode te-lo perdido.
    if (num) {
      curto <- !is.na(lim) & nchar(lim) %in% c(2L, 3L)
      lim[curto] <- formatC(as.integer(lim[curto]), width = 4L, flag = "0",
                            format = "d")
    }
    mau <- (!is.na(lim) & nchar(lim) != 4L) | sujo
    .trata_invalidos(lim, mau, u, "COD", "deve ter 4 digitos")
  })
}

#' Traduz a COD do IBGE em ISCO-08
#'
#' Converte o codigo da Classificacao de Ocupacoes para Pesquisas Domiciliares
#' — a da PNAD Continua e do Censo Demografico — no codigo ISCO-08.
#'
#' @section Por que esta perna e quase gratuita:
#' A COD e construida sobre a ISCO-08, e por isso **428 dos seus 434 grupos de
#' base sao identicos ao codigo internacional**. Nao ha tabua de conversao a
#' consultar nem correspondencia a construir: a traducao e identidade, e o que
#' resta e decidir as seis adaptacoes brasileiras.
#'
#' Compare com a perna da CBO, que exige a tabua do Ministerio do Trabalho e
#' cobre metade do seu universo. A diferenca nao e de esforco: e de desenho das
#' classificacoes.
#'
#' @section As seis adaptacoes:
#' \describe{
#'   \item{`0411`, `0412`, `0511`, `0512`}{policia e bombeiro militar. Vao para
#'     `5412` e `5411`, do grande grupo 5 (servicos protetivos), e nao para o
#'     grande grupo 0 (forcas armadas): a PM e o BM brasileiros sao
#'     militarizados em estatuto, mas exercem servico protetivo civil, e e a
#'     funcao que a classificacao mede. **A distincao entre oficial e praca se
#'     perde** — a ISCO-08 nao a tem, e no Brasil ela e um degrau de status
#'     real. Quem precisar dela tem de trata-la fora do ISEI.}
#'   \item{`5168`}{trabalhadores do sexo, para `5169` (servicos pessoais nao
#'     classificados em outra parte).}
#'   \item{`6225`}{pescadores, para o **subgrupo** `6220`. A COD funde numa
#'     rubrica o que a ISCO-08 reparte em quatro (aquicultura, pesca costeira,
#'     pesca de alto-mar, caca), que vao de ISEI 11 a 21. Escolher uma seria
#'     arbitrario; o subgrupo e a forma arredondada que o proprio ISMF publica.}
#' }
#'
#' @section O unico buraco, e ele vem da fonte:
#' A traducao e completa — os 434 grupos de base chegam a ISCO-08 e a ISCO-88.
#' Mas as FORCAS ARMADAS (`0110` e `0210`) ficam sem **ISEI-88, prestigio-88 e
#' EGP**, porque o ISMF nao pontua o ISCO-88 `0110`. As medidas ancoradas na
#' ISCO-08 existem — `cod_para_isei08("0110")` e 60,9 (oficiais) e `("0210")`,
#' 51,6 —, porque o `isqoisei08.sps` pontua a hierarquia militar da ISCO-08; a
#' lacuna e so na ponte de volta a ISCO-88, e devolver `NA` ali e o
#' comportamento correto, nao um escore inventado.
#'
#' @param cod Vetor de codigos da COD, de quatro digitos.
#' @return Vetor de texto com o codigo ISCO-08 de quatro digitos. Mesmo
#'   comprimento e ordem do vetor de entrada; `NA` onde o codigo da COD nao
#'   tem correspondencia na tabela [cod_isco08].
#' @seealso [cod_para_isei08()], [cod_para_isco()], [crosswalk_cod()]
#' @examples
#' cod_para_isco08(c("2211", "0411", "6225"))
#' @export
cod_para_isco08 <- function(cod) {
  .busca(.norm_cod(cod), ocupacoesBR::cod_isco08, "cod", "isco08",
         o_que = "cod_isco08")
}

#' Converte ISCO-08 em ISCO-88
#'
#' A ponte de volta, do modulo `isco0888.sps` do ISMF.
#'
#' @section A ida e a volta nao se cancelam:
#' Levar um codigo da ISCO-88 a ISCO-08 e traze-lo de volta devolve o ponto de
#' partida em apenas **69% dos casos**. Isso nao e defeito de implementacao: e
#' propriedade da concordancia da Organizacao Internacional do Trabalho, que
#' reparte e funde categorias entre as duas revisoes. Um terco dos codigos nao
#' tem volta ao mesmo lugar, e quem encadeia as duas pontes precisa saber disso.
#'
#' @param isco08 Vetor de codigos ISCO-08.
#' @return Vetor de texto com o codigo ISCO-88 de quatro digitos. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo ISCO-08 nao tem correspondencia na ponte reversa (veja a secao acima sobre a ida e a volta).
#' @examples
#' isco08_para_isco88(c("2211", "5412"))
#' @export
isco08_para_isco88 <- function(isco08) {
  .busca(.norm_isco(isco08), ocupacoesBR::isco08_isco88, "isco08", "isco88",
         o_que = "isco08_isco88")
}

#' ISEI-08 a partir da COD
#' @inheritParams cod_para_isco08
#' @return Vetor numerico com o escore ISEI-08, na escala de Ganzeboom e Treiman reestimada sobre o ISSP de 2002-2007 (de 11 a 89 neste dicionario). Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela [isco08_medidas].
#' @examples
#' cod_para_isei08(c("2211", "9629"))
#' @export
cod_para_isei08 <- function(cod) {
  .busca(cod_para_isco08(cod), ocupacoesBR::isco08_medidas, "isco08", "isei08")
}

#' Prestigio de Treiman ancorado na ISCO-08, a partir da COD
#' @inheritParams cod_para_isco08
#' @return Vetor numerico com o escore SIOPS (Standard International Occupational Prestige Scale) de Treiman, na escala de 0 a 100 do ISMF: quanto maior, mais prestigiada a ocupacao na media dos estudos originais. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela.
#' @examples
#' cod_para_prestigio08(c("2211", "9629"))
#' @export
cod_para_prestigio08 <- function(cod) {
  .busca(cod_para_isco08(cod), ocupacoesBR::isco08_medidas, "isco08", "siops08")
}

#' ISCO-88 a partir da COD
#'
#' Passa pela ISCO-08 e desce pela ponte reversa. E o caminho para o ISEI-88 e
#' para o EGP a partir da PNAD Continua e do Censo.
#'
#' E tambem o ponto em que a adaptacao brasileira da COD se desfaz sem que voce
#' peca: o IBGE aloca a policia militar e o corpo de bombeiros militar ao
#' grande grupo 0, o das forcas armadas, e esta funcao os devolve a 5162 e
#' 5161, que e onde os codigos 145, 232, 233 e 258 do cadastro do TSE tambem
#' aterrissam. Quem ler o primeiro digito da COD em vez de traduzir poe o
#' policial militar da populacao num grande grupo e o candidato policial
#' militar em outro. O exemplo abaixo mostra os dois caminhos.
#'
#' @inheritParams cod_para_isco08
#' @return Vetor de texto com o codigo ISCO-88 de quatro digitos. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo da COD nao tem correspondencia.
#' @seealso O artigo *Comparar duas fontes*, no site do pacote, que trata das
#'   oito decisoes de uma comparacao entre candidaturas e populacao e explica
#'   esta adaptacao em detalhe:
#'   <https://moraespeixoto.github.io/ocupacoesBR/articles/comparar-fontes.html>
#' @examples
#' cod_para_isco(c("2211", "0411"))
#'
#' # a adaptacao da COD, desfeita: 0411 e policia militar
#' cod_para_isco08("0411")   # 5412, servico protetivo na ISCO-08
#' cod_para_isco("0411")     # 5162, o mesmo destino dos codigos do TSE
#' @export
cod_para_isco <- function(cod) isco08_para_isco88(cod_para_isco08(cod))

#' ISEI-88 a partir da COD
#'
#' Use este, e nao [cod_para_isei08()], para comparar com dado eleitoral: o
#' pacote e ancorado na ISCO-88 e e nela que o TSE aterrissa.
#'
#' @inheritParams cod_para_isco08
#' @return Vetor numerico com o escore ISEI-88, na escala de Ganzeboom e Treiman (de 16 a 90 neste dicionario): quanto maior, mais a ocupacao converte escolaridade em renda. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela [isco88_medidas].
#' @examples
#' cod_para_isei(c("2211", "9629"))
#' @export
cod_para_isei <- function(cod) {
  .busca(cod_para_isco(cod), ocupacoesBR::isco88_medidas, "isco88", "isei88")
}

#' Prestigio de Treiman a partir da COD
#' @inheritParams cod_para_isco08
#' @return Vetor numerico com o escore SIOPS (Standard International Occupational Prestige Scale) de Treiman, na escala de 0 a 100 do ISMF: quanto maior, mais prestigiada a ocupacao na media dos estudos originais. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela.
#' @examples
#' cod_para_prestigio(c("2211", "9629"))
#' @export
cod_para_prestigio <- function(cod) {
  .busca(cod_para_isco(cod), ocupacoesBR::isco88_medidas, "isco88", "siops88")
}

#' Classe EGP a partir da COD
#'
#' A PNAD Continua tem posicao na ocupacao (V4012) e o numero de empregados do
#' empregador, o que recupera a pequena burguesia e **separa IVa de IVb** — a
#' distincao que pela porta do TSE fica indeterminada. Passe-os.
#'
#' O que ela nao tem e a supervisao exercida sobre assalariados, que e o que
#' define V (supervisores manuais) e governa as promocoes entre I e II. Por essa
#' porta o EGP fica mais completo que pelas outras, mas nao completo.
#'
#' @inheritParams cod_para_isco08
#' @inheritParams isco88_para_egp
#' @return Se `rotulo = TRUE` (padrao), vetor de texto com o rotulo da classe
#'   EGP (por exemplo "I: dirigentes e profissionais superiores"); se
#'   `rotulo = FALSE`, o codigo inteiro da classe (1 a 11, ou menos nas
#'   versoes colapsadas). Mesmo comprimento e ordem do vetor de entrada; `NA`
#'   onde o codigo de origem nao tem correspondencia.
#' @examples
#' cod_para_egp("2211", avisar = FALSE)
#' @export
cod_para_egp <- function(cod, conta_propria = NULL, n_supervisionados = NULL,
                         n_classes = 11, rotulo = TRUE, avisar = TRUE) {
  isco88_para_egp(cod_para_isco(cod), conta_propria, n_supervisionados,
                  n_classes, rotulo, avisar)
}

#' Verifica a cobertura de codigos da COD
#' @param cod Vetor de codigos da COD observados no seu dado.
#' @param silencioso Se `TRUE`, nao escreve a mensagem de sucesso.
#' @return Invisivelmente, `TRUE`, se todo codigo observado tem entrada na tabela. O valor em si nao carrega informacao alem de confirmar que nao houve erro: a funcao para com `stop()`, nomeando os codigos sem entrada, quando a cobertura falha, e a mensagem de sucesso (a menos que `silencioso = TRUE`) e' o efeito colateral que interessa.
#' @examples
#' checa_cobertura_cod(c("2211", "0411"))
#' @export
checa_cobertura_cod <- function(cod, silencioso = FALSE) {
  obs <- unique(.norm_cod(cod))
  obs <- obs[!is.na(obs)]
  if (!length(obs))
    stop("nenhum c\u00f3digo da COD v\u00e1lido em `cod`",
         if (is.null(cod)) " (o vetor \u00e9 NULL \u2014 confira o nome da coluna)"
         else if (!length(cod)) " (o vetor est\u00e1 vazio)"
         else " (todos os valores s\u00e3o NA)", ".", call. = FALSE)
  fora <- setdiff(obs, ocupacoesBR::cod_isco08$cod)
  if (length(fora))
    stop("c\u00f3digo(s) sem entrada na COD: ",
         paste(utils::head(fora, 20), collapse = ", "),
         if (length(fora) > 20) sprintf(" (e mais %d)", length(fora) - 20) else "",
         ".\nA COD tem 434 grupos de base; confira se a coluna \u00e9 o grupo de ",
         "base e n\u00e3o o subgrupo.", call. = FALSE)
  if (!silencioso)
    message(sprintf("cobertura COD: %d c\u00f3digos, todos na tabela.", length(obs)))
  invisible(TRUE)
}

#' Tabela completa de traducao a partir da COD
#'
#' @param cod Vetor opcional de codigos. Se omitido, devolve a tabela inteira.
#' @return `data.frame` com COD, titulo, ISCO-08, ISCO-88, as duas versoes do
#'   ISEI, o prestigio, o EGP e o tipo de correspondencia.
#'
#' @section A coluna `egp` sai degradada, e em silêncio:
#' O EGP não é função só da ocupação: as suas regras pedem a posição no emprego
#' e o número de subordinados, e nenhum dos dois existe num código de COD da PNAD. A
#' coluna é calculada sem eles, e a consequência não é ruído — **IVa, IVb e V
#' saem estruturalmente vazias**, de modo que a pequena burguesia aparece
#' contada como classe de serviço. Isso é inversão de classe, não
#' arredondamento.
#'
#' A chamada silencia o aviso que [isco88_para_egp()] emitiria, porque repeti-lo
#' uma vez por linha seria inútil; a ressalva passou a viver aqui, na auditoria
#' de 05/09/2026. Para publicar, use os colapsos de 5 ou 3 classes, onde IVa e
#' IVb se fundem a categorias que existem, e considere [isco_posicao_br] como
#' prior empírico da posição no emprego. Compare com [crosswalk_tse()], que é
#' a única das quatro tabelas em que o EGP sai completo, porque o dicionário
#' do TSE marca quem trabalha por conta própria.
#' @examples
#' head(crosswalk_cod())
#' crosswalk_cod(c("2211", "0411", "6225"))
#' @export
crosswalk_cod <- function(cod = NULL) {
  k <- if (is.null(cod)) ocupacoesBR::cod_isco08$cod else .norm_cod(cod)
  i <- match(k, ocupacoesBR::cod_isco08$cod)
  .avisa_ausentes(k, i, "cod_isco08")
  d    <- ocupacoesBR::cod_isco08
  i08  <- d$isco08[i]
  i88  <- suppressWarnings(isco08_para_isco88(i08))
  m08  <- match(i08, ocupacoesBR::isco08_medidas$isco08)
  m88  <- match(i88, ocupacoesBR::isco88_medidas$isco88)
  data.frame(
    cod             = k,
    titulo          = d$titulo[i],
    isco08          = i08,
    isco88          = i88,
    isei08          = ocupacoesBR::isco08_medidas$isei08[m08],
    isei_br         = ocupacoesBR::isco08_isei_br$isei_br[
                        match(i08, ocupacoesBR::isco08_isei_br$isco08)],
    isei88          = ocupacoesBR::isco88_medidas$isei88[m88],
    prestigio88     = ocupacoesBR::isco88_medidas$siops88[m88],
    egp             = isco88_para_egp(i88, avisar = FALSE),
    correspondencia = d$correspondencia[i],
    stringsAsFactors = FALSE, row.names = NULL)
}
