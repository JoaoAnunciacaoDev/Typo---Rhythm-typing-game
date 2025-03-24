extends Control

func _ready() -> void:
	Transition.play_fade_out()

func _on_fase_1_pressed() -> void:
	Transition.next_scene = "res://Scenes/murangaTema.tscn"
	Transition.play_fade_in()

func _on_fase_2_pressed() -> void:
	Transition.next_scene = "res://Scenes/tetris.tscn"
	Transition.play_fade_in()

func _on_voltar_pressed() -> void:
	Transition.next_scene = "res://MainMenu/MainMenu.tscn"
	Transition.play_fade_in()
