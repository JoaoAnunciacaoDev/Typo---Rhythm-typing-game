class_name GameplayRules
extends Resource

@export_group("Tempo")
@export_range(0.1, 10.0, 0.05) var note_travel_seconds := 2.0
@export_range(0.01, 0.5, 0.01) var perfect_window := 0.08
@export_range(0.01, 0.5, 0.01) var good_window := 0.16
@export_range(0.01, 0.75, 0.01) var miss_window := 0.25
@export_range(0.1, 2.0, 0.05) var early_input_window := 0.65

@export_group("Pontuacao")
@export var perfect_score := 1000
@export var good_score := 700
@export var ok_score := 400
@export_range(0.0, 1.0, 0.05) var perfect_accuracy := 1.0
@export_range(0.0, 1.0, 0.05) var good_accuracy := 0.75
@export_range(0.0, 1.0, 0.05) var ok_accuracy := 0.5
@export var combo_step := 10
@export_range(0.0, 1.0, 0.05) var multiplier_step := 0.25
@export_range(1.0, 5.0, 0.25) var maximum_multiplier := 2.0

@export_group("Classificacao")
@export_range(0.0, 100.0, 0.5) var rank_s_threshold := 95.0
@export_range(0.0, 100.0, 0.5) var rank_a_threshold := 90.0
@export_range(0.0, 100.0, 0.5) var rank_b_threshold := 80.0
@export_range(0.0, 100.0, 0.5) var rank_c_threshold := 70.0

@export_group("Trilhas")
@export var lane_s_color := Color("4dd0e1")
@export var lane_d_color := Color("64b5f6")
@export var lane_f_color := Color("9575cd")
@export var lane_j_color := Color("f06292")
@export var lane_k_color := Color("ffb74d")
@export var lane_l_color := Color("81c784")
@export_range(64.0, 256.0, 1.0) var lane_width := 124.0
@export_range(0.0, 1.0, 0.01) var lane_fill_alpha := 0.18
@export_range(0.0, 1.0, 0.01) var lane_underlay_alpha := 0.36
@export_range(0.0, 1.0, 0.01) var lane_border_alpha := 0.5


func score_for(judgement: StringName) -> int:
	match judgement:
		&"perfect": return perfect_score
		&"good": return good_score
		&"ok": return ok_score
		_: return 0


func accuracy_for(judgement: StringName) -> float:
	match judgement:
		&"perfect": return perfect_accuracy
		&"good": return good_accuracy
		&"ok": return ok_accuracy
		_: return 0.0


func multiplier_for_combo(combo: int) -> float:
	var safe_step := maxi(combo_step, 1)
	return minf(1.0 + float(combo / safe_step) * multiplier_step, maximum_multiplier)


func rank_for_accuracy(accuracy: float) -> String:
	if accuracy >= rank_s_threshold:
		return "S"
	if accuracy >= rank_a_threshold:
		return "A"
	if accuracy >= rank_b_threshold:
		return "B"
	if accuracy >= rank_c_threshold:
		return "C"
	return "D"


func lane_color(action: StringName) -> Color:
	match action:
		&"s": return lane_s_color
		&"d": return lane_d_color
		&"f": return lane_f_color
		&"j": return lane_j_color
		&"k": return lane_k_color
		&"l": return lane_l_color
		_: return Color.WHITE
