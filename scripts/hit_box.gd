extends Area2D
class_name  Hitbox

@onready var player: Player = $".."

func get_damage() -> float:
	return player.DAMAGE
