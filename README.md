# Typo

![Ícone do Typo](icon.svg)

**Typo** é um jogo de ritmo e digitação desenvolvido em Godot. Notas geradas a partir de arquivos MIDI descem por seis trilhas, e o jogador precisa pressionar as teclas configuradas no momento correto.

O projeto inclui três músicas/fases:

- Tetris
- Muranga
- Hacker

## Funcionalidades

- Seis trilhas com cores distintas e controles configuráveis.
- Remapeamento por escuta antes de iniciar cada partida.
- Configurações persistentes de teclas, volume e tela cheia.
- Notas e faixas musicais configuradas por recursos `SongData`.
- Posicionamento e julgamento das notas baseados no relógio da música.
- Julgamentos `PERFEITO`, `BOM`, `CERTO`, `MUITO CEDO` e `ERRO`.
- Sistema de pontuação, combo, precisão e classificação de `S` a `D`.
- Tela de resultados com opção de repetir ou selecionar outra música.
- Interface diegética exibida dentro da tela da TV.
- Suporte a músicas com múltiplos players MIDI, como Muranga.

## Como jogar

1. Selecione **Jogar** no menu principal.
2. Escolha uma música.
3. No painel pré-partida, clique em uma trilha para remapeá-la.
4. Pressione a tecla que deseja associar à trilha. Se ela já estiver em uso, os dois bindings são trocados.
5. Selecione **Iniciar**.
6. Pressione a tecla correspondente quando a nota alcançar o centro do botão.

Pressionar uma tecla enquanto a nota ainda está no topo é ignorado. Quando a nota já está se aproximando, mas ainda está fora da janela normal de acerto, a entrada é registrada como `MUITO CEDO`.

## Pontuação

| Julgamento | Pontos-base | Peso na precisão |
| --- | ---: | ---: |
| Perfeito | 1000 | 100% |
| Bom | 700 | 75% |
| Certo | 400 | 50% |
| Erro / Muito cedo | 0 | 0% |

Acertos aumentam o combo; erros e entradas muito antecipadas o zeram. O multiplicador é aplicado aos pontos-base:

| Combo | Multiplicador |
| ---: | ---: |
| 0–9 | 1,00× |
| 10–19 | 1,25× |
| 20–29 | 1,50× |
| 30–39 | 1,75× |
| 40 ou mais | 2,00× |

A classificação final é calculada pela precisão média:

| Precisão | Classificação |
| ---: | :---: |
| 95% ou mais | S |
| 90% ou mais | A |
| 80% ou mais | B |
| 70% ou mais | C |
| Abaixo de 70% | D |

## Executando o projeto

### Requisitos

- Godot 4.7.1 ou uma versão compatível da série 4.x.
- Renderizador OpenGL/GL Compatibility.

### Pelo editor

1. Clone o repositório:

   ```bash
   git clone https://github.com/JoaoAnunciacaoDev/Typo---Rhythm-typing-game.git
   ```

2. Importe o arquivo `project.godot` no Godot.
3. Aguarde a importação dos assets MIDI, SoundFonts, imagens e fontes.
4. Execute o projeto com `F6`/`F5` ou pelo botão **Executar Projeto**.

## Configurações persistentes

As configurações são salvas pelo Godot em:

```text
user://settings.dat
```

O arquivo usa a serialização binária de variantes do Godot e guarda:

- estado de tela cheia;
- volume principal;
- tecla física associada a cada trilha.

Na primeira execução, o jogo inicia em tela cheia e usa `S`, `D`, `F`, `J`, `K` e `L` como bindings padrão.

## Sistema de músicas

Cada fase referencia um recurso `SongData` que declara:

- MIDI usado como chart;
- canal com as notas jogáveis;
- cena visual das notas;
- players MIDI audíveis;
- mapeamento de notas MIDI para trilhas;
- atraso/calibração do áudio.

As regras comuns ficam centralizadas em `gameplayData/default_rules.tres`, incluindo tempo de viagem, janelas de julgamento, tolerância antecipada, pontuação, classificação e estilo das trilhas. As posições de criação e acerto são marcadores `NoteSpawn` e `HitTarget` nas cenas.

As trilhas usam uma base escura, preenchimento colorido e bordas mais fortes para manter o contraste mesmo em fundos movimentados.

As notas usam os eventos MIDI como conteúdo do chart, enquanto um relógio comum controla movimento e julgamento.

## Estrutura do projeto

```text
addons/midi/        Player MIDI e suporte a SoundFonts
Assets/             Imagens, fontes, teclas e elementos visuais
MainMenu/           Menu principal, seleção de músicas e configuração pré-partida
Scenes/             Fases, notas, teclas, CRT e transições
Scripts/            Gameplay, persistência, áudio e scripts de interface
gameplayData/        Regras globais compartilhadas por todas as fases
songData/           Recursos SongData e documentação das músicas
Sounds/             MIDIs, efeitos sonoros e SoundFonts
```
