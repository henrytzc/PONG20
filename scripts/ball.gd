extends CharacterBody2D
##  ball 控制器

@onready var _sound: Node = get_tree().root.get_node("SoundManager")

@export var speed := 500
var direction := Vector2.ZERO
var _spawn_global_position: Vector2

## 與 paddle 的 ai_side_area 一致：球在該半場內已播過 paddle 音效後，須先離場再入場才可再播
var _paddle_hit_sound_armed_by_area_id: Dictionary = {}
var _court_half_areas: Array[Area2D] = []

func _ready():
	_spawn_global_position = global_position
	_cache_court_half_areas_from_paddles()
	reset_ball("")

## serving_side: "left" / "right" 為發球方（朝對手半場）；"" 則開局隨機
func prepare_between_rounds() -> void:
	direction = Vector2.ZERO
	velocity = Vector2.ZERO
	global_position = _spawn_global_position


func reset_ball(serving_side: String = "") -> void:
	global_position = _spawn_global_position
	var base: Vector2
	if serving_side == "left":
		base = Vector2.RIGHT
	elif serving_side == "right":
		base = Vector2.LEFT
	else:
		base = Vector2.RIGHT if randf() < 0.5 else Vector2.LEFT
	direction = base.rotated(randf_range(-0.5, 0.5)).normalized()


func _cache_court_half_areas_from_paddles() -> void:
	_court_half_areas.clear()
	for rel in ["../Paddle_Left", "../Paddle_Right"]:
		var paddle := get_node_or_null(rel) as Node
		if paddle == null:
			continue
		var area_raw: Variant = paddle.get("ai_side_area")
		if area_raw is Area2D:
			var half_area: Area2D = area_raw
			if not _court_half_areas.has(half_area):
				_court_half_areas.append(half_area)


func _rearm_paddle_hit_sound_when_ball_exits_halves() -> void:
	for area in _court_half_areas:
		if not area.get_overlapping_bodies().has(self):
			_paddle_hit_sound_armed_by_area_id[area.get_instance_id()] = true


func _paddle_ai_side_area(collider: Node) -> Area2D:
	var v: Variant = collider.get("ai_side_area")
	return v as Area2D if v is Area2D else null


func _physics_process(delta):
	_rearm_paddle_hit_sound_when_ball_exits_halves()
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)

	if collision:
		var collider = collision.get_collider()
		if collider != null and collider.is_in_group("paddle"):
			var half: Area2D = _paddle_ai_side_area(collider)
			var can_play := true
			if half != null:
				var id := half.get_instance_id()
				can_play = bool(_paddle_hit_sound_armed_by_area_id.get(id, true))
			if can_play:
				_sound.play_paddle_hit()
				if half != null:
					_paddle_hit_sound_armed_by_area_id[half.get_instance_id()] = false
			direction = direction.bounce(collision.get_normal())
			var offset: float = (global_position.y - collider.global_position.y) / 50.0
			direction = Vector2(direction.x, offset).normalized()
			if collider.has_method("on_ai_paddle_struck_ball_in_side"):
				collider.on_ai_paddle_struck_ball_in_side()
		else:
			direction = direction.bounce(collision.get_normal())
			if collider != null and collider.is_in_group("wall"):
				_sound.play_wall_hit()
