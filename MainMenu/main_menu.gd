extends Control




func _on_jogar_pressed():
	get_tree().change_scene_to_file("res://MainMenu/LvlSelectMenu.tscn")



func _on_config_pressed():
	get_tree().change_scene_to_file("res://MainMenu/ConfigMenu.tscn")
	


func _on_sair_pressed():
	get_tree().quit()
