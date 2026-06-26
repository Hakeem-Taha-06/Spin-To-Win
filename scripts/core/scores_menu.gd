extends Control

@onready var leaderboard_container: VBoxContainer = $Leaderboard
@onready var return_button: Button = $ReturnButton

const FONT_SIZE = 40

func _ready() -> void:
	fill_leaderboard()
	return_button.pressed.connect(_on_return_button_pressed)

func fill_leaderboard()->void:
	var leaderboard = GameState.load_scores()
	var remaining_entries := GameState.MAX_LEADERBOARD_SIZE
	
	for i in leaderboard.size():
		var rank = str(i + 1)
		var player_name = leaderboard[i]["name"]
		var score = str(int(leaderboard[i]["score"]))
		
		var entry = create_entry(rank, player_name, score)
		
		leaderboard_container.add_child(entry)
		remaining_entries -= 1
	
	var filled_entries = GameState.MAX_LEADERBOARD_SIZE - remaining_entries
	for i in range(remaining_entries):
		var entry_index = i + filled_entries + 1
		var entry = create_entry(
		str(entry_index),
		"- - - - - - - - - - - - - - - - - - - - - - - - - - - -",
		"0"
		)
		leaderboard_container.add_child(entry)
		
func create_entry(rank: String, player_name: String, score: String) -> HBoxContainer:
	var entry = HBoxContainer.new()
	var name_label = Label.new()
	var score_label = Label.new()
	var rank_label = Label.new()
	
	rank_label.text = rank + "- "
	name_label.text = player_name
	score_label.text = score
	
	rank_label.custom_minimum_size = Vector2(30, 0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	rank_label.add_theme_font_size_override("font_size", FONT_SIZE)
	name_label.add_theme_font_size_override("font_size", FONT_SIZE)
	score_label.add_theme_font_size_override("font_size", FONT_SIZE)
	
	entry.add_child(rank_label)
	entry.add_child(name_label)
	entry.add_child(score_label)
	return entry
	
func _on_return_button_pressed():
	GameState.to_main_menu()
