# Áreas livres e novos moradores

Esta etapa liga a praça ao bairro residencial e à clareira de treino. São áreas
2D conectadas por portas de mapa com transição, sem cidade 3D ou veículos.

## Origem e uso da arte

Os dois PNGs foram recuperados do trabalho iniciado nesta mesma etapa, produzidos
com a ferramenta integrada de geração de imagens. Não substituem os anexos do
usuário. O texto integral dos prompts não estava registrado nos arquivos
recuperados; as descrições abaixo documentam os assets finais, sem atribuí-las
a prompts originais.

| Arquivo | Uso |
| --- | --- |
| `residential-generated.png` | Rua residencial pintada com casas de madeira, telhados, jardins e faixa central livre |
| `../characters/shinobi-neighbors.png` | Atlas transparente de quatro personagens, quatro poses laterais por personagem |
| `../characters/shinobi-neighbors.json` | Regiões, escala e origem dos pés de cada pose, com hash SHA-256 da fonte |

Guardião, ninja médica, aprendiz e artesão usam roupas tradicionais, sandálias,
bandanas ou utensílios da profissão. O atlas mantém 16 poses originais e alpha;
o indexador só calcula recortes e origens. Esquerda usa espelhamento; não há
ciclos frontal ou traseiro. A direção artística aproxima esses moradores do
universo ninja; o cenário continua pintado e os personagens usam contornos de
anime, com diferenças de estilo ainda visíveis.

`python3 tools/index_shinobi_neighbors.py` refaz o manifesto sem redesenhar ou
modificar os pixels do PNG. O campo livre reaproveita `training-premium.png`.

## Jogabilidade e limites

- Na praça, use AÇÃO junto à saída esquerda para o bairro ou à direita para o
  campo. Cada área tem uma saída de retorno sinalizada e mostrada no minimapa.
- Os quatro novos moradores fazem percursos curtos e têm conversas opcionais.
  Quando Henrique chega muito perto, dão um pequeno passo para abrir espaço,
  respeitando os limites da rua. Pausam durante conversas e transições.
- No campo, técnicas podem atingir o alvo sem avançar o treino do prólogo.
- As visitas e a área atual ficam salvas; arquivos antigos voltam à praça.
- A história, a Academia e a casa do Henrique continuam na praça. As casas
  pintadas do bairro não possuem interiores nesta etapa.
- A área transitável acompanha a faixa de rua; jardins e casas ficam fora dos
  limites de caminhada. Não há veículos, combate urbano ou mapa contínuo.
