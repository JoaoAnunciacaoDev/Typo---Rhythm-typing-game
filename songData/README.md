# Como configurar músicas

Cada fase referencia um recurso `SongData` no nó raiz. O recurso concentra o que antes ficava em condicionais de `game.gd` e arquivos `.cfg` separados.

Campos principais:

- `chart_midi_file`: MIDI que emite os eventos usados para criar as notas.
- `note_scene`: aparência/comportamento visual da nota.
- `midi_channel`: canal do chart que contém as notas jogáveis.
- `audio_delay_seconds`: instante em que os players audíveis começam, contado a partir do início do chart.
- `audio_player_paths`: players MIDI audíveis da cena. A fase termina somente quando todos terminarem.
- `midi_notes` e `lane_actions`: arrays paralelos que relacionam cada número MIDI a uma ação de trilha (`s`, `d`, `f`, `j`, `k` ou `l`).

As regras que devem ser iguais em todas as músicas ficam em `gameplayData/default_rules.tres`: tempo de viagem, janelas de julgamento, tolerância antecipada, pontuação, multiplicadores, notas de desempenho e aparência das trilhas.

As posições verticais não são números de `SongData`. Cada cena possui os marcadores `NoteSpawn` e `HitTarget`, que permitem ajustar visualmente onde as notas surgem e onde ocorre o acerto.

Para adicionar uma música:

1. Duplique um dos arquivos `.tres` desta pasta.
2. Configure os campos e o mapeamento nota→trilha.
3. Monte na cena os players audíveis listados em `audio_player_paths`.
4. Adicione `NoteSpawn` e `HitTarget` e atribua os marcadores ao nó raiz.
5. Atribua `song_data` e o recurso compartilhado `gameplay_rules` ao nó raiz.
6. Conecte apenas `MidiQueue.midi_event` a `_on_midi_queue_midi_event`.
