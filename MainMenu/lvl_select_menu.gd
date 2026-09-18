extends Control

const BIND_BUTTONS := {
	&"s": "KeySelection/CenterContainer/PanelContainer/VBoxContainer/Bindings/BindS",
	&"d": "KeySelection/CenterContainer/PanelContainer/VBoxContainer/Bindings/BindD",
	&"f": "KeySelection/CenterContainer/PanelContainer/VBoxContainer/Bindings/BindF",
	&"j": "KeySelection/CenterContainer/PanelContainer/VBoxContainer/Bindings/BindJ",
	&"k": "KeySelection/CenterContainer/PanelContainer/VBoxContainer/Bindings/BindK",
	&"l": "KeySelection/CenterContainer/PanelContainer/VBoxContainer/Bindings/BindL",
}
const ACTION_LABELS := {
	&"s": "Trilha 1",
	&"d": "Trilha 2",
	&"f": "Trilha 3",
	&"j": "Trilha 4",
	&"k": "Trilha 5",
	&"l": "Trilha 6",
}

@onready var key_selection: Control = $KeySelection
@onready var song_label: Label = $KeySelection/CenterContainer/PanelContainer/VBoxContainer/SongLabel
@onready var binding_status: Label = $KeySelection/CenterContainer/PanelContainer/VBoxContainer/BindingStatus

var listening_action: StringName = &""
var pending_scene := ""


func _ready() -> void:
	for action in BIND_BUTTONS:
		var button: Button = get_node(BIND_BUTTONS[action])
		button.pressed.connect(_start_listening.bind(action))
	_refresh_binding_buttons()
	Transition.play_fade_out()


func _input(event: InputEvent) -> void:
	if not key_selection.visible or not event is InputEventKey:
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if listening_action.is_empty():
		if key_event.physical_keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_hide_key_selection()
		return

	get_viewport().set_input_as_handled()
	if key_event.physical_keycode == KEY_ESCAPE:
		listening_action = &""
		binding_status.text = "Remapeamento cancelado."
		_refresh_binding_buttons()
		return

	var keycode: Key = key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode
	Settings.rebind_action(listening_action, keycode)
	listening_action = &""
	binding_status.text = "Teclas atualizadas e salvas."
	_refresh_binding_buttons()


func _on_fase_1_pressed() -> void:
	_show_key_selection("Muranga", "res://Scenes/murangaTema.tscn")

func _on_fase_2_pressed() -> void:
	_show_key_selection("Tetris", "res://Scenes/tetris.tscn")

func _on_fase_3_pressed() -> void:
	_show_key_selection("Hacker", "res://Scenes/hackerScene.tscn")


func _show_key_selection(song_name: String, scene_path: String) -> void:
	pending_scene = scene_path
	song_label.text = "Teclas para %s" % song_name
	binding_status.text = "Clique em uma trilha e aperte a tecla desejada."
	listening_action = &""
	_refresh_binding_buttons()
	key_selection.show()
	TocadorSom.play_sfx("click")


func _hide_key_selection() -> void:
	listening_action = &""
	pending_scene = ""
	key_selection.hide()


func _start_listening(action: StringName) -> void:
	listening_action = action
	binding_status.text = "Aperte a tecla desejada (Esc cancela)."
	var button: Button = get_node(BIND_BUTTONS[action])
	button.release_focus()
	_refresh_binding_buttons()


func _refresh_binding_buttons() -> void:
	for action in BIND_BUTTONS:
		var button: Button = get_node(BIND_BUTTONS[action])
		var binding_text := "Aperte uma tecla..." if action == listening_action else Settings.get_binding_text(action)
		button.text = "%s: %s" % [ACTION_LABELS[action], binding_text]


func _on_iniciar_pressed() -> void:
	if pending_scene.is_empty():
		return
	Settings.apply_all()
	Transition.next_scene = pending_scene
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")


func _on_cancelar_pressed() -> void:
	_hide_key_selection()
	TocadorSom.play_sfx("click")

func _on_voltar_pressed() -> void:
	Transition.next_scene = "res://MainMenu/MainMenu.tscn"
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")

func _on_mouse_entered() -> void:
	TocadorSom.play_sfx("btn_hover")
