extends Sprite2D

@export var expected_time: float
@export var key: String

var state = ""
var error_margin: float = 0.25
var missed = false

func _physics_process(delta: float) -> void:
	if state == "hit": # Caso o jogador acerte, a nota é removida da cena
		queue_free()
	
	if state == "miss": # Caso a nota saia da tela também é removida da tela
		if global_position.y > 1080.0: # Altura da janela
			queue_free()
			
	# node start position - position of button to match (???) Deus sabe o que faz
	var speed = abs(-40.0 - 500.0) 
	global_position.y += delta * speed
	
func test_hit(time: float): # Testa se o jogador acertou dentro da margem de erro
	if abs(expected_time - time) < error_margin:
		return true
	return false
	
func test_miss(time: float): # Se passou o tempo estimado e o jogador não apertou, é considerado erro
	if time > expected_time + error_margin:
		return true
	return false
	
func hit():
	state = "hit"
	
func miss():
	state = "miss"
	
func _on_area_detect_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == "missArea": # Talvez seja desnecessário, mas implementei para garantir que ao passar de certo ponto é considerado erro
		missed = true
