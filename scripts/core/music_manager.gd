extends Node

var music_player: AudioStreamPlayer

var MENU_MUSIC = preload("res://assets/sound/menu_theme.ogg")
var GAME_MUSIC = preload("res://assets/sound/waltz_in_G.ogg")

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.volume_db = 0.0

func play_menu_music():
	if music_player.playing and music_player.stream == MENU_MUSIC:
		return
	music_player.stream = MENU_MUSIC
	music_player.play()
	
func play_game_music():
	if music_player.playing and music_player.stream == GAME_MUSIC:
		return
	music_player.stream = GAME_MUSIC
	music_player.play()

func stop_music():
	music_player.stop()
