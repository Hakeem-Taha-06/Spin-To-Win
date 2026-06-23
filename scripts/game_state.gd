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

var weapon_list = weapons.keys()

func _ready() -> void:
	load_settings()

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
