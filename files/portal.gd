extends Area2D

signal player_entered(portal: Area2D)

func _ready():
	connect("body_entered", _on_body_entered)
	$Sprite2D.centered = true
	$Sprite2D.offset = Vector2.ZERO
	

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("player_entered", self)
