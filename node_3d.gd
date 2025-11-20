extends Node3D

var tween: Tween

func _process(delta: float) -> void:
	if tween and tween.is_running() or Global.health <= 0:
		return
	
	if Input.is_action_just_pressed("ui_up"):
		apply_rotation(Vector3.RIGHT, PI/2)
	elif Input.is_action_just_pressed("ui_down"):
		apply_rotation(Vector3.RIGHT, -PI/2)
	elif Input.is_action_just_pressed("ui_left"):
		apply_rotation(Vector3.UP, PI/2)
	elif Input.is_action_just_pressed("ui_right"):
		apply_rotation(Vector3.UP, -PI/2)

func apply_rotation(axis: Vector3, angle: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	var new_transform = transform.rotated(axis, angle).orthonormalized()
	
	tween.tween_property(self, "transform", new_transform, 0.3)
