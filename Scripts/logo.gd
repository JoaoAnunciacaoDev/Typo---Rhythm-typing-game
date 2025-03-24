extends Control

func _ready() -> void:
	Transition.play_fade_out()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	Transition.next_scene = "res://MainMenu/MainMenu.tscn"
	Transition.play_fade_in()
