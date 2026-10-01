# Naruto EP -1 — A Noite Antes do Começo

Protótipo jogável de fã em Godot 4.x. Abra `project.godot` e execute com F6/F5. Sem plugins ou assets externos. Renderizador Compatibility, interface 960×540 e controles de toque para telas em paisagem.

Henrique Uchiha tem 12 anos. Este prólogo original se passa antes dos acontecimentos do episódio 1: treino de kunai e Katon, encontro com Naruto e Iruka, perseguição furtiva de Mizuki, investigação e alarme do Pergaminho dos Selos. A narrativa é uma criação de fã, não um episódio oficial.

## Controles
- WASD/setas: andar; Shift: andar furtivamente.
- J: kunai (olhe para o alvo a menos de 150 passos).
- K: Katon (consome 25 de chakra, regenerado automaticamente).
- E/Espaço: conversar, investigar e avançar diálogos.
- Botões na tela oferecem as mesmas ações. Toque no diálogo para avançar.

Durante a perseguição, mantenha distância entre 70 e 230 passos e use FURTIVO. Se for detectado, a perseguição reinicia. Complete 12 segundos seguindo Mizuki, investigue a kunai e volte para a casa à esquerda.

## Estado
Arte original em pixel art integrada: quatro personagens com nove quadros cada (frente, costas e lateral), caminhada, vila com casas e telhados, Academia, banca de ramen, canal e ponte, campo de treino, floresta noturna, lanternas, partículas de folhas/vagalumes e efeitos de kunai/Katon. Interface com retrato, barra de chakra e painéis estilizados. Os gráficos são uma interpretação própria simples; a imagem de referência não foi recortada nem usada como atlas. O Episódio 1 agora está implementado como continuação jogável de fã: Academia, roubo do Pergaminho dos Selos, busca na floresta, confronto com Mizuki e conclusão com Naruto reconhecido por Iruka. Save, música, combate completo e exportação APK ainda não estão implementados. Importação e execução headless verificadas no Godot 4.3, incluindo teste da sequência completa do prólogo. Desempenho e toque ainda precisam ser conferidos num aparelho Android real. Para Android, instalar os templates de exportação e configurar um preset Android.


## Arte e desempenho

`assets/art/` contém SVGs feitos com retângulos em uma grade de pixels. O Godot importa essas texturas uma vez; o filtro nearest preserva as bordas. O cenário usa comandos CanvasItem retidos e é redesenhado apenas quando a área muda. Efeitos usam quantidades limitadas de partículas desenhadas e nenhum pós-processamento pesado.

Recriar a arte: `python tools/build_art.py` (Python 3, sem dependências).

Verificação: `godot --headless --path . --editor --quit`, depois `godot --headless --path . --script res://tests/prologue_smoke.gd`.

## Referências pesquisadas

- [Pixel Shippuden](https://www.narutostorm.com/games/english): referência de RPG pixel art com exploração da Vila da Folha.
- [The Fight of Konoha](https://timyfreak.itch.io/the-fight-of-konoha): referência de apresentação de Naruto/Sasuke em pixel art.
- [Simple NES-like Village Tiles, surt / OpenGameArt](https://opengameart.org/content/simple-nes-like-village-tiles): pesquisa de tilesets retro.

Esses links foram referências para a primeira versão visual. A atualização detalhada inclui arte gerada do Henrique baseada na imagem enviada pelo usuário e sprites do Naruto convertidos do pack MUGEN Real Naruto. Consulte `assets/mugen/CREDITS.md` para a origem e créditos do pack. Naruto e personagens associados pertencem aos respectivos titulares. Projeto independente de fã.

### Continuação visual

A praça de Konoha agora ganhou placas da Folha, quadro de missões e marcadores visuais do distrito Uchiha. Naruto deixou de ficar totalmente parado: usa os ciclos MUGEN já importados para alternar idle/caminhada enquanto patrulha a praça. O HUD também passa a mostrar o Sharingan de 1 tomoe depois do primeiro Katon bem-sucedido, sem adicionar pós-processamento pesado.


## Sprites detalhados e MUGEN

- `assets/characters/henrique-detailed.png`: atlas RGBA com 24 poses do Henrique, criado com a ferramenta integrada de geração de imagens a partir da referência enviada. `henrique-frames.json` mapeia os recortes reais da textura, mantendo o PNG original intacto.
- `assets/mugen/naruto/`: 14 sprites originais decodificados do SFF do pack Real Naruto, com quatro animações e os tempos/eixos do AIR preservados. A espera do Naruto usa esses quadros na praça; caminhada, corrida e agachamento ficam disponíveis no manifesto, sem novas cenas para o NPC.
- CORRER na tela ou R: sprint do Henrique. FURTIVO/Shift continua tendo prioridade na perseguição.
- Henrique usa poses próprias de idle, caminhada, corrida, kunai e Katon. Não é um personagem baixado do MUGEN. O jogo permanece em visão de cima; os movimentos laterais usam o atlas detalhado e o idle de costas aparece ao olhar para cima. Ciclos de caminhada vertical exclusivos ainda não estão disponíveis.

Teste atualizado passou no Godot 4.3: importação RGBA, atlas de 24 poses, AIR idle de quatro quadros, seleção de sprint/Katon e sequência completa do prólogo. Não há exportação APK nesta mudança.


## Naruto 2D RPG expansion

A branch `naruto-2d-expansion` adds reusable world/progression foundations: Konoha location registry, classic-era cast registry, mission ranks, XP/level/ryo, inventory and jutsu unlocks. The playable prologue now awards progression for kunai training, Katon, stealth pursuit and the Scroll alarm, then unlocks story era 1 for the Episode 1 continuation. See `docs/NARUTO_2D_ROADMAP.md`.


## Episódio 1 jogável

Depois do EP -1, o jogo entra automaticamente no EP 1. Henrique presencia a reprovação de Naruto na Academia, percebe a manipulação de Mizuki, segue o alarme do Pergaminho dos Selos até a floresta e ajuda Iruka a ganhar tempo. O momento decisivo permanece com Naruto, que usa a técnica aprendida no pergaminho e encerra o confronto. A adaptação é original do projeto e resume/reinterpreta os acontecimentos sem reproduzir o roteiro oficial palavra por palavra.


## Menu de progressão — começo de Naruto Clássico

O HUD agora inclui o botão `PROGRESSO` (tecla `P`). O painel mostra idade, rank, nível, XP, ryo, chakra, avanço da história, missões, inventário e arsenal liberado. Como o jogo ainda está no começo do Episódio 1 de Naruto Clássico, técnicas muito avançadas permanecem explicitamente bloqueadas para fases futuras.

Os ciclos MUGEN já importados do Naruto Kid também ganharam mais uso contextual: idle/caminhada na vila, agachamento na clareira do pergaminho e corrida durante o confronto. Nenhum segundo pack sem licença aberta foi adicionado nesta etapa.
