extends Control

func _ready() -> void:
	Transition.play_fade_out()

func _on_fase_1_pressed() -> void:
	Transition.next_scene = "res://Scenes/murangaTema.tscn"
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")

func _on_fase_2_pressed() -> void:
	Transition.next_scene = "res://Scenes/tetris.tscn"
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")

func _on_fase_3_pressed() -> void:
	Transition.next_scene = "res://Scenes/hackerScene.tscn"
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")

func _on_voltar_pressed() -> void:
	Transition.next_scene = "res://MainMenu/MainMenu.tscn"
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")

func _on_mouse_entered() -> void:
	TocadorSom.play_sfx("btn_hover")
