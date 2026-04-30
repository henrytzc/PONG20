extends Node2D
@export var ball: CharacterBody2D
@export var serve_indicator_left: Sprite2D
@export var serve_indicator_right: Sprite2D
## 每次亮起停留時間（秒）；熄滅後會補足間隔至下一整秒再亮
@export var serve_pulse_visible_sec := 0.5

var _serve_blink_generation := 0


func _ready() -> void:
	GameManager.round_pause_requested.connect(_on_round_pause_requested)
	GameManager.round_reset_requested.connect(_on_round_reset_requested)
	_hide_all_serve_indicators()


func _hide_all_serve_indicators() -> void:
	if serve_indicator_left:
		serve_indicator_left.visible = false
	if serve_indicator_right:
		serve_indicator_right.visible = false


func _on_round_pause_requested(serving_side: String) -> void:
	ball.prepare_between_rounds()
	_serve_blink_generation += 1
	var gen := _serve_blink_generation
	_hide_all_serve_indicators()
	_run_serve_indicator_pulse(gen, serving_side)


func _run_serve_indicator_pulse(gen: int, serving_side: String) -> void:
	var sprite: Sprite2D = serve_indicator_left if serving_side == "left" else serve_indicator_right
	if sprite == null:
		return
	var delay_sec: float = GameManager.round_reset_delay_sec
	var pulses: int = int(floor(delay_sec))
	if pulses < 1:
		return
	var gap_to_next_sec: float = maxf(0.0, 1.0 - serve_pulse_visible_sec)
	for i in pulses:
		if gen != _serve_blink_generation:
			return
		sprite.visible = true
		await get_tree().create_timer(serve_pulse_visible_sec).timeout
		if gen != _serve_blink_generation:
			return
		sprite.visible = false
		if i < pulses - 1:
			await get_tree().create_timer(gap_to_next_sec).timeout


func _on_round_reset_requested(serving_side: String) -> void:
	_serve_blink_generation += 1
	_hide_all_serve_indicators()
	ball.reset_ball(serving_side)
