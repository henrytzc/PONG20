extends Node

@onready var _sound: Node = get_tree().root.get_node("SoundManager")

var score_left := 0
var score_right := 0

@export var round_reset_delay_sec := 3.0 ## 得分後、重新發球前的等待秒數

signal round_pause_requested(serving_side: String)
signal round_reset_requested(serving_side: String)
signal scores_changed(left: int, right: int)

var _pending_serving_side: String = ""


func score_point(side: String) -> void:
	if side == "left":
		score_left += 1
		# 左邊球門進球 → 左方得分 → 輸的是右方 → 右方發球
		_pending_serving_side = "right"
	else:
		score_right += 1
		_pending_serving_side = "left"

	scores_changed.emit(score_left, score_right)
	_sound.play_score_point()
	round_pause_requested.emit(_pending_serving_side)

	var tree := get_tree()
	if tree:
		tree.create_timer(round_reset_delay_sec).timeout.connect(_on_round_reset_timeout, CONNECT_ONE_SHOT)


func _on_round_reset_timeout() -> void:
	round_reset_requested.emit(_pending_serving_side)
