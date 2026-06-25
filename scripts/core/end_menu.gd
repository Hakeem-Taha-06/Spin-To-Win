extends Control

@onready var score_label: Label = $ScoreLabel
@onready var score_enter_label: Label = $ScoreEnterLabel
@onready var text_edit: LineEdit = $TextEdit
@onready var submit_button: Button = $SubmitButton


func _ready() -> void:
	score_label.text = "Total Score: " + str(int(GameState.total_score))
	submit_button.pressed.connect(_on_submit_button_pressed)
	
func _on_submit_button_pressed():
	var player_name = text_edit.text
	var score = int(GameState.total_score)
	GameState.add_score(player_name, score)
	GameState.to_leaderboard()
