# Konoha inteira — overworld RPG

O projeto agora representa Konohagakure como um overworld 2D conectado de 30 áreas, com navegação por bordas de tela e um mapa de viagem.

## Pesquisa usada

A lista de pontos foi montada a partir de referências públicas de Naruto:

- Narutopedia — Konohagakure: lista Academia, Campo de Treinamento 44, Monumento Hokage, Residência do Hokage, Arquivos, Aviário, Cemitério, Hospital, Fontes Termais, Inteligência, Polícia Militar e vários outros pontos.
- Narutopedia — Academia: descreve a Academia na base da Montanha Hokage.
- Narutopedia — Residência do Hokage: descreve a residência próxima da Academia e do Monumento Hokage.
- Narutopedia — Santuário Naka: localiza o santuário no Distrito Uchiha, próximo ao Rio Naka.
- Naruto Official — Konoha Land: confirma como ícones reconhecíveis de Konoha o Portão, Monumento/Escritório do Hokage, área de treinamento do Time Kakashi, Ichiraku e loja de dango.

Não existe uma única planta canônica, completa e rua-por-rua de Konoha para converter diretamente em um tilemap. Por isso, os **nomes dos landmarks são baseados nas referências**, enquanto a posição deles na grade é uma adaptação de gameplay para criar um mundo navegável no estilo de RPG portátil antigo.

## Grade jogável

| Linha | Oeste | | Centro | | Leste |
|---|---|---|---|---|---|
| Norte | Monumento Hokage | Residência do Hokage | Academia | Estação Jōnin | Arquivos |
| Norte-centro | Hospital | Residencial Norte | Praça Central | Missões | Distrito Comercial |
| Centro | Cemitério | Pedra Memorial | Biblioteca | Correio | Ichiraku |
| Sul-centro | Distrito Uchiha | Polícia Militar | Santuário Naka | Rio Naka | Loja de Dango |
| Sul | Treino 3 | Treino 44 | Aviário | Inteligência | Fontes Termais |
| Extremo sul | Residencial Oeste | Residencial Sul | Residencial Leste | Orfanato | Portão de Konoha |

## Áreas canônicas e áreas de ligação

Os pontos como Academia, Hospital, Ichiraku, Distrito Uchiha, Santuário Naka, Rio Naka, Cemitério, Pedra Memorial, Campos de Treino, Polícia Militar, Fontes Termais e Portão são landmarks derivados das referências da série.

Os nomes **Bairro Residencial Norte/Oeste/Sul/Leste** e **Praça Central** são áreas de ligação criadas especificamente para o jogo. Elas existem para impedir que Konoha vire apenas uma lista de teleporte e para dar continuidade espacial entre os landmarks.

## Navegação

- O botão **MAPA** abre as 30 áreas.
- Tocar em uma área move o jogador para ela.
- Também é possível atravessar a borda norte/sul/leste/oeste de uma tela para entrar no vizinho correspondente.
- Durante o incidente do Pergaminho dos Selos (EP 1), fast travel é bloqueado quando a perseguição entra na floresta.
- NPCs de história só aparecem na área onde aquela cena acontece.

## Identidade visual

Cada tipo de área recebe elementos próprios sem aumentar muito o peso no Android:

- Hospital: fachada médica.
- Residência/Hokage: arquitetura administrativa e símbolo do Fogo.
- Monumento: faces estilizadas na montanha.
- Uchiha/Polícia: leques e postes do clã.
- Santuário Naka: torii.
- Rio Naka: água e ponte.
- Treinos: alvos.
- Cemitério/Memorial: lápides.
- Fontes Termais: piscina e vapor.
- Portão: entrada monumental.
- Comércio/Ichiraku/Dango: barracas.
- Biblioteca/Arquivos: estantes/fachadas.
- Residenciais: casas.

A implementação continua usando desenho 2D simples e renderer Compatibility para permanecer leve em Android.
