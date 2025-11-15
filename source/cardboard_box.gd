extends Node3D

@export var shake_strength: float = 0.05

@onready var original_position: Vector3 = position
@onready var shake_timer: Timer = $ShakeTimer

func _ready():
	shake_timer.timeout.connect(_on_shake_timer_timeout)
	set_process(false)

func start_shake(duration: float):
	shake_timer.wait_time = duration
	shake_timer.start()
	set_process(true)

func _process(delta):
	var offset = Vector3(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength)
	)
	position = original_position + offset

func _on_shake_timer_timeout():
	set_process(false)
	position = original_position

func _init():
	set_process(false)
