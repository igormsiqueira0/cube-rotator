extends CanvasLayer

@export var cube: Node3D

var max_score = 0
var score = 0
var hearts_list : Array[TextureRect] = []
var health = 3
var can_take_damage: bool = true
var player_data: PlayerData

@onready var progress_bar: ProgressBar = $Control/MarginContainer/VBoxContainer/PanelContainer/ProgressBar
@onready var score_label: Label = $Control/MarginContainer/VBoxContainer/PanelContainer/ScoreLabel
@onready var max_score_label: Label = $Control/MarginContainer/VBoxContainer/HBoxContainer/MaxScoreLabel
@onready var damage_cooldown_timer: Timer = $DamageCooldownTimer

func _ready() -> void:
	player_data = ResourceLoader.load("user://PlayerData.tres")
	if player_data: max_score = player_data.max_score
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	progress_bar.max_value = max_score
	
	var hearts_parent = $Control/MarginContainer/HBoxContainer2
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	
	damage_cooldown_timer.timeout.connect(_on_damage_cooldown_timeout)

func increment_score() -> void:
	if health > 0:
		score += 1
		score_label.text = str(score)

func take_damage() -> void:
	if health > 0 and can_take_damage:
		can_take_damage = false
		damage_cooldown_timer.start(0.7)
		
		health -= 1
		cube.start_shake(0.7)
		update_heart_display()
	if health <= 0:
		lose()
		
func update_heart_display() -> void:
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health

func lose() -> void:
	if score <= max_score: return
	var save = PlayerData.new()
	save.max_score = score
	ResourceSaver.save(save, "user://PlayerData.tres")

func _on_damage_cooldown_timeout() -> void:
	can_take_damage = true

func _input(event):
	# PARA TESTE
	if Input.is_action_just_pressed("increment_score"): # btn esquerdo mouse
		increment_score()
	if Input.is_action_just_pressed("damage"): # btn direito do mouse
		take_damage()
	if Input.is_action_just_pressed("ui_restart"): # R
		get_tree().reload_current_scene()

func _process(delta: float) -> void:
	progress_bar.value = score
	max_score_label.text = str(max_score)
