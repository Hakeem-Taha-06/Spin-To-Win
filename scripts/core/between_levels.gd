extends Control

@onready var health_button: Button = $HealthButton
@onready var damage_button: Button = $DamageButton
@onready var speed_button: Button = $SpeedButton
@onready var score_label: Label = $ScoreLabel

var health_upgrade = 100
var damage_upgrade = 20
var speed_upgrade = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_button.pressed.connect(_on_health_pressed)
	damage_button.pressed.connect(_on_damage_pressed)
	speed_button.pressed.connect(_on_speed_pressed)
	
	score_label.text = "Score: " + str(int(GameState.total_score))
	
func _on_health_pressed():
	GameState.player_health += health_upgrade
	_proceed()

func _on_damage_pressed():
	GameState.player_damage += damage_upgrade
	_proceed()
	
func _on_speed_pressed():
	GameState.player_speed += speed_upgrade
	_proceed()
	
func _proceed():
	GameState.save_settings()
	GameState.next_level()
