extends Node
## 集中播放 SFX。預設使用 res://resources/；可在 Autoload 檢視器覆寫。
## 每種音效擁有獨立 player pool（stream 在 _ready 預先綁好），play() 時零指派開銷。

@export var paddle_hit_sound: AudioStream = preload("res://resources/paddle_hit_sound.wav")
@export var wall_hit_sound: AudioStream = preload("res://resources/wall_hit_sound.wav")
@export var score_sound: AudioStream = preload("res://resources/get_piont.wav")

## 碰撞音的並發數（牆/拍可能連續快速觸發）
@export_range(1, 8) var collision_polyphony: int = 4
## 得分音通常一次只需一個
@export_range(1, 4) var score_polyphony: int = 2

var _paddle_pool: Array[AudioStreamPlayer] = []
var _wall_pool: Array[AudioStreamPlayer] = []
var _score_pool: Array[AudioStreamPlayer] = []


func _ready() -> void:
	_paddle_pool = _build_pool(paddle_hit_sound, collision_polyphony)
	_wall_pool   = _build_pool(wall_hit_sound,   collision_polyphony)
	_score_pool  = _build_pool(score_sound,       score_polyphony)


func play_paddle_hit() -> void:
	_play_pool(_paddle_pool)


func play_wall_hit() -> void:
	_play_pool(_wall_pool)


func play_score_point() -> void:
	_play_pool(_score_pool)


## 建立指定音效的 player pool，stream 預先綁定，播放時不再重新指派
func _build_pool(stream: AudioStream, count: int) -> Array[AudioStreamPlayer]:
	var pool: Array[AudioStreamPlayer] = []
	if stream == null:
		return pool
	for i in count:
		var p := AudioStreamPlayer.new()
		p.bus = &"Master"
		p.stream = stream   # 只在初始化時指派一次
		add_child(p)
		pool.append(p)
	return pool


## 找到未播放的 player 立即呼叫 play()，省去 stream 指派
func _play_pool(pool: Array[AudioStreamPlayer]) -> void:
	if pool.is_empty():
		return
	for p in pool:
		if not p.playing:
			p.play()
			return
	pool[0].play()  # 全滿時搶佔最舊的
