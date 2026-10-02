# Henrique detalhado

Criado com a ferramenta integrada de geração de imagens (modo built-in), usando `1000178091.png` enviada pelo usuário como referência visual. O personagem no jogo continua tendo 12 anos; a imagem de referência foi usada para aparência e animações.

Prompt final: atlas PNG transparente de 1536×1024, seis colunas e quatro linhas; Henrique com cabelo preto espetado, camiseta branca com leque Uchiha, calça bege e sandálias; três idle de frente, três de costas, seis passos laterais, seis poses de corrida ninja, três poses de lançamento de kunai e três de Katon; pixel art anime detalhada com contorno escuro; sem texto, painéis ou fundos. A saída não seguiu perfeitamente as linhas de 256 px; `henrique-frames.json` mapeia os limites reais de cada pose, preservando a textura original.

Arquivo de consumo: `henrique-detailed.png`. O Godot usa os recortes do manifesto e espelha as poses laterais para a esquerda. Esse atlas não foi extraído do MUGEN.


## Folha visual adicional

O arquivo `file_000000003c88820e930f366203f13d4e.png` foi enviado pelo proprietário do projeto em 2026-10-01 como folha visual adicional do Henrique Uchiha aos 12 anos. Ele agora é a **fonte ativa das animações do Henrique no gameplay**. `assets/characters/henrique-board-frames.json` contém 86 recortes mapeados diretamente nesse PNG, incluindo idle, andar, correr, pular, cair, agachar, esquiva, deslizar, socos, kunai, shuriken, Katon, clone, substituição, dano, queda, levantar e morte. `character_art.gd` remove o fundo escuro de cada recorte em tempo de execução por flood-fill e guarda cada frame em cache. O texto “IDADE: 16” existente na prancha não altera o cânone do jogo: Henrique continua com 12 anos; apenas os sprites são consumidos.


O blob Git exato da prancha usada pelo runtime é `265335ebcdd1d4a16052f968c4c2fb7a21e86b49`, garantindo que o mapeamento aponta para o mesmo PNG colocado pelo usuário na `main`.
