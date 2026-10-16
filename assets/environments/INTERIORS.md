# Interiores da Academia e da casa

Fundos novos produzidos pela ferramenta integrada de geração de imagens, usando
`konoha-premium.png` apenas como referência de estilo. Não foram modificados os
sprites enviados pelo usuário. São interiores 2D pintados, sem geometria 3D.

| Arquivo no jogo | Conteúdo |
| --- | --- |
| academy-interior.jpg | Academia com quadro, plataforma do professor, quatro conjuntos de carteiras e corredor central |
| home-interior.jpg | Casa modesta, mesa, cozinha, área de estudo e futon; tarde |
| home-night-interior.jpg | A mesma casa, mesmos móveis e enquadramento; janelas escuras e luz da lanterna |

Os originais gerados têm 1672×941. A versão do jogo usa 960×540, LANCZOS, JPEG
qualidade 94 e sem subamostragem de cor. Apenas o fundo atual fica referenciado
pelo nó do cenário. A versão noturna usa a mesma colisão da diurna.

As colisões foram ajustadas sobre as pinturas prontas: incluem pés das mesas,
carteiras, almofadas, futon e armário. A posição dos atores usa a mesma linha dos
pés do restante do jogo. Os personagens são ordenados por profundidade na sala.

## Prompts finais

**Academia (geração; referência de estilo: Konoha existente):**

Production 2.5D game background, ninja academy classroom interior, 16:9 wide.
Match warm finely painted pixel-anime materials, wood and sunlit gold palette,
with elevated frontal game view. Background only; no characters, UI, text or
watermark. Rear wall and windows at top; chalkboard centered, teacher platform
and low desk at rear center; two short student bench-desk rows at left and two
at right. Keep a broad empty central aisle and side passages, wooden floor and
bottom-center entry. Small bookcase at rear left, sliding paper windows, no
front wall or ceiling. Actors are about 80 game pixels tall. Detailed readable
wood and materials. Furniture must leave the middle aisle open.

**Casa (geração; mesma referência de estilo):**

Production 2.5D game background, Henrique Uchiha's modest childhood house in
Konoha, 16:9. Warm painted pixel-anime wood and plaster, elevated frontal view.
Modest Japanese-inspired living room and sleeping nook. No characters, UI,
lettering or watermark. Shoji on rear wall; futon and pillow at upper right,
writing desk upper left, low dining table at center, kitchen cabinets against
rear wall, cupboard at right edge. Lantern by futon, soft afternoon sunlight,
plain blanket, books and training pouch, no electronics. Continuous floor with
open bottom-center entry and clear routes around both sides of table. No front
wall or ceiling; minimal furniture, actors about 80 pixels tall.

**Casa noturna (edição da casa gerada):**

Create a NIGHT version of this exact house. Preserve camera, framing, furniture
geometry and positions, empty walking floor, table, cushions, futon, writing
desk, kitchen cabinets, plants, doorway and wood outlines. Change only lighting
and view through windows: late night outside, dark blue foliage through shoji,
no sunlight, sunbeams or afternoon floor reflections. Existing lantern beside
the futon casts a warm amber pool with subtle cool moonlight at the windows.
Keep every furniture footprint identical for the same collision map. Preserve
painted pixel-anime style; no people, text, UI or watermark; same aspect ratio.

Os prompts foram acompanhados por coordenadas normalizadas para organizar os
móveis; as colisões finais em `scripts/interiors.gd` correspondem às imagens
aprovadas, em vez de presumir que a geração seguiu cada coordenada literalmente.
