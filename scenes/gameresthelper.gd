extends Node2D
@export var ball: CharacterBody2D

func _ready() -> void:
	GameManager.round_reset_requested.connect(_on_round_reset_requested)

func _on_round_reset_requested() -> void:
	ball.reset_ball()
