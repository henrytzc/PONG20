extends CharacterBody2D
## 玩家 paddle 控制器

@export var speed := 400 ## 移動速度
@export var input_up := "ui_up"
@export var input_down := "ui_down"

func _physics_process(_delta):
	var dir := 0

	if Input.is_action_pressed(input_up):
		dir -= 1
	if Input.is_action_pressed(input_down):
		dir += 1

	velocity.y = dir * speed
	move_and_slide()
