# Naruto Clássico EP 1 — O Começo

Fangame 2D em Godot 4.x focado no início de Naruto Clássico. Henrique Uchiha tem 12 anos e o jogo agora abre diretamente no Episódio 1.

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
