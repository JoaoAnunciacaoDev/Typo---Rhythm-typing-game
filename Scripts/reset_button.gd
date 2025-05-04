extends TextureButton

func _on_pressed() -> void:
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")

func _on_mouse_entered() -> void:
	TocadorSom.play_sfx("btn_hover")
