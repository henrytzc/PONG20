extends Node

var score_left := 0
var score_right := 0

signal round_reset_requested
signal scores_changed(left: int, right: int)

func score_point(side):
	if side == "left":
		score_left += 1
	else:
		score_right += 1

	round_reset_requested.emit()
	scores_changed.emit(score_left, score_right)
