
extends Polygon2D

func _ready():
	# Affiche la zone de spawn en semi-transparent dans l'éditeur,
	# mais totalement invisible pendant le jeu.
	if Engine.is_editor_hint():
		modulate = Color(1, 1, 0, 0.2)  # jaune transparent
	else:
		modulate = Color(1, 1, 1, 0)    # totalement invisible
