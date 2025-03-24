extends Node2D

@export var next_scene : String

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene_to_file(next_scene)
