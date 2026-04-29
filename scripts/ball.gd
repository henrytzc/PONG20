extends CharacterBody2D
##  ball 控制器

@export var speed := 500
var direction := Vector2.ZERO
var _spawn_global_position: Vector2

func _ready():
	_spawn_global_position = global_position
	reset_ball()

func reset_ball():
	global_position = _spawn_global_position
	direction = Vector2.LEFT.rotated(randf_range(-0.5, 0.5)).normalized()

func _physics_process(delta):
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)

	if collision:
		var collider = collision.get_collider()
		if collider != null and collider.is_in_group("paddle"):
			direction = direction.bounce(collision.get_normal())
			var offset: float = (global_position.y - collider.global_position.y) / 50.0
			direction = Vector2(direction.x, offset).normalized()
			if collider.has_method("on_ai_paddle_struck_ball_in_side"):
				collider.on_ai_paddle_struck_ball_in_side()
		else:
			direction = direction.bounce(collision.get_normal())
