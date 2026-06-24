extends Control

@onready var weapon_list = $VBoxContainer/WeaponList
@onready var start_button = $VBoxContainer/StartButton
@onready var speed_value = $SpeedValue


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weapon_list.add_item("Sword")
	weapon_list.add_item("Axe")
	weapon_list.add_item("Spear")
	
	start_button.pressed.connect(_on_start_button_pressed)
	# find and select the saved weapon in the list
	for i in weapon_list.item_count:
		if weapon_list.get_item_text(i) == GameState.player_weapon:
			weapon_list.select(i)
			break

func _on_start_button_pressed():
	var selected_weapon: String = weapon_list.get_item_text(weapon_list.selected)
	GameState.player_weapon = selected_weapon
	GameState.save_settings()
	GameState.start_game()
