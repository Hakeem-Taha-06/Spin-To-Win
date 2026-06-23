extends Node

var player_weapon := "Sword"
var player_speed := 200.0

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

func get_weapon(weapon_type: String,owner_type: String) -> PackedScene:
	return weapons[weapon_type][owner_type]
	
	
