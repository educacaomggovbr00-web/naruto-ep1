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
Arte original em pixel art integrada: quatro personagens com nove quadros cada (frente, costas e lateral), caminhada, vila com casas e telhados, Academia, banca de ramen, canal e ponte, campo de treino, floresta noturna, lanternas, partículas de folhas/vagalumes e efeitos de kunai/Katon. Interface com retrato, barra de chakra e painéis estilizados. Os gráficos são uma interpretação própria simples; a imagem de referência não foi recortada nem usada como atlas. O episódio 1, save, música, combate completo e exportação APK ainda não estão implementados. Importação e execução headless verificadas no Godot 4.3, incluindo teste da sequência completa do prólogo. Desempenho e toque ainda precisam ser conferidos num aparelho Android real. Para Android, instalar os templates de exportação e configurar um preset Android.


## Arte e desempenho

`assets/art/` contém SVGs feitos com retângulos em uma grade de pixels. O Godot importa essas texturas uma vez; o filtro nearest preserva as bordas. O cenário usa comandos CanvasItem retidos e é redesenhado apenas quando a área muda. Efeitos usam quantidades limitadas de partículas desenhadas e nenhum pós-processamento pesado.

Recriar a arte: `python tools/build_art.py` (Python 3, sem dependências).

Verificação: `godot --headless --path . --editor --quit`, depois `godot --headless --path . --script res://tests/prologue_smoke.gd`.

## Referências pesquisadas

- [Pixel Shippuden](https://www.narutostorm.com/games/english): referência de RPG pixel art com exploração da Vila da Folha.
- [The Fight of Konoha](https://timyfreak.itch.io/the-fight-of-konoha): referência de apresentação de Naruto/Sasuke em pixel art.
- [Simple NES-like Village Tiles, surt / OpenGameArt](https://opengameart.org/content/simple-nes-like-village-tiles): pesquisa de tilesets retro.

Esses links foram referências para a primeira versão visual. A atualização detalhada inclui arte gerada do Henrique baseada na imagem enviada pelo usuário e sprites do Naruto convertidos do pack MUGEN Real Naruto. Consulte `assets/mugen/CREDITS.md` para a origem e créditos do pack. Naruto e personagens associados pertencem aos respectivos titulares. Projeto independente de fã.


## Sprites detalhados e MUGEN

- `assets/characters/henrique-detailed.png`: atlas RGBA com 24 poses do Henrique, criado com a ferramenta integrada de geração de imagens a partir da referência enviada. `henrique-frames.json` mapeia os recortes reais da textura, mantendo o PNG original intacto.
- `assets/mugen/naruto/`: 14 sprites originais decodificados do SFF do pack Real Naruto, com quatro animações e os tempos/eixos do AIR preservados. A espera do Naruto usa esses quadros na praça; caminhada, corrida e agachamento ficam disponíveis no manifesto, sem novas cenas para o NPC.
- CORRER na tela ou R: sprint do Henrique. FURTIVO/Shift continua tendo prioridade na perseguição.
- Henrique usa poses próprias de idle, caminhada, corrida, kunai e Katon. Não é um personagem baixado do MUGEN. O jogo permanece em visão de cima; os movimentos laterais usam o atlas detalhado e o idle de costas aparece ao olhar para cima. Ciclos de caminhada vertical exclusivos ainda não estão disponíveis.

Teste atualizado passou no Godot 4.3: importação RGBA, atlas de 24 poses, AIR idle de quatro quadros, seleção de sprint/Katon e sequência completa do prólogo. Não há exportação APK nesta mudança.
