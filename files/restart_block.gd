extends Area2D

signal restart_game

func _ready():
	monitoring = true
	set_process(true)

func _process(_delta):
	for body in get_overlapping_bodies():
		if body.name == "Player" and body.is_attacking:
			print("🟦 Bloc frappé !")
			emit_signal("restart_game")
