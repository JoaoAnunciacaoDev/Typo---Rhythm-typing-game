extends Sprite2D

@export var expected_time : float
@export var key : String
@export var muranga_key : bool
@export var label : Label

var state : String = ""
var error_margin : float = 0.25
var missed : bool = false
var tutorialNote : bool = false
var speed = abs(-40.0 - 500.0) 

var abc_lower = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

func _ready() -> void:
	if not muranga_key:
		abc_lower.shuffle()
		letters_random()

func letters_random() -> void:
	for i in abc_lower:
		label.text = i
		await get_tree().create_timer(0.15).timeout
	
	letters_random()

func _physics_process(delta: float) -> void:
	if state == "hit": # Caso o jogador acerte, a nota é removida da cena
		queue_free()
	
	if state == "miss": # Caso a nota saia da tela também é removida da tela
		if global_position.y >= 1080.0: # Altura da janela
			queue_free()
	
	# node start position - position of button to match (???) Deus sabe o que faz
	global_position.y += delta * speed
	
func test_hit(time: float) -> bool: # Testa se o jogador acertou dentro da margem de erro
	if abs(expected_time - time) < error_margin:
		return true
	return false
	
func test_miss(time: float) -> bool: # Se passou o tempo estimado e o jogador não apertou, é considerado erro
	if time > expected_time + error_margin:
		return true
	return false

func hit() -> void:
	state = "hit"
	
func miss() -> void:
	state = "miss"
	
func _on_area_detect_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.name == "missArea": # Talvez seja desnecessário, mas implementei para garantir que ao passar de certo ponto é considerado erro
		missed = true
