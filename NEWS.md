# ocupacoesBR 0.8.2

Duas correções, sem mudança de comportamento, de dado ou de resultado: uma
pedida pela revisão manual à 0.8.1, outra completando um pedido da revisão
à 0.8.0 que a 0.8.1 só tinha atendido em parte.

- **`Title` e `Description` ganham a versão em inglês, ao lado da
  portuguesa** (pedido da revisão à 0.8.1). O CRAN pediu "an English title
  and description in addition to the Portuguese one"; os dois campos
  passam a trazer o texto em português seguido de "English: " e a tradução
  correspondente. Para o `Description`, é o mesmo padrão usado pelo pacote
  `datos` (CRAN); o `Title` bilíngue é a mesma convenção aplicada por
  analogia, já que o `datos` não faz isso no `Title`. `Language: pt-BR`
  continua declarado, e o `Title` passa dos 65 caracteres recomendados só
  por ser bilíngue.
- Completa, para as 61 funções exportadas, a exigência de `\value` que a
  0.8.1 só tinha atendido para o único objeto citado nominalmente pelo CRAN
  (`tse_codigos_autorrotulo`). O pedido do CRAN também é geral — "explain the
  functions results ... write about the structure of the output (class) and
  also what the output means" — e 41 páginas de ajuda tinham `\value` presente
  mas raso, dizendo só a classe R ("Vetor numérico.") sem dizer o que o número
  ou o rótulo significam.
  - Toda função que traduz um código em ISEI, prestígio (SIOPS) ou EGP agora
    diz a escala (por exemplo, ISEI de 16 a 90, SIOPS de 0 a 100), o sentido
    de "maior" e o comportamento de `NA` e de comprimento do vetor.
  - `checa_cobertura_cod()`, `checa_cobertura_cbo2002()` e
    `checa_cobertura_cbo94()` agora dizem que o `TRUE` invisível não carrega
    informação por si só — o que importa é o efeito colateral (mensagem de
    sucesso, ou erro nomeando os códigos ausentes).
  - `tse_para_classe()`, `tse_para_estrato()`, `tse_para_componente_alta()`,
    `tse_para_politico()` e `tse_para_rotulo()` agora descrevem as categorias
    do vetor de texto ou lógico que devolvem, em vez de só a classe.

# ocupacoesBR 0.8.1

Correções pedidas pela revisão manual do CRAN à 0.8.0, sem mudança de
comportamento, de dado ou de resultado.

- O campo `Description` do `DESCRIPTION` passa a citar, com DOI ou ISBN, as
  obras que definem cada régua: Ganzeboom e Treiman (1996) para o ISEI,
  Treiman (1977) para o prestígio, Erikson, Goldthorpe e Portocarero (1979)
  para o EGP, além de Ganzeboom, De Graaf e Treiman (1992), já citado, e do
  preprint de método do pacote.
- `?tse_codigos_autorrotulo` ganha a seção de valor (`\value`), que faltava por
  ser uma constante exportada e não uma função: diz que o objeto é um vetor
  `character` de dez códigos e para que serve.

# ocupacoesBR 0.8.0

O índice de referência promete, na porta do IBGE, que "é por aqui que se compara
candidatura com população". Era a promessa mais forte do pacote e a única que
ele não mostrava cumprindo — nem mostrava onde ela falha. Esta versão dá ao
pacote os dois lados da comparação e a página que ensina a fazê-la.

O que motivou: em setembro de 2026 uma comparação entre candidaturas do TSE e
população da PNAD Contínua foi auditada e reprovada. A tradução estava certa e
os testes passaram. O erro estava numa decisão de medida que o site não
desaconselhava em lugar nenhum, porque em lugar nenhum tratava do assunto — ler
o primeiro dígito da ISCO-88 dos dois lados. O que reprovou a régua: os
rótulos de vínculo público do formulário do TSE saem da base classificável e os
mesmos trabalhadores, na PNAD Contínua, ficam dentro dela. O tamanho do viés —
3,4 pontos na classe profissional sobre uma base de 12,3 — foi medido naquela
auditoria, fora deste repositório, e é citado aqui como motivo e não como
número do pacote; o que este pacote mede está nas tabelas abaixo.

## `tse_universo`: de que é feito o resíduo das candidaturas

Sete rubricas, por ano e por sexo, somando 100 dentro de cada recorte.
`checa_cobertura()` já dizia *quanto* de um vetor recebe escore; esta tabela diz
*de que é feito* o que não recebe, e mostra que a resposta muda.

Duas leituras que uma taxa de cobertura única esconde. A não declaração vai a
zero a partir de 2006, o que indica campo obrigatório, e a recusa de nomear
assume o lugar dela: a rubrica `999` sai de 13,5% em 1998 e chega a 21,9% em
2024. E a diferença de cobertura entre os sexos está quase toda numa linha — de
2004 em diante, `Fora da força de trabalho` é 1,2% das candidaturas de homens e
14,6% das de mulheres. A vinheta `qual-regua` já afirmava isso em prosa; agora
há tabela.

## `cod_populacao_br`: o denominador

A distribuição da população pelos endereços da ISCO-88, por piso etário de
elegibilidade (18, 21, 30 e 35 anos, os da Constituição) e por sexo, com a
parcela não ocupada como **linha da tabela** e não como ausência dela.

É decisão de escopo, tomada pelo autor com a tabela medida à vista. O pacote é
um tradutor e uma distribuição populacional é outro tipo de objeto; o precedente
existe nos dois sentidos (`isco_posicao_br` já deriva da população,
`tse_validacao` já deriva das candidaturas) e sem ela nenhum número sobre a
população seria reproduzível por quem lê. Custa 28 KB, sem indivíduo e sem
identificador.

O par que ela permite calcular, e que é o eixo do artigo novo: medida sobre o
mesmo universo, a cobertura do ISEI é de **61,8% na população** de 18 anos ou
mais e de **62,0% nas candidaturas** de 2024. As duas fontes perdem quase a
mesma fração de gente por motivos que não têm nada em comum — a população porque
38,0% dos adultos não estão ocupados, o Tribunal porque um em cada cinco
candidatos marca uma rubrica que não nomeia ocupação. Uma taxa de cobertura
parecida não é sinal de que os dois lados são comparáveis.

Ao contrário das tábuas de conversão, esta tabela **envelhece**, e a ajuda diz
isso na primeira linha: é estimativa de amostra com peso, da PNAD Contínua de
2025, e não um censo.

## `isco_posicao_br` ganha o setor público e a posição militar

`pct_setor_publico` (`V4012 == 4`) é a variável que faltava para medir a maior
assimetria entre as duas fontes. Medido: o setor público é 11,7% dos ocupados
com endereço na ISCO-88, e 37,9% dele está no grande grupo 2, professores
sobretudo — a classe que carrega o argumento em quase toda análise de
recrutamento.

`pct_militar` (`V4012 == 2`) sai da mesma passada e **exige aviso**, que está na
ajuda. O dicionário do IBGE define essa posição como militar do exército, da
marinha, da aeronáutica, da polícia militar **ou** do corpo de bombeiros
militar. Medido: entre quem a declara, 39,9% cai no grande grupo 0 pelo código
de ocupação e 60,1% cai no 5. A pergunta sobre posição e a pergunta sobre
ocupação discordam sobre quem é militar no Brasil, e nenhuma das duas é o erro
da outra.

## O artigo: *Comparar duas fontes*

Oito decisões — a porta, a revisão da ISCO, o ano, a régua, o universo, o
resíduo, a agregação e a ponte —, cada uma com o mesmo bloco de quatro partes: a
decisão, o que ela permite, **quem ela exclui** (nomeado, e com o tamanho) e
como medir esse tamanho no seu dado. Fecha com o que o pacote não faz, uma folha
de decisão de uma página, e um exemplo trabalhado que roda só com dados do
pacote.

Três coisas que a página mede e que não estavam ditas em lugar nenhum:

* **A média não denuncia a fusão.** No grande grupo 1, o ISEI médio dos dois
  lados difere em só 2,8 pontos, mas 25,4% das candidaturas estão no topo da
  escala contra 6,9% da população. Mesmo rótulo, duas populações, e quem
  comparar médias não vê. A lição generaliza: compare distribuições dentro da
  categoria agregada, não centros.
* **7,5% dos códigos da ISCO-88 trocam de grande grupo ao virar ISCO-08**, e o
  maior fluxo isolado são onze códigos que sobem do grupo 3 para o 2 —
  professores de ensino fundamental e pré-escolar, sobretudo. No Brasil isso é
  grande, e não aparece em nenhuma taxa de cobertura.
* **O primeiro dígito não é uma escala.** O enfermeiro está no grande grupo 2 e
  tem ISEI-88 43; o escriturário está no grupo 4 e tem 51.

## Ajuda cruzada

`?cod_para_isco` ganha a explicação da adaptação da polícia militar, com
exemplo, e a remissão ao artigo. `?tse_para_classe` ganha a seção que diz por
que `cod_para_classe()` não existe: quatro das categorias do esquema são
rubricas do formulário do TSE, não posições da ISCO, e o esquema **não atravessa
para a população**. Quem precisa comparar composição de classe entre as duas
fontes não tem régua pronta, e agora isso está dito onde a pessoa vai olhar.

## Uma decisão registrada como decisão, e não como pendência

O plano previa uma função `checa_comparabilidade()`, que receberia dois vetores
de portas diferentes e julgaria se a comparação se sustenta. Ela **não foi
escrita**, e o motivo é bom: as quatro `checa_cobertura_*` existentes valem por
serem triviais de entender, e um juízo de comparabilidade depende de um critério
que depende da pergunta — que é justamente o que o artigo ensina o leitor a
decidir. Uma função ali viraria carimbo de aprovação sobre uma decisão que ela
não pode tomar. Fica registrado que foi avaliada e descartada.

## O repositório abriu, e o manual voltou a compilar

O terceiro preprint saiu em 09/09/2026 — *As duas faces da classe no
recrutamento político brasileiro*, `10.31235/osf.io/muxf8_v1` —, que era a
condição para o repositório deixar de ser privado. Ele foi aberto, o GitHub
Pages passou a servir <https://moraespeixoto.github.io/ocupacoesBR/>, e as três
URLs do `DESCRIPTION` que respondiam 404 ao verificador anônimo do CRAN passaram
a resolver. A NOTE que elas produziam em todo `R CMD check --as-cran` deixou de
ocorrer, sem que nada no arquivo mudasse.

A faixa de publicações da home tinha dois cartões e passa a ter três, agora com
DOI em todos. O cartão do artigo de método ainda dizia "manuscrito em
preparação" com o DOI vazio, o que estava errado desde 04/09. E o selo
"R-CMD-check passing" da home era texto fixo, que afirmava aprovação sem ler o
CI: passou a ser o selo do GitHub Actions, que diz o estado do momento. O README
ganhou o mesmo par, que não tinha nenhum.

Uma correção que só aparece no manual em PDF: três ocorrências do sinal de menos
matemático (U+2212) numa passagem de `?tse_para_isei` faziam o `pdflatex` parar
com "Unicode character not set up for use with LaTeX". Passaram a hífen ASCII. O
leitor lê a mesma coisa; o CRAN, que constrói o manual, deixa de recusar.

# ocupacoesBR 0.7.1

Uma auditoria de conteúdo do site, em quatro frentes, encontrou afirmações que
o próprio pacote já contradizia. Esta versão começa a saldá-las.

## O nível de habilidade 2 da ISCO-88 não vai ao pós-secundário

A aba de classificações definia o nível de habilidade 2 como indo "do secundário
inferior ao pós-secundário não terciário", num parágrafo sobre a ruptura de
1988. Essa é a definição da **ISCO-08**, ancorada na ISCED de 1997.

Conferido na fonte primária — ILO (1990), pp. 2-3: na ISCO-88 o segundo nível é
"ISCED categories 2 and 3, comprising the first and second stages of secondary
education". O pós-secundário não terciário (ISCED-97 nível 4) só entra com a
reancoragem de 2008. O texto passa a dar as quatro correspondências da ISCED-76,
e a dizer que a ISCO-08 reancorou na de 1997 — precisamente porque a confusão é
fácil, e o pacote está ancorado na de 1988.

## A CBO tem dois tamanhos, e o site usava os dois sem avisar

A edição de 2002 traz 2.422 ocupações em 596 famílias; o domínio vigente, do
Novo CAGED, traz **2.777 em 626** — e é contra ele que as taxas de cobertura do
pacote são calculadas. As duas cifras conviviam em páginas diferentes sem
explicação. Agora convivem com ela, e as do domínio saem de um chunk que lê o
próprio arquivo de fontes.

## A coluna `qualidade` resume duas etapas, e a segunda tem precedência

`crosswalk_tse()` marca `"ambígua"` a partir da ponte ISCO-88 → ISCO-08, e essa
marca **sobrepõe** a informação sobre o quanto a tradução TSE → ISCO-88 foi
agregada. O resultado é que códigos traduzidos exatamente, a quatro dígitos,
aparecem como `"ambígua"` — e a ambiguidade deles é da ponte, irrelevante para
quem usa o ISEI-88, que é a régua recomendada. O comportamento não muda; passa a
estar dito, com a remissão a `tse_isco$nivel` para quem quiser só a agregação.

## Outras três da mesma aba

* **"Toda medida deste pacote está publicada sobre a ISCO"** — toda medida
  **importada**. Classe, estrato e componente da classe alta ancoram no cadastro
  do TSE, e o ISEI-BR é estimado sobre a COD; a coluna `ancora` de `reguas` diz
  qual é qual.

* **"Toda função de tradução deste pacote aceita `ano`"** — só as da porta do
  TSE, porque a quebra é do cadastro eleitoral. Verificado nas assinaturas:
  dezesseis funções aceitam, nenhuma das outras portas aceita. A mesma frase
  estava em `vignette("robustez")`, e `test-guia-agente.R` passa a travar as
  duas direções.

* **O instrumento da CBO-2002.** O texto citava a "Resolução CONCLA nº 5 de
  setembro de 2002", que não consegui corroborar em fonte nenhuma. O instrumento
  documentado é a **Portaria MTE nº 397, de 9 de outubro de 2002**, que aprova a
  CBO-2002 para uso em todo o território nacional. Trocado pelo verificável.

E em `vignette("qual-regua")`, "as três não têm sequer o mesmo denominador" —
palavra sem referente — passa a dizer o que de fato difere: população e ano de
estimação.

## A variância "dentro" da ocupação é zero, não "quase nada"

`vignette("validacao")` e `?tse_dispersao_patrimonio` diziam que uma medida de
posição ocupacional "explica a variância entre ocupações e quase nada da
variância dentro de cada uma". O ISEI é **constante** dentro da ocupação: ele
explica exatamente zero, por construção, e "quase nada" sugere que se mediu algo
que não é mensurável.

O que se pode medir, e diz mais, é quanto da variância individual do log do
patrimônio fica **entre** níveis de status — o teto de qualquer função do ISEI.
A vinheta passa a calculá-lo dos somatórios de `tse_dispersao_patrimonio`:
**eta² = 0,077**, contra r² = 0,043 que a relação linear aproveita.

E o contraste 0,681 × 0,207 ganha a ressalva que faltava: os dois números
diferem em mais coisas que o nível de agregação — um é sobre a mediana e não
ponderado, o outro sobre a média do log e ponderado por candidatura. A
comparação limpa, na mesma unidade e com o mesmo peso, é a correlação
**ecológica** de **0,748** contra 0,207, agora publicada ao lado.

Três correções menores no mesmo bloco: a unidade passa a ser chamada de
candidatura, não indivíduo, nos quatro lugares que ainda usavam o nome que
`?tse_dispersao_patrimonio` declara ter abandonado; "não use ISEI como proxy de
renda individual" passa a dizer patrimônio, que é o que foi testado, com a renda
por extensão; e `sd_log ≈ 1,7` deixa de ser "uma ordem de grandeza" — `exp(1,7)`
é 5,5, um fator de cinco a seis por desvio padrão, e são dois desvios que dão
trinta vezes. As correlações de `?tse_validacao` passam a declarar que são não
ponderadas, e o 0,63 do piso a dizer que sai de `data-raw/`, sendo o único
número daquela página que o pacote não recalcula.

## Gênero: o mesmo recorte da ajuda, e o intervalo de especificações

`vignette("validacao")` comparava médias de ISEI por gênero sobre os 207 códigos
com ISEI, enquanto `?tse_para_isei` usa os 168 com `n > 500`. Os dois números
divergiam sem que a vinheta dissesse por quê (46,1 × 47,6 lá, 46,0 × 49,0 aqui).
A vinheta passa a usar o recorte da ajuda, a imprimir `n`, e a remeter à
regressão em vez de deixar uma diferença de médias sem controle carregar o
argumento.

`?tse_para_isei` passa a publicar o **intervalo de especificações** em vez do `p`
pontual. Verificados: ponderada −6,17 (ep 3,03; p = 0,043); com erro-padrão
robusto HC3, ep 4,19 e **p = 0,14**; sem ponderação, −5,34 e p = 0,012; com
`pct_mulher` contínuo, −0,09 por ponto percentual e p = 0,08. O sinal e a ordem
de grandeza sobrevivem a todas — o `p` não, e é o sinal que sustenta a
advertência.

A mesma seção passa a explicitar a premissa que "viés" carrega: o ISEI pondera
escolaridade *e* renda, e ocupações femininas rendem menos com credencial igual.
A escala registra isso fielmente. É viés se o que se quer medir é credencial, e
fidelidade se é retorno — a recomendação vale nos dois casos.

## A assimetria de ausência é de uma classe só

`vignette("qual-regua")` dizia que "cerca de 15% das mulheres declaram posição
fora da PEA, contra pouco mais de 1% dos homens". Confere — mas só para a classe
`"Fora da PEA por posição"` (códigos 581 e 931). A outra residual, `"Inativo com
trajetória"`, fica em torno de 4% nos **dois** sexos: quem somar as duas dilui
justamente o padrão que importa. A classe passa a ser nomeada.

No mesmo parágrafo, "a vantagem feminina em status é, em boa parte, artefato
disso" era uma afirmação quantitativa sem cálculo. Passa a dizer que parte pode
vir daí, que a vinheta não mede quanto, e que o ponto é a comparação não ser
entre iguais.

## "Igualando média e desvio, a correlação some" — ela não pode somer

`vignette("validacao")` justificava a leitura da relocação sobre a diferença
padronizada assim: a diferença bruta correlaciona-se a −0,85 com o ISEI-08, e
"igualando média e desvio, a correlação some". `vignette("robustez")` dizia o
mesmo em forma de teste: "se a diferença fosse substantiva, essa correlação
seria perto de zero".

Ela não some, e a hipótese está invertida. Para dois vetores padronizados com
correlação `r`, vale a identidade

```
cor(z1 - z2, z2) = -sqrt((1 - r) / 2)
```

Com `r` = 0,940, isso dá −0,173 — que é exatamente o valor observado, até a
última casa que o computador guarda. É aritmética, não medida, e é sempre
negativa: regressão à média. Com escalas idênticas e esta correlação, o residual
seria −0,17 **ainda que a diferença fosse inteiramente substantiva**. O chunk
passa a imprimir a identidade ao lado do valor observado, o que mostra o ponto
melhor do que qualquer parágrafo. (De passagem: naquela unidade a correlação
bruta é −0,84, não −0,85 — o −0,85 vem de `?isco08_isei_br`, calculado noutra.)

**A conclusão prática sobrevive inteira**, e é isso que importa: padronizar
remove o artefato de escala, que é grande, e sem padronizar a lista de quem sobe
e desce é em boa parte a lista de quem estava embaixo. O que muda é a
justificativa — e o que passa a sustentá-la é uma conferência, não uma
correlação: o resíduo de uma regressão do ISEI-BR sobre o ISEI-08 é ortogonal ao
ponto de partida **por construção**, e devolve as mesmas seis ocupações em cada
ponta (idênticas e na mesma ordem entre as que sobem; as mesmas seis, com o
clero mudando de lugar, entre as que descem). A leitura substantiva não depende
do critério, e é isso que a autoriza.

`test-isei-br.R` trava as duas coisas: a concordância entre os critérios e a
identidade, para que ninguém volte a ler o residual como "o artefato que sobrou".

## A prosa nomeava duas ocupações que a tabela não imprimia

No mesmo trecho, o texto dizia que entre as seis que mais descem estão
"veterinário e farmacêutico". Estão em **sétimo e oitavo**; a tabela imprime
músico e professor de formação profissional. Corrigido, com os dois citados na
posição que ocupam.

## A primeira página deixa de descrever uma tabela que não é a impressa

`vignette("comece-aqui")` dizia "as quatro primeiras linhas" e "as três
últimas", mas a ordem de `cods` punha o servidor público em quinto e o
comerciante — que recebe ISCO, ISEI e EGP — em sexto. A prosa descrevia uma
tabela diferente da que o chunk imprimia, na página que o leitor abre primeiro.
Os códigos foram reordenados, e o comerciante passa a ser nomeado.

Outras três correções na mesma página:

* **O EGP não se define pela supervisão.** O texto dizia que "o EGP distingue
  quem supervisiona de quem não supervisiona". O eixo primário é a **posição no
  emprego**; a supervisão é o segundo. O dicionário do TSE traz a primeira, e é
  a segunda que falta — como `vignette("qual-regua")` e `?isco88_para_egp` já
  diziam.

* **`checa_cobertura()` nunca devolve `FALSE`.** Devolve `TRUE` invisivelmente
  ou **falha com erro**. É deliberado: cobertura zero quase nunca é achado sobre
  a população e quase sempre é a coluna errada; um `FALSE` seguiria adiante no
  pipeline, o erro para.

* **A COD não está em todo Censo.** É a PNAD Contínua desde 2012 e os Censos de
  2010 e 2022. O Censo de 2000 e a PNAD anual (2002–2015) usam a
  CBO-Domiciliar, para a qual o pacote **não tem porta** — e entrar com esse
  dado pela CBO-2002 traduz códigos que não são os mesmos. A ausência passa a
  estar dita.

## A recusa da CBO-94 é convenção de interface, não impossibilidade

`isco08_para_isei_br(cbo94_para_isco08("2-11.20"))` devolve 72 numa linha: o que
o pacote retirou na 0.5.1 foi o **atalho**, não o caminho. A vinheta passa a
mostrar o encadeamento e a dizer o que ele garante — quem escreve as duas etapas
fez a escolha conscientemente.

E diz o que a razão **não** é. Não é adequação temporal em geral: o ISEI-88 foi
estimado sobre dados de 1968 a 1982 e o pacote o aplica a candidaturas de 2026
sem objeção. A âncora ISCO-88 é escolha por consistência interna da série
eleitoral, não por contemporaneidade. O critério corta num sentido só, e é
melhor dizer isso que deixar o leitor supor uma regra geral de data que o pacote
não segue.

## O que cada porta tem para o EGP, dito porta a porta

`?cbo94_para_egp` afirmava: "Ao contrário do TSE, a RAIS **tem** essas variáveis
no vínculo — vale passá-las." Não tem. A RAIS, o CAGED e o eSocial são registros
de **vínculo empregatício**: toda linha é um empregado. Não há conta própria nem
empregador como observação, e não existe campo com o número de subordinados. Por
essas portas `conta_propria` é `FALSE` por construção e o EGP sai sem IVa, IVb e
V — não por omissão de quem chama, mas porque a fonte não descreve quem está
fora do assalariamento. Ler a distribuição resultante como estrutura de classes
do país é o erro que a ajuda agora nomeia.

Na direção oposta, `?cod_para_egp` e `vignette("qual-regua")` diziam que com a
PNAD Contínua "o esquema funciona por inteiro". Ela vai mais longe que as outras
— tem posição na ocupação e número de empregados, e com isso **separa IVa de
IVb**, que é justamente o que fica indeterminado pela porta do TSE. Mas falta a
supervisão exercida sobre assalariados, que é o que define V. Nenhuma das quatro
portas do pacote a tem, como `vignette("robustez")` já dizia corretamente — as
três páginas agora concordam entre si.

## A marca que recupera a pequena burguesia é `conta_propria`, não `proprietario`

`vignette("qual-regua")` explicava que a pequena burguesia aparece "porque dez
códigos nomeiam o proprietário no próprio rótulo e o pacote usa essa marca". São
duas marcas distintas desde 07/2026, e o EGP usa a outra: `conta_propria`, que
tem **doze** códigos, contra dez de `proprietario`. A diferença é exatamente o
agricultor e o pescador, que trabalham por conta própria — o `SEMPL = 2` que o
esquema exige para chegar a IVc — sem pertencerem à classe proprietária. Os dois
números passam a sair de um chunk.

## A reedição do cadastro é de 2002; os códigos voltam depois

Três páginas diziam que o código 214 "a partir de 2002 é escultor e pintor". A
reedição do cadastro é de 2002 — fato documental —, mas nenhum dos sete códigos
reutilizados reaparece naquele ano: são 2004, 2006 e 2008. O 214 só volta, como
escultor, em **2006**, e há um intervalo em que aquele número não é declarado
por ninguém.

A distinção não é preciosismo: é `primeiro_ano_novo`, e não 2002, que o corte
usa (`ano < primeiro_ano_novo`). Uma candidatura de 2004 com o código 214 volta
`NA` — comportamento certo, que a prosa antiga não previa. Pior: a aba de
classificações imprimia a coluna `primeiro_ano_novo` logo abaixo de afirmar o
contrário. `vignette("percursos")` passa a imprimir também `tse_vigencia(214)`, e
`test-rotulos.R` trava a concordância entre as duas tabelas.

## Não há ano seguro para começar a série

`vignette("qual-regua")` recomendava "começar a série em 2004, ou declarar a
descontinuidade", sem dizer por que 2004. O dado não apoia a escolha: de 2002
para 2004 nada se extingue, mas de 2004 para 2006 três códigos somem e treze
trocam de rótulo, e dois reutilizados só reaparecem em 2006 e 2008. A
recomendação passa a ser a que se sustenta — declarar a descontinuidade e passar
o `ano`, que resolve os reutilizados código a código —, com os `tse_diff_cadastro()`
impressos para o leitor conferir.

No mesmo parágrafo, as contagens da troca de inventário (13 extintos, 122
criados) passam a sair de um chunk em vez da digitação. As duas participações
são o único par de números daquela vinheta que o pacote não recalcula sozinho —
`tse_ocupacao_rotulos` traz `n` por vigência, não por ano —, e agora dizem de
onde vêm: `data-raw/11_confere_retrospectivo.R`, que ganhou o bloco que as
calcula. Recalculadas na microbase, são 12,4% (confere) e **33,1%**; a vinheta
dizia 33,2%.

## A etapa autoral do pacote entra no site

A tradução do cadastro do TSE para a ISCO-88 é a única do pacote sem documento
externo que a confirme — a OIT publica a ponte, o MTE publica a tábua da CBO, o
IBGE publica a da COD, e esta é autoral. Era também a única que `vignette(
"percursos")` não percorria, embora `R/crosswalk.R` já registrasse, **num
comentário de código**, que "o erro de medida resultante não é ruído: é
heterocedástico e correlacionado com o estrato".

A vinheta ganha uma seção que mede isso em vez de afirmá-lo. Os 258 códigos do
TSE com ISCO chegam a 42 valores distintos de ISCO-88 e **29 de ISEI**, e a
compressão não é uniforme: o refinamento a quatro dígitos alcança 12 dos 88
códigos da classe alta e **nenhum** dos 101 das classes populares.

A consequência prática está dita com o alcance que ela tem, e não maior:
comparações dentro das classes populares apoiam-se em escores mais agregados que
as feitas dentro da classe alta, e diferenças finas no fundo da distribuição
merecem menos confiança que as mesmas diferenças no topo. Não é razão para não
usar a medida — é razão para não ler fino onde a tradução foi grossa.

## A escada da CBO: os números e a causa estavam errados

A vinheta dizia: "Quarenta códigos que a tradução direta não resolve, e a escada
resolve trinta e três. Os sete restantes continuam `NA`, porque nem o prefixo de
dois dígitos está na tábua."

São quarenta **entradas**, mas dezesseis códigos distintos; os sete `NA` são um
código só, `142399`, repetido. E a razão é outra: a família `1423` **está** na
tábua, e `cbo2002_para_isco("1423")` devolve `"2419"`. O que falta é ancestral
comum na ISCO — as ocupações de 1423 se espalham por 1233, 1234, 1239 e 2419.

Corrigir isso expôs uma consequência que não estava declarada em lugar nenhum:
**a escada e a consulta por família aplicam regras diferentes à mesma família**.
Quatro dígitos consultam a moda; seis dígitos com `escada = TRUE` exigem
ancestral comum. Em **oito** famílias as duas divergem, e a escada é a mais
conservadora. A divergência é deliberada, mas quem alterna entre as duas
entradas precisa saber que elas não respondem a mesma pergunta. Passa a estar em
`?cbo2002_para_isco`, na vinheta, e travada em `test-cbo.R` — inclusive quais
são as oito.

## A ponte diz agora qual destino escolhe

`?isco88_para_isco08` já explicava que a sintaxe do ISMF guarda as alternativas
na parte decimal e manda truncá-la; a vinheta falava em "destino escolhido" sem
dizer por quem nem como. Passa a dizer, e a tirar a consequência: como o destino
é sempre o mesmo para um dado código de origem, o desvio é **sistemático** e não
se cancela ao agregar.

## Mudança de comportamento: o ano na posição errada agora falha

`tse_para_isei(cod, ano)` aceita o ano na **segunda** posição. Em
`tse_para_classe()` a segunda é `superior`, e em `tse_para_egp()` é
`conta_propria`. Quem escrevesse `tse_para_classe(cod, ano_vec)` por analogia
não recebia erro nenhum: `as.logical(2000)` é `TRUE`, então o ano virava a marca
**ligada em toda linha**, e a coluna saía errada em silêncio. Era o único engano
de chamada do pacote que produzia número plausível sem aviso — e
`vignette("comece-aqui")` chegava a dizer que bastava trocar o nome da função
"e o comportamento é o mesmo", o que só vale com `ano` nomeado.

A correção é uma guarda de **valor**, não de posição: `superior` e
`conta_propria` passam a recusar numérico fora de `{0, 1}`, e a mensagem diz
onde o ano cabe. Reordenar os argumentos quebraria chamadas posicionais
legítimas e o contrato já documentado; o único código que passa a falhar é o que
já estava errado.

```r
tse_para_classe(c(298, 298), c(2000, 2020))
#> Erro: `superior` deve ser lógico (ou 0/1); recebeu 2000, 2020.
#>   Isso parece ser o ano. Ele existe, mas em outra posição: passe-o
#>   nomeado, `ano = `.
```

A sugestão do ano só aparece quando os valores têm cara de ano; fora disso a
recusa é a mesma, sem palpite. `0`, `1`, lógico e `NA` seguem valendo, e
`superior = NA` continua sem virar "médio ou menos".

A guarda roda **antes** do aviso de EGP incompleto. Avisar primeiro e falhar
depois deixava no console um aviso descrevendo um cálculo que nunca aconteceu.

## Os números da ajuda passam a ser conferidos contra as tabelas

A regra do projeto — nenhum valor entra em `.Rd`, NEWS ou vinheta sem ter saído
de execução própria — cobre o momento em que o número é escrito. Não cobre o
depois: um valor correto no dia em que foi digitado continua na página de ajuda
quando a tabela de onde ele veio muda.

Foi assim que `?tse_codigos_autorrotulo` seguiu afirmando que a dispersão de
patrimônio é "de 80 vezes (p90/p10) entre os que declaram empresário, mas de 47
entre os advogados e 54 entre os comerciantes". São os valores da agregação que
somava cada bem duas vezes, corrigida em 09/2026. Os certos são **76, 48 e 55**,
e `?tse_para_componente_alta` já os lia da tabela desde aquela correção — este
parágrafo é que tinha ficado para trás.

Corrigido, o argumento fica mais forte do que era: o comerciante (55) é
autorrótulo e cai **entre** o advogado ancorado (48) e o empresário (76). A
dispersão bruta realmente não separa os dois grupos, que é o que o parágrafo
sempre quis dizer.

`tests/testthat/test-numeros-doc.R` é a trava geral. Ele não guarda os valores:
recomputa das tabelas e confere contra o texto da ajuda, de modo que o que
reprova é a **divergência** entre os dois. Cobre por ora a dispersão por
autorrótulo, os quantis do 257, a regressão de gênero de `?tse_para_isei` (n,
coeficiente e as duas médias) e a parcela mediada de `?isco08_isei_br`. Um dos
blocos trava também a ordem advogado < comerciante < empresário, porque é dela
que o parágrafo depende: se ela inverter, o texto passa a afirmar o contrário do
que o dado mostra, sem que número nenhum fique errado.

## O Brasil estava no ISEI-88, e a justificativa do ISEI-BR dizia que não

A documentação afirmava, em quatro lugares, que Ganzeboom, De Graaf e Treiman
(1992) escalonaram a ISCO sobre "dezesseis países, nenhum deles o Brasil" — e
que o ISEI-BR respondia a como o Brasil ordena as ocupações "em vez da média de
dezesseis países ricos". As duas metades são falsas, e o artigo original
desmente as duas.

O Apêndice A de Ganzeboom, De Graaf e Treiman (1992), sob o título *31 Data
Sets Used to Construct the ISEI Scale*, lista **a PNAD de 1973 (BRA73, 6.697
casos) e a de 1982 (BRA82, 8.742)**. São 15.439 dos 73.901 homens da amostra de
estimação: **20,9%, a segunda maior contribuição nacional, atrás só da
norte-americana**. E os dezesseis países não são ricos — o artigo descreve a
amostra como indo "de países severamente subdesenvolvidos (Índia) ao mais
desenvolvido (Estados Unidos), e de regimes socialistas do Leste Europeu
(Hungria) a estados sul-americanos autocráticos (Brasil)".

A justificativa do ISEI-BR não desaba com a correção; ela fica verificável, que
é o que não era. O Brasil entrou no ISEI-88 com dado de 1973 e 1982, comprimido
junto com outros quinze países num **único** escalonamento. O que não existia é
um ângulo estimado só aqui, e com dado deste século. É isso que a régua nova
faz, e é isso que a documentação passa a dizer — em `?isco08_isei_br`,
`?tse_para_isei_br`, `reguas$pergunta` e no cabeçalho de
`data-raw/09_gera_isei_br.R`.

O erro não era de cálculo, e por isso nenhum teste o pegaria: era um fato
bibliográfico, a única classe de afirmação do pacote que nada confere.

## A enfermagem não foi promovida pela ISCO-08

Quatro páginas do site — `qual-regua`, `validacao`, a aba de classificações e
`?tse_para_isei08` — explicavam o salto de 26 pontos do enfermeiro dizendo que
"a ISCO-08 promoveu a enfermagem a profissão de nível superior (`2221`),
separando-a dos técnicos (`3221`)". O mecanismo é falso, e o pacote já sabia
disso em dois lugares: `R/tse.R` e o `NEWS.md` da 0.6.0 dizem, corretamente, que
a ISCO-88 põe a enfermagem em `2230` **apesar de** ser profissão universitária.

A ISCO-88 já a situava no grande grupo 2, e já a separava da enfermagem técnica
(`3231`). O que ela fazia era pontuá-la em 43, abaixo dos escriturários (45). O
que muda de uma âncora para a outra é a **escala**: o ISEI-08, reestimado por
Ganzeboom sobre o ISSP de 2002-2007 e cobrindo os dois sexos, a põe em 68,7. A
recomendação de ancorar na ISCO-08 para análise de gênero continua valendo — o
que muda é a razão dela, que é de escore e não de alocação.

Dois efeitos colaterais da versão antiga também saem. O primeiro é que `2221` é
**médico** na ISCO-88 e enfermeiro na ISCO-08: o texto citava um código de quatro
dígitos sem dizer de qual classificação, num pacote cuja tese é que código não
sobrevive à troca de versão. Os códigos passam a vir com a âncora nomeada. O
segundo é que o destino que o pacote de fato atribui ao 113 é o agregado `2220`,
não `2221`.

A aba de classificações precisava de um exemplo de promoção 3 → 2 na fronteira
entre profissionais e técnicos, e a enfermagem não serve. Passa a usar os dois
casos reais, que são os mesmos do artigo de método: a fisioterapia (`3226` →
`2264`) e a nutrição (`3223` → `2265`).

`tests/testthat/test-isco08-tse.R` ganhou dois blocos que travam os fatos que
desmentem a versão antiga, para que ela não volte por cópia.

## Valle Silva é da tradição de Duncan, e Ganzeboom o usou para aferir o ISEI

A aba de antecedentes dizia que *Posição social das ocupações* (IBGE, 1974) era
"trabalho contemporâneo da própria tradição de Duncan, e não derivado dela".
Não é o que o próprio texto de 1974 diz: Duncan (1961) é a referência nº 14 da
bibliografia, o procedimento do SEI é descrito em detalhe, e a escala brasileira
é aferida contra as de Blishen e Bogue.

A recíproca é o achado que valia a checagem: quando Ganzeboom, De Graaf e
Treiman construíram o ISEI, foi **a escala de Valle Silva** que serviu de termo
de comparação brasileiro, e ela está na bibliografia deles. A linhagem brasileira
não foi paralela à internacional — foi o parâmetro contra o qual a internacional
se mediu aqui. A aba passa a dizer isso.

## Autorias que estavam fundidas numa só

`vignette("antecedentes")` atribuía a Ganzeboom, De Graaf e Treiman a tradução
da ISCO em ISEI, prestígio e EGP. São três autorias distintas: o ISEI é deles
(1992), o prestígio é de Treiman (1977), o esquema de classes é de Erikson,
Goldthorpe e Portocarero (1979). O que Ganzeboom e Treiman (1996) fizeram foi
**mapear** as três sobre a ISCO-88. Pela mesma razão, Harry Ganzeboom passa a
ser "um dos três autores do procedimento de 1992", e o cartão do EGP na home
deixa de dizer "sintaxes originais" — as sintaxes são a operacionalização do
ISMF, não o texto de Erikson e Goldthorpe, que codificaram sobre classificações
nacionais.

## Correções menores na home

O cartão do ISEI dizia "10 – 90"; o intervalo do ISEI-88 é **16 a 90**, e sai de
`reguas`, não da digitação. O cartão do EGP dizia que o TSE não pergunta a
posição na ocupação — o pacote a preenche pelo dicionário; o que falta, e gera o
aviso, é o número de subordinados. E a chamada de `qual-regua` não conta mais os
erros ("os sete"), porque a vinheta tem nove seções e o número envelhece calado.

# ocupacoesBR 0.7.0

O pacote fica legível por quem lê máquina, e a regra que ele mais repete vira
tabela.

## `reguas`: a escolha da régua deixa de morar só na prosa

O risco central deste pacote nunca foi errar uma tradução. É trocar uma régua
por outra sem perceber — a troca custa uma letra no nome da função, não produz
erro nenhum, e a vinheta `qual-regua` abre dizendo exatamente isso. O aviso
existia, mas em prosa, que é o último formato que um leitor apressado consulta.

Agora existe `reguas`: nove linhas, uma por medida, com a pergunta que cada uma
responde, o que ela mede, de onde vem e **quando não usá-la**. É filtrável:

```r
reguas[reguas$tipo == "continua", c("medida", "ancora", "funcao_tse")]
reguas$quando_nao_usar[reguas$medida == "EGP"]
```

Duas decisões merecem registro. A primeira é que a tabela é **dado, não
função**: é onde a documentação do pacote já manda procurar, e onde `tse_isco`
e `tse_quebra_2002` já guardam julgamento autoral. A segunda é que ela é a
única tabela do pacote que não deriva de fonte externa, e por isso fica fora da
auditoria de proveniência. O que a mantém honesta é outra coisa —
`tests/testthat/test-reguas.R` amarra as funções citadas aos exports reais nas
duas direções, de modo que uma porta nova sem linha na tabela reprova o teste.
Os intervalos das réguas contínuas também não são digitados: saem de
`isco88_medidas` e irmãs no momento da geração.

A seção 1 da vinheta `qual-regua` passou a **consumir** a tabela em vez de
repeti-la. Uma fonte só.

## Um guia de uma página para quem lê por máquina

`inst/llm/GUIA_AGENTE.md` concentra o que precisa ser sabido **antes da
primeira chamada**: a gramática `<origem>_para_<destino>` que 47 dos 61 exports
seguem, o contrato de chamada, e as três maneiras de obter um resultado errado
e silencioso — régua trocada, série longa sem `ano`, `NA` tratado como zero
quando a ausência é generificada.

```r
system.file("llm", "GUIA_AGENTE.md", package = "ocupacoesBR")
```

Ele remete a `reguas` em vez de repetir a tabela, e não é uma quarta cópia da
prosa: `tests/testthat/test-guia-agente.R` confere que toda função citada
existe, que as contagens batem com o NAMESPACE, e que o contraexemplo do guia
(`cbo94_para_isei_br()`, a porta que deliberadamente não existe) continua não
existindo.

## O site parou de sabotar quem copia, e quem lê por máquina

Duas correções na home, com a mesma origem: SVG e `<code>` escritos à mão
atravessam mal o pandoc.

A linha de instalação estava marcada como `<code>` com `<span>` de cor dentro.
O pandoc lê o texto entre tags inline como markdown, e a extensão `smart`
transformava as aspas retas de `install_github("...")` em aspas curvas — quem
copiava do site recebia código que não roda. Agora é um bloco de código de
verdade, realçado pelo próprio pandoc, com as cores devolvidas por CSS.

Os cinco ícones da home eram `<svg>` inline. O pandoc os converte em URI
`data:` base64, o que enchia de lixo os espelhos `.md` que o pkgdown gera e o
`docs/llms.txt` — o arquivo que modelos de linguagem leem. Os ícones viraram
máscaras em CSS: o desenho é o mesmo, e o markup não os contém mais.

# ocupacoesBR 0.6.0

Preparação para o CRAN, e uma aba nova no site.

## O `DIGCLASS` sai de `Suggests` — e o teste fica

O `DIGCLASS` (Cimentada) é a única implementação independente contra a qual o
EGP deste pacote é conferido. Ele não é dependência: é GPL-3, e embarcar
tabela dele tornaria este pacote copyleft.

Simulando a máquina do CRAN — biblioteca sem o pacote e
`_R_CHECK_FORCE_SUGGESTS_` no padrão — o que aparece não é a NOTE que o
`cran-comments.md` vinha explicando:

```
* checking package dependencies ... ERROR
Package suggested but not available: 'DIGCLASS'
```

Verificado com rede: o `DIGCLASS` não está em repositório algum — nem CRAN, nem
Bioconductor, nem r-universe (o universo `cimentadaj` existe e serve só o
`perccalc`). Logo `Additional_repositories:` também não resolve, porque o campo
exige um repositório no formato do CRAN.

A saída preserva as duas coisas: o teste foi para
`tests/testthat/test-digclass.R`, que está em `.Rbuildignore`. Ele continua no
repositório, roda no `devtools::test()` e apareceria num CI; o pacote
distribuído não menciona o `DIGCLASS` em lugar nenhum. Com isso o check volta a
`0 ERROR, 0 WARNING, 1 NOTE`, e a NOTE que sobra é "New submission" mais as
URLs do repositório privado.

## A referência dessa conferência estava solta

O `DIGCLASS` instala-se do HEAD do GitHub. A referência da única validação
externa do pacote era, portanto, um ponteiro móvel: se o autor corrigisse uma
célula, o teste passaria a falhar sem que se soubesse o que ele afirmava quando
a validação foi feita. É o mesmo defeito que as chaves `sha256` do registro de
proveniência existem para impedir nas fontes.

`inst/extdata/PROVENIENCIA.yml` ganhou a seção `conferencia_cruzada`, com a
versão (0.0.3), o commit e a data. `00_confere_proveniencia.R` avisa quando o
instalado diverge do registrado, e um teste falha se a seção sumir.

## As classificações, uma a uma

Aba nova no site, entre *Percursos* e *Antecedentes*. Cada uma das quatro
classificações por onde o dado entra — a ISCO, a CBO, a COD do IBGE e o cadastro
do TSE — com a mesma estrutura: de onde veio, para que foi feita, e o que ela
não pode responder.

A tese da página é que saber a história de uma classificação não é erudição:
**é o que permite prever onde ela vai falhar.** Cada uma carrega no desenho a
pergunta que a originou. A ISCO-88 não dá nível de habilidade aos grandes grupos
0 e 1, e por isso o primeiro dígito não é escala. A CBO ancora em 1988 e a COD
em 2008, e por isso não são duas versões da mesma árvore. O cadastro do TSE não
é classificação estatística: é lista de preenchimento de formulário, e daí vêm
as suas quatro propriedades incômodas, da escala à reutilização de códigos.

Fecha com um quadro comparativo cuja última linha é a razão de o pacote existir:
para a CBO e para a COD há tábua oficial para a ISCO; para o cadastro do TSE não
há.

Os números computáveis saem de *chunks*; as datas e os números de resolução são
digitados e vêm das fontes registradas. Onde os dois poderiam se contradizer — o
tamanho da CBO contra o que o pacote cobre dela — a distinção está dita no
próprio código.

## Antecedentes: uma aba sobre de onde o pacote vem

O site ganhou uma página teórica, entre *Percursos* e *Robustez*. Ela declara a
linhagem em que o pacote se inscreve — Valle Silva, Hasenbalg, Costa Ribeiro,
Carvalhaes — e faz a subtração honesta: o que aqui é reimplementação de coisa
alheia e o que é contribuição.

Três antecedentes que o pacote precisava nomear e não nomeava:

- **Jaime e Ganzeboom (2025)** reestimaram o índice socioeconômico para a
  Argentina pelo mesmo procedimento de 1992 — e encontraram o índice
  internacional superando o local, o oposto do que a validação daqui mostra
  contra patrimônio. A divergência entra declarada, com a separação entre o que
  nela é substantivo e o que é de desenho.
- **Codato, Costa e Massimo (2014)** já haviam classificado a ocupação prévia à
  entrada na política, por critério analítico e não sociográfico. Os dois
  caminhos respondem a perguntas diferentes.
- **Connelly, Gayle e Lambert (2016)** recomendam não desenvolver medida própria
  sem justificativa forte. O pacote faz as duas coisas de que a recomendação
  desconfia, e a página enuncia a justificativa em vez de ignorá-la.

Também se registra o que não existe: nenhum dos pacotes de R que traduzem ISCO
em ISEI, prestígio ou EGP cobre a CBO brasileira, e nenhum leva o cadastro do
TSE a classificação alguma.

## Provas de robustez, com gráficos

Aba nova no site, entre *Percursos* e *Artigos*: nove provas explicadas uma a
uma — o que poderia dar errado, como se testa, o que o gráfico mostra e o que
significaria se falhasse. Ida e volta entre as duas ISCO, ambiguidade
preservada, conferência cruzada, critério externo, estatísticas suficientes,
artefato de escala, quebra de 2002, EGP degradado e `sha256` das fontes.

Nenhum número está digitado: todos saem de *chunks* executados sobre os dados
instalados com o pacote. Três das provas existem porque o erro correspondente
foi cometido e publicado aqui, e a página diz isso.

Escrever a página corrigiu duas afirmações que estavam erradas na documentação
anterior. No EGP degradado são **duas** degradações, e não uma: IVb e IVc
separam o TSE da COD, e a diferença é a marca de posição no emprego; IVa e V
saem vazias nos **dois**, porque separá-las exige o número de subordinados, que
nenhuma porta do pacote tem. E na quebra de 2002, cinco dos sete códigos
reutilizados saltam na escolaridade — o `215` e o `521` quase não se movem, e
no caso da governanta quem separa as duas ocupações é a composição por sexo.

## `Description` com o DOI do método

O `DESCRIPTION` passa a trazer Ganzeboom, De Graaf e Treiman (1992) com
`<doi:10.1016/0049-089X(92)90017-B>`, no formato que o CRAN pede para
referência de método. O DOI foi conferido no Crossref.

# ocupacoesBR 0.5.2

Auditoria geral, feita por três auditores independentes — engenharia de pacotes
R e site, dados eleitorais do TSE, estratificação e medida. O pedido nasceu de
uma insegurança: a 0.5.0 quebrou o pacote e teve de ser corrigida às pressas no
mesmo dia, e não estava claro o que ainda restava errado.

A infraestrutura passou. `R CMD check` limpo, os testes passando, o site
sincronizado, a proveniência conferindo por sha256, e o ISEI-BR reproduzindo
dígito a dígito a partir da PNAD. **O que não passou foi a documentação de
números**: valores que ficaram para trás quando a fonte mudou, e uma
divergência real entre duas funções exportadas.

Nenhuma dessas correções muda uma conclusão do pacote. Quase todas mudam
números que ele publica.

## A correção do patrimônio dobrado estava incompleta

A 0.4.0 trocou a microbase porque a anterior somava cada bem duas vezes. A
tabela de patrimônio do código 257 em `?tse_para_componente_alta` não foi
revisitada, e continuou publicando o dobro por mais duas versões. Vereador
R$ 370.000 onde são R$ 185.000; prefeito R$ 1.628.485 onde são R$ 812.544;
senador R$ 9.345.553 onde são R$ 4.678.498.

O argumento não muda — o fator de 25 entre vereador e senador é o mesmo, e a
razão entre os extremos continua na casa das dezenas. Mudam os reais.

A causa é a mesma que o NEWS 0.3.1 já tinha diagnosticado: "o número era
extraído, o verbo era digitado". Por isso a correção não é digitar os valores
certos. **`tse_autorrotulo_patrimonio` é novo** e publica os quantis de
patrimônio por código e cargo para os dez códigos de `tse_codigos_autorrotulo`,
mais o 131 (ADVOGADO) como contraexemplo ancorado. A documentação e a vinheta
`qual-regua` agora leem a tabela. Uma próxima troca de fonte se propaga
sozinha.

De quebra, a tabela mostra o contraste melhor do que a prosa mostrava: na linha
agregada, o ADVOGADO tem a menor razão entre p90 e p10 de todos os códigos
(47,8), e os autodeclarados vão de 55,1 a 75,6.

## `crosswalk_tse()` e `tse_para_egp()` discordavam

A tabela usava a marca `proprietario` onde a função usa `conta_propria`. As
duas são distintas desde 07/2026, e o crosswalk ficou de fora daquela decisão:
o agricultor (601) e o pescador (604) saíam em VIIb ali e em IVc aqui.

Como `?crosswalk_tse` manda publicar essa tabela como material suplementar de
artigo, o suplemento contradizia o código que produziu as estimativas — e
justamente na distinção que Carvalhaes (2015) aponta como o teste do EGP no
Brasil. Um teste novo trava as duas saídas juntas, porque nenhum `R CMD check`
pega divergência entre duas funções que rodam sem erro.

A mesma afirmação errada estava em `?tse_para_egp`, que dizia ser
`proprietario` o `SEMPL = 2` do ISMF. É `conta_propria`.

## `?tse_para_isei08` publicava a regressão de duas versões atrás

Os coeficientes `1,212` e `-9,80` são anteriores a `.corrige_isco08_tse()`, que
entrou na 0.2.1. Os atuais são `1,266` e `-12,72`, com r = 0,97.

## A comparação entre o ISEI-BR e o ISEI-08 estava contaminada pela escala

A 0.5.0 lia a diferença bruta `isei_br - isei08` como relocação substantiva:
sobem os manuais, descem os credenciados. As duas escalas não têm a mesma
dispersão — o ISEI-BR sai de um min--max e tem desvio padrão 14,3 contra 21,1
—, e numa escala mais estreita o topo cai e a base sobe por aritmética. A
diferença bruta correlaciona-se a **-0,847** com o próprio ISEI-08.

Padronizando antes de subtrair, a correlação cai para -0,17. Sobrevive a alta
da segurança pública e a queda das artísticas, do clero e das liberais da
saúde. **Não sobrevive** a outra metade: igualadas as escalas, entram entre as
maiores altas o diretor de empresas, o médico e o professor de ensino superior.

A escala não foi alterada. A recomendação inicial era reescalar para 16--90,
mas a conta mostra que isso *piora* a compressão — a faixa fica mais estreita,
não mais larga. O que muda é a leitura: `vignette("validacao")` passou a
padronizar antes de comparar, e `?isco08_isei_br` ganhou a ressalva de que a
diagonal de 45 graus marca igualdade de escore e não de posição. Para quem usa
o ISEI-BR sozinho, que é o uso previsto, nada disso importa: a escala é
monotônica.

## `tse_validacao` não respeitava a vigência dos códigos reutilizados

Sete códigos foram reaproveitados para ocupação diferente depois de 2002. O
conjunto os agregava sobre a série inteira, misturando duas populações: o 214
saía com 30,6% de ensino superior porque metade da massa era DELEGADO DE
POLÍCIA, quando ESCULTOR E PINTOR tem 2,3%; o 521 saía com 42,3% de mulheres
onde a GOVERNANTA tem 97,2%.

O pacote manda o usuário passar `ano =` justamente para impedir isso, e não
passava em casa. Agora cada um desses códigos entra a partir do seu
`primeiro_ano_novo`. Um deles deixou de alcançar o piso de 200 candidaturas
dentro da própria vigência: são **220 linhas**, e não 221.

As correlações agregadas não se movem de forma perceptível (escolaridade
r = 0,765; patrimônio r = 0,681). A regressão de gênero de `?tse_para_isei`
passa de 170 para 168 códigos, e o coeficiente de -6,14 para -6,17.

## `tse_quebra_2002$n_ate_2000` contava só uma eleição

A coluna diz "candidaturas com esse código até 2000", que é a soma de 1998 e
2000, e trazia apenas 2000. O total dos reutilizados sobe de 1.628 para 1.755.
O objeto chegava a se contradizer: documentava 52.090 para o 601 e carregava
51.953 na coluna.

## Números que a troca de microbase deixou para trás

`?isei_retrospectivo` afirmava 680.317 pares consecutivos (são 684.179), 52,1%
de mudança de código (52,2%) e 45,3% de mudança de escore (45,2%); a cobertura
feminina vai a 58,8%. `?tse_quebra_2002` descontava uma tendência de +7,8 pp
que hoje é +7,6.

Também esses estavam só digitados. **`data-raw/11_confere_retrospectivo.R`** é
novo, não grava nada e imprime todos eles, medindo a defasagem e a cobertura
com a própria `isei_retrospectivo()` em vez de reimplementá-la.

## O EGP dos crosswalks sai degradado, e agora está dito

`crosswalk_cod()`, `crosswalk_cbo2002()` e `crosswalk_cbo94()` calculam o EGP
sem posição no emprego nem supervisão, porque não há nenhuma das duas num
código de COD ou de CBO. IVa, IVb e V saem estruturalmente vazias — a pequena
burguesia contada como classe de serviço, que é inversão de classe e não
arredondamento. Nenhum dos quatro `.Rd` dizia isso. Os quatro passam a dizer, e
`?crosswalk_cod` aponta `isco_posicao_br` como prior empírico disponível.

## A única validação externa apontava para um alvo móvel

O `DIGCLASS` (Cimentada) é a única implementação independente contra a qual
`R/egp.R` é conferido: os dois são portes das mesmas sintaxes do ISMF, feitos
separadamente, e o teste compara as oito células da grade posição no emprego x
supervisão. Todos os outros testes conferem o pacote contra si mesmo ou contra
a fonte que ele próprio leu.

Só que o `DIGCLASS` não vem de repositório versionado — instala-se do HEAD do
GitHub. A referência da conferência era, portanto, um ponteiro móvel: se o
autor corrigisse uma célula, o teste passaria a falhar sem que se soubesse o
que ele afirmava quando a validação foi feita. É exatamente o defeito que as
chaves `sha256` do registro de proveniência existem para impedir nas fontes, e
que a auditoria acabara de fechar nos números digitados.

`inst/extdata/PROVENIENCIA.yml` ganhou a seção `conferencia_cruzada`, com a
versão (0.0.3), o commit e a data. `00_confere_proveniencia.R` avisa quando o
instalado diverge do registrado, e um teste novo falha se a seção sumir ou se a
versão mudar sem que o registro acompanhe. Congelar a tabela do `DIGCLASS` como
*fixture*, que seria o modo óbvio de fixar a referência, está fechado por
licença: ele é GPL-3, e embarcá-lo tornaria este pacote copyleft.

## Correções menores

- `cbo2002_para_egp()` ganha `empate` e `escada`, que existiam em todas as
  outras portas da CBO-2002 e que o bloco de documentação já anunciava. A porta
  ficava presa em `empate = "na"`.
- `?tse_isco` dizia que `classe` tem dez categorias. Tem doze, como
  `?tse_para_classe` já dizia.
- A tabela de colapsos do EGP em `?tse_para_classe` pulava de 11 para 5 classes,
  omitindo o **7** — que é o colapso mais usado para publicar, e onde a
  distinção entre IVc e VIIb **sobrevive**. A frase "nos colapsos canônicos o
  agricultor e o assalariado rural voltam a ser a mesma coisa" era falsa ali.
- O rótulo da classe V perdia metade do nome: são os *lower-grade technicians
  and supervisors of manual workers*, e os técnicos tinham sumido do português.
- `?tse_dispersao_patrimonio` chamava a unidade de "nível do indivíduo". São
  candidaturas: 1.103.019 delas, de 767.015 pessoas distintas.
- `?isco_posicao_br` não avisava que a sua chave atravessa a ponte reversa
  ISCO-08 -> ISCO-88, que volta ao ponto de partida em 69% dos casos.
- `cbo2002_para_isei_br()` não trazia a ressalva das duas pontes empilhadas que
  as irmãs `cbo2002_para_isei08()` e `cbo2002_para_prestigio08()` já traziam.
- `?checa_periodo` afirmava que o pacote não distribui os rótulos do TSE. Ele
  distribui, em `tse_ocupacao_rotulos`.
- O `DESCRIPTION` não mencionava o ISEI-BR, que é a régua que o pacote estima e
  a única que exige citação própria.
- `LICENSE.md` apontava para `LICENSE.note`, que não é publicado como página —
  era o único link interno quebrado do site.
- `ocupacoesBR-package` entra no índice de referência do pkgdown, de onde
  faltava.
- Um teste novo trava as duas pontes ISCO recíprocas, que são geradas por
  scripts separados e poderiam divergir se um fosse regerado sem o outro.

# ocupacoesBR 0.5.1

Fecha as pontas soltas da 0.5.0, no mesmo dia. Nenhum escore mudou: os 590
valores de `isco08_isei_br` saem idênticos aos da 0.5.0.

## `cbo94_para_isei_br()` foi retirada

Ela não deveria ter sido criada. O pacote recusa, e documenta que recusa,
pendurar medidas ancoradas na ISCO-08 em microdado da CBO-94, e a função
atravessava exatamente essa fronteira. O argumento decisivo não é a coerência
com o texto, é a data: a CBO-94 é microdado anterior a 2003, e o ISEI-BR é uma
régua de 2025 que a própria documentação declara ser de um ano só e não formar
série. Oferecê-la a dado dos anos 1990 contradiz o que ela afirma sobre si.

De passagem, a razão que o pacote alegava para a recusa estava imprecisa desde
antes. Ele dizia que a assimetria era da tábua de conversão, mas a tradução até
a ISCO-08 existe e é exportada em `cbo94_para_isco08()`. O que se recusa é
pendurar escore naquele caminho, e isso é decisão do pacote. `?cbo94_isco88` e
`vignette("comece-aqui")` passam a dizer isso.

## Os números da sensibilidade agora se refazem

A 0.5.0 afirmava, no NEWS e em `?isco08_isei_br`, que sete especificações
alternativas foram testadas e nenhuma move o ordenamento abaixo de 0,99. Era
verdade, mas o script que produzia esses números não estava no repositório, o
que é exatamente o que a proveniência deste pacote existe para impedir.
`data-raw/09b_sensibilidade_isei_br.R` os reproduz e imprime a tabela inteira.

## O tamanho da amostra viaja com a tabela

`isco08_isei_br` ganha os atributos `n_obs` e `n_pessoas`, com a amostra de
estimação. Eles não se recuperavam das colunas, porque `n_obs` por linha conta
a subárvore daquela célula e não a amostra que estimou o ângulo, e por isso
existiam só digitados na documentação.

## Citar o ISEI-BR

O pacote dizia, em quatro lugares, ser o veículo e não a fonte das réguas. Para
o ISEI-BR isso deixou de valer, porque a estimação é dele. `inst/CITATION`,
a home, o README e `vignette("publicacoes")` passam a registrar a exceção e as
três citações que ela pede: o pacote pela estimação, Ganzeboom, De Graaf e
Treiman (1992) pelo método, e o IBGE pela PNAD Contínua de 2025.

## Os dois diagramas

O mapa de rede ganha o nó do ISEI-BR, ligado só à ISCO-08, e a legenda passa a
distinguir medida importada de medida estimada pelo pacote. O fluxograma das
quatro portas ganha o mesmo nó e acrescenta `cbo94_para_isei_br` à lista do que
deliberadamente não existe.

# ocupacoesBR 0.5.0

## A régua deixa de ser importada

A vinheta de validação terminava dizendo que o pacote mostrava que a medida
**ordena** bem as ocupações, mas não que os escores estão **calibrados** para o
Brasil, e que calibrá-los seria a melhoria de maior valor que ainda faltava.
Esta versão a faz.

`isco08_isei_br` traz o procedimento de Ganzeboom, De Graaf e Treiman (1992)
refeito do zero sobre a PNAD Contínua de 2025: 655.787 observações de 339.181
pessoas, dos quatro trimestres. Não é tradução de escala nem recalibragem do
ISEI-08. É o mesmo método, estimado aqui.

**O que a régua brasileira diz de diferente.** Contra o ISEI-08 importado, nas
348 células apuradas em quatro dígitos, o Spearman é 0,894 e o desvio absoluto
médio é 9,7 pontos numa escala de 10 a 90. Concorda o bastante para ser
reconhecível e discorda o bastante para valer a pena.

Onde discorda, é preciso cuidado com a leitura, e a versão 0.5.2 corrigiu a que
estava aqui. As duas escalas **não têm a mesma dispersão** — o ISEI-BR sai de um
min--max sobre as células de estimação e tem desvio padrão 14,3 contra 21,1 do
ISEI-08 —, e por isso a diferença bruta entre as duas correlaciona-se a −0,847
com o próprio ISEI-08: quem estava no topo cai e quem estava embaixo sobe, por
aritmética antes de qualquer sociologia. Igualando média e desvio, essa
correlação cai para −0,17 e o desvio absoluto médio, de 9,7 para 8,1.

O que sobrevive à correção: sobem a segurança pública (policial civil e
militar, bombeiro) e descem as profissões artísticas, o clero e as liberais da
saúde (escultor, sacerdote, cantor, veterinário, farmacêutico) — credencial
alta e remuneração modesta. O que **não** sobrevive é a outra metade da frase:
igualadas as escalas, não são as ocupações manuais que sobem. Entram entre as
maiores altas o diretor de empresas, o médico e o professor de ensino superior.

**A mediação não é completa, e isso é achado.** O procedimento de 1992 supõe
que a ocupação carrega todo o efeito da escolaridade sobre a renda e escolhe o
ângulo onde o efeito direto zera. No Brasil ele não zera: para em 0,206 contra
um efeito total de 0,494, de modo que a ocupação medeia **58,4%**. Os outros
41,6% são escolaridade que paga dentro da mesma ocupação. Adotou-se o ângulo de
mínimo e publicou-se o resíduo, nos atributos da tabela.

A decisão é segura porque o ordenamento não depende do ângulo. O Spearman entre
a escala no ângulo adotado e em mais ou menos 0,15 radianos é 0,999. Sete
especificações alternativas foram testadas — 40 horas, sem restrição de horas,
renda-hora, rendimento efetivo, só homens como em 1992, escolaridade em
categorias, idade a partir de 25 — e nenhuma move o ordenamento abaixo de 0,99
nem a parcela mediada para fora do intervalo de 57,9% a 60,1%. Quem produz
esses três números é `data-raw/09b_sensibilidade_isei_br.R`, e é dele que eles
saem cada vez que forem reafirmados.

**Contra o critério externo, ela vai melhor.** Nas 165 ocupações do TSE com as
três réguas e os dois critérios, a correlação com o log do patrimônio declarado
sobe de 0,676 (ISEI-08) para 0,716, e o Spearman de 0,708 para 0,768. Com a
escolaridade dos candidatos ela vai um pouco pior, 0,736 contra 0,783, o que é
esperado: o ângulo dá mais peso à renda. O patrimônio é o único dos dois que não
entra na construção de régua nenhuma.

## Nomes novos

* `isco08_isei_br`, a tabela, com 590 linhas e os atributos `theta`,
  `beta_direto`, `beta_total` e `parcela_mediada`.
* `tse_para_isei_br()`, `cod_para_isei_br()`, `cbo2002_para_isei_br()` e
  `isco08_para_isei_br()`. São funções irmãs, e não um argumento nas
  existentes, porque é a convenção do pacote e porque uma escala estimada no
  Brasil não deve viajar debaixo do nome "08". Não há porta pela CBO-94, pela
  razão que `?cbo94_isco88` explica.
* `crosswalk_tse()` e `crosswalk_cod()` ganharam a coluna `isei_br`.

## Por que 590 linhas, e não 434

A ocupação declarada ao TSE é grossa, e a porta do TSE aterrissa em códigos
ISCO-08 agregados de dois e três dígitos. Uma tabela só com células de quatro
dígitos devolveria `NA` para a maioria dos candidatos. A tabela cobre então as
mesmas 590 chaves de `isco08_medidas`, e cada agregado é apurado juntando os
**indivíduos** da sua subárvore, não a média das médias. Dos 407 códigos de
quatro dígitos, 348 têm escore próprio e 59 herdam do grupo acima por terem
menos de 30 pessoas na amostra. A coluna `nivel` diz quais.

## O que não mudou

`isco08_medidas` está intacta, e continua sendo a âncora internacional. Nenhuma
assinatura existente mudou. Os 1.524 testes anteriores seguem passando sem
alteração.

## Infraestrutura

* `data-raw/extrai_tri.py` passa a extrair também `VD3005` (anos de estudo),
  `V4039` e `VD4031` (horas) e `VD4017` (rendimento efetivo). As 24 colunas
  antigas saem byte a byte idênticas, e `isco_posicao_br` regenera igual.
* `inst/extdata/PROVENIENCIA.yml` ganha a seção `microdados_externos`, com os
  sha256 dos quatro zips da PNAD e do dicionário de largura fixa. Ela usa
  chaves próprias para não colidir com `00_confere_proveniencia.R`, que
  continua conferindo as mesmas 20 fontes de sempre.

# ocupacoesBR 0.4.1

## O patrimônio estava dobrado, e agora não está

Todo valor de patrimônio que este pacote publicou até a 0.4.0 estava **duas
vezes maior que o declarado**. A causa não é do pacote: a microbase de
validação vinha de uma agregação de bens que somava cada bem duas vezes.

**A prova.** Extraído o CSV bruto do TSE de 2024 (`bem_candidato_2024_AC.csv`)
e somados os bens candidato a candidato, das 1.206 candidaturas com bens a
fonte antiga bate em **2** e a fonte nova bate em **1.206**. Sobre o conjunto
das 296.096 candidaturas de 2024, a razão entre as duas é **exatamente 2,0 em
100% dos casos**. A fonte passa a ser a microbase construída a partir de
`novissimos_dados_tse`, cuja chave tripla de bens já está corrigida.

**O que muda:** todo valor absoluto em reais. A mediana do agricultor (601) vai
de R$ 244.790 para **R$ 122.395**; o máximo das classes populares, de
R$ 253.602 para **R$ 126.801**. Os `.Rd` afetados foram corrigidos.

**O que NÃO muda, e é a maior parte do que o pacote afirma.** Dobrar tudo é
mudança de escala, e `log(2x)` difere de `log(x)` por uma constante. Logo:

* a correlação entre ISEI e log do patrimônio no nível da ocupação segue
  **0,681**, e o Spearman segue 0,695;
* a correlação no nível do indivíduo segue **0,207** (era 0,208 antes de a
  base ganhar 12.798 candidaturas nas safras fechadas, não por causa da
  correção de escala);
* `sd_log` em `tse_dispersao_patrimonio` segue **1,70** — desvio padrão é
  invariante a deslocamento;
* a conclusão sobre o agricultor sobrevive inteira: as duas medianas dobravam
  juntas, de modo que ele continua **dentro** da faixa das classes populares,
  com um só código do estrato acima dele.

Muda também `media_log` em `tse_dispersao_patrimonio`, deslocada por
`log(2) = 0,693` em cada nível — o que não afeta o coeficiente que a tabela
existe para reproduzir, porque um deslocamento constante não move a
correlação.

## A microbase mudou de fonte, e ganhou linhas

`data-raw/05a_microbase_2026.R` passa a ler a microbase de
`classe_recrutamento_politico` em vez da antiga de `vices_do_brasil`. Além da
correção dos bens, a base nova vem do repositório canônico de dados do TSE e
traz **12.798 candidaturas a mais** nas safras de 1998 a 2024. Três colunas
saíram do contrato (`eleito_v1`, `eleito_1t`, `prest_contas`), nenhuma
consumida pela validação.

# ocupacoesBR 0.4.0

## O número que faltava reproduzir agora reproduz: `tse_dispersao_patrimonio`

O artigo de método afirma que a correlação entre status e patrimônio cai de
**0,681** no nível da ocupação para **0,208** no nível do indivíduo, e que essa
queda é o resultado, não um defeito: uma escala de posição ocupacional explica
a variação *entre* ocupações e quase nada *dentro* de cada uma. O segundo
número era o único do texto que o leitor não podia recalcular — dependia da
microbase de patrimônio, que não acompanha o pacote e não vai acompanhar.

A saída não foi publicar microdado. A correlação de Pearson é função apenas de
somatórios, e o ISEI é constante dentro de cada nível: basta publicar, por
nível de status, o `n` e as somas dos logaritmos do patrimônio e dos seus
quadrados. É o que a nova tabela traz — 29 linhas, 1,5 KB, nada identificável —
e dela o coeficiente sai **exato**, não aproximado. `data-raw/08_gera_dispersao.R`
trava essa identidade contra o microdado (`abs(r_micro - r_agreg) < 1e-12`), e
`test-fonte.R` a trava contra o dado publicado.

A coluna `sd_log` mostra o mesmo fato de perto, e é a razão para a tabela ir
além dos somatórios: dentro de um mesmo nível de status, o desvio padrão do log
do patrimônio é da ordem de 1,7 — uma potência de dez. Daí a advertência de
`?tse_para_isei`, que agora aponta para cá: não use o ISEI como proxy de renda
ou patrimônio individual.

A vinheta `validacao` e `?tse_para_isei` passam a extrair o valor da tabela em
vez de citá-lo (a ajuda dizia 0,207; o valor é 0,208).

## No artigo, fora do repositório

A validação convergente ganha a análise de sensibilidade que faltava: o
coeficiente com cada critério externo sob quatro especificações — todas as
ocupações, sem os códigos de autorrótulo, ponderada por candidaturas e na
âncora ISCO-08 — com intervalo de 95% por bootstrap. Retirar os códigos de
autorrótulo **eleva** a correlação com o patrimônio (0,681 para 0,703), que é o
sinal esperado. O artigo passa a declarar também o que o piso de duzentas
candidaturas deixa de fora (50 ocupações, de ISEI médio 53,8 contra 47,4 das
incluídas) e o viés de subdeclaração do patrimônio, que é correlacionado com o
componente proprietário da classe alta. E ganha a primeira figura.

# ocupacoesBR 0.3.1

## A safra de 2026 é atualizada para a geração de 01/09/2026

A eleição de 2026 continua aberta e o TSE republica o arquivo de candidaturas
duas vezes ao dia. Esta versão troca a geração fixada de **17/08/2026, 08:30**
(20.506 candidaturas) pela de **01/09/2026, 12:31** (20.829 candidaturas) —
323 candidaturas a mais, todas com o mesmo tratamento de safra aberta:
`eleito` e votos seguem `NA`, e o patrimônio segue fora da validação por falta
do IPCA de outubro de 2026.

**O achado central não muda.** Dos 210 códigos observados na nova geração (211
na anterior), nenhum é inédito: seguem todos dentro dos 275 que o dicionário já
cobria. `tse_isco` não mudou; nenhuma ponte mudou; nenhum ISEI, prestígio, EGP,
classe ou estrato se deslocou de nenhum código. `tse_diff_cadastro(2024, 2026)`
segue sem código criado (0), e os "extintos" seguem sendo artefato de safra
pequena — 46 contra 2024, 48 contra 2022 (era 47).

O total de candidaturas do pacote sobe de 3.368.921 para **3.369.244**. O
artigo de método (`paper/artigo.qmd`, fora do repositório) foi atualizado para
a nova geração e para as novas contagens.

## Três correções apontadas por revisão externa

* **O patrimônio do agricultor estava descrito com o verbo errado.**
  `?tse_para_classe` (e o artigo) diziam que a mediana do código 601 "fica
  acima do máximo das classes populares por menos de três mil reais". O número
  era de uma safra anterior; recomputado sobre `tse_validacao`, a mediana do
  601 é R$ 244.790 e o máximo das populares (excluído o próprio 601) é
  R$ 253.602 — o agricultor está **dentro** da faixa, com só um código do
  estrato acima dele. A conclusão (topo da classe popular, não fora dela) não
  muda; a frase, sim. É exatamente o modo de erro que a regra "número por
  execução" existe para impedir: o número era extraído, o verbo era digitado.
  O mesmo vale para a correlação ISEI--patrimônio, que os `.Rd` citavam como
  0,682 e é 0,681 na safra atual; a vinheta `validacao` passa a extraí-la.

* **`crosswalk_cbo2002()` devolvia o que `cbo2002_para_isco()` recusa.** Para
  família de quatro dígitos sem ISCO majoritário, a porta devolve `NA` por
  padrão (`empate = "na"`), mas a tabela auditável entregava em silêncio o
  vencedor do desempate lexicográfico — o viés que o próprio pacote documenta
  em `?cbo2002_para_isco`. A função ganha o argumento `empate` (mesmo padrão da
  porta) e a coluna `empate`, que marca a família empatada em qualquer modo.
  Teste novo em `test-cbo.R`.

* **O artigo carimbava a versão errada do pacote.** O Apêndice A imprimia
  `0.3.0` num texto que descrevia a geração da 0.3.1, porque o `.qmd` lê o
  pacote instalado e o cache do Quarto reaproveitava a render antiga. O chunk
  `setup` do artigo passa a exigir `packageVersion("ocupacoesBR") >= "0.3.1"`,
  e ganha travas para os números que a prosa escreve por extenso (os "dezesseis
  mais um" códigos sem ISCO e os 0,68/0,76 do resumo, que o YAML não executa).

Duas frágeis a menos: `data-raw/07_gera_posicao.R` lia a PNAD de um caminho
fixo de outra máquina, e passa a usar `OCUPACOESBR_PNAD` com fallback em
`~/dados_pnad`, como os scripts 05/05a; e `test-rotulos.R` trava que nenhum
rótulo normalizado aponte para dois códigos, condição de que
`tse_rotulo_para_cod(exato = TRUE)` depende sem dizer. O DESCRIPTION distingue
agora as pontes geradas por script do dicionário TSE→ISCO-88, que é autoral.

# ocupacoesBR 0.3.0

## A safra de 2026 entra, e o dicionário não precisou de uma linha

Esta versão estende o pacote das 14 eleições de 1998 a 2024 para as **15 de
1998 a 2026**. O resultado central é negativo, e é o mais informativo que
poderia sair: **o cadastro de ocupações do TSE não criou nenhum código em
2026**. Os 211 códigos observados na safra são subconjunto dos 275 que o
dicionário já cobria, com a mesma grafia acentuada que vigora desde 2018.
`tse_isco` não mudou; nenhuma ponte mudou; nenhum ISEI, prestígio, EGP,
classe ou estrato se deslocou de nenhum código.

Isso importa para quem usa o pacote **na eleição em curso**: a tradução de
2026 não é extrapolação. `checa_cobertura()` sobre a safra inteira passa, e
um teste novo (`test-rotulos.R`) trava a afirmação — se uma safra futura
trouxer código inédito, a suíte quebra em vez de o pacote devolver `NA`
silencioso.

### A safra é aberta, e o pacote diz isso

O prazo de registro encerrou em 15/08/2026, mas o Tribunal ainda julga e
publica candidaturas. Os dados desta versão são a geração do TSE de
**17/08/2026, 08:30** — 20.506 candidaturas, cerca de dois terços do volume
de 2022 nos cargos proporcionais, com `DS_SITUACAO_CANDIDATURA` igual a
`#NE` em toda linha e sem apuração. Nada do que o pacote extrai depende de
apuração: o rótulo de um código é propriedade do cadastro, não da
candidatura. Mas o `n` de 2026 há de crescer, e a documentação dos dados
registra a geração exata para que ninguém confunda duas safras de 2026 — o
TSE gera o arquivo duas vezes por dia.

**Uma armadilha nova, documentada em `?tse_diff_cadastro`.**
`tse_diff_cadastro(2024, 2026)` devolve 46 códigos como "extintos". Nenhum
foi extinto. A vigência se constrói do rótulo observado, e um código raro sem
candidato numa safra pequena registra ausência, não revogação — 2026 é
pequena duas vezes, por ser geral e por estar aberta. Trocar o par não
resolve: contra 2022, que também é geral, são 47. A metade que se sustenta é
a outra, "nenhum código criado", porque um código novo apareceria ainda que
uma vez só.

## A fonte dos rótulos mudou de arquivo, e o N muda por duas razões

`data-raw/04_gera_rotulos.R` lia um `.Rda` agregado de 397 MB e passa a ler
as safras individuais (`bancos/candidaturas/candidaturas_AAAA.rds` do projeto
`novissimos_dados_tse`), quatro colunas de cada. A troca não é de estilo. O
agregado se reconstrói de tempos em tempos e pode estar defasado sem que nada
no arquivo o denuncie: em 17/08/2026 ele trazia 15.866 candidaturas de 2026
contra as 20.506 da safra. Ler as safras é ler a fonte, custa megabytes em vez
de gigabytes, e acrescentar uma eleição passa a ser acrescentar um arquivo.
`OCUPACOESBR_TSE_RDA` continua honrado, para quem só tenha o agregado.

Por isso o total de candidaturas sai de **3.334.269 para 3.368.921**, e a
diferença tem **duas** causas que não convém somar às cegas:

* **+20.506** são a safra de 2026;
* **+14.146** são a reconstrução da base 1998–2024 feita a montante, no
  `novissimos_dados_tse`, que corrigiu a totalização e a deduplicação. Ela
  não é uniforme: soma 15.679 em 2000 e subtrai 1.485 em 2006. O sentinela
  `-4` ("NÃO DIVULGÁVEL", já mapeado para "Não informado") passa de 140 para
  1.698 registros, concentrados em 2012.

Números derivados que se moveram com a base nova, todos recomputados:

| valor | 0.2.1 | 0.3.0 |
|---|---|---|
| candidaturas com rótulo | 3.334.269 | 3.368.921 |
| eleições | 14 | 15 |
| códigos extintos após 2000 | 13 (12,2%) | 13 (12,4%) |
| códigos criados em 2002+ | 122 (33,1%) | 122 (33,2%) |
| `tse_diff_cadastro(2000, 2002)`, criados | 67 | 69 |
| candidaturas do 601 em 1998–2000 | 50.139 | 52.090 |
| reutilizados, candidaturas em 2000 | 1.582 | 1.628 |

Os 69 criados entre 2000 e 2002 substituem 67 porque a base recuperou uma
candidatura de 2002 nos códigos 150 (CHAVEIRO) e 241 (TAPECEIRO), cuja
vigência começava em 2004 e passa a começar em 2002.

### O que ficou idêntico, e é o que mais importa

`tse_ocupacao_rotulos` continua com **334 vigências para os mesmos 275
códigos**, e `tse_quebra_2002` com **44 códigos na mesma partição — 15
redefinidos, 18 refinados, 4 renomeados, 7 reutilizados**. A curadoria
editorial do campo `tipo`, que é a única decisão de medida desta tabela, não
se mexeu sob uma base maior e uma safra a mais. A suíte passa em 1310
expectativas, sem nenhuma alteração de valor esperado além do teto de ano.

## `tse_validacao` vai a 2026, sem o patrimônio de 2026

A tabela do critério externo passa a somar **3.347.794 candidaturas** nas
mesmas 221 ocupações. A safra entra em `n`, `pct_superior` e `pct_mulher`, e
**se abstém de `n_com_bens` e de toda mediana de patrimônio**.

A abstenção é de unidade, não de qualidade do dado. O patrimônio da tabela
está deflacionado a reais de **outubro de 2024**, pelo número-índice do IPCA
do mês da eleição, e outubro de 2026 não aconteceu. Deflacionar por outro mês
poria na coluna um valor que a definição da coluna desmente. A assimetria não
é nova: `n` sempre cobriu período mais largo do que `n_com_bens`, porque não
há declaração de bens antes de 2006, e as candidaturas de 1998 a 2004 já
entravam nessa condição. Quando o índice de outubro de 2026 existir, a coluna
sai de graça.

O desenho é **verificável, e foi verificado**. Rodando `05_gera_validacao.R`
sobre as duas microbases, a safra de 2026 move exatamente o que devia mover e
nada além:

| efeito | `sum(n)` | `sum(n_com_bens)` | `pct_superior` | mediana |
|---|---|---|---|---|
| religação de bens (a montante) | +0 | +67.117 | 0 códigos | 137 códigos |
| safra de 2026 | +20.447 | **+0** | 108 códigos (máx. 1,5 pp) | **0 códigos** |

A religação de bens é a segunda correção vinda de fora: a chave de junção da
declaração de bens passou a ser tripla (`ano`, `sg_ue`, `SQ_CANDIDATO`), o que
recuperou 67.117 declarações que os zeros à esquerda da unidade eleitoral
faziam perder. Ela desloca 137 medianas — entre elas a do código 257, de
R$ 495.400 para R$ 497.797 — e a dispersão do 257 passa de 81 para 80 vezes
(p90/p10). Nenhuma dessas mudanças altera a leitura substantiva registrada em
`?tse_codigos_autorrotulo`: o 257 continua sendo a mistura de duas populações
sob um rótulo só.

As correlações que a vinheta `validacao` reporta:

| | 0.2.1 | 0.3.0 |
|---|---|---|
| ISEI × % superior | r = 0,764 (rho 0,811), n = 208 | **r = 0,765 (rho 0,812), n = 208** |
| ISEI × log mediana de patrimônio | r = 0,682 (rho 0,695), n = 164 | **r = 0,681 (rho 0,695), n = 165** |
| nível do indivíduo | r = 0,207 | **r = 0,208** |

A microbase que sustenta a tabela é produzida por um script novo,
`data-raw/05a_microbase_2026.R`, que **anexa** 2026 às linhas de 1998 a 2024
sem recalcular nenhuma delas. A escolha é o que torna a decomposição acima
possível: se as linhas antigas fossem refeitas junto, toda diferença teria
duas causas e nenhuma separável.

## Correção de um número que estava errado desde antes desta versão

`tse_codigos_autorrotulo` estava documentado como **12,2% das candidaturas**
(em `?tse_para_isei`, `?tse_codigos_autorrotulo` e na vinheta `qual-regua`).
O valor correto é **13,3%**, e o erro não vem da base nova: sobre a base
antiga o valor já era 13,29%, e sobre a microbase do `vices_do_brasil`,
13,30%. Nenhum denominador plausível produz 12,2% — entre as candidaturas com
escore ISEI o percentual é 20,7%.

A origem do engano é visível: 12,2% é o percentual dos **códigos extintos**
sobre as candidaturas de 1998–2000, que aparece a duas seções de distância e
foi copiado para a documentação do autorrótulo, que mede outra coisa. Os dois
valores agora divergem também na aparência (13,3% e 12,4%), o que reduz a
chance de a confusão se repetir.

Nenhum resultado publicado muda por isso: o vetor
`tse_codigos_autorrotulo` sempre teve os mesmos dez códigos, e a análise de
sensibilidade que ele serve nunca dependeu do percentual. O que muda é a
frase que o descreve.

## Auditoria de cobertura de testes, e os defeitos que ela encontrou

A suíte cobria 85,2% das linhas de `R/`. A auditoria começou por uma pergunta
simples — toda função exportada é chamada ao menos uma vez? — e a resposta era
não: **doze das 57 não eram**, entre elas as oito de `R/prestigio.R`, arquivo
que a suíte não executava em nenhuma linha. A cobertura agora é **97,5%**, com
as 57 exportações exercitadas e a suíte em **1.447 expectativas** (eram 1.310).

Escrever esses testes revelou três defeitos reais, e é por isso que eles valem
mais do que o número de cobertura.

### `tse_para_prestigio08()` não aceitava `ano`

A versão 0.2.0 acrescentou o argumento `ano` às portas ancoradas na ISCO-08 e
nomeou três: `tse_para_isco08()`, `tse_para_isei08()` e `tse_para_siops08()`.
Esta ficou de fora. O efeito é perverso porque `*_prestigio()` é o nome
**preferido** e `*_siops()` o alias depreciado: durante duas versões o nome que
a documentação recomenda não mascarava vigência, enquanto o desaconselhado
mascarava. Quem montasse série pela porta certa recebia, sem aviso, o escore do
cadastro errado nos códigos reutilizados em 2002 — exatamente o erro que o
argumento existe para impedir.

Corrigido. Um teste novo compara as assinaturas dos seis pares
`prestigio`/`siops` e falha se voltarem a divergir.

### A família da CBO-2002 perdia `empate` e `escada` no meio do caminho

`cbo2002_para_isco()`, `cbo2002_para_isei08()`, `cbo2002_para_prestigio()`,
`cbo2002_para_prestigio08()` e `cbo2002_para_siops08()` aceitavam os dois
argumentos; `cbo2002_para_isei()` e `cbo2002_para_siops()` não. Quem ligasse a
escada para obter o código ISCO e a perdesse ao pedir o ISEI terminava com duas
colunas calculadas sobre universos diferentes, sem sinal de erro. As duas
funções agora têm a assinatura das demais, com os mesmos padrões.

### `tse_rotulo_para_cod()` devolvia `NULL` em vez de tabela vazia

Com `exato = FALSE` e nada a procurar — vetor vazio, ou todo `NA` —,
`do.call(rbind, ...)` devolvia `NULL`, de modo que o tipo do retorno dependia do
conteúdo do argumento: `data.frame` quase sempre, `NULL` nesses dois casos.
`nrow()` respondia `NULL` em vez de `0` e o acesso a coluna errava. Agora sai
sempre um `data.frame`, com zero linhas quando não há o que procurar. O ramo
`exato = TRUE` nunca teve o problema.

## O pacote ganha um site

A documentação passa a ter uma porta de entrada fora do R. O site é construído
com pkgdown a partir do próprio repositório e será servido pelo GitHub Pages em
`https://moraespeixoto.github.io/ocupacoesBR/` assim que o repositório for
aberto. Ele reúne o que já existia — o README, as duas vinhetas, o changelog, a
citação — e acrescenta quatro coisas novas.

**A referência deixou de ser alfabética.** As 57 funções estão agrupadas por
porta de entrada e por finalidade: a porta do TSE, o cadastro do TSE ao longo do
tempo, a porta da CBO, a porta do IBGE, as medidas a partir da ISCO, a
verificação de cobertura, o carregamento retrospectivo, as tabelas, e por último
os alias depreciados `*_siops*`, com a explicação de por que foram renomeados.
Ordem alfabética é útil para quem já sabe o nome da função; para quem não sabe,
esconde o pacote.

**Quatro artigos novos, só do site.** "Comece aqui" percorre o caminho inteiro
numa sessão e é construído em torno de uma tabela de oito ocupações reais e
frequentes, que mostra onde o ISEI se abstém e o esquema de classes ainda
responde. "Os percursos" mostra cada caminho de tradução e o ponto exato em que
ele para: a ambiguidade da ponte ISCO-08, o `empate` e a `escada` da CBO, a
quebra de 2002, a categoria residual. "A safra de 2026, na régua" reúne o que o
pacote já sabe da eleição em curso e o que não pode saber ainda. "Como citar"
explica por que são duas referências e não uma.

Os artigos vivem em `vignettes/articles/`, que fica fora do tarball: o site
cresce sem que o pacote engorde.

**Quatro fluxogramas.** Escritos em mermaid e pré-renderizados para SVG por
`data-raw/fig_diagramas.R`, de modo que funcionam offline e não dependem de
script carregado de CDN. Reusam a paleta de `data-raw/fig_rede_crosswalks.R`,
para o site não falar dois idiomas visuais. O diagrama da CBO foi redesenhado
depois de conferido contra `cbo2002_para_isco()`: a primeira versão punha a
`escada` antes do `empate`, e a ordem real é a inversa — o `empate` decide a
entrada de quatro dígitos, e a `escada` só age depois, sobre o que sobrou `NA`.

**Exemplos nas 14 tabelas de dados.** Era o único ponto em que a referência
estava incompleta: as 57 funções já tinham exemplo, os dados não tinham nenhum.
Cada tabela ganhou um `@examples` que a mostra e a põe em uso — em
`tse_quebra_2002`, os códigos reutilizados, com o 214 que era delegado de
polícia e passou a ser escultor e pintor.

### Duas armadilhas encontradas no caminho

O pkgdown transforma em página **todo** arquivo `.md` da raiz do repositório e
de `.github/`, sem opção de exclusão. Aqui isso significava publicar o
ferramental de assistentes de IA e os registros datados de auditoria, todos
gitignorados. Apagar as páginas depois do build não resolve: o índice de busca e
o sitemap guardam o *texto* desses arquivos. Por isso o build passa por
`data-raw/constroi_site.R`, que os esconde antes e os devolve depois, com lista
branca — arquivo de trabalho novo na raiz não vaza para o site por esquecimento.

O SVG do mermaid sai de dentro de um HTML, e o parser de HTML rebaixa todo nome
de atributo para minúsculas e não fecha o `<br>`. Num arquivo `.svg` servido
como XML isso quebra o desenho: `viewbox` não é `viewBox`. O extrator restaura
os nomes, fecha as tags e acrescenta `xml:space="preserve"`, sem o qual o SVG
descarta o espaço inicial de cada `tspan` e "o código declarado" é desenhado
como "ocodigodeclarado".

### O que isso mexeu no resto

- `DESCRIPTION` ganha a URL do site no campo `URL`. A NOTE de URL inválida do
  `R CMD check` passa de duas para três entradas, todas pelo mesmo motivo — o
  repositório fechado — e todas resolvem no mesmo momento.
- Dois workflows do GitHub Actions, escritos à mão e ainda não ativados: um
  reconstrói o site, outro roda `R CMD check` em três sistemas. O `.gitignore`
  ganhou a exceção `!.github/workflows/`, mantendo ignorado o resto do
  `.github/`.
- `R CMD check --as-cran`: 0 ERROR, 0 WARNING, as mesmas 2 NOTEs. Suíte em 1470
  testes, sem falha. O tarball continua com os mesmos seis arquivos de topo.

## A porta da CBO-2002 derrubava a chamada quando o código vinha como número

Passar à CBO-2002 um vetor **numérico** com dois ou mais códigos distintos de 3
ou 5 dígitos matava a chamada com `the condition has length > 1`. Não é caso de
laboratório: é o que sai de `read.csv()` sobre a RAIS, onde a coluna de CBO vira
`integer` e qualquer código malformado fica curto.

A causa está numa linha de `.norm_cbo2002()`: o `width` do `formatC()` vinha de
um `ifelse()`, e `formatC()` não vetoriza `width`. Com **um** código curto o
vetor tinha comprimento 1 e a chamada passava — o que escondeu o defeito desde
que a perna CBO existe. Os dois comprimentos agora vão em chamadas separadas,
cada uma com o seu `width` escalar.

As dez portas da CBO-2002 caíam juntas, porque todas passam pelo mesmo
normalizador: as sete `cbo2002_para_*`, `cbo2002_concordancia()`,
`crosswalk_cbo2002()` e `checa_cobertura_cbo2002()`. Um código malformado no
meio do vetor derrubava também a tradução dos vizinhos, que estavam corretos.
Agora ele volta `NA` com aviso, e o resto do vetor é traduzido.

A CBO-94 e a COD nunca tiveram o problema: usam `width` escalar.

### E uma assimetria que a correção revelou

**Nenhum código da CBO-2002 começa com zero** — 0 de 1.387 ocupações, 0 de 436
famílias, 0 de 558 prefixos da escada. Na CBO-94 são 231 de 1.387. Ou seja: a
recuperação de zero à esquerda só faz trabalho de verdade na CBO-94; na
CBO-2002 ela transformava um código curto num código igualmente inexistente,
com a diferença de que o aviso passava a ser "sem correspondência" em vez de
"deve ter 4 ou 6 dígitos". Um teste novo trava as três contagens: se uma tábua
futura trouxer código iniciado em zero na CBO-2002, a suíte quebra e a
assimetria é reexaminada em vez de suposta.


## O uso normal ficou explícito logo no começo

A home do site e o artigo "Comece aqui" passam a abrir com a linha que responde
à pergunta que todo mundo faz primeiro:

```r
dados <- dados |> mutate(isei = tse_para_isei(CD_OCUPACAO, ano = ANO_ELEICAO))
```

A coluna inteira entra, a coluna traduzida sai, alinhada linha a linha, e o
banco não muda de tamanho. Estava implícito em toda a documentação e explícito
em lugar nenhum: os exemplos anteriores usavam vetores curtos como
`c("111", "169", "257")`, que cabem na tela mas sugerem tradução código a
código. A versão em R base (`dados$isei <- ...`) vem logo abaixo, e a junção
com `crosswalk_tse()` fica ao lado, para quem quer as dezesseis colunas de uma
vez.

O exemplo é executado, não digitado, e a moldura inclui de propósito uma linha
de 1998 com o código 214. Com isso as duas formas aparecem lado a lado sobre a
mesma linha: o `mutate()` com `ano` devolve `NA` e avisa, e a junção — que usa o
cadastro corrente — devolve escultor e pintor com ISEI 54, em silêncio. A
ressalva sobre `ano` deixa de ser uma advertência abstrata e passa a ser algo
que o leitor vê acontecer.

`DESCRIPTION` ganha `Config/Needs/website: dplyr`. O `dplyr` não entra em
`Imports` nem em `Suggests`, e o pacote continua com `stats` e `utils` como
únicas dependências: ele é preciso apenas para gerar o README e o site.


## Também nesta versão

* **`DESCRIPTION` declara `Language: pt-BR`**, como a política do CRAN pede
  para pacote que não é em inglês. Além de correto, resolve de vez a NOTE
  "The Title field should be in title case", que era o verificador aplicando a
  convenção do inglês a uma frase portuguesa. `R CMD check --as-cran` agora
  reporta apenas "New submission", o `Suggests` de `DIGCLASS` e as URLs 404 do
  repositório privado.
* **`citation("ocupacoesBR")` deixa de informar a versão errada.** O campo
  `note` do `inst/CITATION` dizia `"R package version 0.1.0"` digitado à mão, e
  continuou dizendo isso por três versões. Agora vem de `meta$Version`, e
  acompanha o `DESCRIPTION` sozinho.
* `?isei_retrospectivo` explicita que a cobertura por gênero (68,5% → 76,0%
  entre homens, 52,9% → 58,7% entre mulheres) segue medida sobre 1998–2024, e
  por quê: ela exige o painel por pessoa, que 2026 ainda não tem montado. É
  o único número do pacote que não acompanha a safra nova, e agora diz isso.
* O ferramental de assistentes de IA (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`
  e afins) sai do repositório e do tarball, via `.gitignore` e `.Rbuildignore`.
* Removidos da árvore de trabalho os resíduos de build que não são fonte:
  `..Rcheck/` (de um `R CMD check .` que falhou em 28/07/2026, porque
  `Author`/`Maintainer` só existem no tarball), `ocupacoesBR.Rcheck/`, `doc/`,
  `Meta/` e `figure/`. Todos regeneráveis, nenhum versionado.

# ocupacoesBR 0.2.1

## Correção da régua ISCO-08: 21 códigos do TSE mudam de destino

Esta versão corrige o passo **TSE → ISCO-08** em 21 dos 275 códigos do
dicionário, o que equivale a **103.365 candidaturas — 3,10% do total e 4,84%
das que têm escore**. A média ponderada do ISEI-08 passa de **49,88 para
50,43** (+0,545). O efeito substantivo é distribucional, não médio: 1,29% das
candidaturas saem do primeiro decil da distribuição para perto da mediana, de
modo que cortes por quantil e dicotomias "classe alta / popular" construídas a
partir do ISEI-08 precisam ser recalculados, não só as médias.

Origem: auditoria da régua conduzida em 2026-08 contra a tabela oficial de
correspondência da OIT (ISCO-88 → ISCO-08) e contra as sintaxes do ISMF
distribuídas em `inst/extdata/fontes/ganzeboom/`.

### O que **não** mudou, e por quê

* **A ponte `isco88_isco08` está intacta.** `isco88_para_isco08("1311")`
  continua devolvendo `6130`, `"7400"` continua devolvendo `7540`. A ponte
  reproduz a correspondência oficial da OIT, que aboliu o grande grupo 13 da
  ISCO-88 e devolveu o proprietário-dirigente à ocupação exercida; quem entra
  pela ISCO-88 tem de receber isso. Nenhum valor de `data/isco88_isco08.rda`,
  `data/isco08_medidas.rda` ou `data/isco88_medidas.rda` foi alterado.
* **A régua TSE → ISCO-88 está intacta.** `tse_para_isco()`, `tse_para_isei()`,
  `tse_para_siops()`, `tse_para_egp()`, `tse_para_classe()` e
  `tse_para_estrato()` devolvem exatamente o que devolviam em 0.2.0. Nenhum
  resultado publicado em ISEI-88 se desloca.
* **Os 17 códigos sem escore continuam `NA`**, inclusive o 295 (membro das
  forças armadas). Ganzeboom pontua ISCO-08 `0000` (ISEI-08 51,25) mas deixa o
  ISCO-88 `0110` sem ISEI-88: preencher só a régua nova criaria uma linha que
  existe numa régua e não existe na outra, quebrando a comparabilidade entre a
  medida primária e a de robustez. Fica `NA` nas duas, por decisão.

### Como a correção foi implementada

`tse_para_isco08()` deixa de ser a mera composição
`isco88_para_isco08(tse_para_isco(cod))`. O código do TSE carrega duas
informações que a ponte genérica não pode ver, e as duas são usadas agora:

1. **A marca de proprietário** (`tse_isco$proprietario`), que é o `SEMPL = 2`
   do ISMF;
2. **O rótulo em português**, mais fino do que o código ISCO-88 **agregado** a
   que o dicionário associa aquele código.

A regra mora numa única função interna, `.corrige_isco08_tse()` (em
`R/isco08.R`), chamada tanto por `tse_para_isco08()` quanto por
`crosswalk_tse()` — não há duas cópias que possam divergir, e
`test-isco08-tse.R` trava a igualdade entre as duas saídas. Como
`tse_para_siops08()` e `tse_para_prestigio08()` passam por
`tse_para_isco08()`, o SIOPS-08 desses 21 códigos também se corrige.

### 1. Promoção do proprietário rural (`iskopromo.sps`)

Os três códigos abaixo recebiam, na mesma linha do `crosswalk_tse()`, EGP
`IVc: proprietário rural`, estrato "Classe alta", componente "Alta
proprietária" **e** o ISEI-08 de trabalhador agrícola. Eram as **únicas três
linhas da tabela inteira** em que "Classe alta" convivia com ISEI-08 abaixo de
40 — o teste de consistência interna que a auditoria propôs isola exatamente
estas três, e agora ele está na suíte.

| Cód. | Rótulo | ISCO-08 antes | ISEI-08 antes | ISCO-08 agora | ISEI-08 agora | % cand. |
|---|---|---|---|---|---|---|
| 234 | PRODUTOR AGROPECUÁRIO | 6130 | 17,79 | **1311** | **49,48** | 0,572 |
| 602 | PECUARISTA | 6130 | 17,79 | **1311** | **49,48** | 0,509 |
| 901 | PROPRIETÁRIO DE ESTABELECIMENTO AGRÍCOLA, DA PECUÁRIA E FLORESTAL | 6130 | 17,79 | **1311** | **49,48** | 0,212 |

**Fonte.** `iskopromo.sps` (Ganzeboom, ISMF), primeira regra do módulo, cuja
finalidade declarada é "*make sure that managers and owners with certain
employment statuses go into the right place*":

```
do repeat iii=@isko / sss=@sempl.
do if (sss eq 2).          /* proprietário / conta própria com empregados */
. recode iii (6130=1311).
end if.
end repeat.
```

O pacote já aplicava esta linha desde 0.1.0, mas **só no caminho do EGP**
(`R/egp.R`), o que é a razão de a contradição ser interna: o EGP sabia que
aquela pessoa era proprietária e o ISEI-08 não. ISCO-08 `1311` é
*Agricultural and forestry production managers*; ISEI-08 = 49,48, lido de
`isqoisei08.sps` linha 28 (`recode @isqo (1311=49.48)`).

A correção também remenda uma série que o TSE construiu homogênea e a tradução
partia ao meio: os irmãos diretos de 901 — 902 (comercial), 903 (industrial),
904 (serviços), 905 (microempresa) — recebem todos ISEI-08 51,01, com o mesmo
estrato e o mesmo componente de classe. Só o agrícola desabava para 17,79.

**Recomendação da auditoria que foi REJEITADA.** A auditoria propunha obter o
mesmo resultado recodificando a origem, TSE → ISCO-88 de `1311` para `1221`
(*department managers in agriculture*). Não foi feito: a codificação em `1311`
é deliberada (o comentário do autor em
`inst/extdata/fontes/R/classe_ocupacao.R` registra "PRODUTOR AGROPECUÁRIO:
61=23 → 1311=43 (proprietário rural)"), e a rota `1221` mudaria **também a
régua antiga**, levando o ISEI-88 de 43 para 67 e deslocando resultados já
publicados em ISEI-88. A promoção via `iskopromo.sps` chega ao mesmo ISCO-08
sem tocar em nada da ISCO-88 — e tem precedente dentro do próprio pacote.

*Efeito colateral que convém declarar:* para estes três códigos a ida e a volta
deixam de fechar. `isco08_para_isco88("1311")` devolve `1221`, porque a ponte
de volta (`isco0888.sps`) também é a da OIT. A assimetria é inerente a
`iskopromo.sps`, cuja recodificação depende do status de emprego, que a volta
não conhece.

### 2. Destinos ISCO-08 refinados pelo rótulo do TSE

Onze códigos do TSE cujo ISCO-88 é o **agregado 7400** (*other craft and
related trades workers*) caíam em ISCO-08 **7540**, que é o grupo-menor
**residual** da submajor 75 ("*other craft*": mergulhadores, dinamitadores,
classificadores de produtos). O ISEI-08 de 7540 (43,19) destoa em ~19 pontos de
toda a sua própria família (7500 = 23,97; 7510 = 23,46; 7520 = 23,65;
7530 = 22,03). A prova de que é transposição de dígito, e não escolha, está no
próprio `isco8808.sps`: ele manda cada ramo filho ao lugar certo — `7410=7510`,
`7420=7520`, `7430=7530`, `7440=7536`, `7441=7535`, `7442=7536` — e só o
agregado ao residual.

| Cód. | Rótulo | Antes | Agora | ISEI-08 | % cand. | Fonte |
|---|---|---|---|---|---|---|
| 713 | CARPINTEIRO, MARCENEIRO E ASSEMELHADOS | 7540 (43,19) | **7520** | **23,65** | 0,252 | `isco8808.sps`: 7422 (marceneiros) → 7520 |
| 228 | PADEIRO, CONFEITEIRO E ASSEMELHADOS | 7540 (43,19) | **7510** | **23,46** | 0,154 | 7412 (padeiros, confeiteiros) → 7510 |
| 710 | TRAB. DE FABRICAÇÃO E PREPARAÇÃO DE ALIMENTOS E BEBIDAS | 7540 (43,19) | **7510** | **23,46** | 0,051 | 7410 (*food processing trades*) → 7510 |
| 591 | ALFAIATE E COSTUREIRO | 7540 (43,19) | **7530** | **22,03** | 0,069 | 7430 (*textile, garment trades*) → 7530 |
| 705 | TRABALHADOR DE FABRICAÇÃO DE ROUPAS | 7540 (43,19) | **7530** | **22,03** | 0,063 | 7430 → 7530 |
| 188 | FIANDEIRO, TECELÃO, TINGIDOR E ASSEMELHADOS | 7540 (43,19) | **7530** | **22,03** | 0,005 | 743 (*textile trades*) → 7530; ver ressalva |
| 241 | TAPECEIRO | 7540 (43,19) | **7530** | **22,03** | 0,018 | 7437 (estofadores) → 7534, dentro de 753 |
| 186 | ESTOFADOR | 7540 (43,19) | **7530** | **22,03** | 0,011 | 7437 → 7534, dentro de 753 |
| 149 | CHAPELEIRO | 7540 (43,19) | **7530** | **22,03** | 0,001 | 7433 (*tailors, dressmakers and hatters*) → 7531, dentro de 753 |
| 715 | TRAB. DE FABRICAÇÃO DE CALÇADOS E ARTEFATOS DE COURO | 7540 (43,19) | **7536** | **18,07** | 0,047 | 7442 (*shoemakers arw*) → 7536, destino único |
| 250 | TRABALHADOR DE CURTIMENTO | 7540 (43,19) | **7535** | **28,08** | 0,003 | 7441 (*pelt dressers, tanners and fellmongers*) → 7535, destino único |

**Ressalva sobre o cód. 188** (0,005% das candidaturas, n = 170). Este é o
único dos onze em que a leitura fina não fecha: `isco8808.sps` manda `7431`
(*fibre preparers*) para 7318 (artesanato, ISEI-08 28,97) e `7432` (*weavers,
knitters*) para 8152 (operadores de máquina, ISEI-08 18,03) — a ISCO-08
dispersou o grupo. Como o dicionário lê este código pelo ramo **artesanal**
(ISCO-88 74, não 82), adotou-se o grupo-menor do agregado ISCO-88 743, que é
7530. As quatro leituras possíveis ficam entre 18 e 29; nenhuma se aproxima dos
43,19 anteriores, que é o que a correção precisa garantir.

Três códigos cujo ISCO-88 é o **agregado 2220** (*health professionals except
nursing*) caíam no agregado ISCO-08 2200, que é a média de **todos** os
profissionais de saúde, inclusive a enfermagem. Os rótulos do TSE nomeiam a
ocupação exata, e para cada uma a OIT dá destino **único**:

| Cód. | Rótulo | Antes | Agora | ISEI-08 | % cand. | Fonte |
|---|---|---|---|---|---|---|
| 115 | ODONTÓLOGO | 2200 (76,98) | **2261** *(Dentists)* | **88,31** | 0,299 | `isco8808.sps`: 2222 → 2261, único |
| 112 | VETERINÁRIO | 2200 (76,98) | **2250** *(Veterinarians)* | **84,14** | 0,131 | 2223 → 2250, único |
| 117 | FARMACÊUTICO | 2200 (76,98) | **2262** *(Pharmacists)* | **81,13** | 0,155 | 2224 → 2262, único |

Um código cujo ISCO-88 é **2320**, que tem exatamente dois destinos na OIT —
2320 (*vocational education teachers*) e 2330 (*secondary education
teachers*) —, e que a ponte trunca para 2330 nos dois casos:

| Cód. | Rótulo | Antes | Agora | ISEI-08 | % cand. | Fonte |
|---|---|---|---|---|---|---|
| 235 | PROFESSOR E INSTRUTOR DE FORMAÇÃO PROFISSIONAL | 2330 (82,41) | **2320** | **72,30** | 0,211 | dos 2 destinos da OIT para 2320, o que o rótulo nomeia. O 2330 fica com o cód. 266, PROFESSOR DE ENSINO MÉDIO, que não muda |

Três códigos cujo ISCO-88 é o **agregado 3470** (*artistic and cultural
associate professionals*), traduzido por 3430, que pressupõe nível técnico —
embora os rótulos do TSE reproduzam literalmente os títulos de ISCO-88 2453 e
2454, de nível profissional:

| Cód. | Rótulo | Antes | Agora | ISEI-08 | % cand. | Fonte |
|---|---|---|---|---|---|---|
| 164 | MÚSICO | 3430 (50,15) | **2652** *(Musicians, singers and composers)* | **64,44** | 0,220 | `isco8808.sps`: 2453 → 2652, único |
| 163 | CANTOR E COMPOSITOR | 3430 (50,15) | **2652** | **64,44** | 0,113 | 2453 → 2652, único |
| 165 | COREÓGRAFO E BAILARINO | 3430 (50,15) | **2653** *(Dancers and choreographers)* | **61,82** | 0,007 | 2454 → 2653, único |

Todos os valores de ISEI-08 acima foram lidos de
`inst/extdata/fontes/ganzeboom/isqoisei08.sps`; nenhum foi estimado.

### Onde esta versão diverge da auditoria

* **Cód. 250 (TRABALHADOR DE CURTIMENTO): 7535, e não 7536.** A auditoria
  propunha 7536 (ISEI-08 18,07) "via 7440". Mas 7536 é *Shoemakers arw*, e
  curtimento é curtume: `isco8808.sps` mapeia `7441` (*pelt dressers, tanners
  and fellmongers*) para **7535** (ISEI-08 28,08), destino único. 7536 e 7535
  são irmãos dentro do mesmo grupo-menor 753, e a auditoria pegou o irmão
  errado. Aplicada a leitura exata do rótulo.
* **Códigos 163, 164 e 165 foram aplicados junto com o Bloco A.** A auditoria
  os classificou como "Bloco C — precisão menor", separado. A lógica e a
  qualidade da evidência são idênticas às do Bloco A (destino único na OIT, sem
  ambiguidade de rótulo), e tratá-los à parte só deixaria três linhas
  conhecidamente erradas na tabela.
* **A recodificação de origem 1311 → 1221 foi rejeitada** (ver acima).
* **O agregado ISCO-88 2400** (26 códigos, 2,848% das candidaturas) **não foi
  tocado**: exige julgamento substantivo caso a caso sobre 26 rótulos e mudaria
  as duas réguas. Fica registrado como a maior pendência conhecida da régua.

### Pendências conhecidas, herdadas da auditoria

Nenhuma foi resolvida nesta versão; ficam anotadas para a nota de método de
quem publicar a partir do pacote.

* **Agregado ISCO-88 2400 → 2400** (2,848% das candidaturas). PSICÓLOGO,
  SOCIÓLOGO, MEMBRO DO MINISTÉRIO PÚBLICO ficam subestimados; ASSISTENTE
  SOCIAL, BIBLIOTECÁRIO, ATOR, superestimados.
* **Restante do agregado 3470** (0,433%): 166 LOCUTOR/RADIALISTA, 105
  DESENHISTA INDUSTRIAL, 193 DECORADOR, 130 ARTISTA DE CIRCO, 168 ATLETA — a
  OIT dá destinos múltiplos e o rótulo do TSE não desempata.
* **Agregado ISCO-88 9100 → 9620** (0,242%), destino no topo da faixa possível,
  e as mesmas 10 linhas com EGP `IIIa` convivendo com ISCO-08 do grande grupo 9
  — herança de `iskoroot.sps`, não decisão do pacote.
* **Cód. 303 GERENTE** (0,402%): o rótulo não desempata entre gerente
  assalariado (12xx) e proprietário-dirigente (13xx). Mantido como está.
* **Cód. 903** PROPRIETÁRIO DE ESTABELECIMENTO **INDUSTRIAL** (0,042%) recebe
  ISCO-08 1400 (*hospitality, retail and other services managers*) — setor
  errado; seria 1321 (*manufacturing managers*).
* **Códs. 906 e 907** (rentista de imóveis, capitalista de ativos financeiros)
  estão corretamente sem ISEI, mas no estrato "Fora da PEA / não informado",
  quando são por definição posições de classe proprietária. 131 candidaturas.
* **Códs. 163, 164 e 165** passam agora, na ISCO-08, do grande grupo 3 para o
  2, sem que o esquema de classes do pacote os acompanhe (seguem em
  "Profissionais de nível médio"). A régua de classe não foi tocada nesta
  versão; a decisão fica com o autor.

### Documentação e testes

* `?tse_para_isei08`, seção **"Quando *não* usar"**: o exemplo do produtor
  agropecuário "que cai cerca de 25 pontos ao mudar de âncora" era justamente o
  erro corrigido acima e foi substituído por dois deslocamentos verdadeiros —
  o enfermeiro (cód. 113), que sobe 26 pontos porque a ISCO-08 promoveu a
  enfermagem a profissão de nível superior, e o vendedor (cód. 411), que cai 13
  porque a revisão reavaliou o grupo 52 inteiro. **A advertência geral da seção
  continua valendo e foi reforçada:** para comparar candidaturas entre si,
  fique na ISCO-88, que é onde o pacote está ancorado. O mesmo exemplo foi
  trocado em `README.Rmd` e na seção 7 de `vignette("qual-regua")`.
* `?tse_para_isco08` ganhou a seção **"Não é a mera composição das duas
  etapas"**, que declara a diferença em relação a `isco88_para_isco08()`.
* **`test-isco08-tse.R` (novo, 33 asserções)** trava, uma a uma: a ponte
  ISCO-88 intacta; a régua TSE → ISCO-88 intacta; a promoção dos três agrários;
  que a promoção é **regra** e não lista (um código novo marcado proprietário
  com destino 6130 também será promovido, e nenhum não-proprietário pode ser);
  os 18 refinamentos por rótulo, um a um; que nenhum código do TSE cai mais no
  residual 7540; que `crosswalk_tse()` e as funções não podem divergir; e o
  **teste de consistência interna** descoberto pela auditoria: nenhuma linha do
  `crosswalk_tse()` pode ter estrato "Classe alta" com ISEI-08 abaixo de 40.
* `test-armadilha.R` distingue agora o deslocamento de grande grupo na **ponte
  crua** (que segue como estava: 114, 222, 234, 602, 901) do deslocamento no
  passo **TSE → ISCO-08** (114, 222, 163, 164, 165).

# ocupacoesBR 0.2.0

## `tse_para_isei08()` passa a aceitar `ano`

As portas ancoradas na ISCO-08 — `tse_para_isco08()`, `tse_para_isei08()` e
`tse_para_siops08()` — ganharam o argumento `ano`, com a mesma máscara de
vigência que as portas da ISCO-88 já tinham. Passando o ano da eleição, as
candidaturas cujo código o TSE **reutilizou** em 2002 voltam `NA` com aviso da
classe `ocupacoesBR_quebra_2002`, em vez de traduzidas pelo cadastro errado.
Antes, quem quisesse o ISEI-08 mascarado por vigência tinha de aplicar a máscara
à mão; agora é `tse_para_isei08(cod, ano = ano)`, simétrico a
`tse_para_isei(cod, ano = ano)`. Veja `?tse_vigencia` e `?checa_periodo`.

## Uma classe própria para o agricultor: criada e revertida (29/07/2026)

Nenhuma proporção publicada muda. O registro fica porque a decisão chegou a ser
implementada, e o motivo da reversão é reaproveitável.

* **O que se fez.** Os códigos 601 (agricultor) e 604 (pescador) receberam a
  classe `"Conta própria rural"`, fora dos três estratos. A justificativa era que
  os dois esquemas do pacote discordavam: `tse_para_egp()` os põe em
  `IVc: proprietário rural` e `tse_para_classe()` os mantinha nas classes
  populares.

* **Por que se desfez.** O argumento era inválido. O EGP só separa IVc de VIIb
  nas **onze** classes; nos colapsos canônicos de cinco e de três, o agricultor e
  o assalariado rural caem na mesma categoria. Comparar um esquema de onze
  classes com uma partição em três estratos é comparar resoluções diferentes, não
  encontrar divergência — e na resolução equivalente à do estrato o próprio EGP
  funde os dois.

* **O dado externo concorda com a reversão.** O ISEI do agricultor, 23, está
  dentro da faixa das classes populares (16 a 43). O patrimônio mediano de
  R$ 254.582 fica acima do máximo das populares por menos de três mil reais: põe
  o agricultor no topo da classe popular, não fora dela. A comparação original
  era contra a mediana das populares, o que inflava a distância.

* **Onde a distinção continua disponível:** em `tse_para_egp(n_classes = 11)`,
  que é onde Erikson e Goldthorpe a puseram. `test-posicao.R` agora trava os dois
  fatos — que os colapsos de 5 e 3 fundem 601 e 606, e que o de 11 os separa.

* A documentação do esquema volta a dizer **doze** categorias, e `?tse_para_classe`
  ganhou a seção que explica por que o agricultor não tem classe própria.

## Correção em `tse_validacao` (29/07/2026)

### Muda o conteúdo de um conjunto de dados publicado

* **`tse_validacao` passa de 175 para 221 linhas.** O piso de 200 declarações de
  bens, que a mediana de patrimônio exige para não ficar ruidosa, descartava a
  **linha inteira** em vez de apenas a mediana. Isso amputava do conjunto 46
  ocupações cuja escolaridade e cuja composição por gênero estão perfeitamente
  medidas e que apenas carecem de declarações de bens. Agora o piso zera a
  mediana e preserva a linha: `mediana_patrimonio` é `NA` onde
  `n_com_bens < 200`.

* **A regressão de gênero documentada em `?tse_para_isei` volta a reproduzir a
  partir do dado publicado.** Ela é calculada sobre 170 códigos com pelo menos
  500 candidaturas, mas o conjunto publicado só continha 157, e a divergência
  atravessava o limiar convencional de significância (p = 0,044 contra 0,061).
  O invariante está agora travado por teste em `test-fonte.R`, que verifica os
  170 códigos, os 28 femininos e o coeficiente de −6,14.

* **A correlação com escolaridade passa a ser reportada sobre 208 ocupações, e
  não 164**, porque a escolaridade está medida em toda linha do conjunto. O
  valor vai de 0,772 para **0,764**. A correlação com patrimônio permanece
  **0,682**, calculada sobre as mesmas 164 ocupações de antes — o que corrige,
  de passagem, o 0,671 que a vinheta `validacao` ainda reportava.

### Quem precisa mudar código

* Quem correlaciona com `mediana_patrimonio` deve filtrar
  `!is.na(mediana_patrimonio)`. Quem usa apenas `pct_superior` ou `pct_mulher`
  ganha 46 ocupações sem fazer nada.

## Segunda rodada de auditoria (27/07/2026)

Quatro revisores independentes reauditaram o estado corrigido
(`AUDITORIA_2026-07-27.md`), rodando R sobre o dado real. A fidelidade às fontes
do ISMF é byte-a-byte (zero divergências). Estas são as correções aplicadas.

### Muda resultado obtido com a versão anterior

* **Escultor, pintor e artista plástico deixam de entrar na "alta credenciada"
  com ISEI 68.** Os códigos **191, 214 e 215** caíam no agregado ISCO `2400`
  (ISEI 68) — o escore do advogado —, apesar de só 18,6%–29,7% dos que os
  declaram terem ensino superior. Passam ao código preciso `2452` (escultores,
  pintores e artistas plásticos, **ISEI 54**), que a ISCO já oferece. É a mesma
  correção de 114/222 na rodada anterior. O **estrato não muda** (seguem
  "Profissionais de nível superior" / classe alta, pelo primeiro dígito); só o
  ISEI. O alinhamento da *classe* dos artistas visuais com os performers ficou
  como decisão editorial na branch `proposta-bloco-c`.

* **`tse_para_classe(cod, superior = NA)` não imputa mais a metade baixa.** Quem
  não declarou escolaridade (`superior = NA`) permanecia, calado, em "Vínculo
  público, médio ou menos". Agora fica no rótulo residual "Vínculo público não
  especificado" — não dividido, não imputado —, coerente com a política de não
  imputação que o pacote adota no EGP. São ~16 mil candidaturas, e a ausência de
  escolaridade é correlacionada com posição social.

* **Fisioterapeuta (114) e nutricionista (222) passam a "Profissionais de nível
  superior".** A regra de classe lê o primeiro dígito da ISCO-88, e a ISCO-88 de
  1988 classificou fisioterapia e nutrição como ocupações auxiliares da medicina
  (grande grupo 3). Elas se universitarizaram, e a **própria OIT corrigiu isso em
  2008**, movendo-as ao grande grupo 2 — códigos `2264` e `2265`, que este pacote
  já computa. O critério externo concorda: 95,8% e 85,4% dos que declaram esses
  códigos têm superior completo, contra 74,7% da professora fundamental (265),
  que a régua punha um estrato **acima**. A régua estava incoerente com a sua
  própria lógica, e no caso mais feminizado da tabela.

  Efeito medido: **5.455 candidaturas (0,164%)**; a classe alta vai de 32,54%
  para 32,71%. O **ISEI não muda** (segue 60 e 51) — as duas réguas continuam
  independentes, que é o desenho do pacote.

  **A regra geral foi testada e rejeitada.** Trocar o grande grupo da ISCO-88
  pelo da ISCO-08 para todos os códigos conserta estes dois e **quebra três**:
  234, 602 e 901 cairiam de classe alta para rural, porque a ponte 88→08 do
  código `1311` tem nove destinos possíveis segundo a OIT e o truncado (`6130`)
  vale ISEI-08 17,8 contra 43 do ISCO-88. A regra de princípio sai pior que o
  remendo — desfaz um patch deliberado por uma ambiguidade da ponte, não por uma
  decisão sociológica. Por isso a correção é um patch de dois códigos, explícito
  e documentado em `.PATCH_CLASSE`, e não uma mudança de regra.

* **O EGP deixa de ler o agricultor familiar como proletário rural.** A marca
  `tse_isco$proprietario` fazia dois trabalhos ao mesmo tempo: definia a
  pertença à classe "Proprietários e empregadores" **e** alimentava o `SEMPL`
  que o EGP exige. São perguntas diferentes — "trabalha por conta própria?" não
  é "pertence à classe proprietária?" —, e enquanto compartilharam um vetor,
  marcar o agricultor como conta própria o promovia junto à classe alta, que o
  patrimônio não sustenta.

  Agora há duas colunas. `conta_propria` é superconjunto de `proprietario` e
  inclui **601 (agricultor)** e **604 (pescador)**, que trabalham por conta
  própria sem serem a classe proprietária. O esquema de classes **não muda**:
  os dois seguem em "Trabalhadores rurais" / classes populares. (Em 29/07/2026
  testou-se movê-los para uma classe própria e a mudança foi revertida; ver a
  entrada do topo deste arquivo.)

  O EGP muda muito:

  | classe EGP | antes | depois |
  |---|---|---|
  | IVc: proprietário rural | 2,02% | **16,25%** |
  | VIIb: trabalhador agrícola | 16,24% | **2,01%** |

  **14,23% das candidaturas classificadas mudam de classe.** A oferta eleitoral
  brasileira deixa de aparecer como um proletariado rural e passa a aparecer
  como o que a definição da OIT e o dado dizem que ela é: pequena propriedade
  familiar. É o ponto de Carvalhaes (2015) que `?isco88_para_egp` cita — no
  Brasil, a categoria que o EGP melhor capta é o conta própria — finalmente
  operando.

  A marcação é por **código do TSE**, não por ISCO, porque três códigos dividem
  a ISCO 6100 e não são a mesma coisa: agricultor e pescador são conta própria;
  **jardineiro é trabalho contratado** e segue em VIIb.

### As advertências saem da vinheta e entram nas páginas de ajuda

O pacote já conhecia os seus limites e os documentava — nas vinhetas. Quem faz
`?tse_para_isei`, que é o caminho de quase todo usuário, não os recebia. Três
seções novas, com números reproduzidos no dado real:

* **`?tse_para_isei` ganha "Anomalias conhecidas da escala".** A ISCO-88 é
  enviesada contra ocupações femininas: a credencial constante, um código
  majoritariamente feminino recebe **6,1 pontos de ISEI a menos** (ep 3,02;
  p = 0,044; 170 códigos com n ≥ 500). E não é falta de escolaridade — esses
  códigos têm **mais**: 29,8% de superior contra 23,9%, com ISEI médio de 46,0
  contra 48,7. O caso emblemático é a enfermagem, que a ISCO-88 põe em `2230`
  com **ISEI 43, abaixo dos escriturários (45)**, apesar de ser profissão
  universitária; a âncora da ISCO-08 dá **68,7**. Daí a recomendação explícita:
  para análise de gênero, prefira [tse_para_isei08()].

* **`?tse_para_componente_alta` declara a assimetria de confiabilidade.** A
  partição é simétrica no desenho e assimétrica na medição: "advogado"
  pressupõe inscrição na OAB; "empresário" não pressupõe nada. O patrimônio
  mediano de quem se declara 257 varia por um fator de **25** conforme o cargo
  disputado (R$ 367 mil entre candidatos a vereador, R$ 9,3 milhões entre
  candidatos a senador), sob um único ISEI e uma única classe. Um gráfico que
  compare os dois componentes compara uma quantidade ancorada em registro
  externo a outra autodeclarada que agrega posições muito distantes.

  A seção também registra **o que o dado não mostra**: não há evidência de que
  as pessoas troquem de rótulo conforme o cargo. A frequência do 257 não cresce
  com a importância do posto — tem pico em prefeito (10,6%) e cai em senador
  (7,1%) e governador (6,2%); quem cresce monotonicamente é "advogado" (1,6% a
  15,2%), o caso ancorado, e "comerciante" **cai** de 6,2% a 0%. O gradiente de
  patrimônio é consistente tanto com recrutamento seletivo quanto com
  relabeling, e estes dados não separam as duas hipóteses.

* **`?isei_retrospectivo` ganha "O que ele erra, medido".** Entre os 680.317
  pares consecutivos em que o ISEI foi observado nas duas pontas, **52,1%**
  mudam de código e **45,3%** mudam de escore, com diferença absoluta média de
  **18,9 pontos** quando muda. Mesmo com defasagem zero o escore herdado
  estaria errado em quase metade dos casos — e a defasagem não é zero: mediana
  de 4 anos, **34,6%** de 8 anos ou mais. Pior que o tamanho é a direção: o erro
  aponta sempre para o passado, então para quem ascendeu ele puxa a posição
  para baixo. É viés sistemático contra a própria quantidade que estudos de
  profissionalização política querem medir.

* **`tse_codigos_autorrotulo`** — os dez códigos cujo rótulo designa
  propriedade por autodescrição (empresário, comerciante, industrial,
  proprietário de estabelecimento) e que, por isso, não são ancorados em
  registro nenhum. São **12,2%** das candidaturas. O uso é análise de
  sensibilidade em uma linha:

  ```r
  d$isei_ancorado <- ifelse(d$cod %in% tse_codigos_autorrotulo, NA, d$isei)
  ```

  A decisão sobre o código **257 (EMPRESÁRIO) foi medir e não mover**. A
  proposta da auditoria — levá-lo à ISCO 13, ISEI 51 — é rejeitada pelo
  critério externo: 257 tem o **maior** patrimônio mediano entre os códigos
  proprietários (R$ 495.400, contra R$ 303.874 do industrial e R$ 296.088 do
  comerciante), e rebaixá-lo o poria abaixo do industrial. O problema do 257
  não é o nível, é a dispersão: dentro do código os extremos de patrimônio
  distam 81 vezes, e o mediano varia por um fator de 25 conforme o cargo
  disputado. É uma **mistura** de duas populações sob um rótulo, e mistura não
  se corrige mudando o ponto — se torna visível.

  A escolha da classe e do estrato **não dependia** dessa decisão: 257 está em
  `.COD_PROPRIETARIO`, e a regra de classe testa a pertença antes de olhar o
  ISCO.

### Correções

* **O parâmetro `ano` chega às medidas contínuas.** `tse_para_isei()`,
  `tse_para_siops()` e `tse_para_egp()` passam a aceitar `ano`, como as portas
  categóricas já faziam. Sem ele, uma série de ISEI que atravessa 2002
  classificava o período pré-reutilização pelo dicionário pós-reutilização, sem
  aviso: `tse_para_isei(215)` devolvia 68 (artista) para uma candidatura de 2000,
  quando 215 designava um cargo de direção. Agora `tse_para_isei(215, ano = 2000)`
  devolve `NA` com aviso.

* **`data-raw/03_gera_quebra_2002.R` foi aposentado.** Ele ainda montava
  `tse_quebra_2002` de uma tabela de 3 linhas digitada à mão (sem a coluna
  `tipo`) e chamava `use_data()`. Rodá-lo isolado rebaixava o dataset e desligava
  o filtro de vigência do `ano` **em silêncio**. A geração vive só em
  `04_gera_rotulos.R`. Com isso, a afirmação "nenhuma tabela é digitada à mão"
  passa a valer sem exceção.

### A medida se afere contra a PNAD

* **`isco_posicao_br`** — a posição na ocupação que o TSE não pergunta, medida
  onde ela existe. Para cada um dos 319 códigos ISCO-88 observados, a
  distribuição brasileira de conta própria, empregador e número de empregados,
  apurada nos **quatro trimestres de 2025 da PNAD Contínua** (437.880 pessoas
  distintas; 258 códigos com n ≥ 100).

  Isto só ficou possível por causa da perna COD: a PNAD usa a COD, a COD é a
  ISCO-08, e `cod_para_isco08()` a leva ao mesmo espaço em que o TSE aterrissa.

  | ISCO-88 | conta própria ou empregador |
  |---|---|
  | 61 (agrícolas qualificados) | **67,6%** |
  | 6150 (pesca) | **83,8%** |
  | 92 (rurais elementares) | 16,5% |
  | todas as ocupações | 29,4% |

  É um **prior empírico**, não uma imputação: a tabela não atribui posição a
  ninguém, informa a composição da ocupação no país. O uso legítimo é análise
  de sensibilidade; o ilegítimo é tratar a proporção como se fosse o caso
  individual.

  Dois cuidados de método ficam registrados na documentação. A PNAD é **painel
  rotativo** — 864.870 observações são de 437.880 pessoas (1,98×) —, então os
  pesos são divididos pelos quatro trimestres e a coluna de precisão é
  `n_pessoas`, não `n_obs`. E a hipótese de **sazonalidade agrícola**, que
  motivou usar o ano inteiro, **não se confirmou**: a amplitude entre
  trimestres é de 2,5 pp. O ganho do ano completo foi precisão nas células
  finas, não correção de viés.

  Os microdados (212 MB por trimestre) **não** viajam com o pacote; o que entra
  é a tabela agregada de 4,5 KB, gerada por `data-raw/07_gera_posicao.R`.

* **Conformidade:** `.claude/` deixa de entrar no tarball; a doc de
  `cod_para_isco08()` corrige a afirmação sobre forças armadas (a perna ISCO-08
  as pontua — o buraco é só na âncora ISCO-88).

### `*_para_prestigio()` passa a ser o nome canônico

No Brasil, **SIOPS** é o Sistema de Informações sobre Orçamentos Públicos em
Saúde (Ministério da Saúde, LC 141/2012). Um pacote em português que exporta
`tse_para_siops()` colide em toda busca, e a interseção de públicos — saúde,
orçamento, dados administrativos — não é pequena. Ganzeboom pode usar a sigla;
um pacote brasileiro não deveria, sem mais.

São oito portas: `tse_para_prestigio()`, `tse_para_prestigio08()`,
`isco88_para_prestigio()`, `cbo2002_para_prestigio()`,
`cbo2002_para_prestigio08()`, `cbo94_para_prestigio()`, `cod_para_prestigio()` e
`cod_para_prestigio08()`. **Nenhum número muda:** as formas `*_siops()`
continuam existindo como alias, verificados idênticos um a um, e não serão
removidas de uma vez.

Junto vem o que faltava à régua: **Treiman (1977)** citado, e a advertência de
que a escala é média de estudos de ~60 países dos anos 1960–70 — aplicá-la a
dado recente pressupõe que a ordem de prestígio é invariante no tempo, que é a
tese de Treiman e não um fato dado. Ela quebra onde a ocupação mudou de posição
desde então: bancário, professor, policial, ocupações de tecnologia.

---

Correções da auditoria de 26/07/2026 (`AUDITORIA_2026-07.md`). Cinco revisores
independentes varreram o pacote linha a linha rodando R sobre 3.334.269
candidaturas.

## Mudanças que alteram resultado

Estas mudam números já obtidos com a versão 0.1.0. Quem publicou com ela deve
reconferir.

* **`crosswalk_tse()` deixa de publicar um EGP sem pequena burguesia.** A função
  chamava `isco88_para_egp(isco, avisar = FALSE)`; o `avisar = FALSE` fixo
  silenciava o aviso de EGP degradado e a coluna saía com IVa, IVb e V zeradas.
  A marca `proprietario` do dicionário é o `SEMPL` do ISMF e estava disponível o
  tempo todo. Os códigos **169, 902, 903, 904 e 905** saem de
  `II: dirigentes e profissionais inferiores` para `IVb: conta própria`.
  `tse_para_egp()` ganha `usa_proprietario = TRUE` por padrão; passe `FALSE`
  para o comportamento antigo.

* **`cbo2002_para_isco()` devolve `NA` em família sem ISCO majoritário.** Em 19
  famílias a moda não é maioria, e o desempate anterior era mudo e ia sempre
  para o menor código ISCO — efeito da ordenação lexicográfica de `table()`.
  Como a hierarquia da ISCO é ordenada por status, o menor código tem o maior
  ISEI em 16 dos 19 casos: viés sistemático, não ruído. Use `empate = "moda"`
  para o comportamento antigo.

* **`concordancia` só é afirmada sobre família vista por inteiro.** Era apurada
  sobre as ocupações que a tábua do MTE cobre, não sobre a família real: 131
  famílias tinham uma única ocupação vista e reportavam `concordancia = 1`, e em
  **87** delas a família de fato tem mais de uma. Agora fica `NA` quando
  `cobertura_familia < 1` (261 das 436); a proporção bruta segue em
  `concordancia_vista`.

* **Código sujo de RAIS/CAGED não derruba mais o vetor.** `-1`, `0000-1`,
  `{ñ class}` e `999999` — os sentinelas que o layout da RAIS **declara** —
  viram `NA` **em silêncio**, porque são a forma declarada do "ignorado", não
  sujeira (a sujeira genuína, como `AB@CD1`, avisa com
  `ocupacoesBR_codigo_invalido`). Antes abortavam a chamada inteira, e `000-1`
  sobrevivia à limpeza como a família `0001`: uma ausência virando ocupação.
  O erro ficou reservado ao caso em que nenhum valor é válido.

* **Entrada numérica recompõe o zero à esquerda.** O Novo CAGED grava a CBO como
  número, e `010105` chega como `10105`. Vale só para entrada numérica: `"111"`
  como texto continua sendo erro, porque é código malformado e não a família
  `"0111"`.

## Correções silenciosas que passaram a fazer barulho

* `isco88_para_egp()` voltou a **avisar sobre ISCO ambíguo**. Um
  `suppressWarnings()` mal posicionado envolvia `.norm_isco()` inteiro e engolia
  o aviso que a documentação prometia por escrito: quem passasse `"110"`
  querendo forças armadas recebia, calado, a classe I.
* `n_supervisionados` como `factor` agora é **erro**. Era lido como índice de
  nível (`as.numeric(factor(c("0","5","20")))` dá `1 3 2`) e produzia tabela de
  classe errada sem aviso.
* `data.frame` ou `list` na entrada agora é **erro** em todas as portas.
  `as.character()` de um quadro faz deparse por coluna, de modo que
  `tse_para_classe(df["cod"])` devolvia **um** `NA` — que, reciclado, apaga uma
  coluna inteira. `df["cod"]` é o que `data.table` e `dplyr::select()` devolvem.
* `cbo2002_concordancia()` avisa sobre família inexistente, em vez de devolver
  uma linha inteira de `NA` em silêncio.
* Todos os avisos têm **classe** (`ocupacoesBR_codigo_ausente`,
  `ocupacoesBR_egp_incompleto`, `ocupacoesBR_isco_ambiguo`,
  `ocupacoesBR_familia_empatada`, `ocupacoesBR_quebra_2002` e outros). Antes
  eram todos `simpleWarning`: quem calava o aviso rotineiro calava junto o do
  EGP incompleto, e `options(warn = 2)` transformava o rotineiro em fatal.

## Duas vinhetas

* **`vignette("qual-regua")`** — a que faltava. O pacote oferece quatro medidas
  com a mesma facilidade e nenhuma orientação sobre qual usar, e essa facilidade
  é o principal risco de usá-lo. A vinheta é sobre escolher, e cobre os sete
  erros na ordem em que são cometidos: confundir status com prestígio, tratar
  `NA` como zero, somar categoria residual a estrato, publicar EGP de onze
  classes a partir do TSE, atravessar 2002 sem `ano`, misturar as duas âncoras
  do ISEI, e não chamar `checa_cobertura()`.

  O caso que abre a vinheta: ISEI e prestígio correlacionam-se forte — e por isso
  a diferença passa despercebida —, mas **se invertem** onde importa. O
  magistrado tem ISEI 90 e prestígio 76; o enfermeiro tem ISEI 43 e prestígio 54.
  Uma pesquisa sobre posição de topo e outra sobre valorização social vão ordenar
  as profissões de saúde de formas opostas, e as duas estarão certas.

* **`vignette("validacao")`** — a aferição contra critério externo.

## A porta do IBGE, e a ponte que faltava de volta

* **`cod_para_isco08()` e companhia** abrem a **PNAD Contínua e o Censo**. A COD
  é construída sobre a ISCO-08, e por isso **428 dos seus 434 grupos de base são
  o próprio código internacional** — não há tábua a consultar. A perna cobre
  **100%** do seu universo, contra os 49,8% da perna CBO. A diferença não é de
  esforço: é de desenho das classificações.

  As seis adaptações brasileiras estão decididas e documentadas uma a uma.
  Polícia e bombeiro militar vão para o grande grupo 5 (serviços protetivos) e
  não para o 0 (forças armadas) — são militarizados em estatuto e exercem
  serviço civil, e é a função que a classificação mede. **A distinção entre
  oficial e praça se perde**, porque a ISCO-08 não a tem, e no Brasil ela é um
  degrau de status real.

* **`isco08_para_isco88()`** — a ponte de volta. O `isco0888.sps` estava no
  repositório desde sempre e nunca havia sido lido: o parser esperava
  `recode @isko (X=Y)` uma vez por linha, e o arquivo traz o `recode` uma única
  vez seguido de 596 pares soltos com sinal negativo.

  Sem ela, quem entrava pela COD alcançava o ISEI-08 mas **não** o ISEI-88 nem o
  EGP. Com ela, a PNAD chega ao esquema de classes inteiro.

  **A ida e a volta não se cancelam:** levar um código da ISCO-88 à ISCO-08 e
  trazê-lo de volta devolve o ponto de partida em **69%** dos casos. Não é
  defeito — a OIT reparte e funde categorias entre as revisões. Um teste trava o
  número, para que ninguém "conserte" a ponte inventando volta onde não há.

* Novas funções: `cod_para_isco()`, `cod_para_isei()`, `cod_para_isei08()`,
  `cod_para_prestigio()`, `cod_para_prestigio08()`, `cod_para_egp()`,
  `checa_cobertura_cod()` e `crosswalk_cod()`. Novos dados: `cod_isco08` e
  `isco08_isco88`.

* **O único buraco vem da fonte.** As forças armadas (`0110`, `0210`) ficam sem
  ISEI, prestígio e EGP porque o ISMF não pontua o ISCO-88 `0110`. São 2 dos
  434, e `NA` é a resposta correta — inventar um escore para militares seria
  pior que a ausência dele.

## A medida passa a se aferir contra algo fora dela

Até aqui, tudo no pacote era tradução — código do TSE para ISCO, ISCO para ISEI
— e nada nessa cadeia se conferia contra coisa alguma **externa**. Um crosswalk
internamente consistente pode estar inteiramente errado.

* **`tse_validacao`** — 175 ocupações com patrimônio mediano declarado e
  escolaridade, duas variáveis que o TSE coleta e que não entram na construção
  da medida em momento nenhum. Agregado, 175 linhas, nada identificável.

* **`vignette("validacao")`** — a aferição:

  | critério | Pearson | Spearman |
  |---|---|---|
  | % com ensino superior | 0,764 | 0,845 |
  | log da mediana de patrimônio | 0,671 | 0,688 |

  E o contraste que é o verdadeiro resultado: no nível do **indivíduo**, a
  correlação entre ISEI e patrimônio é de **0,207**; no da **ocupação**, 0,671.
  Isso não é defeito, é a definição — uma medida de posição ocupacional explica
  a variância *entre* ocupações e quase nada *dentro* de cada uma. Daí a regra
  prática: **não use ISEI como proxy de renda individual.**

  A vinheta também documenta onde a medida não é monótona (comerciante e
  empresário com ISEI de classe média e patrimônio de classe alta) e quantifica
  o viés de gênero: ocupações majoritariamente femininas têm **mais**
  escolaridade e **menos** ISEI.

* **Invariante I9 na suíte.** É o único teste que amarra o pacote a algo de fora
  dele mesmo: se as correlações com patrimônio e escolaridade desabarem, é a
  medida que quebrou, não o teste.

* **`isei_retrospectivo()` exportada.** Quando um registro não traz ocupação
  classificável, carrega o último escore observado **da própria pessoa**, e
  devolve junto a marca de herança e a defasagem. Nada é modelado: usa-se apenas
  a história ocupacional do indivíduo, jamais patrimônio, partido ou
  escolaridade — de modo que o escore continua independente das variáveis com
  que se vai cruzá-lo.

  Nas candidaturas ao TSE, a cobertura do ISEI sobe de 68,5% para 76,0% entre
  homens e de **52,9% para 58,7% entre mulheres**; o ganho é maior entre elas
  porque o padrão de ausência é fortemente generificado. Reimplementada em R
  base para não acrescentar dependência, e conferida contra a implementação
  original em `data.table`: escore, marca e defasagem idênticos em 3,3 milhões
  de linhas.

## A história do cadastro do TSE

O `DS_OCUPACAO` vem ao lado do `CD_OCUPACAO` nos arquivos `consulta_cand` e está
**100% preenchido nas 14 eleições de 1998 a 2024**. O pacote supunha não tê-lo:
`?checa_periodo` dizia, por escrito, *"não por rótulo — o pacote não distribui
os rótulos do TSE — e sim pelo dado"*. A resposta exata sempre esteve na coluna
ao lado.

* **`tse_ocupacao_rotulos`** — 334 vigências `(cod_tse, de, ate, rotulo)` para os
  275 códigos. Um código que nunca mudou de nome tem uma linha; um que mudou tem
  uma por período.

* **`tse_quebra_2002` reconstruída**, de 3 para 44 códigos com rótulo alterado, e
  com a coluna **`tipo`** — que é o que impede a tabela de virar um alarme falso.
  Nem toda mudança de nome é problema:

  | tipo | códigos | o que fazer |
  |---|---|---|
  | `reutilizado` | 7 (1.582 candidaturas) | o código passou a designar outra ocupação: exclua ou reclassifique |
  | `renomeado` | 4 | mesma ocupação, nome novo: nada a fazer |
  | `redefinido` | 15 | o escopo mudou: cautela |
  | `refinado` | 18 | rótulo mais preciso |

  **Quatro das sete reutilizações são invisíveis ao método anterior.** O código
  `215` era "OCUPANTE DE CARGO DE DIREÇÃO E ASSESSORAMENTO SUPERIOR" até 2000 e
  virou "ARTISTA PLÁSTICO" a partir de 2006, com variação de escolaridade de
  **+6,5 pp** — um DAS e um artista plástico têm perfil de diploma parecido, e
  por isso a heurística que só olhava escolaridade não o via.

  Na direção oposta, `601` foi de "TRABALHADOR AGRÍCOLA" para "AGRICULTOR": muda
  todo o léxico e é o mesmo ofício. Classificá-lo como reutilização mandaria
  descartar 50.139 candidaturas válidas. Por isso `tipo` é **julgamento curado
  sobre 44 casos**, e não fórmula — mas auditável na própria tabela, que carrega
  os dois rótulos ao lado das duas evidências.

  As colunas `pct_superior_*` agora são **calculadas**. Elas reproduzem
  exatamente os seis números que a versão anterior trazia digitados à mão — que
  eram a única tabela do pacote não gerada por script, e deixaram de ser.

* **`ano` nas funções de tradução.** `tse_para_isco(cod, ano)`,
  `tse_para_classe()`, `tse_para_estrato()`, `tse_para_componente_alta()` e
  `tse_para_politico()` aceitam o ano da eleição; as candidaturas cujo código
  estava sob outra ocupação voltam `NA` com aviso, em vez de traduzidas pelo
  dicionário errado. Sem `ano`, o comportamento é o de antes.

* **`tse_vigencia()`**, **`tse_diff_cadastro()`**, **`tse_para_rotulo()`** e
  **`tse_rotulo_para_cod()`**. A última torna o pacote utilizável por quem
  recebe a ocupação como texto — o caso de quem baixa
  `br_tse_eleicoes.candidatos` no `basedosdados`.

  `tse_diff_cadastro()` descreve o que quase ninguém trata: entre 2000 e 2002 o
  TSE aposentou 13 códigos (**12,2%** das candidaturas do período antigo) e
  criou 122 (**33,1%** do novo). Quem monta série 1998–2024 mede "Proprietários
  e empregadores" com dois vocabulários incomensuráveis.

* **`crosswalk_tse()` ganha `rotulo`.** Sem ele a função não servia ao uso que a
  própria documentação anuncia: ninguém audita `169 → 1300 → 51 → Proprietários`
  sem saber que 169 é COMERCIANTE.

* **`checa_periodo()` passa a distinguir por `tipo`.** Antes marcaria os 44; agora
  marca só os 7 reutilizados, e usa o ano real da reutilização em vez de um
  corte fixo em 2000.

## Novidades

* **Escada hierárquica da CBO.** `cbo2002_para_isco(cbo, escada = TRUE)` sobe da
  ocupação de seis dígitos para a família, o subgrupo e o subgrupo principal até
  achar um nível com correspondência. Sobre o domínio oficial (2.777 ocupações),
  a cobertura vai de **49,8% para 89,8%**: 1.384 diretas, 760 pela família, 306
  pelo subgrupo, 44 pelo subgrupo principal, 283 sem rota. Onde as ocupações
  mapeadas não concordam, usa-se o ancestral comum delas na ISCO — a forma
  arredondada que o ISMF publica.

  **Para em dois dígitos de propósito.** Descer a um fecharia parte das 283
  restantes cometendo a armadilha que o pacote existe para impedir: o grande
  grupo 9 da CBO é reparação e manutenção, o da ISCO é ocupações elementares.
  O padrão é `escada = FALSE`, porque o resultado deixa de ser a ocupação
  declarada e passa a ser o seu grupo; `crosswalk_cbo2002()` expõe
  `nivel_usado` para auditar caso a caso.

* **Oito funções que faltavam**, fechando a assimetria entre as portas:
  `isco88_para_isei()`, `isco88_para_siops()`, `cbo94_para_siops()`,
  `cbo94_para_isco08()`, `cbo94_para_egp()`, `cbo2002_para_isei08()`,
  `cbo2002_para_siops08()`, `checa_cobertura_cbo94()` e `crosswalk_cbo94()`.
  O ISCO-88 é o hub do pacote e era a única origem sem porta para o ISEI —
  justamente por onde chega quem vem de survey próprio ou da PNAD via COD.
  De 27 para 50 funções exportadas.

* **`isco88_para_egp()` deduplica.** Era a única função vetorial que não passava
  por `.por_unico()`: cerca de vinte `ifelse()` sobre o vetor inteiro, cada um
  alocando cópia completa. Medido em 2 milhões de linhas, mesma máquina:
  **7,42 s → 0,59 s (12,6×) e 702 Mb → 137 Mb**, com resultado `identical()`.

* `crosswalk_tse()` ganha `nivel`, `n_destinos_tse`, `n_alt_08` e `qualidade`
  (`exata` / `agregada` / `ambígua`). Metade das candidaturas é traduzida a dois
  dígitos e 52 códigos têm mais de um destino na ISCO-08; publicar tudo com a
  mesma tipografia esconde erro de medida que é correlacionado com o estrato.
* `cbo2002_familia_isco88` ganha `n_ocupacoes_cbo`, `cobertura_familia` e
  `concordancia_vista`. O denominador passa a ser o domínio oficial da CBO-2002
  no Novo CAGED (2.777 ocupações), embarcado em `inst/extdata/fontes/`.
* `inst/extdata/PROVENIENCIA.yml` registra URL, data de acesso e `sha256` de
  cada fonte, mais as âncoras de versão que as próprias fontes publicam
  (`Build 20260707-1823` do MTE; "CBO 2002 atualizada em 23/08/2004" do layout
  da RAIS). `data-raw/00_confere_proveniencia.R` confere, e um teste falha se
  divergir.

## Infraestrutura

* **As fontes passaram de `data-raw/` para `inst/extdata/` e viajam com o
  pacote.** Os três testes que amarram as tabelas às sintaxes de Ganzeboom eram
  pulados justamente no `R CMD check` — o único lugar onde a garantia importa.
* A validação cruzada contra o `DIGCLASS` passou de **uma** célula para as
  **oito** de posição no emprego × supervisão. Zero divergência: o porte de
  `iskopromo.sps` está correto também nos ramos que nunca haviam sido testados.
* Suíte: de 562 asserções com 3 `skip` para 1.219 sem nenhum.

---

# ocupacoesBR 0.1.0

Primeira versão. Duas portas de entrada (TSE e CBO-2002/CBO-94), 27 funções
exportadas, 8 conjuntos de dados, todas as tabelas geradas por script a partir
das fontes originais.

**Mudança de dado registrada retroativamente:** durante o desenvolvimento, o
código `111` do TSE passou de ISCO-88 `2220` para `2221` (e o ISEI de 85 para
88), ao descer de dois para quatro dígitos e separar médico de enfermeiro.
Resultados obtidos antes dessa correção diferem. Não havia `NEWS.md` à época —
este parágrafo existe para que a diferença seja rastreável.
