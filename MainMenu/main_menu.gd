extends Control

func _ready() -> void:
	Transition.play_fade_out()

func _on_jogar_pressed():
	Transition.next_scene = "res://MainMenu/LvlSelectMenu.tscn"
	Transition.play_fade_in()

func _on_config_pressed():
	Transition.next_scene = "res://MainMenu/ConfigMenu.tscn"
	Transition.play_fade_in()

func _on_sair_pressed():
	get_tree().quit()
