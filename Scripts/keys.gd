extends Node2D

@export var pressed: bool
@export var color: Color
@export var key: String
@export var Message: Label

var message_counter = 0.0
var max_message = 0.4


func _ready() -> void:
	_update_key_texture()


func _input(_event) -> void:
	if Input.is_action_just_pressed(key):
		pressed = true
	if Input.is_action_just_released(key):
		pressed = false

func _process(delta: float) -> void:
	if pressed:
		scale.y = lerp(scale.y, 6.0, 1.0)
		scale.x = lerp(scale.x, 6.0, 1.0)
	else:
		scale.y = lerp(scale.y, 7.0, delta * 7.0)
		scale.x = lerp(scale.x, 7.0, delta * 7.0)


func _update_key_texture() -> void:
	var action := StringName(key)
	var key_name := Settings.get_binding_text(action).to_lower()
	var asset_names := {
		"escape": "esc",
		"up": "arrow_up",
		"down": "arrow_down",
		"left": "arrow_left",
		"right": "arrow_right",
		"delete": "del",
		"pageup": "page_up",
		"pagedown": "page_down",
	}
	key_name = asset_names.get(key_name, key_name.replace(" ", "_"))
	var texture_path := "res://Assets/key/%s.png" % key_name
	if ResourceLoader.exists(texture_path):
		var key_sprite := get_node_or_null("Sprite2D") as Sprite2D
		if key_sprite:
			key_sprite.texture = load(texture_path)
