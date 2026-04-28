extends Area2D

@export var side: String = "left"  # 編輯器裡左區設 "left"，右區設 "right"

func _ready():
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		GameManager.score_point(side)
