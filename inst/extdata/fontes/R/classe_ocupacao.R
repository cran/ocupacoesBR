# ============================================================================
# classe_ocupacao.R — medida de classe v2: TUDO por código (CD_OCUPACAO)
# ----------------------------------------------------------------------------
# Substitui a classificação por regex de rótulo (R/crosswalk_cbo.R, mantido no
# repo como registro histórico) em resposta ao parecer de estratificação (P1):
# a classificação por palavras-chave tinha erros de precedência (AUXILIAR DE
# ESCRITÓRIO casava `ESCRITOR`; TÉCNICO DE ENFERMAGEM casava `ENFERMEIR`;
# OPERADOR DE ... PRODUÇÃO INDUSTRIAL casava `INDUSTRIAL` e virava proprietário)
# e 76 códigos reais caíam no default "fora da PEA". Aqui, um código → um ISCO
# → uma classe, sem regex, com teste de cobertura contra o dado.
#
# ARQUITETURA (uma fonte de verdade + patches auditáveis):
#   base   = .TSE_PARA_ISCO de R/isei_ocupacao.R (259 códigos, v1)
#   patch  = .PATCH_ISCO (decisões da Fase 0, documentadas em
#            PARECERES/MEMO_DECISOES_MEDIDA.md): correções de 3 dígitos
#            flagradas pelo P1 + os 17 códigos ausentes do dado 1998–2024.
#   valores ISEI: .ISEI_POR_ISCO de isei_ocupacao.R + .PATCH_ISEI (minor
#            groups novos, verificados na tabela de Ganzeboom via occupar:
#            2421=85, 2422=90, 246=53, 5162=50, 1311=43).
#
# NOTA sobre 1311 (dirigentes de empresa agropecuária): o parecer sugeriu 1311
# supondo ISEI 51; a tabela-fonte dá 1311 = 43. Segue-se a fonte, nunca a
# estimativa. Proprietários rurais (901, 234, 602) ficam em 43.
# ============================================================================

source("R/isei_ocupacao.R")   # traz .TSE_PARA_ISCO, .ISEI_POR_ISCO, .COD_POLITICO

# ---- patches de ISCO (Fase 0; MEMO_DECISOES_MEDIDA.md §§2–3) ---------------
.PATCH_ISCO <- c(
  # correções de 3 dígitos flagradas pelo P1 (M5/M6)
  "131" = "2421",   # ADVOGADO: 24=68 → 2421=85 (70 mil casos)
  "271" = "2422",   # MAGISTRADO: 24=68 → 2422=90
  "910" = "246",    # SACERDOTE/RELIGIOSO: 24=68 → 246=53
  "233" = "5162",   # POLICIAL MILITAR: 51=38 → 5162=50
  "232" = "5162",   # POLICIAL CIVIL
  "258" = "5162",   # BOMBEIRO MILITAR
  "145" = "5162",   # BOMBEIRO CIVIL
  "234" = "1311",   # PRODUTOR AGROPECUÁRIO: 61=23 → 1311=43 (proprietário rural)
  "602" = "1311",   # PECUARISTA: idem
  # PROFESSOR DE ENSINO DE 1º E 2º GRAUS (rodada 4g): a v1 mandava para 232
  # (docência de nível médio, ISEI 69), o que dava a esta categoria MISTA o
  # escore mais alto das três docentes — acima do professor fundamental (233,
  # ISEI 66). O dado desmente: entre os candidatos, só 55,1% dos que declaram
  # 143 têm superior completo, contra 74,7% dos que declaram 265 (fundamental)
  # e 92,1% dos que declaram 266 (médio). A categoria menos credenciada não
  # pode receber o escore mais alto. Vai para 233.
  "143" = "233",
  # --- rodada 5 (revisão sociológica, jul/2026): precisão dentro da saúde ---
  # Três códigos caíam em agregados que o dado desmente. Não é override da
  # hierarquia da ISCO: é escolher o código PRECISO que a ISCO já oferece,
  # mesmo procedimento das correções acima.
  #   114 FISIOTERAPEUTA: caía em 32 (=3200, associate professionals genérico,
  #       ISEI 48) apesar de 95,8% dos que o declaram terem superior completo.
  #       Existe 3226 (physiotherapists etc, ISEI 60), específico.
  #   222 NUTRICIONISTA: caía em 222 (=2220, ISEI 85) — o MESMO escore do
  #       médico, que tem 99,0% de superior e patrimônio mediano oito vezes
  #       maior (R$ 1,66 mi contra R$ 198 mil). Existe 3223 (dieticians &
  #       nutritionists, ISEI 51).
  #   111 MÉDICO: 2220 é "health professionals except nursing"; 2221 é
  #       "medical doctors", ISEI 88. Refinamento, sem troca de estrato.
  "114" = "3226",
  "222" = "3223",
  "111" = "2221",
  # --- rodada 6 (auditoria 27/jul/2026): artes visuais no código preciso ------
  # 214 ESCULTOR E PINTOR, 215 ARTISTA PLÁSTICO e 191 (escultor/pintor/artista)
  # caíam em 24 (=2400, ISEI 68) — o MESMO escore do advogado (2421=85 no patch)
  # e da "alta credenciada" — apesar de só 18,6%-29,7% dos que os declaram terem
  # superior completo. É a armadilha do segundo dígito que o pacote existe para
  # evitar: a ISCO já oferece 2452 (escultores, pintores e artistas plásticos,
  # ISEI 54), preciso. Mesmo procedimento de 114/222. NÃO troca de estrato — o
  # primeiro dígito segue 2 —, só corrige o ISEI. O alinhamento da CLASSE dos
  # artistas visuais com os performers (347, classe média) fica como decisão
  # editorial na branch proposta-bloco-c.
  "191" = "2452",
  "214" = "2452",
  "215" = "2452",
  # os 17 códigos ausentes do mapa v1 (MEMO §2)
  "0"   = NA,       # NÃO INFORMADA
  "902" = "13",     # PROPR. ESTAB. COMERCIAL (36.265)
  "901" = "1311",   # PROPR. ESTAB. AGRÍCOLA/PECUÁRIA (7.070)
  "905" = "13",     # PROPR. MICROEMPRESA
  "903" = "13",     # PROPR. ESTAB. INDUSTRIAL
  "904" = "13",     # PROPR. ESTAB. DE SERVIÇOS
  "924" = NA,       # PENSIONISTA (fora da PEA)
  "542" = "72",     # ELETRICISTA DE MANUT. DE VEÍCULOS
  "138" = "24",     # PROFISSIONAIS DE LETRAS E ARTES
  "274" = "11",     # GOVERNADOR (+ .COD_POLITICO abaixo)
  "108" = "21",     # TECNÓLOGO (nível superior tecnológico)
  "906" = NA,       # PROPR. DE IMÓVEL/ALUGUEL (rentista, como 907)
  "105" = "347",    # DESENHISTA INDUSTRIAL
  "205" = "2422",   # MINISTRO DE TRIBUNAL SUPERIOR / MAGISTRADO
  "533" = "31",     # CONTRAMESTRE DE EMBARCAÇÕES
  "949" = NA        # ESPÓLIO (1 caso)
)

.PATCH_ISEI <- c("2421" = 85, "2422" = 90, "246" = 53, "5162" = 50, "1311" = 43,
                 # rodada 5: valores da tabela de Ganzeboom, nunca estimados
                 "3226" = 60, "3223" = 51, "2221" = 88,
                 # rodada 6: idem, escultores/pintores/artistas plásticos
                 "2452" = 54)

# ---- (3b) PATCH DE CLASSE: onde a ISCO-88 envelheceu -------------------------
# A regra de classe le o PRIMEIRO DIGITO da ISCO-88 (bloco `classe_v2` adiante).
# Isso e uma hipotese: a de que o endereco de uma ocupacao no arquivo da OIT
# descreve a sua posicao social. Ela vale quase sempre, e quebra onde a fonte
# envelheceu — porque o primeiro digito e de 1988 e as ocupacoes se moveram.
#
# Fisioterapia e nutricao foram classificadas em 1988 como "associate
# professionals" (grande grupo 3), auxiliares da medicina. Universitarizaram-se,
# e a PROPRIA OIT reconheceu isso na revisao de 2008, movendo-as ao grande grupo
# 2 (2264 fisioterapeutas, 2265 nutricionistas) — codigos que este pacote ja
# computa. O criterio externo concorda: 95,8% dos que declaram 114 e 85,4% dos
# que declaram 222 tem superior completo, contra 74,7% da professora fundamental
# (265), que a regra atual poe um estrato ACIMA. A regua ficava incoerente com a
# sua propria logica, e no caso mais feminizado da tabela.
#
# POR QUE UM PATCH, E NAO UMA REGRA NOVA. Medimos a alternativa de principio —
# ler o grande grupo da ISCO-08 no lugar do da ISCO-88, para todos os codigos.
# Ela conserta estes dois e QUEBRA TRES: 234, 602 e 901 (produtor agropecuario,
# pecuarista, proprietario agricola) cairiam de classe alta para rural, porque a
# ponte 88->08 do codigo 1311 tem NOVE destinos possiveis segundo a OIT e o
# truncado, 6130, vale ISEI-08 17,8 contra 43 do ISCO-88. A regra de principio
# sai pior que o remendo: desfaz um patch deliberado por conta de uma
# ambiguidade da ponte, nao de uma decisao sociologica. Ler o "nivel de
# habilidade" formal da ISCO seria pior ainda — os quatro niveis da OIT fundem
# os grandes grupos 4 a 8 num so.
#
# O ISEI NAO MUDA (segue 60 e 51): as duas reguas continuam independentes, que e
# o desenho deste pacote. Muda a classe, o estrato e o componente da alta.
.PATCH_CLASSE <- c("114" = "Profissionais de nível superior",   # FISIOTERAPEUTA
                   "222" = "Profissionais de nível superior")  # NUTRICIONISTA

# mapa e tabela consolidados (v2)
.TSE_PARA_ISCO_V2 <- .TSE_PARA_ISCO
.TSE_PARA_ISCO_V2[names(.PATCH_ISCO)] <- .PATCH_ISCO
.ISEI_POR_ISCO_V2 <- c(.ISEI_POR_ISCO, .PATCH_ISEI)

# políticos: v1 + governador (274)
.COD_POLITICO_V2 <- union(.COD_POLITICO, "274")

# ---- conjuntos de classificação (MEMO §§4–7) --------------------------------
# proprietários e empregadores (o polo do CAPITAL → "alta proprietária")
.COD_PROPRIETARIO <- c("901","902","903","904","905",  # proprietários nomeados
                       "257",                          # EMPRESÁRIO
                       "169",                          # COMERCIANTE
                       "206",                          # INDUSTRIAL
                       "234","602")                    # produtor agropec., pecuarista
# ---- posicao na ocupacao (SEMPL), DISTINTA da pertenca ao esquema -----------
# .COD_PROPRIETARIO fazia dois trabalhos ao mesmo tempo: definia quem e
# "Proprietarios e empregadores" no esquema de classes E alimentava o SEMPL do
# EGP. Sao duas perguntas diferentes. "Este candidato trabalha por conta
# propria?" nao e a mesma coisa que "este candidato pertence a classe
# proprietaria?" — o agricultor familiar responde sim a primeira e nao a
# segunda.
#
# Enquanto os dois compartilhavam um vetor, marcar o agricultor como conta
# propria (que o EGP exige para chegar a IVc) o promovia junto a classe alta,
# que o patrimonio nao sustenta: 601 tem mediana de R$ 254.582 contra
# R$ 996 mil do pecuarista.
#
# .COD_CONTA_PROPRIA e o SEMPL = 2 do ISMF: superconjunto de
# .COD_PROPRIETARIO, com os codigos que trabalham por conta propria sem serem
# a classe proprietaria.
#
# A EVIDENCIA e externa e esta em `isco_posicao_br`, apurada na PNAD Continua
# de 2025 (4 trimestres, 437.880 pessoas). Entre os brasileiros ocupados:
#
#   ISCO 61 (agricolas qualificados)   67,6% conta propria ou empregador
#   ISCO 6150 (pesca)                  83,8%
#   ISCO 92 (rurais elementares)       16,5%
#   todas as ocupacoes                 29,4%
#
# A ISCO 61 e, na definicao da OIT, quem OPERA A PROPRIA TERRA, e o dado
# brasileiro confirma com folga. Como candidatos sao selecionados por
# patrimonio, 67,6% e um piso, nao uma estimativa central.
#
# A marcacao e por CODIGO DO TSE, e nao por ISCO, porque tres codigos dividem
# a ISCO 6100 e nao sao a mesma coisa: 601 AGRICULTOR e 604 PESCADOR sao
# conta propria; 207 JARDINEIRO e trabalho contratado. Marcar por ISCO
# arrastaria o jardineiro junto.
.COD_CONTA_PROPRIA <- union(.COD_PROPRIETARIO,
                            c("601",    # AGRICULTOR (ISCO 61: 67,6%)
                              "604"))   # PESCADOR   (ISCO 6150: 83,8%)

# ---- por que o agricultor NAO tem classe propria (rodada 7, 29/07/2026) ------
# Em 29/07/2026 os codigos 601 (AGRICULTOR) e 604 (PESCADOR) receberam por
# algumas horas uma classe propria, "Conta propria rural", fora dos tres
# estratos. A decisao foi REVERTIDA no mesmo dia, e o motivo merece ficar aqui
# para nao ser refeita.
#
# O ARGUMENTO QUE A SUSTENTAVA ERA INVALIDO. Dizia-se que os dois esquemas do
# pacote discordavam: o relacional poe 601 em IVc (proprietario rural) e o
# categorico o punha nas classes populares. Mas o EGP so separa IVc de VIIb nas
# ONZE classes. Nos colapsos canonicos de Erikson e Goldthorpe:
#
#   n_classes = 11 : 601 -> IVc          606 -> VIIb        (separados)
#   n_classes =  5 : 601 -> IVc+VIIb     606 -> IVc+VIIb    (FUNDIDOS)
#   n_classes =  3 : 601 -> Agricolas    606 -> Agricolas   (FUNDIDOS)
#
# Comparar um esquema de onze classes com uma particao de tres estratos e
# comparar resolucoes diferentes, nao encontrar discordancia. Na resolucao
# equivalente a do estrato, o EGP funde os dois — o contrario do que se alegava.
#
# E O DADO POE O 601 DENTRO DA FAIXA POPULAR:
#   ISEI 23      = percentil 5 do dicionario; faixa das populares e 16 a 43
#   prestigio 38 = percentil 36
#   patrimonio R$ 254.582 contra MAXIMO de R$ 251.986 entre as populares
#
# O patrimonio nao o poe acima da classe popular; poe no topo dela, por tres mil
# reais. A comparacao original era contra a MEDIANA das populares (R$ 132.000),
# o que inflava a distancia.
#
# A distincao entre agricultura familiar e proletariado rural e real e continua
# registrada onde Erikson e Goldthorpe a puseram: no EGP de onze classes, que
# `tse_para_egp(n_classes = 11)` entrega. O que nao se justifica e move-la para
# a particao em estratos, que e a resolucao em que o proprio esquema a funde.

# vínculo público sem ocupação (MEMO §5): categoria própria, fora dos estratos
.COD_VINCULO_PUB  <- c("291","296","297","298")
# segurança pública (MEMO §6): estrato médio (ISEI 50), não mais "populares"
.COD_SEGURANCA    <- c("232","233","258","145","295")

# ---- a partição do resíduo (rodada 5) ---------------------------------------
# O rótulo único "Fora da PEA / não informado" reunia 26,9% das candidaturas e
# fundia três situações que o dado mostra serem distintas:
#
#   grupo                        n         % sup   patrimônio mediano
#   Não informado            602.444        11,1   R$ 154.475
#   Fora da PEA por posição  167.419         4,3   R$ 103.511
#   Inativo com trajetória   128.010        20,7   R$ 388.167
#
# O terceiro grupo é MAIS RICO que a classe alta da vereança (R$ 305.988) e
# estava invisível, somado a quem não informou ocupação. São aposentados,
# reformados e rentistas: gente com trajetória ocupacional real, que é
# exatamente o caso de uso de `isei_retrospectivo()`.
#
# A partição NÃO altera nenhuma proporção de classe alta, média ou popular: os
# três rótulos continuam fora dos estratos. O que muda é poder dizer algo
# verdadeiro sobre eles em vez de tratá-los como ausência homogênea.
.COD_NAO_INFORMADO <- c("0","-4","999","949")        # inclui espólio
.COD_FORA_PEA_POS  <- c("581","931")                 # dona de casa, estudante
.COD_INATIVO       <- c("921","922","923","924","906","907")  # aposent./rentista
.CLASSE_RESIDUAL   <- c("Não informado", "Fora da PEA por posição",
                        "Inativo com trajetória")

# ---- funções públicas (tudo por código) -------------------------------------
isco_v2 <- function(cod) unname(.TSE_PARA_ISCO_V2[as.character(cod)])
isei_v2 <- function(cod) {
  isco <- isco_v2(cod)
  unname(.ISEI_POR_ISCO_V2[isco])
}
politico_v2 <- function(cod) as.character(cod) %in% .COD_POLITICO_V2

# classe social (8 + 2 categorias), por código
#
# `superior`: vetor lógico opcional (ensino superior completo). Quando fornecido,
# a categoria residual "Vínculo público não especificado" — que sozinha reúne
# ~9% das candidaturas e confunde do faxineiro ao secretário de finanças — é
# estratificada pela escolaridade declarada. A validação que motivou o corte:
# entre os servidores cuja ocupação real foi recuperada pela ligação
# retrospectiva por pessoa, os com superior têm ISEI médio de 62,5 contra 45,4
# dos demais — uma distância maior que todo o gradiente vereador→governador.
#
# O corte é DELIBERADAMENTE feito aqui, no esquema CATEGÓRICO, e não no ISEI:
# usar escolaridade para imputar o escore contínuo contaminaria a comparação de
# credencial por gênero, que o artigo ancora justamente na escolaridade. Assim
# as duas réguas — categórica e contínua — permanecem independentes.
classe_v2 <- function(cod, superior = NULL) {
  cod  <- as.character(cod)
  isco <- isco_v2(cod)
  g1   <- substr(isco, 1, 1)            # 1º dígito ISCO
  cl <- data.table::fcase(
    cod %in% .COD_VINCULO_PUB,  "Vínculo público não especificado",
    cod %in% .COD_PROPRIETARIO, "Proprietários e empregadores",
    cod %in% .COD_SEGURANCA,    "Militares e segurança pública",
    # o resíduo, agora em três (ver o bloco de comentários acima)
    cod %in% .COD_INATIVO,      "Inativo com trajetória",
    cod %in% .COD_FORA_PEA_POS, "Fora da PEA por posição",
    cod %in% .COD_NAO_INFORMADO,"Não informado",
    is.na(isco),                "Não informado",
    g1 == "1",                  "Dirigentes e políticos",
    g1 == "2",                  "Profissionais de nível superior",
    g1 %in% c("3","4"),         "Classe média técnica e administrativa",
    isco %in% c("61","62","92"),"Trabalhadores rurais",
    g1 %in% c("5","9"),         "Trabalhadores de serviços e comércio",
    g1 %in% c("7","8"),         "Operários e trabalhadores manuais",
    default = "Não informado"
  )
  # onde a ISCO-88 envelheceu e a propria OIT ja corrigiu (ver .PATCH_CLASSE)
  pc <- .PATCH_CLASSE[cod]
  cl[!is.na(pc)] <- pc[!is.na(pc)]
  if (!is.null(superior)) {
    if (length(superior) != length(cl))
      stop("`superior` deve ter o mesmo comprimento de `cod`.")
    pub <- cl == "Vínculo público não especificado"
    sup <- !is.na(superior) & superior
    cl[pub &  sup] <- "Vínculo público, superior"
    cl[pub & !sup] <- "Vínculo público, médio ou menos"
  }
  cl
}

# rótulos que compõem o estrato residual de vínculo público (com e sem corte)
.CLASSE_VINCULO_PUB <- c("Vínculo público não especificado",
                         "Vínculo público, superior",
                         "Vínculo público, médio ou menos")

# estrato de tendência (com as duas categorias próprias explícitas)
# O corte por escolaridade do vínculo público NÃO altera o estrato: as três
# variantes do rótulo continuam no mesmo estrato residual, de modo que nenhuma
# proporção de classe alta, média ou popular do artigo se move com o corte.
estrato_v2 <- function(cod, superior = NULL) {
  cl <- classe_v2(cod, superior)
  data.table::fcase(
    cl %in% c("Proprietários e empregadores","Dirigentes e políticos",
              "Profissionais de nível superior"),          "Classe alta",
    cl %in% c("Classe média técnica e administrativa",
              "Militares e segurança pública"),            "Classe média",
    cl %in% c("Trabalhadores de serviços e comércio",
              "Operários e trabalhadores manuais",
              "Trabalhadores rurais"),                     "Classes populares",
    cl %in% .CLASSE_VINCULO_PUB,                           "Vínculo público não especificado",
    # os três rótulos residuais continuam FORA dos estratos, exatamente como
    # antes: a partição não move nenhuma proporção de classe alta, média ou
    # popular. O estrato agrega os três sob um nome só, para que as tabelas de
    # estrato do artigo permaneçam comparáveis com as já publicadas.
    cl %in% .CLASSE_RESIDUAL,                              "Fora da PEA / não informado",
    default = "Fora da PEA / não informado"
  )
}

# a PARTIÇÃO da classe alta (o enquadre da revisão; MEMO §7)
componente_alta_v2 <- function(cod) {
  cl <- classe_v2(cod)
  data.table::fcase(
    cl == "Proprietários e empregadores",    "Alta proprietária",
    cl == "Profissionais de nível superior", "Alta credenciada",
    cl == "Dirigentes e políticos",          "Dirigentes e políticos",
    default = NA_character_
  )
}

# ---- ISEI com carregamento retrospectivo por pessoa -------------------------
# O ISEI observado cobre ~64% das candidaturas: quem declara "outros", vínculo
# público sem função ou posição fora da PEA não tem ocupação mensurável por
# status. Metade desses casos é resíduo irrecuperável; a outra metade é gente
# fora do mercado NAQUELE momento, que em geral teve ocupação classificável
# numa candidatura anterior. Esta função carrega o último escore conhecido da
# própria pessoa (last observation carried forward).
#
#   - só o PASSADO: usar aparições futuras descreveria a posição no momento da
#     candidatura por uma ocupação que a pessoa ainda não tinha;
#   - `excluir_cod` fica fora do carregamento (por padrão, estudante/bolsista/
#     estagiário — categoria em que a recuperação pelo passado é mínima e o
#     apelo estaria justamente no futuro que a regra proíbe);
#   - não é circular: usa só a história ocupacional da pessoa, nunca
#     patrimônio, partido ou escolaridade.
#
# Devolve uma lista com o escore carregado, a marca de herdado e a defasagem em
# anos, para que a qualidade do carregamento seja auditável.
isei_retrospectivo <- function(dt, isei = "isei", id = "id_pessoa",
                               ano = "ano", cod = "cod_ocup",
                               excluir_cod = "931") {
  stopifnot(data.table::is.data.table(dt))
  d <- data.table::data.table(
    .i = seq_len(nrow(dt)), .isei = dt[[isei]], .id = dt[[id]],
    .ano = dt[[ano]], .cod = as.character(dt[[cod]]))
  data.table::setorder(d, .id, .ano)
  d[, .locf := data.table::nafill(.isei, type = "locf"), by = .id]
  d[, .ano_obs := data.table::fifelse(!is.na(.isei), .ano, NA_integer_)]
  d[, .ano_locf := data.table::nafill(.ano_obs, type = "locf"), by = .id]
  d[, .ret := data.table::fifelse(
    !is.na(.isei), .isei,
    data.table::fifelse(.cod %in% excluir_cod, NA_real_, .locf))]
  d[, .herdado := is.na(.isei) & !is.na(.ret)]
  d[, .defasagem := data.table::fifelse(.herdado, .ano - .ano_locf, NA_integer_)]
  data.table::setorder(d, .i)                       # devolve na ordem original
  list(isei = d$.ret, herdado = d$.herdado, defasagem = d$.defasagem)
}

# ---- teste de COBERTURA contra o dado (substitui o autoteste interno) -------
# Chamar com o vetor de códigos OBSERVADOS; falha se algum código não estiver
# no dicionário (o defeito silencioso que escondeu os proprietários na v1).
testa_cobertura <- function(cods_observados) {
  obs  <- unique(as.character(cods_observados))
  fora <- setdiff(obs, names(.TSE_PARA_ISCO_V2))
  if (length(fora))
    stop("Códigos de ocupação SEM entrada no dicionário v2: ",
         paste(fora, collapse = ", "))
  # todo ISCO usado tem ISEI
  usados <- unique(na.omit(unname(.TSE_PARA_ISCO_V2[obs])))
  sem    <- setdiff(usados, names(.ISEI_POR_ISCO_V2))
  if (length(sem))
    stop("ISCO sem valor ISEI: ", paste(sem, collapse = ", "))
  message(sprintf("cobertura v2 OK: %d códigos observados, todos no dicionário.",
                  length(obs)))
  invisible(TRUE)
}

# ---- exporta o dicionário completo como tabela (CSV suplementar; MEMO/P1-d8) --
exporta_crosswalk <- function(arquivo, rotulos = NULL) {
  dt <- data.table::data.table(cod = names(.TSE_PARA_ISCO_V2))
  dt[, isco    := isco_v2(cod)]
  dt[, isei    := isei_v2(cod)]
  dt[, classe  := classe_v2(cod)]
  dt[, estrato := estrato_v2(cod)]
  dt[, componente_alta := componente_alta_v2(cod)]
  dt[, politico := politico_v2(cod)]
  if (!is.null(rotulos)) dt <- merge(dt, rotulos, by = "cod", all.x = TRUE)
  data.table::fwrite(dt, arquivo)
  message("crosswalk v2 exportado: ", arquivo, " (", nrow(dt), " códigos)")
  invisible(dt)
}
