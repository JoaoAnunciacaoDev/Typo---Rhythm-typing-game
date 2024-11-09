extends Node2D

var delta_sum = 0.0 # Matém o controle do tempo geral

var time_to_start = 2.0 # O tempo entre o MidiQueue e o MidiPlayer + música

var startSong = {"first": false, "second": false} # Estado do MidiQueue e Player para evitar que se repita

var note = preload("res://Scenes/midi_note.tscn") # Cena das notas que caem, carregar com antecedência para instanciar futuramente

@onready var state = { # Armazena os dados das notas da música, cada nota possui um número, e estão atreladas a uma tecla 
	68: { # A chave é o número referente a nota
		"key": "up", # Tecla ao qual a nota é referente
		"queue": [], # Conforme as notas são "spawnadas", elas são colocadas na fila para poder serem inseridas na cena
		"node": get_node("arrows/arrowUp") # Guarda o nó que representa a "fileira" por onde a nota vai cair
	},
	69: {
		"key": "down",
		"queue": [],
		"node": get_node("arrows/arrowDown")
	},
	71: {
		"key": "left",
		"queue": [],
		"node": get_node("arrows/arrowLeft")
	},
	72: {
		"key": "right",
		"queue": [],
		"node": get_node("arrows/arrowRight")
	},
	74: {
		"key": "up",
		"queue": [],
		"node": get_node("arrows/arrowUp")
	},
	76: {
		"key": "down",
		"queue": [],
		"node": get_node("arrows/arrowDown")
	},
	77: {
		"key": "left",
		"queue": [],
		"node": get_node("arrows/arrowLeft")
	},
	79: {
		"key": "right",
		"queue": [],
		"node": get_node("arrows/arrowRight")
	},
	80: {
		"key": "up",
		"queue": [],
		"node": get_node("arrows/arrowUp")
	},
	81: {
		"key": "up",
		"queue": [],
		"node": get_node("arrows/arrowUp")
	}
}

func _physics_process(delta: float) -> void:
	delta_sum += delta
	
	if delta_sum >= time_to_start and not $MidiQueue.playing and not startSong["first"]: # Primeiro toca o midiQueue, que irá ser responsável pornos mostrar as notas, é chamado antes da música começar para condizer com a música
		$MidiQueue.play()
		startSong["first"] = true
		
	if delta_sum >= 3.85 and not $MidiPlayer.playing and not startSong["second"]: # Após certo tempo o midiplayer responsável pelos sons das notas que o jogador vai tocar inicia
		$MidiPlayer.play()
		startSong["second"] = true
	
	for elem in state.values():
		if Input.is_action_just_pressed(elem.key): # No momento que o jogador pressionar uma tecla
			if not elem.queue.is_empty(): # É verificado se há alguma nota na fila
				if elem.queue.front().test_hit(delta_sum) and not elem.queue.front().missed: # Se houver, é checado se o jogador acertou o momento
					elem.queue.pop_front().hit() # É removido da fila e da cena
					msgErrorOrNot(elem.node.Message, true) # Mensagem na tela
				else:
					msgErrorOrNot(elem.node.Message, false)
		if not elem.queue.is_empty(): # O trecho anterior apenas verifica quando o jogador pressiona, aqui é verificado se o jogador deixou passar alguma tecla
			if elem.queue.front().test_miss(delta_sum):
				elem.queue.pop_front().miss()
				msgErrorOrNot(elem.node.Message, false)

func msgErrorOrNot(texto, perfomance):
	if perfomance:
		texto.set_text("Acertou")
	else:
		texto.set_text("Errou")
	texto.visible = true
	await get_tree().create_timer(0.5).timeout
	texto.visible = false

func _on_midi_player_2_midi_event(channel: Variant, event: Variant) -> void:
	if channel.number == 0: # Sempre que houver algum evento(nota sendo tocada) no canal 0(canal onde está as notas), faça:
		if event.type == 144: # 144 significa "Note on"
			queue_midi_note(event) 

func queue_midi_note(ev):
	var elem = state.get(ev.note) # event.note nos dará o número da nota, que será referente a algum disponível na variável state
		# 128 on, 144 off
	if elem and ev.type == 144: # No momento em que a nota estiver sendo tocada, criaremos uma cópia do nó que representará a nota
		var n = note.instantiate()
		n.expected_time = delta_sum + time_to_start
		n.global_position.y = -40
		n.global_position.x = elem.node.global_position.x
		n.key = elem.key
		add_child(n)
		elem.queue.push_back(n)
