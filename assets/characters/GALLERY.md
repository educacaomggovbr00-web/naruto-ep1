# Sprites da galeria do ChatGPT

Arquivos originais examinados visualmente em 16/10/2026, todos com 1536×1024.
São folhas ilustradas geradas anteriormente; as legendas não são regras do jogo.
Henrique continua com 12 anos e com as habilidades do prólogo.

| Arquivo | Conteúdo identificado | Uso nesta atualização |
| --- | --- | --- |
| Sprite Sheet Pixel Art de Henrique Uchiha.png | Retratos, trajes, parado, andar, correr, pular, cair, agachar, esquiva, deslizar, socos, kunai, shuriken, Katon, clones, substituição, dano e levantar | Quatro poses da linha ESQUIVA; demais poses ficam como referências |
| Ficha de Sprites Pixelados do Henrique Uchiha.png | Movimentos básicos, ataques, kunai, técnicas elementais, olhos, Susanoo, estados de dano e poses cotidianas | Referência; fundo, texto e efeitos sobrepostos, sem necessidade de substituir a arte atual |
| Sprite Sheet Pixelado do Naruto com Jutsus.png | Parado, movimento, saltos, socos, chutes, armas, dano, selos, clones, fumaça e efeitos azuis | Referência; Naruto MUGEN mantém seus quadros, eixos e tempos originais |

## Integração

`henrique-gallery-dodge.png` contém quatro células RGBA de 96×96. Não inclui
legendas, painéis ou o fundo da folha. O leque/camiseta branca e a calça bege
mantêm a roupa da versão existente. A esquiva substitui temporariamente a pose
de corrida apenas durante os 0,16 s da ação, a 25 quadros/s, sem repetição.

Todos os recortes compartilham origem (48,94), escala 0,96 e a linha dos pés do
desenho existente. O personagem permanece baixo durante a esquiva; não há
normalização da altura a cada quadro. A direção horizontal usa o vetor da
esquiva e permite espelhamento para a esquerda. A cor noturna continua ativa.

Colisões, distância de esquiva, fôlego, diálogo, controles e formato do save
não foram alterados. O modo leve explícito mantém seu atlas SVG. Não foram
introduzidos poderes, saltos ou combate que o prólogo não possui.

## Origem e reprodução

A fonte usada foi `Sprite Sheet Pixel Art de Henrique Uchiha.png`, da galeria
do próprio usuário. SHA256 e os recortes originais estão em `gallery-dodge.json`.
A folha original não precisa acompanhar o jogo; o pequeno atlas pronto é local.

Para reproduzir a extração com a mesma imagem original:

```sh
python3 tools/import_gallery_dodge.py '/caminho/Sprite Sheet Pixel Art de Henrique Uchiha.png'
```

Dependências de desenvolvimento: Pillow, numpy e OpenCV (validado com 5.0.0).
A ferramenta verifica a fonte e protege o cabelo escuro durante a remoção do
fundo. O resultado foi inspecionado visualmente em fundo transparente e no jogo.
Não há dependência de Python/OpenCV durante o gameplay.

## Validação

Godot 4.4.1 Compatibility, Linux: importação, prólogo completo, interface,
movimento/colisões/salvamento, câmera/áudio e `gallery_smoke.gd`. Prólogo e atlas
também verificados com `NARUTO_LOW_MEMORY=1`.

`gallery_smoke.gd` verifica os quatro tempos, direção esquerda/direita,
deslocamento original e cancelamento em diálogo. `capture_gallery.gd` chega à
praça com kunai/Katon, depois congela a simulação para capturar cada quadro
real do renderer do jogo; não é uma montagem. Capturas com OpenGL Mesa/llvmpipe.

Ainda depende de Android físico: desempenho/memória, áudio no aparelho, alcance
dos polegares, toque real simultâneo, suspensão/retomada e persistência após
fechar/reabrir o app. Esta atualização não gera APK.
