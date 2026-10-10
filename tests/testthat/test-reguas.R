# A tabela `reguas` e a unica do pacote que nao deriva de fonte externa: e
# prosa destilada da documentacao. O risco dela e outro, entao — nao errar a
# fonte, e sim envelhecer em silencio quando o pacote ganhar ou perder uma
# porta. Os dois testes de deriva abaixo amarram a tabela aos exports reais nas
# DUAS direcoes, que e o que impede isso.

test_that("a tabela tem a forma prometida", {
  expect_s3_class(reguas, "data.frame")
  expect_named(reguas, c("medida", "tipo", "ancora", "escala", "funcao_tse",
                         "outras_portas", "pergunta", "mede",
                         "quando_nao_usar", "fonte", "ver"))
  expect_equal(nrow(reguas), 9L)
  expect_false(any(duplicated(reguas$medida)))
  expect_true(all(reguas$tipo %in% c("continua", "categorica", "ordinal")))
})

test_that("toda celula de orientacao esta preenchida", {
  for (col in c("pergunta", "mede", "quando_nao_usar", "fonte", "ver")) {
    expect_true(all(nzchar(reguas[[col]])), info = col)
    expect_false(anyNA(reguas[[col]]), info = col)
  }
})

# As funcoes citadas na tabela, em um vetor so.
funcoes_citadas <- function() {
  outras <- stats::na.omit(reguas$outras_portas)
  unique(c(reguas$funcao_tse, trimws(unlist(strsplit(outras, ",")))))
}

test_that("deriva 1: toda funcao citada na tabela existe", {
  expect_true(all(funcoes_citadas() %in% getNamespaceExports("ocupacoesBR")))
})

test_that("deriva 3: nenhum destino novo escapa a classificacao", {
  # A deriva 2 enumera os destinos conhecidos, entao NAO ve um destino novo em
  # folha (`tse_para_wright`, digamos). Este teste ve: ele parte TODO export
  # `_para_` em tres baldes e falha se sobrar alguma coisa fora deles. Um
  # destino novo obriga quem o criou a decidir onde ele entra.
  # greedy: a origem pode ter underscore, como em `tse_rotulo_para_cod`
  destino <- function(x) sub("^.*_para_", "", x)
  reguas_tab   <- unique(destino(funcoes_citadas()))
  # destinos que sao classificacao ou marca, nao regua de posicao social
  classificar  <- c("isco", "isco08", "isco88", "rotulo", "politico", "cod")
  depreciados  <- c("siops", "siops08")

  todos <- grep("_para_", getNamespaceExports("ocupacoesBR"), value = TRUE)
  sobra <- setdiff(unique(destino(todos)),
                   c(reguas_tab, classificar, depreciados))
  expect_equal(sobra, character(0),
               info = paste("destino sem lugar definido:", paste(sobra, collapse = ", ")))
})

test_that("deriva 2: toda porta de medida esta na tabela", {
  # Se uma porta nova entrar no NAMESPACE sem ganhar linha aqui, este teste
  # falha — que e exatamente o servico que ele presta.
  portas <- grep("_para_(isei|isei08|isei_br|prestigio|prestigio08|egp|classe|estrato|componente_alta)$",
                 getNamespaceExports("ocupacoesBR"), value = TRUE)
  expect_setequal(funcoes_citadas(), portas)
})

test_that("o texto viaja marcado como UTF-8", {
  for (col in names(reguas)) {
    x <- reguas[[col]]
    if (!is.character(x)) next
    acentuados <- x[!is.na(x) & grepl("[^ -~]", x)]
    if (length(acentuados))
      expect_true(all(Encoding(acentuados) == "UTF-8"), info = col)
  }
})

test_that("os intervalos das reguas continuas batem com as tabelas do pacote", {
  # `escala` e calculada na geracao a partir de isco88_medidas e irmas; se
  # aquelas mudarem sem regerar a tabela, isto pega.
  faixa <- function(x) {
    r <- range(x, na.rm = TRUE)
    sprintf("%g a %g", round(r[1]), round(r[2]))
  }
  expect_equal(reguas$escala[reguas$medida == "ISEI-88"],
               faixa(isco88_medidas$isei88))
  expect_equal(reguas$escala[reguas$medida == "ISEI-08"],
               faixa(isco08_medidas$isei08))
  expect_equal(reguas$escala[reguas$medida == "ISEI-BR"],
               faixa(isco08_isei_br$isei_br))
  expect_equal(reguas$escala[reguas$medida == "Prestigio-88"],
               faixa(isco88_medidas$siops88))
})
