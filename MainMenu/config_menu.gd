extends Control

var switch : bool = false

func _ready() -> void:
	Transition.play_fade_out()

func _on_voltar_pressed() -> void:
	Transition.next_scene = "res://MainMenu/MainMenu.tscn"
	Transition.play_fade_in()
	TocadorSom.play_sfx("click")
	
func _on_full_screen_check_box_toggled(_toggled_on) -> void:
	TocadorSom.play_sfx("click")
	if not switch:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		switch = not switch
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		switch = not switch

func _on_mouse_entered() -> void:
	TocadorSom.play_sfx("btn_hover")
