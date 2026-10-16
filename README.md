# Naruto EP -1 — A Noite Antes do Começo

Protótipo de fã em Godot 4.x, desenvolvido na branch **main** a partir do prólogo original `fix/primeiro-mugen-diagnostico`. Henrique Uchiha, 12 anos, treina kunai e Katon, encontra Naruto e Iruka, segue Mizuki à noite e investiga o alarme do Pergaminho dos Selos. A narrativa é uma criação de fã, anterior ao episódio 1.

Abra `project.godot` e execute com F5. Renderizador Compatibility, interface em paisagem de 960×540, sem plugins ou downloads durante o jogo.

## Visual e interface

- Cenários 2.5D detalhados para Konoha, campo de treino e floresta noturna, com luz, materiais, vegetação e profundidade pintados. Apenas a imagem da área atual fica carregada.
- Casa com floreira, Academia com faixas, armazém com chaminé e Ichiraku com toldo; o layout mantém as posições das construções e a clareira de movimentação do protótipo.
- Atlas detalhado original de Henrique e Naruto MUGEN preservados. Iruka e Mizuki usam desenho procedural com proporções próximas, roupa, protetor de testa, detalhes de rosto e movimentos sutis.
- HUD compacto com retrato, missão e barra de chakra ampliada. Controles sobrepostos nas laterais deixam o centro livre.
- Direcional compacto, botões de ação e suporte a dedos independentes para andar e correr juntos. Arrastar para fora do botão libera o comando.
- **AJUSTES** ajusta a opacidade entre 30% e 100%, gravada em `user://interface.cfg`.
- Diálogos com nome, retrato e texto progressivo. O primeiro toque revela a fala; o seguinte avança. A mudança para a floresta acontece no momento do anoitecer durante a conversa.
- Folhas, vagalumes, poeira, anel de acerto, partículas de chakra e Katon com brilho e núcleo luminoso. Cenários estáticos são redesenhados apenas ao mudar de área.

A arte dos personagens usa técnicas distintas: o atlas detalhado e os quadros MUGEN são mantidos, e o cenário/NPCs foram aproximados por proporção e paleta. O jogo continua sendo um protótipo.

## Controles

| Ação | Teclado |
| --- | --- |
| Andar | WASD / setas |
| Correr | R |
| Furtivo | Shift |
| Esquiva | Q |
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
- `assets/environments/`: pinturas geradas para o projeto, com procedência em [CREDITS.md](assets/environments/CREDITS.md). `scripts/npc_art.gd` desenha os NPCs por código.
- `tools/build_art.py`: gerador dos SVGs originais, ainda usados em alvos, kunai e modo leve.

Referências originais: [Pixel Shippuden](https://www.narutostorm.com/games/english), [The Fight of Konoha](https://timyfreak.itch.io/the-fight-of-konoha) e [Village Tiles / OpenGameArt](https://opengameart.org/content/simple-nes-like-village-tiles).

Naruto e personagens associados pertencem aos respectivos titulares. Projeto independente de fã. Episódio 1, trilha musical e combate completo ainda não estão implementados.

## Apresentação cinematográfica

A câmera acompanha o jogador suavemente e reage a kunai e Katon. O HUD e os controles usam uma camada separada e permanecem estáveis. Um shader simples aplica contraste, cor de dia/noite e vinheta ao mundo; os sprites e os cenários continuam sendo 2D, sem geometria 3D ou ray tracing.

Há sons originais sintetizados de kunai, impacto e fogo, além de um ambiente discreto de vento e pássaros. **AJUSTES** permite desligar áudio e movimento da câmera; as preferências são gravadas no mesmo arquivo da opacidade. Os efeitos não dependem de arquivos baixados durante o jogo.

Verificação adicional:

```sh
godot --headless --path . --script res://tests/cinematic_smoke.gd
```

A referência a consoles descreve a direção de apresentação. O protótipo não é uma versão de PS5 nem alcança a produção de um jogo AAA. Desempenho e saída de áudio no Android continuam pendentes de teste em aparelho real.

## Esquiva e progresso salvo

**Q / ESQUIVA** avança na direção em que Henrique está olhando. Cada esquiva usa 30 de fôlego, recuperado automaticamente; a barra dourada abaixo do chakra mostra a reserva. Ela respeita as colisões, inclusive em quadros mais lentos. Movimento diagonal desliza junto às paredes, e a água só pode ser atravessada pela ponte. Naruto e Iruka também bloqueiam passagem.

Ataques agora avisam quando falta chakra, a técnica está recarregando ou o alvo está longe/fora da mira. O personagem para a animação de caminhada quando fica bloqueado.

O progresso fica em `user://prologue_save.json`. Há salvamento ao avançar falas, a cada oito segundos durante exploração e ao sair do foco/fechar a janela. **AJUSTES → SALVAR / CARREGAR** oferece controle manual. Ao abrir com um arquivo válido, **CONTINUAR** retoma a etapa, posição, chakra, fôlego e a fala atual; **NOVO JOGO** substitui esse progresso pelo início do prólogo.

O arquivo usa versão e validação de campos. A escrita primeiro cria um arquivo temporário e depois substitui o anterior. Um arquivo inválido não é aplicado ao jogo; a tela inicial avisa e oferece um novo começo. O progresso é local ao aparelho e não tem sincronização em nuvem.

```sh
godot --headless --path . --script res://tests/gameplay_smoke.gd
NARUTO_PREVIEW_DIR=/tmp godot --path . --audio-driver Dummy --script res://tests/capture_gameplay.gd
```

Esses testes usam arquivos próprios e não alteram o progresso normal do jogador. A captura mostra esquiva, ajustes e a tela de continuar.

## Conforto dos controles e coerência do cenário

- Direcional em cruz com alvos de 58×58 e margem na borda; ações de 78×78, separadas em duas colunas. Durante diálogos, só AÇÃO permanece visível.
- CORRER e FURTIVO no toque funcionam por alternância: toque para ativar, toque novamente para desligar. Um modo desliga o outro. Teclado mantém R e Shift pressionados como antes.
- O dedo pode deslizar entre setas, atravessar o espaço entre botões e voltar ao direcional sem precisar levantar. Sair do direcional interrompe o movimento.
- `scripts/world_layout.gd` centraliza chão transitável, ponte, água, bancos e posições dos NPCs. O personagem pode cruzar a ponte inteira até a margem sul, sem caminhar pelos telhados ou pela vegetação pintada.
- A trajetória de Mizuki permanece na clareira; posições de saves antigos são ajustadas aos limites atuais. A escala de Henrique foi aproximada da dos NPCs e das portas.

A ergonomia foi verificada com eventos de toque no Godot. Ainda é necessário conferir o alcance dos polegares em um Android real.
