extends Control

var switch : bool = false

func _ready() -> void:
	Transition.play_fade_out()

func _on_voltar_pressed() -> void:
	Transition.next_scene = "res://MainMenu/MainMenu.tscn"
	Transition.play_fade_in()
	
func _on_full_screen_check_box_toggled(_toggled_on) -> void:
	if not switch:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		switch = not switch
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		switch = not switch
