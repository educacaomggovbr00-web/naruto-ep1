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

Esses links são referências de pesquisa, não fornecedores das imagens incluídas. Toda a arte desta atualização foi criada no código do projeto; nenhum sprite ou cenário desses jogos foi copiado. Naruto e personagens associados pertencem aos respectivos titulares. Projeto independente de fã.
