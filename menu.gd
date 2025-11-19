extends Control

@onready var debug_label := $DebugLabel
@onready var test_button := $TestButton

func _ready():
	$VBoxContainer/GameDurationSelector.add_item("30 secondes", 30)
	$VBoxContainer/GameDurationSelector.add_item("60 secondes", 60)
	$VBoxContainer/GameDurationSelector.add_item("90 secondes", 90)

	$VBoxContainer/MusicSelector.add_item("Musique 1", 0)
	$VBoxContainer/MusicSelector.add_item("Musique 2", 1)
	$VBoxContainer/MusicSelector.add_item("Musique 3", 2)
	$VBoxContainer/MusicSelector.add_item("Musique 4", 3)

	#$VBoxContainer/ThemeButton.add_item("Bleu")
#	$VBoxContainer/ThemeButton.add_item("Classique")
	#$VBoxContainer/ThemeButton.add_item("Ippo")

	#$VBoxContainer/ThemeButton.connect("item_selected", _on_theme_button_item_selected)
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)

func _on_play_pressed():
	var duration = $VBoxContainer/GameDurationSelector.get_selected_id()
	var music_id = $VBoxContainer/MusicSelector.get_selected_id()

	var music_paths = [
		"res://music1.mp3",
		"res://music2.mp3",
		"res://music3.mp3",
		"res://music4.mp3"
	]

	Global.game_time = duration
	Global.selected_music = music_paths[music_id]

	get_tree().change_scene_to_file("res://Main.tscn")

func _on_test_button_pressed() -> void:
	print("test")

#func _on_theme_button_item_selected(index: int) -> void:
	#match index:
		#0:
		#	Global.background_texture = load("res://Going+Merry+2.jpg")
		#	Global.platform_color = Color(0.3, 0.7, 1.0)
		#1:
		#	Global.background_texture = load("res://wxj9avp9w0v51.webp")
	#		Global.platform_color = Color(1, 1, 1)
	#	2:
	#		Global.background_texture = load("res://Ippo_winning_against_Miyata_in_their_second_spar.webp")
	#		Global.platform_color = Color(0.1, 0.6, 0.2)

#	print("🎨 Thème choisi : ", Global.background_path)
