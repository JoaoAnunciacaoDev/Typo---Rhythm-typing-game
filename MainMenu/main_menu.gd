extends Control

func _ready() -> void:
	Transition.play_fade_out()

func _on_jogar_pressed() -> void:
	Transition.next_scene = "res://MainMenu/LvlSelectMenu.tscn"
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")

func _on_config_pressed() -> void:
	Transition.next_scene = "res://MainMenu/ConfigMenu.tscn"
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")

func _on_sair_pressed() -> void:
	get_tree().quit()

func _on_mouse_entered() -> void:
	TocadorSom.play_sfx("btn_hover")
