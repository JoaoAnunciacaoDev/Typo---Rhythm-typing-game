extends Node2D

@export var song_data: SongData
@export var gameplay_rules: GameplayRules
@export var midi_queue: MidiPlayer
@export var camera: Camera2D
@export var notes: Node2D
@export var note_spawn: Marker2D
@export var hit_target: Marker2D

var note_to_action: Dictionary = {}
var lanes: Dictionary = {}
var music_players: Array[MidiPlayer] = []
var finished_players: Dictionary = {}
var clock_started_usec := 0
var music_started := false
var ending := false

var score := 0
var combo := 0
var max_combo := 0
var judged_notes := 0
var accuracy_points := 0.0
var judgement_generation := 0
var judgement_counts := {
	&"perfect": 0,
	&"good": 0,
	&"ok": 0,
	&"miss": 0,
	&"early": 0,
}

var score_label: Label
var combo_label: Label
var accuracy_label: Label
var rank_label: Label
var judgement_label: Label
var result_screen: Control
var result_summary_label: Label


func _ready() -> void:
	Transition.next_scene = "res://MainMenu/MainMenu.tscn"
	Transition.play_fade_out()

	if (
		song_data == null
		or not song_data.is_valid()
		or gameplay_rules == null
		or note_spawn == null
		or hit_target == null
	):
		push_error("A cena precisa de SongData, GameplayRules, NoteSpawn e HitTarget válidos.")
		set_physics_process(false)
		return

	note_to_action = song_data.build_note_map()
	_build_lanes()
	_resolve_music_players()
	_create_lane_guides()
	_create_hud()
	_create_results_screen()

	midi_queue.file = song_data.chart_midi_file
	clock_started_usec = Time.get_ticks_usec()
	midi_queue.play()


func _physics_process(_delta: float) -> void:
	if ending:
		return

	if Input.is_action_just_pressed("esc"):
		ending = true
		Transition.next_scene = get_tree().current_scene.scene_file_path
		Transition.play_fade_in()
		return

	var song_time := get_song_time()
	if not music_started and song_time >= song_data.audio_delay_seconds:
		_start_music()

	for action: StringName in lanes:
		var lane: Dictionary = lanes[action]
		var queue: Array = lane["queue"]
		for active_note in queue:
			active_note.update_song_time(song_time)

		while not queue.is_empty() and queue.front().is_late(song_time, gameplay_rules.miss_window):
			var missed_note = queue.pop_front()
			missed_note.miss()
			_register_judgement(action, &"miss")

		if Input.is_action_just_pressed(action):
			_judge_lane(action, song_time)


func get_song_time() -> float:
	if clock_started_usec == 0:
		return 0.0
	return float(Time.get_ticks_usec() - clock_started_usec) / 1_000_000.0


func _build_lanes() -> void:
	for action in Settings.INPUT_ACTIONS:
		var lane_node := get_node_or_null("buttons/%s_Key" % String(action))
		if lane_node == null:
			continue
		lanes[action] = {
			"node": lane_node,
			"queue": [],
		}


func _resolve_music_players() -> void:
	for player_path in song_data.audio_player_paths:
		var player := get_node_or_null(player_path) as MidiPlayer
		if player == null:
			push_error("Player MIDI não encontrado: %s" % player_path)
			continue
		music_players.append(player)
		var finished_callback := _on_music_player_finished.bind(player)
		if not player.finished.is_connected(finished_callback):
			player.finished.connect(finished_callback)


func _start_music() -> void:
	music_started = true
	for player in music_players:
		player.play()


func _judge_lane(action: StringName, song_time: float) -> void:
	var lane: Dictionary = lanes[action]
	var queue: Array = lane["queue"]
	if queue.is_empty():
		return

	var active_note = queue.front()
	var judgement: StringName = active_note.judgement_at(
		song_time,
		gameplay_rules.perfect_window,
		gameplay_rules.good_window,
		gameplay_rules.miss_window,
	)
	if judgement.is_empty():
		var time_until_note: float = active_note.expected_time - song_time
		if time_until_note > gameplay_rules.miss_window and time_until_note <= gameplay_rules.early_input_window:
			queue.pop_front()
			active_note.miss()
			_register_judgement(action, &"early")
		return

	queue.pop_front()
	active_note.hit()
	_register_judgement(action, judgement)


func _register_judgement(action: StringName, judgement: StringName) -> void:
	judged_notes += 1
	accuracy_points += gameplay_rules.accuracy_for(judgement)
	judgement_counts[judgement] = int(judgement_counts.get(judgement, 0)) + 1

	if judgement == &"miss" or judgement == &"early":
		combo = 0
		TocadorSom.play_sfx("erro")
		camera.shake()
	else:
		combo += 1
		max_combo = maxi(max_combo, combo)
		var multiplier := gameplay_rules.multiplier_for_combo(combo)
		score += int(float(gameplay_rules.score_for(judgement)) * multiplier)

	_show_lane_message(action, judgement)
	_update_hud(judgement)


func _show_lane_message(action: StringName, judgement: StringName) -> void:
	var lane: Dictionary = lanes[action]
	var lane_node: Node = lane["node"]
	var message := lane_node.get("Message") as Label
	if message == null:
		return
	message.text = _judgement_text(judgement)
	message.visible = true
	var tween := create_tween()
	tween.tween_interval(0.45)
	tween.tween_callback(message.hide)


func _update_hud(judgement: StringName = &"") -> void:
	var accuracy := 100.0 if judged_notes == 0 else (accuracy_points / judged_notes) * 100.0
	score_label.text = "PONTOS  %08d" % score
	combo_label.text = "COMBO  %d" % combo
	accuracy_label.text = "PRECISÃO  %.1f%%" % accuracy
	rank_label.text = "NOTA  %s" % gameplay_rules.rank_for_accuracy(accuracy)

	if not judgement.is_empty():
		judgement_generation += 1
		var generation := judgement_generation
		judgement_label.text = _judgement_text(judgement)
		judgement_label.modulate = _judgement_color(judgement)
		_clear_judgement_later(generation)


func _clear_judgement_later(generation: int) -> void:
	await get_tree().create_timer(0.55).timeout
	if generation == judgement_generation:
		judgement_label.text = ""


func _judgement_text(judgement: StringName) -> String:
	match judgement:
		&"perfect": return "PERFEITO"
		&"good": return "BOM"
		&"ok": return "CERTO"
		&"early": return "MUITO CEDO"
		_: return "ERRO"


func _judgement_color(judgement: StringName) -> Color:
	match judgement:
		&"perfect": return Color("7dff9b")
		&"good": return Color("f4e66a")
		&"ok": return Color("ef9f55")
		_: return Color("ff5c67")


func _create_lane_guides() -> void:
	var guides := Node2D.new()
	guides.name = "LaneGuides"
	guides.z_index = -1
	add_child(guides)
	var buttons := get_node("buttons")
	move_child(guides, buttons.get_index())

	for action in Settings.INPUT_ACTIONS:
		if not lanes.has(action):
			continue
		var lane: Dictionary = lanes[action]
		var lane_node: Node2D = lane["node"]
		var lane_x := lane_node.global_position.x
		var start := Vector2(lane_x, note_spawn.global_position.y)
		var finish := Vector2(lane_x, hit_target.global_position.y)
		var lane_color := gameplay_rules.lane_color(action)

		_add_lane_line(
			guides,
			start,
			finish,
			gameplay_rules.lane_width + 16.0,
			Color(0.0, 0.0, 0.0, gameplay_rules.lane_underlay_alpha),
		)
		var fill_color := lane_color
		fill_color.a = gameplay_rules.lane_fill_alpha
		_add_lane_line(guides, start, finish, gameplay_rules.lane_width, fill_color)

		var border_color := lane_color
		border_color.a = gameplay_rules.lane_border_alpha
		var half_width := gameplay_rules.lane_width * 0.5
		_add_lane_line(guides, start + Vector2.LEFT * half_width, finish + Vector2.LEFT * half_width, 3.0, border_color)
		_add_lane_line(guides, start + Vector2.RIGHT * half_width, finish + Vector2.RIGHT * half_width, 3.0, border_color)


func _add_lane_line(parent: Node2D, start: Vector2, finish: Vector2, width: float, color: Color) -> void:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.points = PackedVector2Array([start, finish])
	parent.add_child(line)


func _create_hud() -> void:
	var hud := Control.new()
	hud.name = "GameplayHUD"
	hud.z_index = -1
	hud.set_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(hud)

	var left_box := _make_hud_panel(hud, Vector2(185, 105), Vector2(400, 112))
	accuracy_label = _make_panel_label(left_box, 23, HORIZONTAL_ALIGNMENT_LEFT)
	rank_label = _make_panel_label(left_box, 29, HORIZONTAL_ALIGNMENT_LEFT)

	var right_box := _make_hud_panel(hud, Vector2(1075, 105), Vector2(400, 112))
	score_label = _make_panel_label(right_box, 27, HORIZONTAL_ALIGNMENT_RIGHT)
	combo_label = _make_panel_label(right_box, 24, HORIZONTAL_ALIGNMENT_RIGHT)

	var judgement_box := _make_hud_panel(hud, Vector2(665, 155), Vector2(350, 72))
	judgement_label = _make_panel_label(judgement_box, 36, HORIZONTAL_ALIGNMENT_CENTER)
	_update_hud()


func _make_hud_panel(parent: Control, position: Vector2, size: Vector2) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = size
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.01, 0.025, 0.015, 0.82), 2))
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)
	return box


func _make_panel_label(parent: Control, font_size: int, alignment: HorizontalAlignment) -> Label:
	var result := Label.new()
	result.custom_minimum_size.y = float(font_size + 12)
	result.horizontal_alignment = alignment
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", Color(0.55, 0.9, 0.55))
	result.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	result.add_theme_constant_override("shadow_offset_x", 2)
	result.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(result)
	return result


func _panel_style(background: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = Color(0.36, 0.7, 0.38, 0.9)
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(7)
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


func _create_results_screen() -> void:
	result_screen = Control.new()
	result_screen.name = "ResultsScreen"
	result_screen.z_index = -1
	result_screen.position = Vector2(172, 91)
	result_screen.size = Vector2(1343, 926)
	result_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	result_screen.hide()
	add_child(result_screen)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_screen.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_screen.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 650)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.01, 0.025, 0.015, 0.97), 3))
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)

	var title := _make_panel_label(content, 46, HORIZONTAL_ALIGNMENT_CENTER)
	title.text = "RESULTADO"
	title.add_theme_color_override("font_color", Color("7dff9b"))

	result_summary_label = _make_panel_label(content, 27, HORIZONTAL_ALIGNMENT_CENTER)
	result_summary_label.custom_minimum_size = Vector2(630, 330)
	result_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 24)
	content.add_child(actions)

	var retry_button := _make_result_button("Jogar novamente")
	retry_button.pressed.connect(_on_retry_pressed)
	actions.add_child(retry_button)

	var select_button := _make_result_button("Selecionar música")
	select_button.pressed.connect(_on_song_select_pressed)
	actions.add_child(select_button)


func _make_result_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(280, 76)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color("8fe99b"))
	button.add_theme_stylebox_override("normal", _panel_style(Color(0.015, 0.035, 0.02, 1), 2))
	button.add_theme_stylebox_override("hover", _panel_style(Color(0.05, 0.12, 0.06, 1), 3))
	return button


func _show_results() -> void:
	for lane: Dictionary in lanes.values():
		var queue: Array = lane["queue"]
		for active_note in queue:
			active_note.queue_free()
		queue.clear()

	var accuracy := 100.0 if judged_notes == 0 else (accuracy_points / judged_notes) * 100.0
	var total_errors := int(judgement_counts[&"miss"]) + int(judgement_counts[&"early"])
	result_summary_label.text = (
		"NOTA  %s\n\n" % gameplay_rules.rank_for_accuracy(accuracy)
		+ "PONTUAÇÃO  %08d\n" % score
		+ "PRECISÃO  %.1f%%\n" % accuracy
		+ "COMBO MÁXIMO  %d\n\n" % max_combo
		+ "PERFEITOS  %d    BONS  %d    CERTOS  %d\n" % [judgement_counts[&"perfect"], judgement_counts[&"good"], judgement_counts[&"ok"]]
		+ "ERROS  %d    MUITO CEDO  %d" % [total_errors, judgement_counts[&"early"]]
	)
	result_screen.show()


func _on_retry_pressed() -> void:
	_transition_to(get_tree().current_scene.scene_file_path)


func _on_song_select_pressed() -> void:
	_transition_to("res://MainMenu/LvlSelectMenu.tscn")


func _transition_to(scene_path: String) -> void:
	Transition.next_scene = scene_path
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")


func _on_midi_queue_midi_event(channel: Variant, event: Variant) -> void:
	if channel.number == song_data.midi_channel and event.type == 144:
		_queue_midi_note(event.note)


func _queue_midi_note(midi_note: int) -> void:
	var action: StringName = note_to_action.get(midi_note, &"")
	if action.is_empty() or not lanes.has(action):
		return

	var lane: Dictionary = lanes[action]
	var lane_node: Node2D = lane["node"]
	var queue: Array = lane["queue"]
	var note = song_data.note_scene.instantiate()
	notes.add_child(note)
	var expected_time := get_song_time() + gameplay_rules.note_travel_seconds
	note.configure(
		action,
		expected_time,
		Vector2(lane_node.global_position.x, note_spawn.global_position.y),
		Vector2(lane_node.global_position.x, hit_target.global_position.y),
		gameplay_rules.note_travel_seconds,
	)
	queue.push_back(note)


func _on_music_player_finished(player: MidiPlayer) -> void:
	finished_players[player.get_instance_id()] = true
	if finished_players.size() < music_players.size() or ending:
		return
	ending = true
	midi_queue.stop()
	_show_results()
