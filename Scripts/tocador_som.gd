extends Node2D

var erro = preload("res://Sounds/Som_de_erro.mp3")
var hover = preload("res://Sounds/btn_hover.wav")
var click = preload("res://Sounds/click.mp3")

func play_sfx(sfx_name : String):
	var asp = AudioStreamPlayer.new()

	if sfx_name == "erro":
		asp.stream = erro
	elif sfx_name == "btn_hover":
		asp.stream = hover
		asp.pitch_scale = randf_range(0.9, 1.2)
	elif sfx_name == "click":
		asp.stream = click

	add_child(asp)
	
	asp.bus = "sfx"

	asp.play()

	await asp.finished

	asp.queue_free()
