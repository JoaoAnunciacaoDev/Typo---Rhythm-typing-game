extends Node2D

var action : int = 0

func _on_midi_player_midi_event(channel: Variant, event: Variant) -> void:
	if channel.number == 0:
		if event.type == 144:
			if action == 0:
				$Icon.position.x += 150
				action = 1
			elif action == 1:
				$Icon.position.x -= 150
				action = 0
