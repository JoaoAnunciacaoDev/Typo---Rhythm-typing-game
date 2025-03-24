extends Control

var switch = false


func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")
	


func _on_full_screen_check_box_toggled(toggled_on):
	
	if not switch:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		switch = not switch
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		switch = not switch
