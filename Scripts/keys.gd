extends Node2D

@export var pressed: bool
@export var color: Color
@export var key: String
@export var Message: Label

var message_counter = 0.0
var max_message = 0.4

func _input(_event):
	if Input.is_action_just_pressed(key):
		pressed = true
	if Input.is_action_just_released(key):
		pressed = false

func _process(delta):
	if pressed:
		scale.y = lerp(scale.y, 0.95, 1.0)
		scale.x = lerp(scale.x, 0.95, 1.0)
	else:
		scale.y = lerp(scale.y, 1.0, delta * 1.0)
		scale.x = lerp(scale.x, 1.0, delta * 1.0)
