extends Node

var player_weapon := "Sword"
var player_speed := 200.0

var weapons = {
	"Sword": preload("res://scenes/weapons/sword.tscn"),
	"Axe"  : preload("res://scenes/weapons/axe.tscn"),
	"Spear": preload("res://scenes/weapons/spear.tscn")
}

func get_weapon() -> PackedScene:
	return weapons.get(player_weapon, weapons["Sword"])
	
	
