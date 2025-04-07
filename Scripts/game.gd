extends Node2D

@export var delta_sum : float = 0.0 # Matém o controle do tempo geral
@export var midi_player : MidiPlayer
@export var midi_queue : MidiPlayer
@export var adsr : AudioStreamPlayerADSR
@export var camera : Camera2D
@export var notes : Node2D

var time_to_start : float = 2.0 # O tempo entre o MidiQueue e o MidiPlayer + música
var startSong = {"first": false, "second": false} # Estado do MidiQueue e Player para evitar que se repita
var note = preload("res://Scenes/mechanics/midi_note.tscn")  # Cena das notas que caem, carregar com antecedência para instanciar futuramente
var selected_Channel : int # Canal MIDI selecionado
var beat_interval : float
var config_path # Seleção do arquivo com as notas da música
var state = {}

func _ready() -> void:
	Transition.play_fade_out()
	
	if name == "Tetris":
		note = preload("res://Scenes/mechanics/midi_note_tetris.tscn")
		config_path = "res://songData/Tetris.cfg"
		Transition.next_scene = "res://Scenes/tetris.tscn"
		selected_Channel = 0
	elif name == "MurangaTema":
		note = preload("res://Scenes/mechanics/midi_note_muranga.tscn")
		config_path = "res://songData/murangaCanal.cfg"
		Transition.next_scene = "res://Scenes/murangaTema.tscn"
		selected_Channel = 1
	
	var config_file = ConfigFile.new()

	# Carrega o arquivo de configuração
	var err = config_file.load(config_path)
	if err != OK:
		print("Erro ao carregar o arquivo de configuração:", err)
		return

	# Itera sobre cada chave do arquivo, recriando o dicionário
	for key in config_file.get_section_keys("Data"):
		var note_num = int(key.split("/")[0])

		# Se a nota ainda não foi criada no dicionário, cria-a
		if !state.has(note_num):
			state[note_num] = {
			"key": "",
			"queue": [],
			"node": null
			}
		# Define cada campo
		if "/key" in key:
			state[note_num]["key"] = config_file.get_value("Data", key)
		elif "/queue" in key:
			state[note_num]["queue"] = config_file.get_value("Data", key)
		elif "/node" in key:
			state[note_num]["node"] = get_node(config_file.get_value("Data", key))

func _physics_process(delta: float) -> void:
	delta_sum += delta
	if delta_sum >= time_to_start and not startSong["first"]: # Primeiro toca o midiQueue, que irá ser responsável pornos mostrar as notas, é chamado antes da música começar para condizer com a música
		startSong["first"] = true
		midi_queue.play()
		
	if delta_sum >= 3.85 and not startSong["second"]: # Após certo tempo o midiplayer responsável pelos sons das notas que o jogador vai tocar inicia
		startSong["second"] = true
		get_tree().call_group("midiSong", "play")
	
	for elem in state.values():
		if Input.is_action_just_pressed(elem.key): # No momento que o jogador pressionar uma tecla
			if not elem.queue.is_empty(): # É verificado se há alguma nota na fila
				if elem.queue.front().test_hit(delta_sum) and not elem.queue.front().missed: # Se houver, é checado se o jogador acertou o momento
					elem.queue.pop_front().hit() # É removido da fila e da cena
					msgErrorOrNot(elem.node.Message, true) # Mensagem na tela
				else:
					msgErrorOrNot(elem.node.Message, false)
		
		if not elem.queue.is_empty(): # Aqui é verificado se o jogador deixou passar alguma tecla
			if elem.queue.front().test_miss(delta_sum):
				elem.queue.pop_front().miss()
				msgErrorOrNot(elem.node.Message, false)

func msgErrorOrNot(texto, perfomance) -> void:
	if perfomance:
		texto.set_text("Acertou")
		var bus_index = AudioServer.get_bus_index("Master")
		midi_player.volume_db = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	else:
		texto.set_text("Errou")
		midi_player.volume_db = -80
		TocadorSom.play_sfx("erro")
		camera.shake()
		
	texto.visible = true
	await get_tree().create_timer(0.6).timeout
	texto.visible = false

func _on_midi_queue_midi_event(channel: Variant, event: Variant) -> void:
	if channel.number == selected_Channel: # Sempre que houver algum evento(nota sendo tocada) no canal 0(canal onde está as notas), faça:
		if event.type == 144: # 144 significa "Note on"
			queue_midi_note(event)
			
func queue_midi_note(ev) -> void:
	var elem = state.get(ev.note) # event.note nos dará o número da nota, que será referente a algum disponível na variável state
		# 128 off, 144 on
	if elem and ev.type == 144:
		var n = note.instantiate() # No momento em que a nota estiver sendo tocada, criaremos uma cópia do nó que representará a nota
		n.expected_time = delta_sum + time_to_start
		n.global_position.y = -40
		n.global_position.x = elem.node.global_position.x
		n.key = elem.key
		notes.add_child(n)
		elem.queue.push_back(n)

func _on_midi_player_finished() -> void:
	Transition.next_scene = "res://MainMenu/LvlSelectMenu.tscn"
	Transition.play_fade_in()
