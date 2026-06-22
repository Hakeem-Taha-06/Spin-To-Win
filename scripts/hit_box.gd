extends Area2D

@onready var attacker = $".."

func get_damage() -> float:
	return attacker.DAMAGE
