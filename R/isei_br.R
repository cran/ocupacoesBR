#' ISEI-BR: status ocupacional estimado em dado brasileiro
#'
#' Escore de status ocupacional obtido refazendo o procedimento de Ganzeboom,
#' De Graaf e Treiman (1992) sobre a PNAD Continua de 2025, em vez de importar
#' os escores calculados por eles em dado estrangeiro. Esta funcao entra pela
#' ocupacao declarada ao TSE; as irmas entram pela COD ([cod_para_isei_br()]),
#' pela CBO-2002 ([cbo2002_para_isei_br()]) e pela propria ISCO-08
#' ([isco08_para_isei_br()]). Nao ha porta pela CBO-94, e a razao esta em
#' [cbo94_isco88].
#'
#' @section O que esta regua e e o que ela nao e:
#'
#' O ISEI trata a ocupacao como o meio pelo qual a escolaridade se converte em
#' renda, e da a cada ocupacao o escore que melhor cumpre esse papel de
#' intermediario. O ISEI-88 e o ISEI-08 que este pacote tambem oferece foram
#' estimados assim, mas em dado de outros paises. O ISEI-BR e o mesmo metodo
#' estimado aqui, sobre 655.787 observacoes de 339.181 pessoas.
#'
#' Ele **nao substitui** o ISEI-08. Comparacao internacional continua exigindo
#' a ancora internacional, e uma serie nao pode trocar de regua no meio. O
#' ISEI-BR responde a outra pergunta: como o mercado de trabalho brasileiro de
#' hoje, e nao um escalonamento unico de dezesseis paises com dado brasileiro
#' de 1973 e 1982, ordena as ocupacoes.
#'
#' Duas coisas precisam ser ditas por quem usa. A primeira e que a mediacao
#' nao e completa: no Brasil a ocupacao explica cerca de 58% do efeito da
#' escolaridade sobre a renda, e o resto e escolaridade que paga dentro da
#' mesma ocupacao. Os valores exatos estao nos atributos de
#' [isco08_isei_br]. A segunda e que a escala vem de um ano so, 2025, e nao
#' forma serie.
#'
#' Codigos finos com menos de 30 pessoas na amostra herdam o escore do grupo
#' acima. A coluna `nivel` de [isco08_isei_br] diz quais.
#'
#' @references
#' Ganzeboom, H. B. G., De Graaf, P. M., & Treiman, D. J. (1992). A standard
#' international socio-economic index of occupational status.
#' *Social Science Research*, 21(1), 1-56.
#'
#' @inheritParams tse_para_isco
#' @return Vetor numerico com o escore ISEI-BR, na escala estimada pelo proprio pacote sobre a PNAD Continua de 2025 (de 11,7 a 90 nesta tabela): quanto maior, mais a ocupacao converte escolaridade em renda no mercado de trabalho brasileiro de hoje. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela [isco08_isei_br].
#' @seealso [isco08_isei_br] para a tabela e o metodo; [tse_para_isei08()]
#'   para a ancora internacional; `vignette("validacao")` para a comparacao
#'   das duas contra o patrimonio dos candidatos.
#' @examples
#' data.frame(cod    = c(111, 113, 601),
#'            rotulo = tse_para_rotulo(c(111, 113, 601)),
#'            isei08 = tse_para_isei08(c(111, 113, 601)),
#'            isei_br = tse_para_isei_br(c(111, 113, 601)))
#' @export
tse_para_isei_br <- function(cod, ano = NULL) {
  .busca(tse_para_isco08(cod, ano = ano), ocupacoesBR::isco08_isei_br,
         "isco08", "isei_br")
}

#' ISEI-BR a partir da COD
#'
#' Versao para a classificacao do IBGE, que e a da PNAD Continua e do Censo.
#' Leia [tse_para_isei_br()] para o que a regua e e o que ela nao e.
#'
#' @inheritParams cod_para_isco08
#' @return Vetor numerico com o escore ISEI-BR, na escala estimada pelo proprio pacote sobre a PNAD Continua de 2025 (de 11,7 a 90 nesta tabela): quanto maior, mais a ocupacao converte escolaridade em renda no mercado de trabalho brasileiro de hoje. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela [isco08_isei_br].
#' @seealso [tse_para_isei_br()], [isco08_isei_br]
#' @examples
#' cod_para_isei_br(c("2211", "9629"))
#' @export
cod_para_isei_br <- function(cod) {
  .busca(cod_para_isco08(cod), ocupacoesBR::isco08_isei_br,
         "isco08", "isei_br")
}

#' ISEI-BR a partir da CBO-2002
#'
#' Versao para o microdado do trabalho a partir de 2003, RAIS, CAGED e
#' eSocial. Leia [tse_para_isei_br()] para o que a regua e e o que ela nao e.
#'
#' @section Duas pontes empilhadas:
#' O caminho e CBO-2002 -> ISCO-88 (tabua do Ministerio do Trabalho) -> ISCO-08
#' (ponte da OIT) -> ISEI-BR, e a segunda ponte e ambigua em cerca de um terco
#' dos codigos de origem. A ressalva e a mesma de [cbo2002_para_isei08()] e
#' [cbo2002_para_prestigio08()], que ja a traziam; esta porta nao a trazia ate
#' 05/09/2026.
#'
#' Vale ainda lembrar a data. O ISEI-BR e uma regua estimada em 2025 e que a
#' propria documentacao declara nao formar serie. Foi esse o argumento que
#' retirou a porta pela CBO-94 na versao 0.5.1 — e o que se retirou ali foi o
#' ATALHO, nao o caminho: `isco08_para_isei_br(cbo94_para_isco08(x))` continua
#' funcionando, e quem escreve as duas etapas fez a escolha conscientemente, que
#' e o que a recusa pretende garantir. O argumento nao se aplica aqui com a
#' mesma forca — a CBO-2002 esta em uso hoje —, mas se aplica ao inicio de uma
#' serie de RAIS que comece em 2003.
#'
#' @inheritParams cbo2002_para_isco
#' @return Vetor numerico com o escore ISEI-BR, na escala estimada pelo proprio pacote sobre a PNAD Continua de 2025 (de 11,7 a 90 nesta tabela): quanto maior, mais a ocupacao converte escolaridade em renda no mercado de trabalho brasileiro de hoje. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela [isco08_isei_br].
#' @seealso [tse_para_isei_br()], [isco08_isei_br]
#' @examples
#' cbo2002_para_isei_br("225120")
#' @export
cbo2002_para_isei_br <- function(cbo, empate = c("na", "moda"),
                                 escada = FALSE) {
  i08 <- isco88_para_isco08(cbo2002_para_isco(cbo, empate, escada))
  .busca(i08, ocupacoesBR::isco08_isei_br, "isco08", "isei_br")
}

#' ISEI-BR a partir da ISCO-08
#'
#' Entrada direta para quem ja tem o codigo internacional. Leia
#' [tse_para_isei_br()] para o que a regua e e o que ela nao e.
#'
#' @param isco08 Vetor de codigos ISCO-08.
#' @return Vetor numerico com o escore ISEI-BR, na escala estimada pelo proprio pacote sobre a PNAD Continua de 2025 (de 11,7 a 90 nesta tabela): quanto maior, mais a ocupacao converte escolaridade em renda no mercado de trabalho brasileiro de hoje. Mesmo comprimento e ordem do vetor de entrada; `NA` onde o codigo nao tem correspondencia na tabela [isco08_isei_br].
#' @seealso [tse_para_isei_br()], [isco08_isei_br]
#' @examples
#' isco08_para_isei_br(c("2211", "5411"))
#' @export
isco08_para_isei_br <- function(isco08) {
  .busca(.norm_isco(isco08), ocupacoesBR::isco08_isei_br,
         "isco08", "isei_br", o_que = "isco08_isei_br")
}
