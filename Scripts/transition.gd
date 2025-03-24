extends Node2D

@export var next_scene : String
@onready var anim: AnimationPlayer = $anim

func play_fade_in() -> void:
	anim.play("fade_in")

func play_fade_out() -> void:
	anim.play("fade_out")

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene_to_file(next_scene)
