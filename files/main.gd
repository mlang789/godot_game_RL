extends Node2D

@onready var restart_block := $RestartBlock
@onready var TargetScene := preload("res://target.tscn")
@onready var target_counter_label := $CanvasLayer/TargetCounter
@onready var timer_label := $CanvasLayer/TimerLabel
@onready var final_score_label := $CanvasLayer/FinalScoreLabel
@onready var game_timer := $GameTimer
@onready var menu_button := $CanvasLayer/MenuButton
@onready var menu_dialog := $CanvasLayer/MenuDialog
@onready var PortalScene := preload("res://portal.tscn")
@onready var teleport_button := $CanvasLayer/MobileControls/TeleportButton

var active_portals := []
var teleport_cooldown := false

var target_count = 0
var game_time: int
var selected_music: String
var initial_game_time: int
var game_active = true

# Limites de la map
var map_bounds := Rect2(Vector2(53, 39), Vector2(1239 - 53, 650 - 39))

# Zone de spawn aléatoire
var spawn_area := [
	Vector2(-260, -340),
	Vector2(870, -340),
	Vector2(870, 220),
	Vector2(-260, 220)
]

func _ready():
	print("🧪 Test du singleton :", Global)
	print("🎮 Game time:", game_time)
	print("🎵 Selected music:", selected_music)
	Global.return_to_menu = false

	game_time = Global.game_time
	selected_music = Global.selected_music
	initial_game_time = game_time
	
	menu_button.pressed.connect(_on_menu_pressed)
	
	if selected_music != "":
		$MusicPlayer.stream = load(selected_music)
		$MusicPlayer.play() 
	
	start_game()
	restart_block.visible = false
	restart_block.monitoring = false
	restart_block.connect("restart_game", Callable(self, "_on_restart_game"))
	
	teleport_button.pressed.connect(_on_teleport_button_pressed)

	# Afficher bouton mobile si Android ou pas de manette
	if OS.get_name() == "Android" or Input.get_connected_joypads().size() == 0:
		teleport_button.visible = true
	else:
		teleport_button.visible = false

func _on_menu_pressed():
	menu_dialog.dialog_text = "Quitter la partie et revenir au menu ?"
	menu_dialog.get_ok_button().text = "Oui"
	menu_dialog.get_cancel_button().text = "Non"
	menu_dialog.popup_centered()
	
func _go_to_menu():
	get_tree().call_deferred("change_scene_to_file", "res://Menu.tscn")

func start_game():
	target_count = 0
	game_active = true
	final_score_label.visible = false
	update_target_counter()
	for i in range(3):
		spawn_target()
	game_timer.start()

func _on_timer_tick():
	if game_time > 0:
		game_time -= 1
		timer_label.text = "Temps : %ds" % game_time
	else:
		game_active = false
		timer_label.text = "Temps écoulé !"
		game_timer.stop()
		show_final_score()

func spawn_target():
	if not game_active:
		return
	var target = TargetScene.instantiate()
	add_child(target)
	target.position = get_random_spawn_point()
	target.connect("target_destroyed", Callable(self, "on_target_destroyed"))

func get_random_spawn_point() -> Vector2:
	var rand_x = randf_range(spawn_area[0].x, spawn_area[1].x)
	var rand_y = randf_range(spawn_area[0].y, spawn_area[2].y)
	return Vector2(rand_x, rand_y)

func on_target_destroyed():
	target_count += 1
	update_target_counter()
	spawn_target()

func update_target_counter():
	target_counter_label.text = "Cibles : %d" % target_count

func show_final_score():
	final_score_label.text = "Score final : %d" % target_count
	final_score_label.visible = true
	restart_block.visible = true
	restart_block.monitoring = true

func _on_restart_game():
	print("🔁 Partie redémarrée !")
	target_count = 0
	game_time = initial_game_time
	update_target_counter()
	timer_label.text = "Temps : %ds" % game_time
	final_score_label.visible = false
	game_active = true
	restart_block.visible = false
	restart_block.monitoring = false
	
	# Supprimer anciennes cibles
	for child in get_children():
		if child is Area2D and child.scene_file_path == "res://target.tscn":
			child.queue_free()

	for i in range(3):
		spawn_target()

	$GameTimer.start()
	
	# Redémarrer la musique
	if selected_music != "":
		$MusicPlayer.stream = load(selected_music)
	$MusicPlayer.stop()
	$MusicPlayer.play()

func create_portal_at_player():
	if teleport_cooldown:
		print("⛔ Refusé : cooldown actif")
		return
	print("✨ Création portail...")
	print("✨ Création d’un portail demandée")
	teleport_cooldown = true

	if active_portals.size() >= 2:
		active_portals[0].queue_free()
		active_portals.remove_at(0)

	var portal = PortalScene.instantiate()
	portal.global_position = $Player.global_position
	add_child(portal)
	portal.connect("player_entered", Callable(self, "_on_player_entered_portal"))
	active_portals.append(portal)

	print("⏳ attente cooldown")
	await get_tree().create_timer(0.5).timeout
	teleport_cooldown = false
	print("✅ cooldown terminé")

func _on_player_entered_portal(portal):
	if teleport_cooldown or active_portals.size() < 2:
		return

	teleport_cooldown = true

	var other_portal = active_portals[0] if active_portals[1] == portal else active_portals[1]
	var offset := Vector2(50, 0)
	if $Player.global_position.x > portal.global_position.x:
		offset = Vector2(-50, 0)

	var new_pos = other_portal.global_position + offset

	# ✅ Limiter à la zone de jeu
	new_pos.x = clamp(new_pos.x, map_bounds.position.x, map_bounds.position.x + map_bounds.size.x)
	new_pos.y = clamp(new_pos.y, map_bounds.position.y, map_bounds.position.y + map_bounds.size.y)

	$Player.global_position = new_pos

	await get_tree().create_timer(0.5).timeout
	teleport_cooldown = false

func _on_game_timer_timeout() -> void:
	_on_timer_tick()

func _on_move_left_pressed() -> void:
	Input.action_press("move_left")

func _on_move_left_released() -> void:
	Input.action_release("move_left")

func _on_move_right_pressed() -> void:
	Input.action_press("move_right")

func _on_move_right_released() -> void:
	Input.action_release("move_right")

func _on_move_up_pressed() -> void:
	Input.action_press("move_up")

func _on_move_up_released() -> void:
	Input.action_release("move_up")

func _on_move_down_pressed() -> void:
	Input.action_press("move_down")

func _on_move_down_released() -> void:
	Input.action_release("move_down")

func _on_kick_pressed() -> void:
	Input.action_press("kick")

func _on_kick_released() -> void:
	Input.action_release("kick")

func _on_dash_pressed() -> void:
	Input.action_press("dash")

func _on_dash_released() -> void:
	Input.action_release("dash")

func _on_menu_dialog_confirmed() -> void:
	Global.return_to_menu = true

func _process(_delta):
	if Input.is_action_just_pressed("create_portal"):
		create_portal_at_player()
	if Global.return_to_menu:
		Global.return_to_menu = false
		get_tree().change_scene_to_file("res://Menu.tscn")

func _on_teleport_button_pressed() -> void:
	create_portal_at_player()
