# ============================================================================
# isei_ocupacao.R — Ocupação do TSE → ISCO-88 (2–3 dígitos) → ISEI
# ----------------------------------------------------------------------------
# PROPÓSITO (reutilizável). Constrói um escore socioeconômico CONTÍNUO de
# ocupação — o ISEI (International Socio-Economic Index of occupational status,
# de Ganzeboom) — para a ocupação declarada no TSE. É a metodologia-bônus do
# artigo: como adaptar uma classificação nacional (a ocupação do TSE) a um
# instrumento internacional (ISCO/ISEI) sem cometer o erro do nível errado.
#
# POR QUE NÃO USAR O GRANDE GRUPO (1 dígito). O ISEI é definido sobre a ISCO
# (classificação internacional). A ocupação do TSE já foi vertida para a CBO
# brasileira em R/crosswalk_cbo.R, mas a CBO só é compatível com a ISCO no
# nível de 2 DÍGITOS (subgrupo principal); a 1 dígito as duas desenham as
# caixas de forma diferente. O caso-limite: o grande grupo 9 da CBO é
# "reparação e manutenção" (mecânicos, ISEI ~34), enquanto o grande grupo 9 da
# ISCO é "ocupações elementares" (serventes, ISEI ~20). Traduzir a 1 dígito
# carimbaria todo mecânico com o ISEI de um servente — erro sistemático na base
# da escala. A tradução válida é, no mínimo, a 2 dígitos; usam-se 3 dígitos onde
# o rótulo do TSE distingue o que a ISCO só separa nesse nível (ver abaixo).
#
# QUATRO PASSOS (é a receita geral de adaptação entre classificações):
#   (1) universo — as ~259 ocupações distintas do TSE (CD_OCUPACAO / DS_OCUPACAO);
#   (2) ponte    — cada código do TSE recebe um código ISCO-88 (2 ou 3 dígitos),
#                  por julgamento documentado, no nível mais fino defensável;
#   (3) valor    — cada código ISCO recebe seu ISEI, de fonte verificada;
#   (4) uso      — junta-se o ISEI à microbase pela CHAVE ESTÁVEL (o código,
#                  não o rótulo, que às vezes vem truncado nos dados do TSE).
#
# ONDE 3 DÍGITOS É INDISPENSÁVEL (a 2 dígitos distorceria):
#   - Saúde: ISCO 22 (profissionais de saúde) = 80 mistura médico e enfermeiro.
#     A 3 dígitos, médico/dentista/vet/farmacêutico = 222 (ISEI 85) e enfermeiro
#     = 223 (ISEI 43) — 42 pontos de diferença que o 2 dígitos apagaria.
#   - Docência: professor superior = 231 (77), médio = 232 (69), fundamental =
#     233 (66); a 2 dígitos (23 = 69) o professor primário sobe indevidamente.
#
# FONTE DOS VALORES ISEI (verificada, não estimada). Ganzeboom & Treiman, mapa
# ISCO-88 → ISEI-92, conforme implementado no pacote R `occupar`
# (isco88toISEI92; http://www.harryganzeboom.nl). Os valores por subgrupo estão
# gravados abaixo em `.ISEI_POR_ISCO` para auditoria direta. NUNCA preencher um
# ISEI por estimativa: ocupação sem código ISCO defensável recebe NA.
#
# O QUE FICA COMO NA (não classificável por ocupação — honestidade > cobertura):
#   - Fora da PEA: dona de casa, estudante, aposentado, militar reformado.
#   - Categorias genéricas de vínculo, não de ocupação: "servidor público
#     municipal/estadual/federal", "ocupante de cargo em comissão" — conflam do
#     faxineiro ao secretário de finanças; sem ocupação, sem ISEI.
#   - "Outros", "não divulgável", rentista ("capitalista de ativos financeiros").
#   - Forças armadas propriamente ditas (ISCO grande grupo 0 não tem ISEI). A
#     POLÍCIA e o bombeiro, porém, são serviços de proteção (ISCO 51) e entram.
#
# NOTA sobre ocupações POLÍTICAS. Vereador, prefeito, deputado etc. são a ISCO
# 11 (legisladores) = 70. Como muitos candidatos declaram o próprio mandato como
# ocupação, o flag `ocup_politico()` permite a robustez de excluí-los (o mesmo
# espírito de SCRIPTS/checagem_politico.R).
#
# Uso:
#   source("R/isei_ocupacao.R")
#   d[, isei := isei_ocupacao(CD_OCUPACAO)]          # chave estável (recomendado)
#   d[, isco := isco_da_ocupacao(CD_OCUPACAO)]       # subgrupo ISCO-88
#   d[, pol  := ocup_politico(CD_OCUPACAO)]          # flag de ocupação-mandato
# ============================================================================

suppressMessages(library(data.table))

# ---- (3) VALOR: ISEI por código ISCO-88 (Ganzeboom, via occupar) -----------
# Subgrupos de 2 dígitos e os poucos minor groups de 3 dígitos usados na ponte.
# (Transcritos de isco88toISEI92; conferíveis um a um.)
.ISEI_POR_ISCO <- c(
  # 2 dígitos (subgrupo principal)
  "11" = 70, "12" = 68, "13" = 51,          # dirigentes/gerentes
  "21" = 69,                                 # profis. ciências físicas/engenharia
  "24" = 68,                                 # outros profis. (direito, negócios, ciências sociais, artes eruditas)
  "31" = 50, "32" = 48, "34" = 55,          # técnicos de nível médio
  "41" = 45, "42" = 49,                     # apoio administrativo
  "51" = 38, "52" = 43,                     # serviços e vendas
  "61" = 23,                                 # agropecuários qualificados (mercado)
  "71" = 31, "72" = 34, "73" = 34, "74" = 33, # ofícios/artesanato/construção
  "81" = 30, "82" = 32, "83" = 32,          # operadores de instalações/máquinas/condutores
  "91" = 25, "92" = 16, "93" = 23,          # ocupações elementares
  # 3 dígitos (onde 2 dígitos distorceria)
  "121" = 70,                                # diretores-gerais de empresa
  "222" = 85, "223" = 43,                   # médico/dentista/vet/farm. vs enfermeiro
  "231" = 77, "232" = 69, "233" = 66,       # docência superior / médio / fundamental
  "347" = 52,                                # artistas intérpretes (associados)
  "833" = 26,                                # operadores de máquinas agrícolas
  "913" = 16, "916" = 23                    # faxineiro/doméstico vs coletor de lixo
)

# ---- (2) PONTE: código de ocupação do TSE (CD_OCUPACAO) → código ISCO-88 ----
# Uma linha por código do TSE. A escolha do ISCO é julgamento documentado; onde
# houve dúvida, preferiu-se o subgrupo modal da categoria. NA = não classificável
# (ver cabeçalho). Códigos políticos marcados no bloco `.COD_POLITICO` adiante.
.TSE_PARA_ISCO <- c(
  "999"=NA, "601"="61", "298"=NA,  "169"="13", "257"="12", "278"="11", "581"=NA,
  "923"=NA, "265"="233","266"="232","131"="24", "606"="92", "931"=NA,  "125"="24",
  "297"=NA, "531"="83", "537"="83", "532"="83", "394"="41", "512"="51", "411"="52",
  "254"="51","402"="34", "292"="41", "709"="71", "243"="32", "109"="32", "113"="223",
  "233"="51","170"="52", "111"="222","541"="72", "234"="61", "604"="61", "230"="233",
  "703"="71","403"="34", "303"="13", "275"="11", "101"="21", "602"="61", "124"="24",
  "296"=NA, "237"="34", "922"=NA,  "134"="24", "166"="347","536"="83", "142"="231",
  "921"=NA, "713"="74", "115"="222","171"="24", "176"="51", "235"="232","164"="347",
  "390"="41","702"="82", "232"="51", "221"="83", "151"="34", "228"="74", "598"="913",
  "129"="73","397"="42", "117"="222","395"="41", "156"="31", "194"="52", "910"="24",
  "132"="24","153"="31", "206"="12", "114"="32", "503"="913","227"="833","239"="72",
  "112"="222","513"="51","213"="34", "291"=NA,  "163"="347","190"="34", "103"="21",
  "502"="91","401"="34", "172"="24", "196"="51", "158"="31", "144"="12", "197"="916",
  "157"="32","707"="72", "593"="34", "140"="51", "121"="24", "516"="72", "102"="21",
  "413"="91","207"="61", "514"="51", "591"="74", "119"="41", "246"="31", "258"="51",
  "126"="21","143"="232","596"="32", "705"="74", "195"="72", "161"="34", "277"="11",
  "293"="34","222"="222","110"="41", "168"="347","263"="21", "301"="121","215"="24",
  "160"="51","592"="32", "155"="31", "710"="74", "145"="51", "249"="72", "178"="41",
  "248"="32","511"="51", "515"="51", "295"=NA,  "192"="31", "517"="72", "398"="42",
  "715"="74","543"="72", "216"="93", "208"="91", "214"="24", "147"="916","244"="31",
  "167"="31","534"="83", "264"="21", "162"="24", "193"="347","137"="24", "224"="31",
  "590"="42","128"="21", "599"="51", "392"="41", "136"="24", "104"="21", "133"="24",
  "595"="51","241"="74", "211"="93", "405"="34", "255"="21", "544"="72", "148"="73",
  "185"="24","294"="24", "154"="31", "393"="41", "150"="72", "603"="92", "605"="71",
  "711"="73","210"="91", "245"="31", "118"="32", "220"="82", "200"="24", "186"="74",
  "260"="24","712"="82", "127"="24", "217"="91", "396"="41", "256"="21", "253"="71",
  "708"="72","175"="91", "252"="51", "226"="81", "189"="42", "209"="91", "187"="83",
  "412"="52","130"="347","159"="24", "165"="347","223"="21", "181"="31", "535"="83",
  "236"="73","238"="51", "492"="52", "231"="81", "716"="82", "146"="93", "177"="51",
  "704"="81","714"="81", "225"="32", "188"="74", "174"="73", "107"="21", "-4"=NA,
  "123"="21","247"="31", "242"="83", "259"="24", "521"="51", "501"="91", "251"="82",
  "183"="31","180"="72", "404"="34", "273"="11", "271"="24", "152"="32", "717"="73",
  "262"="24","191"="24", "179"="34", "250"="74", "701"="31", "199"="91", "240"="41",
  "491"="52","141"="21", "907"=NA,  "201"="11", "706"="82", "184"="91", "106"="21",
  "218"="24","122"="21", "120"="24", "229"="32", "149"="74", "182"="51", "139"="51",
  "597"="93","594"="42", "261"="24", "219"="21", "276"="11", "173"="31", "116"="21",
  "391"="41","212"="24", "198"="21", "203"="11", "135"="24", "272"="11", "270"="24"
)

# ocupações que são MANDATO político (para robustez de exclusão)
.COD_POLITICO <- c("278","275","277","273","201","276","203","272")

# ---- funções públicas -------------------------------------------------------
# aceitam o CÓDIGO (CD_OCUPACAO) — chave estável e recomendada.
isco_da_ocupacao <- function(cod) {
  cod <- as.character(cod)
  unname(.TSE_PARA_ISCO[cod])
}

isei_ocupacao <- function(cod) {
  isco <- isco_da_ocupacao(cod)
  unname(.ISEI_POR_ISCO[isco])            # NA se isco é NA ou não mapeado
}

ocup_politico <- function(cod) {
  as.character(cod) %in% .COD_POLITICO
}

# rótulo legível do subgrupo ISCO (para figuras/apêndice)
.ISCO_ROTULO <- c(
  "11"="Legisladores e dirigentes públicos", "12"="Dirigentes de empresa",
  "13"="Dirigentes de pequenas empresas", "21"="Profissionais das ciências e engenharia",
  "24"="Profissionais (direito, negócios, ciências sociais, artes)",
  "31"="Técnicos das ciências/engenharia", "32"="Técnicos das ciências da vida e saúde",
  "34"="Outros técnicos de nível médio", "41"="Escriturários", "42"="Atendimento ao público",
  "51"="Serviços pessoais e de proteção", "52"="Vendedores", "61"="Agropecuários qualificados",
  "71"="Construção e extração", "72"="Metalurgia e mecânica", "73"="Artesanato de precisão",
  "74"="Outros ofícios (alimentos, têxtil, madeira)", "81"="Operadores de instalações fixas",
  "82"="Operadores de máquinas e montadores", "83"="Condutores", "91"="Serviços elementares",
  "92"="Trabalhadores agrícolas elementares", "93"="Trabalhadores elementares (indústria/construção/transporte)",
  "121"="Diretores-gerais de empresa", "222"="Médicos, dentistas, veterinários, farmacêuticos",
  "223"="Enfermeiros", "231"="Professores de ensino superior", "232"="Professores de ensino médio",
  "233"="Professores de ensino fundamental", "347"="Artistas intérpretes",
  "833"="Operadores de máquinas agrícolas", "913"="Faxineiros e domésticos", "916"="Coletores de lixo"
)
isco_rotulo <- function(isco) unname(.ISCO_ROTULO[as.character(isco)])

# ---- autoteste de cobertura (roda ao dar source, silencioso se OK) ----------
local({
  n_tot <- length(.TSE_PARA_ISCO)
  n_na  <- sum(is.na(.TSE_PARA_ISCO))
  # todo ISCO usado precisa ter ISEI
  usados <- unique(na.omit(unname(.TSE_PARA_ISCO)))
  faltam <- setdiff(usados, names(.ISEI_POR_ISCO))
  if (length(faltam))
    stop("ISCO sem ISEI em .ISEI_POR_ISCO: ", paste(faltam, collapse=", "))
  message(sprintf("isei_ocupacao.R: %d ocupações do TSE mapeadas (%d NA, %d classificáveis).",
                  n_tot, n_na, n_tot - n_na))
})
