extends Control

@onready var music_selector := $OptionButton
@onready var play_button := $Button

# Liste des chemins de musiques (adapte selon tes fichiers)
var music_choices = {
	"Musique 1" : "res://Foregone Destruction (Facing Worlds) - Unreal Tournament.mp3", 
	"Musique 2" : "res://Gathers Under Night....mp3",
	"Musique 3" : "res://Timothy Seals - Chasing Voids (Unreal Tournament 4 CTF-BigRock).mp3"
}

func _ready():
	for name in music_choices.keys():
		music_selector.add_item(name)

	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed():
	var selected_name = music_selector.get_item_text(music_selector.get_selected())
	var music_path = music_choices.get(selected_name, "")
	
	var packed_scene = preload("res://main.tscn")
	var main = packed_scene.instantiate()
	main.set("selected_music", music_path)  # 💡 on transmet le chemin de musique
	get_tree().root.add_child(main)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = main
