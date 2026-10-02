# Assets recortados das imagens enviadas pelo usuário

As duas imagens enviadas no chat foram tratadas como as fontes visuais deste pacote.

## O que foi separado

Da prancha geral foram isolados e preparados:

- overworld de Henrique, Naruto, Sasuke, Sakura e Kakashi;
- faixas de batalha 2D de Henrique, Naruto, Sasuke, Sakura e Kakashi;
- painéis de Iruka, Mizuki, Konohamaru, Ebisu, Teuchi, Ayame, Terceiro Hokage, ANBU e dois moradores;
- mapa visual de Konoha;
- elementos de mapa;
- itens/UI;
- quadro de cenários de batalha;
- recortes individuais de floresta, vila, ponte e campo de treino.

Da folha de animações do Naruto foram isolados:

- idle;
- andar;
- correr;
- pular;
- cair;
- agachar;
- combo de socos;
- chute;
- kunai;
- shuriken;
- clone das sombras;
- substituição;
- Rasengan carregando;
- Rasengan atacando;
- levando dano;
- caindo;
- levantando.

## Fundo e tamanho

Os painéis escuros foram removidos durante a preparação dos sprites de personagem/animação. O resultado foi quantizado para uma paleta pequena e comprimido para não transformar o APK mobile num monstro de memória.

O pacote final contém **45 recursos recortados** e fica em:

`assets/user_pack/user_assets.json.gz`

O arquivo não é só uma imagem decorativa: `scripts/user_asset_pack.gd` reconstrói os PNGs em memória sob demanda e mantém as texturas em cache.

## Uso no jogo

- Naruto, Sasuke, Sakura e Kakashi priorizam os overworlds recortados da imagem enviada.
- As apresentações de batalha do Naruto priorizam a segunda folha enviada e animam os recortes de idle/run e demais ações registradas.
- Konoha, campo de treino e floresta usam os cenários recortados como base visual.
- Todos os demais recortes ficam disponíveis no mesmo pack para UI, batalha e cenas futuras.
- Se algum recurso do pacote falhar, o jogo mantém os sprites anteriores como fallback.

As imagens foram fornecidas pelo usuário para uso neste projeto; este arquivo registra apenas como o jogo as processa e utiliza.
