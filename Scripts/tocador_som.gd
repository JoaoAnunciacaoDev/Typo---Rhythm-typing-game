extends Node2D

var erro = preload("res://Sounds/Som_de_erro.mp3")

func play_sfx(sfx_name : String):
	var asp = AudioStreamPlayer.new()

	if sfx_name == "erro":
		asp.stream = erro

	add_child(asp)

	asp.play()

	await asp.finished

	asp.queue_free()
