# Naruto EP -1 — A Noite Antes do Começo

Protótipo de fã em Godot 4.x, desenvolvido na branch **main** a partir do prólogo original `fix/primeiro-mugen-diagnostico`. Henrique Uchiha, 12 anos, treina kunai e Katon, encontra Naruto e Iruka, segue Mizuki à noite e investiga o alarme do Pergaminho dos Selos. A narrativa é uma criação de fã, anterior ao episódio 1.

Abra `project.godot` e execute com F5. Renderizador Compatibility, interface em paisagem de 960×540, sem plugins ou downloads durante o jogo.

## Visual e interface

- Konoha com caminhos sem textura granulada repetitiva, silhueta de montanhas, árvores de tamanhos diferentes, sombras, bancos, canal e ponte.
- Casa com floreira, Academia com faixas, armazém com chaminé e Ichiraku com toldo; as construções mantêm as posições e colisões do protótipo.
- Atlas detalhado original de Henrique e Naruto MUGEN preservados. Iruka e Mizuki usam desenho procedural com proporções próximas, roupa, protetor de testa, detalhes de rosto e movimentos sutis.
- HUD compacto com retrato, missão e barra de chakra ampliada. Controles sobrepostos nas laterais deixam o centro livre.
- Direcional compacto, botões de ação e suporte a dedos independentes para andar e correr juntos. Arrastar para fora do botão libera o comando.
- **CONTROLES** ajusta a opacidade entre 30% e 100%, gravada em `user://interface.cfg`.
- Diálogos com nome, retrato e texto progressivo. O primeiro toque revela a fala; o seguinte avança. A mudança para a floresta acontece no momento do anoitecer durante a conversa.
- Folhas, vagalumes, poeira, anel de acerto, partículas de chakra e Katon com brilho e núcleo luminoso. Cenários estáticos são redesenhados apenas ao mudar de área.

A arte dos personagens usa técnicas distintas: o atlas detalhado e os quadros MUGEN são mantidos, e o cenário/NPCs foram aproximados por proporção e paleta. O jogo continua sendo um protótipo.

## Controles

| Ação | Teclado |
| --- | --- |
| Andar | WASD / setas |
| Correr | R |
| Furtivo | Shift |
| Kunai | J |
| Katon | K |
| Interagir / diálogo | E / Espaço |
| Fechar ajustes | Esc |

Os botões de toque oferecem as mesmas ações. Durante diálogos, apenas AÇÃO permanece visível. Diálogos, ajustes e perda de foco liberam os comandos para evitar movimento preso.

Para chegar à praça das capturas: acerte o alvo três vezes com kunai, mirando a menos de 150 passos, e use Katon perto dele. Katon consome 25 de chakra. Na perseguição, mantenha 70–230 passos de distância de Mizuki e use FURTIVO; complete 12 segundos, investigue a kunai e volte para a casa à esquerda.

## Android e modo leve

Henrique usa o atlas detalhado por padrão também no Android. O Android limita a execução a 30 FPS. O modo simplificado é opcional: `NARUTO_LOW_MEMORY=1` usa o pequeno atlas SVG de Henrique e tem aparência diferente das capturas detalhadas. Os quadros MUGEN são carregados sob demanda.

Toque e desempenho ainda precisam de validação em aparelho Android real. Esta atualização não inclui APK. Para exportar, instale os templates do Godot e configure um preset Android.

## Validação

```sh
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/prologue_smoke.gd
NARUTO_LOW_MEMORY=1 godot --headless --path . --script res://tests/prologue_smoke.gd
godot --headless --path . --script res://tests/interface_smoke.gd
```

O teste do prólogo percorre todas as etapas, consumo de chakra e caminhos gráficos. O teste da interface injeta eventos no sistema de entrada do Godot e verifica texto progressivo, toque simultâneo, liberação ao arrastar, ações, pausa nos ajustes e persistência da opacidade. Também impede o avanço duplo provocado pelo clique de mouse emulado de um toque.

Com display gráfico ou Xvfb, gere capturas reais do treino, praça, diálogo, Katon e perseguição:

```sh
NARUTO_PREVIEW_DIR=/tmp godot --path . --audio-driver Dummy --script res://tests/capture_preview.gd
```

O script percorre as ações do treino antes de capturar a praça. Não usa uma cena visual separada do jogo.

## Recursos e créditos

- `assets/characters/henrique-detailed.png`: atlas RGBA original de 24 poses; recortes em `henrique-frames.json`.
- `assets/mugen/naruto/`: 14 quadros decodificados do pack Real Naruto, preservando tempos e eixos AIR. Origem e créditos em [assets/mugen/CREDITS.md](assets/mugen/CREDITS.md).
- `scripts/background.gd` e `scripts/npc_art.gd`: cenários e NPCs desenhados por código, sem novos recursos externos.
- `tools/build_art.py`: gerador dos SVGs originais, ainda usados em alvos, kunai e modo leve.

Referências originais: [Pixel Shippuden](https://www.narutostorm.com/games/english), [The Fight of Konoha](https://timyfreak.itch.io/the-fight-of-konoha) e [Village Tiles / OpenGameArt](https://opengameart.org/content/simple-nes-like-village-tiles).

Naruto e personagens associados pertencem aos respectivos titulares. Projeto independente de fã. Episódio 1, save de história, música e combate completo ainda não estão implementados.
