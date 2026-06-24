extends Node

const SETTINGS_PATH = "user://settings.cfg"

var player_weapon := "Sword"
var player_speed := 200.0
var player_health := 100.0
var player_damage := 10.0

var weapons = {
	"Sword": 
		{ 
			"player": preload("res://scenes/weapons/player/player_sword.tscn"),
			"enemy": preload("res://scenes/weapons/enemy/enemy_sword.tscn"),
		} ,
	"Axe"  : 
		{ 
			"player": preload("res://scenes/weapons/player/player_axe.tscn"),
			"enemy": preload("res://scenes/weapons/enemy/enemy_axe.tscn"),
		} ,
	"Spear":  
		{ 
			"player": preload("res://scenes/weapons/player/player_spear.tscn"),
			"enemy": preload("res://scenes/weapons/enemy/enemy_spear.tscn"),
		} ,
}

var current_level := 0
var weapon_list = weapons.keys()

var levels = [
	"res://scenes/levels/level1.tscn",
]

var total_score := 0.0

func _ready() -> void:
	load_settings()
	
func start_game():
	get_tree().change_scene_to_file(levels[0])
	
func end_level():
	current_level += 1
	if current_level >= levels.size():
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		#switch to end screen or boss level
	else:
		get_tree().change_scene_to_file("res://scenes/levels/between_levels.tscn")
		
func next_level():
	get_tree().change_scene_to_file(levels[current_level])

func get_weapon(weapon_type: String,owner_type: String) -> PackedScene:
	return weapons[weapon_type][owner_type]
	
func save_settings():
	var config = ConfigFile.new()
	config.set_value("player", "health", player_health)
	config.set_value("player", "damage", player_damage)
	config.set_value("player", "speed", player_speed)
	config.set_value("player", "weapon", player_weapon)
	config.save(SETTINGS_PATH)
	
func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	if err != OK:
		return
	player_health = config.get_value("player", "health", player_health)
	player_damage = config.get_value("player", "damage", player_damage)
	player_speed  = config.get_value("player", "speed", player_speed)
	player_weapon = config.get_value("player", "weapon", player_weapon)
