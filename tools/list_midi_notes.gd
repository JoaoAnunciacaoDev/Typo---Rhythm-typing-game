extends SceneTree

## Lista as notas de um ou mais arquivos MIDI usando o leitor ja incluido no projeto.
##
## Uso:
##   godot --headless --path . --script res://tools/list_midi_notes.gd -- Sounds/song.mid
##   godot --headless --path . --script res://tools/list_midi_notes.gd -- --channel 1 Sounds/song.mid


func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	var files: Array[String] = []
	var channel_filter := -1
	var index := 0

	while index < arguments.size():
		if arguments[index] == "--channel":
			if index + 1 >= arguments.size() or not arguments[index + 1].is_valid_int():
				_print_usage()
				quit(2)
				return
			channel_filter = arguments[index + 1].to_int()
			if channel_filter < 0 or channel_filter > 15:
				_print_usage()
				quit(2)
				return
			index += 2
			continue

		files.append(arguments[index])
		index += 1

	if files.is_empty():
		_print_usage()
		quit(2)
		return

	var had_error := false
	for argument in files:
		if not _print_report(argument, channel_filter):
			had_error = true
	quit(1 if had_error else 0)


func _print_report(argument: String, channel_filter: int) -> bool:
	var path := _resolve_path(argument)
	if not FileAccess.file_exists(path):
		printerr("\n%s\n  Erro: arquivo nao encontrado." % argument)
		return false

	var result := SMF.new().read_file(path)
	if result.error != OK or result.data == null:
		printerr("\n%s\n  Erro: nao foi possivel interpretar o MIDI." % argument)
		return false

	# A chave combina canal e numero da nota: canal * 128 + nota.
	var counts := {}
	for track in result.data.tracks:
		for event_chunk in track.events:
			var event = event_chunk.event
			if event.type != SMF.MIDIEventType.note_on or event.velocity <= 0:
				continue
			var key: int = event_chunk.channel_number * 128 + event.note
			counts[key] = counts.get(key, 0) + 1

	var channels: Array[int] = []
	for key: int in counts:
		var channel := key / 128 as int
		if not channels.has(channel):
			channels.append(channel)
	channels.sort()

	if channel_filter >= 0:
		channels = [channel_filter] if channels.has(channel_filter) else []

	print("\n", argument)
	if channels.is_empty():
		var suffix := " no canal %d" % channel_filter if channel_filter >= 0 else ""
		print("  Nenhuma nota encontrada", suffix, ".")
		return true

	for channel in channels:
		_print_channel(channel, counts)
	return true


func _print_channel(channel: int, counts: Dictionary) -> void:
	var note_numbers: Array[int] = []
	var event_count := 0
	for key: int in counts:
		if key / 128 as int != channel:
			continue
		var note_number := key % 128
		note_numbers.append(note_number)
		event_count += counts[key]

	note_numbers.sort()
	print(
		"  Canal %d: %d notas distintas, %d eventos"
		% [channel, note_numbers.size(), event_count]
	)

	var values: Array[String] = []
	for note_number in note_numbers:
		print(
			"    %3d  %-4s  %4d ocorrencias"
			% [note_number, _note_name(note_number), counts[channel * 128 + note_number]]
		)
		values.append(str(note_number))
	print("  midi_notes = PackedInt32Array(%s)" % ", ".join(values))


func _resolve_path(argument: String) -> String:
	var normalized := argument.replace("\\", "/")
	if normalized.begins_with("res://") or normalized.begins_with("user://"):
		return normalized
	if normalized.is_absolute_path():
		return normalized
	return "res://" + normalized.trim_prefix("./")


func _note_name(number: int) -> String:
	var names := ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	return "%s%d" % [names[number % 12], number / 12 as int - 1]


func _print_usage() -> void:
	printerr(
		"Uso: godot --headless --path . --script res://tools/list_midi_notes.gd "
		+ "-- [--channel 0-15] arquivo.mid [outro.mid ...]"
	)
