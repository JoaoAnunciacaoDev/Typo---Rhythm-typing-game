extends Sprite2D

@export var expected_time := 0.0
@export var key: StringName
@export var muranga_key : bool
@export var label : Label
@export var textures : Array[Texture2D]
@export var sprite : Sprite2D
@export var animate_textures := false
@export_range(1.0, 30.0, 0.5) var texture_fps := 8.0

var texture_frame := 0
var texture_elapsed := 0.0
var spawn_position := Vector2.ZERO
var target_position := Vector2.ZERO
var travel_time := 2.0

func _ready() -> void:
	if not textures.is_empty() and is_instance_valid(sprite):
		if animate_textures:
			sprite.texture = textures[texture_frame]
		else:
			sprite.texture = textures.pick_random()

	_update_label()

func _physics_process(delta: float) -> void:
	_update_texture_animation(delta)


func configure(action: StringName, hit_time: float, from_position: Vector2, to_position: Vector2, duration: float) -> void:
	key = action
	expected_time = hit_time
	spawn_position = from_position
	target_position = to_position
	travel_time = maxf(duration, 0.01)
	global_position = spawn_position
	_update_label()


func update_song_time(song_time: float) -> void:
	var progress := 1.0 - ((expected_time - song_time) / travel_time)
	global_position = spawn_position.lerp(target_position, progress)


func judgement_at(song_time: float, perfect_window: float, good_window: float, miss_window: float) -> StringName:
	var difference := absf(expected_time - song_time)
	if difference <= perfect_window:
		return &"perfect"
	if difference <= good_window:
		return &"good"
	if difference <= miss_window:
		return &"ok"
	return &""


func is_late(song_time: float, miss_window: float) -> bool:
	return song_time > expected_time + miss_window


func _update_texture_animation(delta: float) -> void:
	if not animate_textures or textures.size() < 2 or not is_instance_valid(sprite):
		return

	texture_elapsed += delta
	var frame_duration := 1.0 / texture_fps
	while texture_elapsed >= frame_duration:
		texture_elapsed -= frame_duration
		texture_frame = (texture_frame + 1) % textures.size()
		sprite.texture = textures[texture_frame]
	
func hit() -> void:
	queue_free()
	
func miss() -> void:
	queue_free()


func _update_label() -> void:
	if is_instance_valid(label) and not key.is_empty():
		label.text = Settings.get_binding_text(key).to_upper()
