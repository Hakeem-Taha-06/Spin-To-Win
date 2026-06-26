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
	"res://scenes/levels/level2.tscn",
	"res://scenes/levels/level3.tscn",
	"res://scenes/levels/level4.tscn",
]

var total_score := 0.0
var scores := []
const MAX_LEADERBOARD_SIZE := 10
#scores = [
#	{"name": "name1", "score": 1000},
#	{"name": "name2", "score": 500},
#]


func _ready() -> void:
	MusicManager.play_menu_music()
	load_settings()
	
func start_game():
	player_speed = 200.0
	player_health = 100.0
	player_damage = 10.0
	total_score = 0
	current_level = 0
	save_settings()
	# MusicManager.play_game_music() # this will be handled by the first level
	MusicManager.stop_music()
	get_tree().change_scene_to_file(levels[0])
	
func end_level():
	current_level += 1
	if current_level >= levels.size():
		MusicManager.play_menu_music()
		get_tree().change_scene_to_file("res://scenes/end_menu.tscn")
	else:
		MusicManager.play_game_music()
		get_tree().change_scene_to_file("res://scenes/levels/between_levels.tscn")
		
func next_level():
	MusicManager.play_game_music()
	get_tree().change_scene_to_file(levels[current_level])

func to_leaderboard():
	MusicManager.play_menu_music()
	get_tree().change_scene_to_file("res://scenes/scores_menu.tscn")
	
func to_main_menu():
	MusicManager.play_menu_music()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func game_over():
	Engine.time_scale = 0.2
	get_tree().create_timer(2.0, true, false, true).timeout.connect(
		func(): 
			get_tree().change_scene_to_file("res://scenes/end_menu.tscn")
			Engine.time_scale = 1.0
			MusicManager.play_menu_music()
	)

func quit_game():
	get_tree().quit(0)

func get_weapon(weapon_type: String,owner_type: String) -> PackedScene:
	return weapons[weapon_type][owner_type]
	
func save_settings():
	var config = ConfigFile.new()
	config.load(SETTINGS_PATH)
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

func load_scores() -> Array:
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return []
	return config.get_value("leaderboard", "entries", [])
	
func save_scores(leaderboard: Array):
	var config = ConfigFile.new()
	config.load(SETTINGS_PATH)
	scores = leaderboard
	config.set_value("leaderboard", "entries", leaderboard)
	config.save(SETTINGS_PATH)
	
@warning_ignore("shadowed_variable_base_class") #im not using it anyways
func add_score(name: String, score: int):
	var leaderboard = load_scores()
	leaderboard.append({"name": name, "score": score})
	
	leaderboard.sort_custom(func(a,b): return a["score"]>b["score"])
	if leaderboard.size() > MAX_LEADERBOARD_SIZE:
		leaderboard.resize(MAX_LEADERBOARD_SIZE)
	save_scores(leaderboard)
	
