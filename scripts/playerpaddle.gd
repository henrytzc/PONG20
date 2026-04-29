extends CharacterBody2D
## 玩家 paddle 控制器及 AI 追球

@export var speed := 400.0 ## 移動速度
@export var input_up := "ui_up"
@export var input_down := "ui_down"
@export var ball: Node2D ## 球物件
@export var ai_side_area: Area2D ## 己方半場
@export var start_with_ai := true ## 是否初始為 AI 追球
@export var ai_track_deadzone := 50.0 ## 球與拍子 Y 差距小於此則不動，減少抖動

var _use_ai: bool = true
## 己方半場內擊中球後至「球先離場再入場」前不進行 AI 移動
var _ai_pursue_frozen_until_reentry: bool = false
var _ball_left_side_after_ai_freeze: bool = false

## 初始化時代入 start_with_ai
func _ready() -> void:
	_use_ai = start_with_ai

func _physics_process(_delta: float) -> void:
	if _use_ai and (Input.is_action_pressed(input_up) or Input.is_action_pressed(input_down)):
		_use_ai = false
		_reset_ai_pursue_freeze()

	if not _use_ai:
		_reset_ai_pursue_freeze()

	_update_reentry_unfreeze()

	var dir := 0.0
	if _use_ai:
		if (not _ai_pursue_frozen_until_reentry) and _is_ball_in_my_side():
			dir = _ai_dir()
	else:
		if Input.is_action_pressed(input_up):
			dir -= 1.0
		if Input.is_action_pressed(input_down):
			dir += 1.0

	velocity.y = dir * speed
	move_and_slide()

func _reset_ai_pursue_freeze() -> void:
	_ai_pursue_frozen_until_reentry = false
	_ball_left_side_after_ai_freeze = false

## 凍結中：先等球離開己方半場，再入場時解凍
func _update_reentry_unfreeze() -> void:
	if ai_side_area == null or not _ai_pursue_frozen_until_reentry or ball == null:
		return
	var in_side := _is_ball_in_my_side()
	if not in_side:
		_ball_left_side_after_ai_freeze = true
		return
	if _ball_left_side_after_ai_freeze:
		_reset_ai_pursue_freeze()

## 由 ball.gd 在與本拍子反彈時呼叫；僅在 AI 且當下球在己方半場內觸發凍結
func on_ai_paddle_struck_ball_in_side() -> void:
	if not _use_ai or ai_side_area == null:
		return
	if not _is_ball_in_my_side():
		return
	_ai_pursue_frozen_until_reentry = true
	_ball_left_side_after_ai_freeze = false

## 球是否在己方半場
func _is_ball_in_my_side() -> bool:
	if ai_side_area == null:
		return true
	if ball == null:
		return false
	return ai_side_area.get_overlapping_bodies().has(ball)

## AI 追球方向
func _ai_dir() -> float:
	if ball == null: ## 沒有指到 ball → 不動，回傳 0.0
		return 0.0
	var dy: float = ball.global_position.y - global_position.y ## 算 dy = 球的 Y − 球拍的 Y
	if absf(dy) < ai_track_deadzone: ## 差距小於 deadzone → 不動，回傳 0.0
		return 0.0
	return signf(dy) ## 差距大於 deadzone → 回傳 dy 的符號
