# ---------------------------------------------------------------------------
# TSE -> ISCO-88 -> medidas de posição social
# ---------------------------------------------------------------------------

#' Traduz a ocupação declarada ao TSE em ISCO-88
#'
#' Converte o código de ocupação da candidatura (`CD_OCUPACAO`) no código da
#' Classificação Internacional Uniforme de Ocupações de 1988, com quatro
#' dígitos.
#'
#' @section A armadilha do primeiro dígito:
#' Traduzir ocupação pelo primeiro dígito **inverte classes inteiras**. O grande
#' grupo 9 da CBO brasileira é reparação e manutenção (mecânicos, ISEI em torno
#' de 34); o grande grupo 9 da ISCO é o das ocupações elementares (serventes,
#' ISEI entre 16 e 30). Toda tradução válida é, no mínimo, a dois dígitos — que
#' é o nível em que este pacote opera, descendo a três ou quatro onde dois
#' fundiriam posições distantes demais (médico e enfermeiro, por exemplo).
#'
#' @param cod Vetor de códigos de ocupação do TSE (numérico ou texto).
#' @param ano Vetor opcional de anos de eleição, do mesmo comprimento de `cod`.
#'   Com ele, as candidaturas cujo código o TSE **reutilizou** depois voltam
#'   `NA` com aviso, em vez de traduzidas pelo dicionário errado: o código 215
#'   designava um cargo de direção até 2000 e passou a designar artista
#'   plástico. Sem ele, o comportamento é o de sempre. Veja [tse_vigencia()].
#' @return Vetor de texto com o ISCO-88 de quatro dígitos. `NA` para códigos que
#'   não designam ocupação (não informada, fora da PEA, vínculo sem função).
#' @seealso [tse_para_isei()], [tse_para_classe()], [crosswalk_tse()]
#' @examples
#' tse_para_isco(c(111, 169, 257))
#' @export
tse_para_isco <- function(cod, ano = NULL) {
  k <- .norm_tse(cod)
  i <- match(k, ocupacoesBR::tse_isco$cod_tse)
  .avisa_ausentes(k, i, "tse_isco")
  .aplica_vigencia(ocupacoesBR::tse_isco$isco88[i], k, ano)
}

#' Índice socioeconômico ISEI da ocupação declarada ao TSE
#'
#' Devolve o escore ISEI (International Socio-Economic Index of occupational
#' status) de Ganzeboom, De Graaf e Treiman, ancorado na ISCO-88.
#'
#' @section Anomalias conhecidas da escala:
#' O ISEI não é constante da natureza: é o escalonamento que maximiza o efeito
#' indireto da escolaridade sobre a renda **via ocupação**, estimado por
#' Ganzeboom, De Graaf e Treiman (1992) sobre dados internacionais dos anos
#' 1970--80. Duas consequências para quem usa a versão ancorada na ISCO-88.
#'
#' **A escala é enviesada contra ocupações femininas.** Regressão no nível do
#' código, ponderada por número de candidaturas (168 códigos com n >= 500, dos
#' quais 28 são majoritariamente femininos):
#'
#' ```
#' ISEI = 38,6 + 0,469 x (% com superior) - 6,17 x (código majoritariamente feminino)
#'                                           (ep 3,03; p = 0,043)
#' ```
#'
#' **A credencial constante, um código feminino recebe 6,2 pontos de ISEI a
#' menos.** E não é que essas ocupações tenham menos escolaridade — têm mais:
#' 29,9% de superior contra 24,1%, com ISEI médio de 46,0 contra 49,0.
#'
#' **O sinal é robusto; o `p` não.** A especificação acima pondera por número de
#' candidaturas, o que muda a população-alvo de códigos para candidaturas — é
#' escolha defensável, mas o erro-padrão de `lm` ponderado não a descreve, e o
#' ISEI é atributo determinístico do código, não estimativa com variância
#' inversa a `n`. Trocando a especificação: com erro-padrão robusto (HC3) o
#' coeficiente fica em -6,2 com p = 0,14; sem ponderação, -5,3 com p = 0,012;
#' com `pct_mulher` contínuo em vez da dicotomia, -0,09 por ponto percentual com
#' p = 0,08. O sinal e a ordem de grandeza sobrevivem a todas; o `p = 0,043` é da
#' primeira. Use o intervalo de especificações, não o `p` pontual.
#'
#' **E "viés" pede uma premissa que convém explicitar.** O ISEI pondera
#' escolaridade *e* renda, e ocupações femininas rendem menos com credencial
#' igual: a escala registra isso fielmente. Chamar de viés supõe que status
#' *deveria* seguir a credencial. Se o que se quer medir é credencial, é viés; se
#' é retorno, é fidelidade. A recomendação abaixo vale nos dois casos, porque a
#' ISCO-08 reestima o retorno sobre uma população que inclui mulheres.
#'
#' O caso emblemático é a enfermagem, que a ISCO-88 põe em `2230` com **ISEI
#' 43** — abaixo dos escriturários (`4100`, ISEI 45), apesar de ser profissão
#' universitária. A âncora da ISCO-08 corrige boa parte disso: o mesmo posto
#' recebe **68,7**.
#'
#' Daí a recomendação prática: **para análise de gênero, prefira
#' [tse_para_isei08()]**. Ganzeboom rebalanceou saúde e cuidado na revisão de
#' 2008. Isto qualifica a defesa de que a ISCO-88 é "a escolha conservadora":
#' ela está certa no sinal, mas é conservadora *porque* a escala é enviesada
#' contra ocupações femininas, o que não é a mesma coisa que ser robusta.
#'
#' **A relação com o critério externo não é linear nem monótona.** Veja
#' `vignette("validacao")`: a correlação entre ISEI e patrimônio é de 0,681 no
#' nível da ocupação e de apenas 0,207 no da candidatura, valor que
#' [tse_dispersao_patrimonio] permite recalcular. Uma medida de posição
#' ocupacional explica a variância *entre* ocupações e quase nada *dentro* de
#' cada uma — por isso **não use o ISEI como proxy de renda individual**.
#'
#' @inheritParams tse_para_isco
#' @return Vetor numérico com o escore ISEI-88, ou `NA`.
#' **Nem todo escore tem a mesma procedência.** Um ISEI de 68 é impresso do
#' mesmo jeito venha de "advogado", que pressupõe inscrição na OAB, ou de
#' "empresário", que não pressupõe registro nenhum e cobre desde o
#' microempreendedor até o capitalista. Veja [tse_codigos_autorrotulo] para
#' rodar a sua análise com e sem esses códigos — são 13,3% das candidaturas.
#'
#' @seealso [tse_para_isei08()], para a âncora da ISCO-08; [isco_posicao_br],
#'   para a posição na ocupação; [tse_codigos_autorrotulo], para a
#'   sensibilidade aos rótulos sem âncora; `vignette("qual-regua")`.
#' @references Ganzeboom, H. B. G.; De Graaf, P. M.; Treiman, D. J. (1992).
#'   A standard international socio-economic index of occupational status.
#'   *Social Science Research*, 21(1), 1--56.
#' @examples
#' tse_para_isei(c(111, 169, 257))
#' @export
tse_para_isei <- function(cod, ano = NULL) {
  .busca(tse_para_isco(cod, ano), ocupacoesBR::isco88_medidas, "isco88", "isei88")
}

#' Prestígio ocupacional SIOPS da ocupação declarada ao TSE
#'
#' Devolve o escore SIOPS (Standard International Occupational Prestige Scale),
#' de Treiman, ancorado na ISCO-88. É uma régua de prestígio, distinta do ISEI,
#' que mede posição socioeconômica.
#'
#' @inheritParams tse_para_isco
#' @return Vetor numérico com o escore SIOPS (Standard International
#'   Occupational Prestige Scale) de Treiman, na escala de 0 a 100 do ISMF:
#'   quanto maior, mais prestigiada a ocupação na média dos estudos
#'   originais. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o
#'   código do TSE não tem entrada no dicionário.
#' @examples
#' tse_para_siops(c(111, 169, 257))
#' @export
tse_para_siops <- function(cod, ano = NULL) {
  .busca(tse_para_isco(cod, ano), ocupacoesBR::isco88_medidas, "isco88", "siops88")
}

#' Classe social da ocupação declarada ao TSE
#'
#' Esquema de doze categorias desenhado para o dado eleitoral brasileiro. Não é
#' o EGP: parte do ISCO como o EGP parte, mas trata como categorias próprias
#' duas situações que o registro eleitoral cria e que os esquemas canônicos não
#' preveem — proprietários e empregadores nomeados pelo próprio código de
#' ocupação, e o vínculo público declarado sem função especificada. Para o EGP
#' canônico, veja [tse_para_egp()].
#'
#' @section O agricultor, e por que ele não tem classe própria:
#' Os códigos 601 (agricultor) e 604 (pescador) ficam em `"Trabalhadores
#' rurais"`, portanto nas classes populares, embora [tse_para_egp()] os
#' classifique como `IVc: proprietário rural`. A aparente discordância entre as
#' duas medidas é **artefato de granularidade**, e o registro é útil porque a
#' classe própria chegou a ser criada, em 29/07/2026, e foi revertida no mesmo
#' dia.
#'
#' O esquema relacional separa IVc de VIIb nas **onze** e nas **sete** classes.
#' Nos dois colapsos mais fortes de Erikson e Goldthorpe, o agricultor e o
#' assalariado rural voltam a ser a mesma coisa:
#'
#' | `n_classes` | 601 agricultor | 606 assalariado rural |
#' |---|---|---|
#' | 11 | IVc | VIIb |
#' | 7 | IVc | VIIb |
#' | 5 | IVc+VIIb | IVc+VIIb |
#' | 3 | Agrícolas | Agrícolas |
#'
#' A linha de sete classes estava ausente desta tabela até 05/09/2026, e a
#' ausência importava: ela é o colapso mais usado para publicar, e nela a
#' distinção **sobrevive**. Comparar um esquema de onze classes com uma
#' partição em três estratos é comparar resoluções diferentes, não encontrar
#' divergência. Só nas resoluções equivalentes à do estrato o próprio EGP funde
#' os dois.
#'
#' O dado externo concorda. O ISEI do agricultor, 23, está **dentro** da faixa
#' das classes populares, que vai de 16 a 43, e corresponde ao percentil 5 do
#' dicionário. O patrimônio mediano declarado, de R$ 122.395, fica dentro da
#' faixa das classes populares, cujo máximo é R$ 126.801 -- só um dos sessenta
#' demais códigos do estrato declara mais: põe o agricultor no topo da classe
#' popular, não fora dela.
#'
#' A distinção entre agricultura familiar e proletariado rural é real, e continua
#' disponível onde Erikson e Goldthorpe a puseram: em
#' `tse_para_egp(n_classes = 11)`. O que não se justifica é transportá-la para a
#' partição em estratos.
#'
#' @section Não há equivalente pela COD, e o motivo é do esquema:
#' `cod_para_classe()` não existe, e não é omissão. Quatro das categorias deste
#' esquema — "Vínculo público não especificado", "Fora da PEA por posição",
#' "Inativo com trajetória" e "Não informado" — são **rubricas do formulário do
#' TSE**, e não posições da ISCO. Elas existem porque o cadastro do Tribunal
#' oferece à pessoa rótulos que *substituem* a ocupação em vez de a nomear. A
#' PNAD Contínua e o Censo não têm nada disso: lá, vínculo e ocupação são
#' perguntas separadas, e quem é servidor público **também** declara a
#' ocupação. Traduzir o esquema para a COD exigiria inventar do lado da
#' população categorias que só existem por causa de um formulário.
#'
#' A consequência prática é direta: **este esquema não atravessa para a
#' população**, e quem precisa comparar composição de classe entre as duas
#' fontes não tem régua pronta. O caminho é comparar pelo ISEI, que é
#' literalmente o mesmo construto dos dois lados, ou construir uma régua
#' própria declarando as categorias que só existem de um lado. O tamanho do
#' problema está medido em [tse_universo] e o artigo *Comparar duas fontes*
#' desenvolve as alternativas:
#' <https://moraespeixoto.github.io/ocupacoesBR/articles/comparar-fontes.html>
#'
#' @inheritParams tse_para_isco
#' @param superior Vetor lógico opcional, do mesmo comprimento de `cod`,
#'   indicando ensino superior completo. Quando fornecido, a categoria residual
#'   "Vínculo público não especificado" — que sozinha reúne cerca de 9% das
#'   candidaturas, do faxineiro ao secretário de finanças — é dividida pela
#'   escolaridade declarada.
#' @return Vetor de texto com o rotulo da classe (por exemplo "Classe alta", "Vinculo publico, superior"), nas categorias descritas acima. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo do TSE nao tem entrada no dicionario.
#' @examples
#' tse_para_classe(c(111, 169, 291))
#' tse_para_classe(c(291, 291), superior = c(TRUE, FALSE))
#' @export
tse_para_classe <- function(cod, superior = NULL, ano = NULL) {
  k  <- .norm_tse(cod)
  i  <- match(k, ocupacoesBR::tse_isco$cod_tse)
  .avisa_ausentes(k, i, "tse_isco")
  cl <- .aplica_vigencia(ocupacoesBR::tse_isco$classe[i], k, ano)
  if (is.null(superior)) return(cl)
  if (length(superior) != length(cl))
    stop("`superior` deve ter o mesmo comprimento de `cod`.", call. = FALSE)
  # um fator aqui produzia, calado, a categoria residual não dividida
  if (!is.logical(superior) && !is.numeric(superior))
    stop("`superior` deve ser l\u00f3gico (ou 0/1); recebido: ",
         class(superior)[1], ".", call. = FALSE)
  .guarda_binaria(superior, "superior")
  superior <- as.logical(superior)
  pub <- !is.na(cl) & cl == "V\u00ednculo p\u00fablico n\u00e3o especificado"
  # `superior = NA` NAO vira "medio ou menos": imputar a metade baixa a quem nao
  # declarou escolaridade e' o mesmo erro que o pacote recusa em R/egp.R:191-192,
  # e a ausencia de escolaridade e' correlacionada com posicao social. Esses
  # casos ficam no rotulo residual "nao especificado" \u2014 nao divididos, nao
  # imputados, e distinguiveis de uma ocupacao ausente (que seria NA).
  sup    <- !is.na(superior) &  superior
  naosup <- !is.na(superior) & !superior
  cl[pub &  sup]    <- "V\u00ednculo p\u00fablico, superior"
  cl[pub &  naosup] <- "V\u00ednculo p\u00fablico, m\u00e9dio ou menos"
  cl
}

#' Estrato social da ocupação declarada ao TSE
#'
#' Agrega as classes de [tse_para_classe()] em classe alta, classe média e
#' classes populares, mantendo à parte as duas categorias residuais (vínculo
#' público sem função e fora da PEA), que não são estratos e não devem ser
#' silenciosamente somadas a nenhum deles.
#'
#' @section O estrato e o ISEI se cruzam por desenho:
#' O estrato é uma régua de **posição** — de onde vem o sustento: de um diploma,
#' de um patrimônio, de um salário, da terra. O ISEI ([tse_para_isei()]) é uma
#' régua de **status**, que ordena ocupações pela eficiência com que convertem
#' escolaridade em renda. Que discordem em alguns pontos não é defeito: é a
#' razão de haver duas. Um esquema de classes que apenas reordenasse o ISEI em
#' fatias seria redundante, e a distinção entre classe e status é justamente o
#' que Weber propôs e Goldthorpe endureceu.
#'
#' Medidas sobre os 258 códigos do dicionário, as duas réguas concordam quase
#' inteiramente — os intervalos interquartis não se tocam:
#'
#' | estrato | n | mín | mediana | máx |
#' |---|---|---|---|---|
#' | Classe alta | 88 | 43 | 68 | 90 |
#' | Classe média | 69 | 45 | 50 | 55 |
#' | Classes populares | 101 | 16 | 33 | 43 |
#'
#' Nenhum código de classe média tem ISEI acima da mediana da classe alta.
#' Quatro dos 88 códigos de classe alta ficam abaixo da mediana da classe média,
#' e cada um tem explicação própria:
#'
#' - **113 (enfermeiro), ISEI 43** — é a anomalia de gênero da própria escala,
#'   documentada em [tse_para_isei()]: enfermagem recebe menos que o técnico de
#'   enfermagem (48) e que o escriturário (45). Aqui é o ISEI que erra, não a
#'   classe. Enfermagem é bacharelado regulado, e a própria ISCO-88 a põe no
#'   grande grupo 2.
#' - **234, 602 e 901 (produtor agropecuário, pecuarista, proprietário
#'   agrícola), ISEI 43** — são classe alta por propriedade, com status baixo. É
#'   exatamente o contraste que [tse_para_componente_alta()] existe para exibir:
#'   capital econômico e capital cultural não se acompanham.
#'
#' A leitura prática: uma discordância entre as duas réguas é achado a
#' interpretar, não erro a corrigir. Quem publicar as duas no mesmo gráfico
#' precisa dizer qual pergunta cada uma responde — veja `vignette("qual-regua")`.
#'
#' @inheritParams tse_para_isco
#' @return Vetor de texto com o estrato ("Classe alta", "Classe media", "Classes populares", ou uma das duas categorias residuais descritas acima). Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo do TSE nao tem entrada no dicionario.
#' @examples
#' tse_para_estrato(c(111, 169, 291, 931))
#' @export
tse_para_estrato <- function(cod, ano = NULL) {
  k <- .norm_tse(cod)
  i <- match(k, ocupacoesBR::tse_isco$cod_tse)
  .avisa_ausentes(k, i, "tse_isco")
  .aplica_vigencia(ocupacoesBR::tse_isco$estrato[i], k, ano)
}

#' Partição da classe alta em proprietária, credenciada e dirigente
#'
#' Separa a classe alta nas duas espécies de recurso que a compõem — o capital e
#' a credencial — além das ocupações propriamente políticas. Devolve `NA` fora
#' da classe alta.
#'
#' @section As duas metades não têm a mesma confiabilidade:
#' A partição é simétrica no desenho e **assimétrica na medição**, e quem
#' publica o contraste precisa dizê-lo.
#'
#' A **alta credenciada** é ancorada em registro externo. "Advogado" não é
#' autodescrição: pressupõe inscrição na OAB. Por isso o rótulo se comporta de
#' modo estável — entre os que declaram o código 131, a proporção com ensino
#' superior varia pouco mais de um ponto entre vereador e presidente (98,6% a
#' 100%).
#'
#' A **alta proprietária** não tem âncora nenhuma. "Empresário" (código 257) é
#' autodeclaração: nenhum registro precisa existir para que alguém se descreva
#' assim. E o mesmo rótulo cobre posições materialmente incomparáveis — entre os
#' que declaram 257, o patrimônio mediano varia por um fator de **25** conforme
#' o cargo disputado:
#'
#' | cargo | patrimônio mediano de quem declara 257 |
#' |---|---|
#' | Vereador | R$ 185.000 |
#' | Prefeito | R$ 812.544 |
#' | Senador | R$ 4.678.498 |
#'
#' Tudo isso sob um **único** ISEI (68) e uma única classe. Dentro do código, os
#' extremos de patrimônio distam 76 vezes (p10 R$ 19,8 mil, p90 R$ 1,50 milhão).
#' A tabela acima e esses dois quantis saem de [tse_autorrotulo_patrimonio], e
#' não estão digitados aqui — a versão anterior deles estava, e sobreviveu
#' errada à correção do patrimônio de 09/2026.
#'
#' O 257 não é uma ocupação medida com erro: é uma **mistura** de duas
#' populações — o microempreendedor e o capitalista — sob um rótulo só. Nenhum
#' escore único está certo para as duas, razão pela qual mudá-lo de valor não
#' resolve (veja [tse_codigos_autorrotulo]).
#'
#' Consequência: um gráfico que compare os dois componentes está comparando uma
#' quantidade ancorada em registro externo a uma quantidade autodeclarada que
#' agrega posições muito distantes. Teoricamente a partição é boa (é Bourdieu e
#' Wright operacionalizados), mas Wright insistia em *employment relations*, não
#' em rótulos.
#'
#' **O que o dado NÃO mostra**, e vale dizer para que ninguém repita: não há
#' evidência de que as pessoas troquem de rótulo conforme o cargo. A frequência
#' do 257 não cresce com a importância do posto — tem pico em prefeito (10,6%) e
#' cai em senador (7,2%) e governador (6,9%). Quem cresce monotonicamente é
#' "advogado" (1,6% a 14,8%), que é o caso ancorado, e "comerciante" **cai** de
#' 6,2% a 0%. O gradiente de patrimônio acima é consistente tanto com
#' recrutamento seletivo quanto com relabeling, e estes dados não separam as
#' duas hipóteses.
#'
#' Se a sua conclusão depende do tamanho relativo dos dois componentes, rode-a
#' também sem [tse_codigos_autorrotulo] e relate as duas versões.
#'
#' @inheritParams tse_para_isco
#' @return Vetor de texto com o componente da classe alta ("Proprietaria", "Credenciada" ou a categoria politica, conforme descrito acima), ou `NA` fora da classe alta e onde o codigo do TSE nao tem entrada no dicionario.
#' @examples
#' tse_para_componente_alta(c(257, 111, 274, 411))
#' @export
tse_para_componente_alta <- function(cod, ano = NULL) {
  k <- .norm_tse(cod)
  i <- match(k, ocupacoesBR::tse_isco$cod_tse)
  .avisa_ausentes(k, i, "tse_isco")
  .aplica_vigencia(ocupacoesBR::tse_isco$componente_alta[i], k, ano)
}

#' A ocupação declarada é um mandato ou cargo político?
#'
#' Marca as ocupações que são o próprio ofício político (vereador, deputado,
#' prefeito, governador e afins). Útil para separar quem já vive da política de
#' quem chega a ela de outra ocupação.
#'
#' @inheritParams tse_para_isco
#' @return Vetor logico: `TRUE` quando o codigo e' um cargo ou mandato politico (vereador, deputado, prefeito, governador e afins), `FALSE` caso contrario. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo do TSE nao tem entrada no dicionario.
#' @examples
#' tse_para_politico(c(274, 169))
#' @export
tse_para_politico <- function(cod, ano = NULL) {
  k <- .norm_tse(cod)
  i <- match(k, ocupacoesBR::tse_isco$cod_tse)
  .avisa_ausentes(k, i, "tse_isco")
  .aplica_vigencia(ocupacoesBR::tse_isco$politico[i], k, ano)
}

#' Códigos cujo rótulo é autodescrição, sem registro externo que o valide
#'
#' Os códigos de ocupação do TSE que designam **propriedade ou empreendimento**
#' — empresário, comerciante, industrial, proprietário de estabelecimento — e
#' que, por isso, não são ancorados em nenhum registro. Servem para rodar uma
#' análise com e sem eles, em uma linha.
#'
#' @format Vetor de texto com os códigos.
#'
#' @section Por que estes e não outros:
#' O critério é **a priori, não empírico**: existe um registro externo que
#' precisa ser satisfeito para que alguém use o rótulo? "Advogado" pressupõe
#' inscrição na OAB, "médico" pressupõe CRM; "empresário" não pressupõe nada.
#' Não é uma afirmação sobre a honestidade de quem declara, e sim sobre a
#' existência de uma trava externa.
#'
#' Este critério é conceitual porque **o dado não o produz sozinho**. A
#' dispersão de patrimônio dentro do código, por exemplo, não separa os dois
#' grupos: é de 76 vezes (p90/p10) entre os que declaram empresário e de 55
#' entre os comerciantes, que são autorrótulos, mas de 48 entre os advogados,
#' que não é — e o comerciante fica **entre** os outros dois. Patrimônio é
#' disperso em toda parte. O que distingue não é a dispersão bruta, é a
#' ausência da trava.
#'
#' Estes três números saem de [tse_autorrotulo_patrimonio] e são conferidos
#' contra ela em `tests/testthat/test-numeros-doc.R`. A versão anterior dizia
#' 80, 47 e 54: eram os valores da agregação que somava cada bem duas vezes,
#' corrigida em 09/2026, e sobreviveram por estarem digitados.
#'
#' @section Como usar:
#' Os escores destes códigos não são inválidos — são menos confiáveis do que os
#' ancorados, e a diferença não aparece na tabela, porque um ISEI de 68 é
#' impresso do mesmo jeito venha de onde vier. A recomendação é tratá-los como
#' análise de sensibilidade:
#'
#' ```r
#' d$isei <- tse_para_isei(d$cod)
#' d$isei_ancorado <- ifelse(d$cod %in% tse_codigos_autorrotulo, NA, d$isei)
#' # rode a sua análise com as duas colunas e relate as duas
#' ```
#'
#' São **13,3%** das candidaturas de 1998 a 2026 — o bastante para mover um
#' resultado, e por isso o bastante para valer o teste.
#'
#' @section Relação com `tse_isco$proprietario`:
#' Hoje os dois conjuntos coincidem, mas respondem a perguntas diferentes, e por
#' isso são objetos diferentes: `proprietario` é **pertença de classe** (define
#' quem entra em "Proprietários e empregadores"); este é **confiabilidade de
#' medida** (define de quem o escore é autodeclarado). É a mesma distinção que
#' separou `proprietario` de `conta_propria`, e pela mesma razão: quando dois
#' conceitos compartilham um vetor, mexer num arrasta o outro.
#'
#' @return Não é função, e sim um vetor `character` de comprimento 10, exportado
#'   como constante. Cada elemento é um código de ocupação do TSE, em texto com
#'   três dígitos, cujo rótulo é autodescrição de propriedade ou empreendimento.
#'   Serve de filtro: `x %in% tse_codigos_autorrotulo` marca as candidaturas
#'   cujo escore ocupacional não tem registro externo que o ancore.
#' @seealso [tse_para_componente_alta()], que documenta a assimetria de
#'   confiabilidade entre as duas metades da classe alta.
#' @examples
#' tse_codigos_autorrotulo
#' tse_para_rotulo(tse_codigos_autorrotulo)
#' @export
tse_codigos_autorrotulo <- c("169", "206", "234", "257", "602",
                             "901", "902", "903", "904", "905")
