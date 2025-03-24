extends Control


# Called when the node enters the scene tree for the first time.


func _on_fase_1_pressed():
	get_tree().change_scene_to_file("res://Scenes/murangaTema.tscn")



func _on_fase_2_pressed():
	get_tree().change_scene_to_file("res://Scenes/tetris.tscn")



func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")
