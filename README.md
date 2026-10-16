# Naruto EP -1 — A Noite Antes do Começo

Protótipo de fã em Godot 4.x, desenvolvido na branch **main** a partir do prólogo original `fix/primeiro-mugen-diagnostico`. Henrique Uchiha, 12 anos, treina kunai e Katon, encontra Naruto e Iruka, segue Mizuki à noite e investiga o alarme do Pergaminho dos Selos. A narrativa é uma criação de fã, anterior ao episódio 1.

Abra `project.godot` e execute com F5. Renderizador Compatibility, interface em paisagem de 960×540, sem plugins ou downloads durante o jogo.

## Visual e interface

- Cenários 2.5D detalhados para Konoha, campo de treino e floresta noturna, com luz, materiais, vegetação e profundidade pintados. Apenas a imagem da área atual fica carregada.
- Casa com floreira, Academia com faixas, armazém com chaminé e Ichiraku com toldo; o layout mantém as posições das construções e a clareira de movimentação do protótipo.
- Henrique usa a folha preta/vermelha enviada, com 27 quadros e retrato. Naruto usa quatro recortes originais da galeria. Iruka e Mizuki usam os sprites e retratos enviados; Sasuke, Sakura e Iruka estão na Academia; Hiruzen e Teuchi ficam na praça. Todos têm conversas opcionais. Atlas anteriores e código MUGEN preservados.
- HUD compacto com retrato, missão e barra de chakra ampliada. Controles sobrepostos nas laterais deixam o centro livre.
- Direcional compacto, botões de ação e suporte a dedos independentes para andar e correr juntos. Arrastar para fora do botão libera o comando.
- **AJUSTES** ajusta a opacidade entre 30% e 100%, gravada em `user://interface.cfg`.
- Diálogos com nome, retrato e texto progressivo. O primeiro toque revela a fala; o seguinte avança. A mudança para a floresta acontece no momento do anoitecer durante a conversa.
- Folhas, vagalumes, poeira, anel de acerto, partículas de chakra e Katon recortado do efeito enviado, com brilho discreto. Cenários estáticos são redesenhados apenas ao mudar de área.

Os personagens ativos usam recortes dos arquivos enviados, com proporções e pés ajustados ao cenário. As fontes anteriores foram preservadas. O jogo continua sendo um protótipo.

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
| Diário de missões | M |
| Fechar diário / ajustes | Esc |

Os botões de toque oferecem as mesmas ações. Durante diálogos, apenas AÇÃO permanece visível. Diálogos, ajustes e perda de foco liberam os comandos para evitar movimento preso.

Para chegar à praça das capturas: acerte o alvo três vezes com kunai, olhando na direção dele e dentro do alcance da kunai (280 passos), e acerte-o com Katon (220 passos). Katon consome 25 de chakra. Na perseguição, mantenha 70–230 passos de distância de Mizuki e use FURTIVO; complete 12 segundos, investigue a kunai, entre na casa à esquerda e use AÇÃO perto da cama.

## Android e modo leve

Henrique usa o novo atlas dos anexos por padrão também no Android. O Android limita a execução a 30 FPS. O modo simplificado é opcional: `NARUTO_LOW_MEMORY=1` usa o pequeno atlas SVG de Henrique e tem aparência diferente das capturas detalhadas. Os quadros MUGEN são carregados sob demanda.

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

- Integração da galeria: 27 quadros de Henrique, quatro poses de Naruto e seis personagens com sprites e retratos dos anexos. Sem redesenho; arte anterior preservada. Inventário, origem e validação em [assets/characters/GALLERY.md](assets/characters/GALLERY.md).

- `assets/characters/henrique-detailed.png`: atlas RGBA original de 24 poses; recortes em `henrique-frames.json`.
- `assets/mugen/naruto/`: 14 quadros decodificados do pack Real Naruto, preservando tempos e eixos AIR. Origem e créditos em [assets/mugen/CREDITS.md](assets/mugen/CREDITS.md).
- `assets/environments/`: pinturas geradas para o projeto, com procedência em [CREDITS.md](assets/environments/CREDITS.md). `scripts/npc_art.gd` preserva o desenho anterior; os NPCs ativos usam `assets/characters/attached-cast.png`.
- `tools/build_art.py`: gerador dos SVGs originais, ainda usados em alvos, kunai e modo leve.

Validação dos sprites e capturas reais dos quatro quadros:

```sh
godot --headless --path . --script res://tests/gallery_smoke.gd
NARUTO_PREVIEW_DIR=/tmp godot --path . --audio-driver Dummy --script res://tests/capture_gallery.gd
```

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

## Personagens dos anexos

Use E/AÇÃO perto de Hiruzen e Teuchi na praça, ou de Iruka, Sasuke e Sakura dentro da Academia, para conversar. A missão com Naruto e a perseguição de Mizuki mantêm a progressão original. Posições antigas dentro de um novo NPC são ajustadas ao carregar.

```sh
godot --headless --path . --script res://tests/attached_cast_smoke.gd
NARUTO_PREVIEW_DIR=/tmp godot --path . --audio-driver Dummy --script res://tests/capture_attached.gd
```

## Academia e casa exploráveis

Depois do treino, aproxime-se das portas sinalizadas **ACADEMIA** e **SUA CASA** e use E/AÇÃO. A saída dos interiores fica no centro da parte de baixo. As transições têm fade e liberam entradas de toque para evitar comandos presos.

- **Academia:** sala de aula com corredor central, carteiras sólidas, Iruka, Sasuke e Sakura. Converse com Iruka e leia o quadro. As conversas são de fã e não iniciam o exame do episódio 1.
- **Casa:** mesa, cozinha, cadernos e cama interativos. De dia, Henrique pode explorar; depois da perseguição noturna, usar a cama conclui o prólogo. Há arte diurna e noturna com o mesmo layout.
- **Ambiente:** os NPCs foram distribuídos entre sala de aula e praça. Ações de combate ficam ocultas nos interiores; o som externo fica mais baixo. Mobília e atores bloqueiam passagem sem fechar o corredor de circulação.
- **Progresso:** o save guarda interior, posição de retorno e visitas/revisão. Arquivos antigos da versão 1 continuam válidos e retomam do lado de fora. Entrar e sair não reinicia o treino, chakra ou etapa da história.

```sh
godot --headless --path . --script res://tests/interiors_smoke.gd
NARUTO_LOW_MEMORY=1 godot --headless --path . --script res://tests/interiors_smoke.gd
NARUTO_PREVIEW_DIR=/tmp godot --path . --audio-driver Dummy --script res://tests/capture_interiors.gd
```

Verificado em Godot 4.4.1: portas, bloqueio de entrada durante transição, circulação entre os móveis, diálogos/objetos, salvamento dentro das duas salas, compatibilidade dos saves antigos e conclusão pela cama. Capturas são do próprio jogo após as ações do treino. Android físico ainda precisa validar ergonomia, memória, áudio e retomada do app.

Origem e prompts dos novos fundos: [assets/environments/INTERIORS.md](assets/environments/INTERIORS.md).

## Precisão das técnicas e resposta do movimento

Kunai e Katon agora têm preparação, trajetória e contato real com o alvo; apertar o botão não conta um acerto. A kunai prepara em 0,06 s, viaja a 640 passos/s e alcança 280 passos. O Katon prepara em 0,18 s, viaja a 420 passos/s e alcança 220 passos. A colisão verifica o segmento percorrido, incluindo quadros lentos. O raio de contato inclui o tamanho do alvo e do projétil.

- Uma pequena assistência corrige a direção quando Henrique já está olhando quase para o alvo (produto escalar ≥ 0,96). Olhar para o lado oposto ou lançar de longe continua resultando em erro.
- Os três contatos de kunai liberam a lição de Katon. O Katon deve atingir o alvo para concluir o treino. Chakra, diálogos e restante da história mantêm o fluxo anterior.
- O alvo reage com tremor, cor, faíscas e som no contato. A chama de `katon-fire.png` usa RGB original da folha `10-1000214538.png`; somente a transparência foi tratada. Fonte e recorte estão em `katon-fire.json`.
- Os botões mostram a recarga compartilhada de 0,4 s para kunai ou 1 s para Katon. Um toque nos últimos 0,12 s fica reservado para executar uma única técnica ao terminar a recarga. Diálogos, ajustes, perda de foco, entrada em cômodos e carregamento descartam comandos pendentes.
- O movimento acelera brevemente ao partir ou trocar de direção e para imediatamente ao soltar o direcional. Passos discretos acompanham caminhada, corrida e furtividade; ficam mais baixos nos interiores, sem poeira dentro de casa ou da Academia.
- A atualização melhora o treino. Os NPCs continuam sendo personagens de conversa; combate contra inimigos e episódio 1 permanecem pendentes.

```sh
python3 tools/import_katon_fire.py /caminho/para/10-1000214538.png
godot --headless --path . --script res://tests/combat_smoke.gd
NARUTO_LOW_MEMORY=1 godot --headless --path . --script res://tests/combat_smoke.gd
NARUTO_PREVIEW_DIR=/tmp godot --path . --audio-driver Dummy --script res://tests/capture_combat.gd
```

O teste cobre preparação, voo, alcance, erro de mira, assistência, contato em quadro lento, repetição de toque, cancelamento, gasto de chakra, progressão e parada sem deslizamento. As capturas registram o jogo executando com renderizador Compatibility, sem uma cena visual separada. Toque físico, desempenho, áudio e retomada no Android ainda precisam de aparelho real.

## Diário shinobi

Use **DIÁRIO · M** no topo da tela ou a tecla **M** para consultar o objetivo e uma dica para o local atual. **VOLTAR**, **M** ou **Esc** fecham o painel. O mundo fica pausado: não há movimento, regeneração, recarga ou avanço da perseguição enquanto você lê. Ao abrir, a interface libera os dedos e descarta ataques pendentes; os controles de exploração ficam ocultos.

O caminho do prólogo mostra os seis objetivos, com futuras etapas ainda ocultas. Cinco anotações opcionais acompanham as visitas à Academia e à casa, a conversa com Iruka, a revisão no quadro e os cadernos de Henrique. Essas descobertas não bloqueiam a história. O diário não abre durante falas, carregamento inicial, ajustes ou transições entre ambientes.

As dicas distinguem exterior, sala de aula e casa. Elas explicam como voltar à praça, encontrar Naruto ou contornar a mesa para chegar à cama. Abrir o diário não altera a etapa. A nova anotação dos cadernos usa o campo opcional `visited.notes`; arquivos antigos da versão 1 continuam carregando e recebem `false` nesse campo.

```sh
godot --headless --path . --script res://tests/journal_smoke.gd
NARUTO_LOW_MEMORY=1 godot --headless --path . --script res://tests/journal_smoke.gd
NARUTO_PREVIEW_DIR=/tmp godot --path . --audio-driver Dummy --script res://tests/capture_journal.gd
```

O teste injeta teclas e toques, verifica pausa da perseguição, cancelamento de comandos, bloqueio durante diálogos, revelação gradual das etapas, dicas por cômodo e salvamento das descobertas com compatibilidade antiga. As capturas são do jogo em execução, após completar o treino e visitar os dois interiores. Toque físico, legibilidade e ergonomia em Android real permanecem pendentes.
