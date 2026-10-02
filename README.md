# Naruto Clássico — O Começo

Fangame 2D em Godot 4.x focado no início de Naruto Clássico. Henrique Uchiha tem 12 anos. O jogo abre no Episódio 1 e agora continua jogavelmente pelo Episódio 2.

## Direção do jogo

A exploração usa visão de cima, mapa compacto e leitura de RPG portátil antigo. O combate e as cutscenes podem usar apresentação lateral mais detalhada, no estilo dos fangames 2D/JUS/NZC/MUGEN, sem misturar esse corpo lateral com o overworld.

Naruto, Iruka, Mizuki, Sasuke e Sakura aparecem em escala coerente no mapa. O Naruto lateral importado do pack MUGEN deixou de ser o corpo de exploração; ele aparece apenas como apresentação curta de batalha no momento decisivo do confronto com Mizuki.

## Controles

- WASD/setas: andar.
- R / botão CORRER: correr.
- Shift / FURTIVO: andar furtivamente.
- J / KUNAI: lançar kunai.
- K / KATON: Katon básico.
- E/Espaço / AÇÃO: conversar e interagir.
- P / PROGRESSO: abrir o menu de progressão.

## Progressão

O menu mostra nível, XP, ryo, chakra, inventário, missões, avanço da história e técnicas atuais.

Começo do Episódio 1:
- Kunai
- Shuriken
- Katon básico
- movimentos e ações básicas

Mantidos para fases futuras, mas bloqueados agora:
- Chidori
- Mangekyo
- Amaterasu
- Susanoo
- técnicas avançadas e transformações

## Animações do Henrique

`assets/characters/henrique-actions.json` mantém o catálogo enviado pelo usuário: idle, caminhada, corrida, pulo, queda, agachar, esquiva, deslizar, soco, chute, combos, kunai, shuriken, Katon, Chidori, corrente elétrica, clones, substituição, Sharingan, Mangekyo, genjutsu, Susanoo, dano, levantar, Amaterasu, ataques aéreos e extras.

O jogo só libera ações compatíveis com a fase atual da história.

## Sprites 2D

- `assets/art/naruto.svg`: overworld do Naruto clássico.
- `assets/art/iruka.svg`: overworld do Iruka.
- `assets/art/mizuki.svg`: overworld do Mizuki.
- `assets/art/sasuke.svg`: overworld original do Sasuke adicionado para a Academia.
- `assets/art/sakura.svg`: overworld original da Sakura adicionado para a Academia.
- `assets/mugen/naruto/`: quadros de um Naruto Kid fan-MUGEN já existentes no projeto, usados apenas em apresentação de combate/cutscene.
- `assets/characters/henrique-detailed.png`: atlas detalhado do Henrique.

Créditos e procedência do material MUGEN estão em `assets/mugen/CREDITS.md`.

## Mundo

A praça de Konoha recebeu mais elementos de RPG top-down: caminhos quebrados, bancos, caixas, placa de direção, áreas de grama, Academia, ramen, quadro de missões, ponte/canal e marcadores de distrito.

## História

A abertura começa no dia da prova de graduação. Naruto falha na Academia; Mizuki o manipula; o Pergaminho dos Selos é roubado; Henrique segue os acontecimentos até a floresta e ajuda Iruka a ganhar tempo. O momento decisivo continua sendo de Naruto.

Esta é uma adaptação jogável de fã e não reproduz o roteiro oficial palavra por palavra.

## Pesquisa e direção visual

A direção de arte foi refinada olhando referências de fangames Naruto 2D/JUS/NZC/MUGEN e mantendo a escala dos personagens coerente, além do material oficial do Episódio 1. Consulte `docs/CLASSIC_EP1_STYLE.md`.

## Teste

```
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/prologue_smoke.gd
```

O renderizador continua em Compatibility e a interface permanece 960×540 para manter o projeto leve no Android.


## Episódio 2 — Konohamaru

Depois da conclusão do confronto com Mizuki, o jogo passa automaticamente para o Episódio 2. Naruto já se formou e cruza com Konohamaru, neto do Terceiro Hokage. A adaptação mantém o foco em reconhecimento, esforço e no começo da relação entre Naruto e Konohamaru, sem reproduzir o roteiro oficial palavra por palavra.

O Episódio 2 adiciona Konohamaru e Ebisu ao overworld, um pequeno treino interativo e recompensa própria de progressão. O próximo gancho narrativo aponta para a formação dos times e o futuro Time 7.

## Menu TÉCNICAS e animações do Henrique

Além de KUNAI, KATON e AÇÃO, existe um botão TÉCNICAS para celular. Ele expõe ações básicas ligadas ao catálogo do Henrique:

- soco / combo básico
- shuriken
- esquiva/rolamento
- agachar
- pular
- deslizar
- clone das sombras
- substituição

O manifesto também registra estados de dano, queda, levantar e morte básica, além das animações avançadas já guardadas para fases futuras. O atlas transparente atual tem 24 poses e reutiliza algumas delas para representar ações adicionais até que cada pose da folha visual enviada seja exportada como frame transparente individual.


## Sprites pesquisados na internet

Foi adicionado um pacote opcional de sprites 2D fan-made do Naruto vindo do projeto público `vikas0304/vscode-anime`. O repositório usa licença MIT e informa no README que a arte de sprites da versão inicial foi gerada com IA.

O jogo tenta carregar e armazenar em cache `idle_1`, `idle_2` e `walk_1..4` em `user://external_sprites/`. Se o aparelho estiver sem internet ou o download falhar, a apresentação de batalha volta automaticamente para os quadros MUGEN já incluídos no projeto.

Outros packs JUS/NZC/MUGEN encontrados durante a pesquisa foram usados somente como referência visual quando não havia uma licença de redistribuição clara.

Consulte `assets/external/CREDITS.md` e `assets/external/naruto_fan_sources.json`.


## Henrique — PNG exato ativo no gameplay

A prancha `assets/characters/file_000000003c88820e930f366203f13d4e.png` deixou de ser apenas referência: ela agora alimenta diretamente as animações do Henrique.

`assets/characters/henrique-board-frames.json` mapeia 86 recortes da própria prancha. Para não exibir os painéis escuros do arquivo original, `character_art.gd` extrai cada pose sob demanda, remove o fundo por flood-fill e mantém a textura resultante em cache. Assim o jogo usa os sprites daquele PNG sem precisar trocar para o antigo `henrique-detailed.png`.

As animações mapeadas incluem idle, caminhada, corrida, pulo, queda, agachar, esquiva/rolamento, deslizar, combo de socos, kunai, shuriken, Katon, clone das sombras, substituição, levar dano, cair, levantar e morte básica. Técnicas futuras continuam cadastradas como aliases temporários até terem quadros próprios.


## Konoha inteira — 30 áreas

Konoha agora funciona como um overworld conectado de RPG portátil antigo. O botão **MAPA** abre uma grade de 30 áreas, e o jogador também pode atravessar as bordas da tela para ir para áreas vizinhas.

Entre os pontos implementados estão Academia, Monumento e Residência do Hokage, Hospital, Estação Jōnin, Arquivos, Atribuição de Missões, Distrito Comercial, Cemitério, Pedra Memorial, Biblioteca, Correio, Ichiraku, Distrito Uchiha, Polícia Militar, Santuário Naka, Rio Naka, loja de dango, Campos de Treino 3 e 44, Aviário, Divisão de Inteligência, Fontes Termais, Orfanato e Portão de Konoha, além de bairros residenciais usados para conectar o mapa.

A posição exata das ruas é uma adaptação de gameplay: as fontes de Naruto fornecem landmarks e relações importantes, mas não uma única planta canônica completa, rua por rua, pronta para ser convertida em tilemap. A pesquisa e a grade usada pelo jogo estão documentadas em `docs/KONOHA_WORLD.md`.

Cada tipo de local recebe elementos visuais próprios e os NPCs de história só aparecem no local correto. Durante a perseguição do Pergaminho dos Selos, o fast travel é bloqueado na parte da floresta para preservar a sequência.


## Episódios 4-5 — Teste de sobrevivência

Depois do EP 3, o jogo segue para o Campo de Treinamento 3. Naruto, Sasuke e Sakura fazem o teste de sobrevivência de Kakashi como Time 7. Henrique participa apenas de uma avaliação paralela para não substituir nenhum integrante do time.

No gameplay, o avanço de Henrique exige ações executadas de verdade: esquiva perto de Kakashi, substituição junto ao alvo e dois acertos de shuriken. Kakashi registra o resultado separado do Time 7. A conclusão preserva a ideia central do teste: Naruto, Sasuke e Sakura precisam deixar de agir apenas individualmente e aprender a funcionar como equipe.

## Episódio 6 — Saída de Konoha

A sequência seguinte leva o grupo à Residência do Hokage. Hiruzen apresenta a primeira missão C, Tazuna entra como cliente e o jogador segue até o Portão de Konoha.

Naruto, Sasuke, Sakura e Kakashi permanecem visíveis durante toda a saída da vila, usando os mesmos sprites top-down do overworld já estabelecido. Henrique acompanha como apoio extra desta adaptação, enquanto o Time 7 continua sendo oficialmente Naruto, Sasuke, Sakura e Kakashi.

Ao atravessar o portão, o mapa de fast travel é bloqueado e o cenário muda para a estrada fora de Konoha. A missão só é registrada quando o jogador realmente percorre o trecho de saída.

A ordem narrativa foi ajustada para seguir a cronologia do anime: o teste de sobrevivência ocupa os episódios 4-5; a missão de Tazuna e a viagem ao País das Ondas começam no episódio 6.


## Pacote gráfico da prancha

A referência visual enviada pelo usuário agora está representada no projeto como um pacote gráfico completo e leve. Foram adicionados Teuchi, Ayame, ANBU e variantes de moradores ao overworld; strips 2D de batalha para Henrique, Naruto, Sasuke, Sakura e Kakashi; biblioteca de VFX de fogo/raio/água/fumaça/impacto/aura; tileset de Konoha; ícones de itens/UI; e nove cenários de batalha.

Os NPCs novos já aparecem em locais coerentes de Konoha, e os VFX básicos já participam de Katon, clone, substituição, impactos e Sharingan. O inventário também passou a registrar pergaminhos, ryō, ramen, dango, água e remédio.

Detalhes em `docs/GRAPHICS_PACK.md`.


## Imagens enviadas no chat — agora usadas de verdade

As duas pranchas mais recentes fornecidas pelo usuário foram recortadas, tiveram o fundo escuro removido nos sprites e foram compactadas em um pacote mobile de 45 recursos.

O runtime agora prioriza:
- overworld de Naruto, Sasuke, Sakura e Kakashi tirado da prancha enviada;
- animações do Naruto tiradas da folha enviada, incluindo idle, andar, correr, pulo, queda, agachar, socos, chute, kunai, shuriken, clone, substituição, Rasengan, dano, cair e levantar;
- mapa de Konoha e cenários de campo de treino/floresta tirados da prancha.

O pack fica em `assets/user_pack/user_assets.json.gz` e é decodificado por `scripts/user_asset_pack.gd`. Os sprites antigos permanecem apenas como fallback. Detalhes: `docs/USER_IMAGE_ASSETS.md`.


### Integração mais recente das imagens exatas

- O Henrique em exploração agora prioriza o overworld recortado da prancha mais recente; as animações de ação continuam usando a folha detalhada já integrada.
- O menu **MAPA** usa a imagem de Konoha recortada da prancha como fundo visual.
- O menu **PROGRESSO** mostra o recorte exato de itens/UI enviado pelo usuário.
- Os cenários de batalha de praça/vila, floresta, ponte e campo de treino priorizam os recortes exatos antes dos cenários procedurais de fallback.
- O teste automático verifica que Henrique, itens/UI e os cenários exatos são realmente decodificados pelo runtime.
