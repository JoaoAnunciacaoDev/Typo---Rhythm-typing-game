extends Label

var abc_lower : Array[String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
var abc_upper = abc_lower.map(func(letter): return letter.to_upper())
var word : String = "Typo"
var positionCounter : int = 0

func _ready() -> void:
	abc_lower.shuffle()
	letters_random()

func letters_random() -> void:
	if positionCounter == 0:
		for i in abc_upper:
			text[positionCounter] = i
			await get_tree().create_timer(0.05).timeout
		
			if i == word[positionCounter]:
				break
	else:
		for i in abc_lower:
			text[positionCounter] = i
			await get_tree().create_timer(0.05).timeout
			
			if i == word[positionCounter]:
				break
	
	if positionCounter == 3:
		positionCounter = 0
		await get_tree().create_timer(0.5).timeout
	else:
		positionCounter += 1
	
	letters_random()
