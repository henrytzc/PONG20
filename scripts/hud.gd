extends Control

@export var left_score_label: Label
@export var right_score_label: Label

func _ready() -> void:
	GameManager.scores_changed.connect(_on_scores_changed)
	update_score(GameManager.score_left, GameManager.score_right)

func _on_scores_changed(left: int, right: int) -> void:
	update_score(left, right)

func update_score(left: int, right: int) -> void:
	left_score_label.text = str(left)
	right_score_label.text = str(right)
