extends CanvasLayer

@export var cube: Node3D

var max_score = 0
var score = 0
var hearts_list : Array[TextureRect] = []
var can_take_damage: bool = true
var player_data: PlayerData

var indicator_directions = ["up", "down", "left", "right"]
var indicator_types = ["arrow", "finger", "text"]
var indicator_symbols = {
	"up":    ["↑", "👆", "UP"],
	"down":  ["↓", "👇", "DOWN"],
	"left":  ["←", "👈", "LEFT"],
	"right": ["→", "👉", "RIGHT"]
}
var indicators = []
var majority_direction = ""
var num_directions = indicator_directions.size()
var num_types = indicator_types.size()

@onready var indicator_container: HBoxContainer = $Control/MarginContainer/IndicatorsContainer
# TODO: ensure one direction is most frequent

@onready var progress_bar: ProgressBar = $Control/MarginContainer/VBoxContainer/PanelContainer/ProgressBar
@onready var score_label: Label = $Control/MarginContainer/VBoxContainer/PanelContainer/ScoreLabel
@onready var max_score_label: Label = $Control/MarginContainer/VBoxContainer/HBoxContainer/MaxScoreLabel
@onready var damage_cooldown_timer: Timer = $DamageCooldownTimer

func _ready() -> void:
	player_data = ResourceLoader.load("user://PlayerData.tres")
	if player_data: max_score = player_data.max_score
	progress_bar.max_value = max_score

	var hearts_parent = $Control/MarginContainer/HBoxContainer2
	for child in hearts_parent.get_children():
		hearts_list.append(child)

	damage_cooldown_timer.timeout.connect(_on_damage_cooldown_timeout)

	generate_and_render_indicators()

func generate_and_render_indicators():
	indicators.clear()
	var direction_count = {"up": 0, "down": 0, "left": 0, "right": 0}
	
	# number of indicators
	var total = randi_range(3, 11)
	# ensure majority direction
	majority_direction = indicator_directions[randi() % num_directions]
	var min_majority = int(total / 2) + 1
	var majority_count = randi_range(min_majority, total)
	direction_count[majority_direction] = majority_count
	# add majority indicators first
	for i in majority_count:
		var type_idx = randi() % num_types
		var symbol = indicator_symbols[majority_direction][type_idx]
		indicators.append(
			{"direction": majority_direction, "type": indicator_types[type_idx], "symbol": symbol}
		)

	# add remaining indicators
	var remaining = total - majority_count
	var other_directions = indicator_directions.duplicate()
	other_directions.erase(majority_direction)
	for i in remaining:
		var dir = other_directions[randi() % (num_directions - 1)]
		var type_idx = randi() % num_types
		var symbol = indicator_symbols[dir][type_idx]
		indicators.append(
			{"direction": dir, "type": indicator_types[type_idx], "symbol": symbol}
		)
		direction_count[dir] += 1

	# shuffle indicators
	indicators.shuffle()

	render_indicators()

func render_indicators():
	for child in indicator_container.get_children():
		child.queue_free()
	for ind in indicators:
		var lbl = Label.new()
		lbl.text = str(ind["symbol"])
		lbl.add_theme_color_override("font_color", Color(1,1,1))
		lbl.add_theme_font_size_override("font_size", 30)
		indicator_container.add_child(lbl)

func next_round():
	generate_and_render_indicators()

func evaluate(input_direction: String) -> void:
	if Global.health <= 0: return
	if input_direction == majority_direction:
		increment_score()
	else:
		take_damage()
	next_round()

func increment_score() -> void:
	if Global.health > 0:
		score += 1
		score_label.text = str(score)

func take_damage() -> void:
	if Global.health > 0 and can_take_damage:
		can_take_damage = false
		damage_cooldown_timer.start(0.7)
		
		Global.health -= 1
		cube.start_shake(0.7)
		update_heart_display()
	if Global.health <= 0:
		lose()
		
func update_heart_display() -> void:
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < Global.health

func lose() -> void:
	if score <= max_score: return
	var save = PlayerData.new()
	save.max_score = score
	ResourceSaver.save(save, "user://PlayerData.tres")

func _on_damage_cooldown_timeout() -> void:
	can_take_damage = true

func _input(event):
	# PARA TESTE
	if Input.is_action_just_pressed("ui_left"):
		evaluate("left")
	if Input.is_action_just_pressed("ui_right"):
		evaluate("right")
	if Input.is_action_just_pressed("ui_up"):
		evaluate("up")
	if Input.is_action_just_pressed("ui_down"):
		evaluate("down")
	if Input.is_action_just_pressed("ui_restart"): # R
		get_tree().reload_current_scene()
		Global.health = 3
	if Input.is_action_just_pressed("ui_accept"): # ENTER for next round (example)
		next_round()

func _process(delta: float) -> void:
	progress_bar.value = score
	max_score_label.text = str(max_score)
