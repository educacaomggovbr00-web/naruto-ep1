# Pacote gráfico completo da referência

A prancha enviada pelo usuário foi tratada como uma especificação visual do projeto. Em vez de copiar assets aleatórios da internet, o repositório agora contém versões próprias e leves, coerentes com o estilo já construído.

## Personagens

Overworld:
- Henrique
- Naruto clássico
- Sasuke clássico
- Sakura clássica
- Kakashi clássico
- Iruka
- Mizuki
- Konohamaru
- Ebisu
- Teuchi
- Ayame
- Terceiro Hokage
- ANBU
- quatro variantes de moradores/NPCs

Batalha 2D:
- Henrique
- Naruto
- Sasuke
- Sakura
- Kakashi

Arquivos: `assets/art/` e `assets/battle/`.

## Animações do Henrique

O catálogo mantém idle, andar, correr, pular, cair, agachar, esquiva, deslizar, combo, kunai, shuriken, Katon, clone, substituição, dano, cair, levantar e morte.

## Efeitos de jutsu

`scripts/vfx.gd` adiciona famílias de:
- fogo
- raio
- água
- fumaça
- impacto
- aura de chakra
- aura roxa/Susanoo visual

Os efeitos básicos já estão ligados ao Katon, impactos, clone, substituição e Sharingan.

## Tileset e mapas

`assets/tiles/konoha_tiles.svg` fornece o tileset visual leve de Konoha no estilo RPG portátil antigo.

Os mapas representados pelo projeto incluem praça, Academia, Ichiraku, ruas de Konoha, casa do Henrique, campo de treino e floresta, integrados ao overworld de 30 áreas.

## Itens e UI

`assets/ui/items.svg` contém ícones para kunai, shuriken, pílula, pergaminhos, bolsa de ryō, ramen, dango, água e remédio. O inventário do RPG registra esses tipos.

## Cenários de batalha

`scripts/battle_stages.gd` e `assets/stages/battle_stages.svg` registram:
- praça
- floresta
- ponte
- Academia
- Exame Chūnin
- Vale do Fim
- rio
- campo de treino
- interior

## Uso em Konoha

Teuchi e Ayame aparecem no Ichiraku. ANBU aparece em áreas administrativas/Inteligência e no portão. Moradores aparecem na praça, comércio e bairros residenciais. Isso deixa a vila mais viva sem trocar o renderer Compatibility nem adicionar shaders pesados.
