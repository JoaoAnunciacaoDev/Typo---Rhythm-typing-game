extends TextureButton

@export var next_scene : String

func _on_pressed() -> void:
	Transition.next_scene = next_scene
	Transition.play_fade_in()
