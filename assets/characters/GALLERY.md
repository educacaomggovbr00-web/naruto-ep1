# Arte original da galeria e dos anexos

Nenhum personagem desta atualização foi redesenhado ou baixado da internet.
Os PNGs prontos usam os pixels RGB dos arquivos enviados. Nas folhas com fundo
azul, somente a máscara de transparência é produzida; não são repintados rostos,
roupas ou efeitos. A escala de exibição é ajustada no Godot, com filtro nearest.

## Arquivos recebidos

| Arquivos | Conteúdo e uso |
| --- | --- |
| 1000214529.jpg | Ficha geral do Henrique com trajes, movimentos e técnicas; referência |
| 1000214530.jpg | Henrique de camiseta branca; atlas anterior preservado |
| 1000214531.png | Naruto: quatro poses de parado e recorte do retrato ativos em Konoha |
| 1000214532.jpg, 1000214533.jpg, 1000214534.jpg | Três cópias idênticas da ficha geral de personagens, cenários e efeitos; não duplicadas no jogo |
| 1000214535.png | Fonte ativa dos sprites e retratos de Iruka, Mizuki, Sasuke, Sakura, Hiruzen e Teuchi |
| 1000214536.png | Fonte ativa de Henrique com roupa preta/vermelha: 6 idle, 2 andar, 6 correr, 7 esquiva, 3 kunai e 3 Katon, mais o retrato |
| 1000214537.png | Folha dedicada do Naruto, disponível para futuras ações; o NPC atual mantém os recortes transparentes de 1000214531.png |
| 1000214538.png | Chama ativa do Katon; tiles, mapas e itens disponíveis como referência; cenários 2.5D existentes preservados |

Os arquivos 1000214535.png e 1000214536.png são folhas ilustradas RGB, sem alpha
real. Seus nomes internos no upload têm prefixos 07- e 08-. Os hashes SHA256,
recortes e âncoras usados estão nos manifestos `attached-cast.json` e
`attached-henrique.json`. Dois quadros independentes de andar foram selecionados;
outras poses dessa linha se sobrepõem a partes dos vizinhos. Nada foi inventado
para completar os ciclos. O conjunto ativo de Henrique tem 27 quadros.

## Gameplay

- Iruka e Mizuki usam os recortes e retratos da folha enviada. Iruka recebe Henrique na sala de aula; Mizuki mantém a perseguição da floresta. Os grupos rotulados quatro direções não são tratados como ciclos de idle: NPCs mantêm a pose frontal, e Mizuki se desloca pela trajetória existente sem uma marcha inventada.
- Sasuke, Sakura e Iruka aparecem dentro da Academia; Hiruzen e Teuchi ficam na praça durante a etapa de Konoha.
  Aproxime-se e pressione AÇÃO/E para conversas opcionais de fã, sem avançar a
  missão principal. A conversa existente com Naruto mantém o fluxo original.
- Todos os NPCs da praça bloqueiam a posição dos pés. Saves antigos que caiam
  dentro de um novo NPC são deslocados para o chão livre mais próximo.
- Henrique usa sua folha dedicada nas ações já existentes. Idle, andar e correr
  têm 3, 6 e 13 quadros/s; kunai, Katon e esquiva acompanham as durações originais
  de 0,20, 0,50 e 0,16 s. Esquiva e ataques não repetem o ciclo.
- Cada recorte é colocado numa célula fixa, com pés alinhados e escala constante.
  O desenho não é esticado quadro a quadro. A iluminação noturna continua ativa.
- Não foram ativados Sharingan avançado, Susanoo, Rasengan, salto ou outros
  poderes que não façam parte do gameplay existente. Kakashi, Konohamaru, Ebisu,
  Ayame, ANBU e aldeões presentes nas folhas ficam disponíveis como referências.
- História, etapas, controles e versão do arquivo salvo permanecem compatíveis.
  O modo leve explícito mantém o SVG de Henrique.

## Fontes anteriores preservadas

O atlas detalhado de camiseta branca, o atlas anterior de esquiva, os quadros
Naruto MUGEN e seu código AIR continuam no projeto. O visual ativo agora segue
os anexos acima. Henrique continua com 12 anos, independentemente das legendas
das fichas ilustradas.

`naruto-gallery-idle.png` copia quatro recortes RGBA da folha transparente sem
alterar sequer os valores de alpha. O importador e o manifesto registram hashes
dos pixels originais. A folha anexada 1000214531.png tem o mesmo SHA256 da folha
“Sprite Sheet Pixelado do Naruto com Jutsus.png” já encontrada na galeria.

## Reprodução e validação

```sh
python3 tools/import_attached_sheets.py /caminho/para/upload
python3 tools/import_gallery_naruto.py /caminho/para/1000214531.png
godot --headless --path . --script res://tests/attached_cast_smoke.gd
NARUTO_PREVIEW_DIR=/tmp godot --path . --audio-driver Dummy --script res://tests/capture_attached.gd
```

Importadores de desenvolvimento: Pillow, numpy e OpenCV 5.0.0. O jogo não usa
Python, OpenCV ou downloads. Os importadores verificam hashes e copiam RGB dos
originais; somente os fundos das folhas RGB recebem alpha.

Verificado em Godot 4.4.1 Compatibility, Linux: importação, prólogo completo,
conversas opcionais, retratos, posições dos NPCs, colisões, salvamento e retomada,
toque simulado, câmera e controles de áudio. Prólogo e novos atores também
verificados no modo leve. Capturas vêm do jogo executado com OpenGL/Mesa, após
chegar à praça por ações de treino, incluindo a transição para a perseguição.

Android físico ainda precisa validar desempenho, memória, áudio, toque real,
alcance dos polegares, suspensão/retomada e persistência após reabrir o app.

## Efeito de fogo do anexo

`katon-fire.png` recorta uma bola de fogo da folha `10-1000214538.png`. O manifesto
`katon-fire.json` registra SHA256 da fonte, retângulo e limites da máscara.
`tools/import_katon_fire.py` copia os canais RGB e remove o fundo azul somente
pelo alpha, incluindo azul preso entre as pontas da chama. A arte anterior não
foi apagada. O efeito gira com a direção do ataque e acompanha o projétil real.
