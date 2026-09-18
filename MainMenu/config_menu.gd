extends Control

@onready var full_screen_check_box: CheckButton = $CenterContainer/VBoxContainer/FullScreenCheckBox

func _ready() -> void:
	full_screen_check_box.set_pressed_no_signal(Settings.fullscreen)
	Transition.play_fade_out()

func _on_voltar_pressed() -> void:
	Transition.next_scene = "res://MainMenu/MainMenu.tscn"
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")
	
func _on_full_screen_check_box_toggled(_toggled_on) -> void:
	TocadorSom.play_sfx("click")
	Settings.set_fullscreen(_toggled_on)

func _on_mouse_entered() -> void:
	TocadorSom.play_sfx("btn_hover")
