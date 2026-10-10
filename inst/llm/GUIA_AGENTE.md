# ocupacoesBR — guia para agentes

Este arquivo é o resumo operacional do pacote, escrito para quem lê antes de
escrever código: um modelo de linguagem, ou uma pessoa com pressa. Ele não
substitui a documentação — concentra o que precisa ser sabido **antes da
primeira chamada**, que é o momento em que os erros deste pacote acontecem.

Caminho no disco:

```r
system.file("llm", "GUIA_AGENTE.md", package = "ocupacoesBR")
```

---

## 1. A gramática dos nomes

São 61 funções exportadas, e 47 delas seguem um padrão só:

```
<origem>_para_<destino>()
```

As **origens** são as quatro portas de entrada, uma por fonte de dado
brasileira:

| origem | de onde vem |
|---|---|
| `tse_` | `CD_OCUPACAO` das candidaturas ao TSE |
| `cbo2002_`, `cbo94_` | CBO da RAIS, do CAGED e do eSocial |
| `cod_` | COD da PNAD Contínua e do Censo |
| `isco88_`, `isco08_` | quem já tem o código internacional |

Os **destinos** são as classificações e as réguas de posição social:
`isco`, `isco08`, `isei`, `isei08`, `isei_br`, `prestigio`, `prestigio08`,
`egp`, e — só pela porta do TSE — `classe`, `estrato`, `componente_alta`,
`rotulo`, `politico`.

Composto o nome, a função existe: `cod_para_egp()`, `isco88_para_isei()`,
`cbo2002_para_prestigio08()`. As exceções à gramática são poucas e todas
prefixadas: `crosswalk_*()` devolve a tabela inteira em vez de um vetor,
`checa_*()` verifica em vez de traduzir, e `isei_retrospectivo()` é o único
nome fora de padrão.

**Nem toda combinação existe, e a ausência tem razão.** Não há
`cbo94_para_isei_br()`: o ISEI-BR é ancorado na ISCO-08 e estimado em 2025, e a
CBO-94 saiu de uso muito antes. Uma chamada a um nome inexistente falha com
`could not find function` — não invente a função, procure a razão em `?reguas`.

**Um alias a evitar.** Seis exports contêm `siops` (`tse_para_siops()` e
companhia). São **alias depreciados** de `*_prestigio*`, mantidos por
compatibilidade. Funcionam e estão corretos, mas o nome preferido é
`prestigio`: no Brasil, SIOPS designa o Sistema de Informações sobre Orçamentos
Públicos em Saúde, e a colisão é certa.

## 2. O contrato de chamada

Toda função de tradução é **vetorizada e pura**: entra um vetor de códigos, sai
um vetor do mesmo comprimento, na mesma ordem. Não há estado de sessão, não há
ordem obrigatória de chamadas, não há leitura de disco. Cada régua é uma coluna
nova, e todas cabem no mesmo `mutate()`.

```r
library(ocupacoesBR)

candidaturas |>
  dplyr::mutate(
    isco  = tse_para_isco(CD_OCUPACAO, ano = ANO_ELEICAO),
    isei  = tse_para_isei(CD_OCUPACAO, ano = ANO_ELEICAO),
    egp   = tse_para_egp(CD_OCUPACAO,  ano = ANO_ELEICAO, n_classes = 5),
    class = tse_para_classe(CD_OCUPACAO, ano = ANO_ELEICAO)
  )
```

Códigos inválidos **não abortam** a chamada: viram `NA` com aviso, porque em
dado administrativo o valor sujo é a regra e não a exceção. O erro só acontece
quando *nenhum* valor é válido — sinal quase certo de que a coluna passada foi
a errada. A mensagem diz o que era exigido e imprime os valores recebidos;
leia-a antes de tentar outra coisa.

## 3. As três armadilhas

Estas são as maneiras de obter um resultado **errado e silencioso**. Nenhuma
delas produz erro.

### 3.1 Escolher a régua errada

As réguas não são intercambiáveis, e trocar uma pela outra custa uma letra no
nome da função. ISEI e prestígio correlacionam-se forte e discordam onde
importa: o magistrado tem ISEI 90 e prestígio 76; o enfermeiro, 43 e 54. Uma
pesquisa sobre "quem tem posição de topo" e outra sobre "quem é socialmente
valorizado" ordenam as profissões de saúde de formas diferentes, e as duas
estão certas.

**Consulte a tabela antes de escolher**, e diga na análise qual régua escolheu:

```r
reguas[, c("medida", "pergunta", "quando_nao_usar")]
reguas[reguas$tipo == "continua", c("medida", "ancora", "funcao_tse")]
```

Três consequências que a tabela detalha e que se erram muito: não publique EGP
de onze classes a partir do TSE (sem número de subordinados, IVa e IVb não se
separam — colapse em 5 ou 3); não misture ISEI-88 e ISEI-08 na mesma série, que
é troca de âncora no meio do caminho; e não use ISEI como proxy de renda ou
patrimônio individual (r = 0,207 no nível da candidatura).

### 3.2 Traduzir série longa sem passar o `ano`

Entre 2000 e 2002 o TSE reeditou a tabela de ocupações, e sete códigos passaram
a designar **outra** ocupação. O 215 era ocupante de cargo de direção até 2000
e virou artista plástico depois.

```r
tse_para_classe(c("215", "215"), ano = c(2000, 2020))
```

Com `ano`, a candidatura antiga volta `NA` com aviso. **Sem `ano`, ela é
traduzida pelo dicionário errado, calada.** Toda porta do TSE aceita `ano`;
passe-o sempre que o dado cruzar 2002.

O problema maior nem é a reutilização: é a troca de inventário. Comparando os
períodos inteiros, são 13 códigos extintos e 122 criados, entre eles
`COMERCIANTE` e `EMPRESÁRIO` (`tse_diff_cadastro()` compara duas safras
quaisquer). Uma série que
atravesse 2002 mede "Proprietários e empregadores" com dois vocabulários
incomensuráveis. O caminho honesto é começar em 2004, ou declarar a
descontinuidade.

### 3.3 Tratar `NA` como zero, ou como ausência aleatória

Dezessete dos 275 códigos não designam ocupação — não informada, fora da PEA,
vínculo sem função. Eles **não têm** ISEI, prestígio ou EGP, e isso é a resposta
correta, não falha de cobertura. Têm classe, porém: o esquema categórico cobre
onde a escala contínua não chega.

E a ausência é **fortemente generificada**: cerca de 15% das mulheres declaram
posição fora da PEA, contra pouco mais de 1% dos homens. Uma média de ISEI por
gênero com `na.rm = TRUE` compara duas subpopulações truncadas de formas
diferentes, e a "vantagem feminina em status" que aparece é em boa parte
artefato disso. **Quem compara médias por grupo reporta a cobertura junto.**

Uma quarta armadilha, menor mas fatal quando acontece: toda tradução válida é,
no mínimo, a dois dígitos. Pelo primeiro dígito a correspondência **inverte
classes inteiras** — o grande grupo 9 da CBO é reparação e manutenção, e o da
ISCO é o das ocupações elementares.

## 4. Verifique antes, não depois

As duas travas são `opt-in` e ficam fora do caminho feliz. Chame-as:

```r
checa_cobertura(candidaturas$CD_OCUPACAO)
checa_periodo(candidaturas$CD_OCUPACAO, candidaturas$ANO_ELEICAO)
```

`checa_cobertura()` falha **com erro** se aparecer código fora do dicionário. O
modo silencioso de errar uma medida de classe não é classificar mal um caso: é
um código novo cair num rótulo residual sem ninguém perceber.

## 5. Onde ler o resto

| o quê | onde |
|---|---|
| a escolha da régua, como dado | `?reguas` |
| a escolha da régua, com exemplos | `vignette("qual-regua")` |
| a medida se sustenta? | `vignette("validacao")` |
| tudo de um código de uma vez | `crosswalk_tse()` |
| a história do cadastro do TSE | `?tse_ocupacao_rotulos`, `?tse_quebra_2002` |

Tudo neste guia é verificável dentro do pacote, sem dado externo: as tabelas
viajam com ele e os exemplos rodam.
