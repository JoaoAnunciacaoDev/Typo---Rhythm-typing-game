class_name SongData
extends Resource

@export_file("*.mid") var chart_midi_file := ""
@export var note_scene: PackedScene
@export_range(0, 15) var midi_channel := 0
@export_range(0.0, 10.0, 0.01) var audio_delay_seconds := 1.85
@export var audio_player_paths: Array[NodePath] = []
@export var midi_notes := PackedInt32Array()
@export var lane_actions := PackedStringArray()


func build_note_map() -> Dictionary:
	var result := {}
	if midi_notes.size() != lane_actions.size():
		push_error("SongData inválido: midi_notes e lane_actions têm tamanhos diferentes.")
		return result

	for index in midi_notes.size():
		result[midi_notes[index]] = StringName(lane_actions[index])
	return result


func is_valid() -> bool:
	return (
		note_scene != null
		and not chart_midi_file.is_empty()
		and not audio_player_paths.is_empty()
		and midi_notes.size() == lane_actions.size()
	)
