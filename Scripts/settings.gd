extends Node

const SAVE_PATH := "user://settings.dat"
const SAVE_VERSION := 1
const INPUT_ACTIONS: Array[StringName] = [&"s", &"d", &"f", &"j", &"k", &"l"]
const DEFAULT_BINDINGS := {
	&"s": KEY_S,
	&"d": KEY_D,
	&"f": KEY_F,
	&"j": KEY_J,
	&"k": KEY_K,
	&"l": KEY_L,
}

var fullscreen := true
var master_volume := 1.0
var bindings: Dictionary = {}


func _ready() -> void:
	_load_settings()
	apply_all()


func apply_all() -> void:
	_apply_fullscreen()
	_apply_volume()
	_apply_bindings()


func set_fullscreen(enabled: bool) -> void:
	fullscreen = enabled
	_apply_fullscreen()
	save()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_volume()
	save()


func rebind_action(action: StringName, physical_keycode: Key) -> void:
	if action not in INPUT_ACTIONS or physical_keycode == KEY_NONE:
		return

	var previous_keycode: Key = bindings.get(action, DEFAULT_BINDINGS[action])
	for other_action in INPUT_ACTIONS:
		if other_action != action and bindings.get(other_action) == physical_keycode:
			bindings[other_action] = previous_keycode
			_apply_binding(other_action, previous_keycode)
			break

	bindings[action] = physical_keycode
	_apply_binding(action, physical_keycode)
	save()


func get_binding(action: StringName) -> Key:
	return bindings.get(action, DEFAULT_BINDINGS.get(action, KEY_NONE))


func get_binding_text(action: StringName) -> String:
	return OS.get_keycode_string(get_binding(action))


func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível salvar as configurações: %s" % FileAccess.get_open_error())
		return

	file.store_var({
		"version": SAVE_VERSION,
		"fullscreen": fullscreen,
		"master_volume": master_volume,
		"bindings": bindings,
	}, true)


func _load_settings() -> void:
	bindings = DEFAULT_BINDINGS.duplicate()
	if not FileAccess.file_exists(SAVE_PATH):
		save()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Não foi possível carregar as configurações; usando os padrões.")
		return

	var stored_value: Variant = file.get_var(true)
	if not stored_value is Dictionary:
		push_warning("Arquivo de configurações inválido; usando os padrões.")
		return

	var stored: Dictionary = stored_value
	fullscreen = bool(stored.get("fullscreen", true))
	master_volume = clampf(float(stored.get("master_volume", 1.0)), 0.0, 1.0)
	var stored_bindings: Variant = stored.get("bindings", {})
	if stored_bindings is Dictionary:
		for action in INPUT_ACTIONS:
			var value: Variant = stored_bindings.get(action, stored_bindings.get(String(action), DEFAULT_BINDINGS[action]))
			if value is int and int(value) != KEY_NONE:
				bindings[action] = int(value) as Key


func _apply_fullscreen() -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)


func _apply_volume() -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(master_volume))


func _apply_bindings() -> void:
	for action in INPUT_ACTIONS:
		_apply_binding(action, get_binding(action))


func _apply_binding(action: StringName, physical_keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	var event := InputEventKey.new()
	event.physical_keycode = physical_keycode
	InputMap.action_add_event(action, event)
