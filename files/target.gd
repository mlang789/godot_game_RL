extends Area2D

signal target_destroyed

func _ready():
	print("Cible prête !")

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.name == "Player":
			if body.is_attacking:
				print("💥 CIBLE DÉTRUITE PAR OVERLAP")
				
				if body.has_method("reset_jumps"):
					body.reset_jumps()
				
				if $BreakSound:
					$BreakSound.play()
					
				emit_signal("target_destroyed")
				queue_free()
			else:
				print("👀 Le joueur touche, mais n'attaque pas")
