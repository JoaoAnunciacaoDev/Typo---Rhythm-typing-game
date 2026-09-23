# Como configurar músicas

Cada fase herda `Scenes/gameplay_base.tscn` e referencia um recurso `SongData` no nó raiz. A cena-base concentra câmera, trilhas, marcadores, fila MIDI e conexão dos eventos. Cada cena de música mantém somente os players de áudio e elementos visuais específicos.

O recurso `SongData` concentra o que antes ficava em condicionais de `game.gd` e arquivos `.cfg` separados.

Campos principais:

- `chart_midi_file`: MIDI que emite os eventos usados para criar as notas.
- `note_scene`: aparência/comportamento visual da nota.
- `midi_channel`: canal do chart que contém as notas jogáveis.
- `audio_delay_seconds`: instante em que os players audíveis começam, contado a partir do início do chart.
- `audio_player_paths`: players MIDI audíveis da cena. A fase termina somente quando todos terminarem.
- `midi_notes` e `lane_actions`: arrays paralelos que relacionam cada número MIDI a uma ação de trilha (`s`, `d`, `f`, `j`, `k` ou `l`).

As regras que devem ser iguais em todas as músicas ficam em `gameplayData/default_rules.tres`: tempo de viagem, janelas de julgamento, tolerância antecipada, pontuação, multiplicadores, notas de desempenho e aparência das trilhas.

As posições verticais não são números de `SongData`. A cena-base possui os marcadores `NoteSpawn` e `HitTarget`, que permitem ajustar visualmente onde as notas surgem e onde ocorre o acerto para todas as músicas.

Para adicionar uma música:

1. Duplique um dos arquivos `.tres` desta pasta.
2. Configure os campos e o mapeamento nota→trilha.
3. Crie uma cena herdada de `Scenes/gameplay_base.tscn`.
4. Atribua `song_data` no nó raiz.
5. Monte na cena os players audíveis listados em `audio_player_paths` e os visuais exclusivos da música.

## Descobrindo as notas de um MIDI

O utilitário GDScript `tools/list_midi_notes.gd` lista as notas usadas em cada canal e
gera o `PackedInt32Array` pronto para copiar para `midi_notes`:

```powershell
godot --headless --path . --script res://tools/list_midi_notes.gd -- Sounds/tetrisTheme.mid
```

Para inspecionar somente o canal configurado no `SongData`, use `--channel` (os canais
MIDI são numerados de 0 a 15):

```powershell
godot --headless --path . --script res://tools/list_midi_notes.gd -- --channel 1 Sounds/Muranga/murangaMelodiaPrincipal.mid
```

Também é possível informar vários arquivos no mesmo comando. O número de ocorrências
ajuda a decidir como distribuir as notas entre as ações de `lane_actions`.
