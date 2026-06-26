extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer

@onready var weapon_list = $VBoxContainer/WeaponList
@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button: Button = $VBoxContainer/HBoxContainer/QuitButton
@onready var help_button: Button = $VBoxContainer/HBoxContainer/HelpButton
@onready var back_button: Button = $BackButton
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var title: Label = $Title
@onready var instructions_label: Label = $InstructionsLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weapon_list.add_item("Sword")
	weapon_list.add_item("Axe")
	weapon_list.add_item("Spear")
	
	back_button.visible = false
	instructions_label.visible = false
	
	
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	help_button.pressed.connect(_on_help_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	# find and select the saved weapon in the list
	for i in weapon_list.item_count:
		if weapon_list.get_item_text(i) == GameState.player_weapon:
			weapon_list.select(i)
			break

func _process(delta: float) -> void:
	sprite_2d.rotation = (get_global_mouse_position() - sprite_2d.global_position).angle() - 90

func _on_start_button_pressed():
	var selected_weapon: String = weapon_list.get_item_text(weapon_list.selected)
	GameState.player_weapon = selected_weapon
	GameState.save_settings()
	GameState.to_story_menu()
	
func _on_quit_button_pressed():
	GameState.quit_game()
	
func _on_help_button_pressed():
	v_box_container.visible = false
	title.visible = false
	back_button.visible = true
	instructions_label.visible = true
	
	
func _on_back_button_pressed():
	v_box_container.visible = true
	title.visible = true
	back_button.visible = false
	instructions_label.visible = false
