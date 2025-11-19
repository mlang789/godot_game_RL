extends Control

@onready var label := $Label
@onready var button := $Button

func _ready():
	button.pressed.connect(_on_pressed)

func _on_pressed():
	label.text = "TOUCHE CLIQUÉE"
