extends Node2D

@onready var message_label: Label = $MessageLabel
@onready var combo_label: Label = $ComboLabel
@onready var score_label: Label = $ScoreLabel

var label_visible_cooldown := 2.0
var label_visible_timer := 0.0

var in_level_end_cooldown := false
var level_end_cooldown := 2.0
var level_end_timer := 0.0

var accumulative_score := 0.0
var combo_multiplier := 1.0
var combo_timer := 0.0
var combo_cooldown := 3.0
var in_combo_time := false
var combo_label_start_scale = Vector2.ONE

func _ready() -> void:
	SignalBus.enemy_hit.connect(_on_enemy_hit)
	SignalBus.enemy_died.connect(_on_enemy_died)
	
	await level_start_cooldown()

func level_start_cooldown():
	Engine.time_scale = 0.0
	message_label.visible = true
	
	for i in range(3, 0, -1):
		message_label.text = str(i)
		await get_tree().create_timer(1.0, true, false, true).timeout
	
	message_label.text = "GO!"
	label_visible_timer = label_visible_cooldown
	Engine.time_scale = 1.0

func _process(delta: float) -> void:
	
	if get_tree().get_nodes_in_group("enemy").is_empty() and not in_level_end_cooldown:
		in_level_end_cooldown = true
		level_end_timer = level_end_cooldown
		message_label.text = "NICE"
		
	if in_combo_time:
		var t = combo_timer/combo_cooldown
		# can shrink to (0.2, 0.2), and starts at whatever is set in combo_label_start_scale
		combo_label.scale = (Vector2.ONE/5).lerp(combo_label_start_scale, t)
	
	score_label.text = "Total Score: " + str(int(GameState.total_score)) +" Level Score: "+ str(int(accumulative_score))
	
	cooldowns(delta)

func _on_enemy_hit():
	combo_multiplier += 1.0
	combo_timer = combo_cooldown
	in_combo_time = true
	combo_label.rotation = deg_to_rad(randi_range(-15, 15))
	combo_label.scale = combo_label_start_scale
	combo_label.visible = true
	combo_label.text = "x" + str(combo_multiplier)

func _on_enemy_died():
	accumulative_score += 200 * combo_multiplier

func cooldowns(delta: float):
	if message_label.visible and label_visible_timer >= 0:
		label_visible_timer -= delta
	elif not in_level_end_cooldown:
		message_label.visible = false
		
	if in_combo_time:
		if combo_timer >= 0:
			combo_timer -= delta
		else:
			in_combo_time = false
			combo_multiplier = 1.0
			combo_label.visible = false
	
	if in_level_end_cooldown:
		if level_end_timer >= 0:
			level_end_timer -= delta
		else:
			GameState.total_score += accumulative_score
			GameState.end_level()
