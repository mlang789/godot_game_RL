extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -560.0
const GRAVITY = 1000
const FAST_FALL_SPEED = 4000.0

const DASH_SPEED = 800.0
const DASH_DURATION = 0.25
const WAVEDASH_WINDOW = 0.15

var is_dashing = false
var dash_direction = 0
var last_direction = 1
var is_fast_falling = false
var has_jumped = false
var can_double_jump = false
var is_attacking = false
var is_crouching = false
var can_wavedash = false
var target_count = 0
# Pour le double-tap
var tap_time_threshold := 0.25
var last_left_tap_time := -1.0
var last_right_tap_time := -1.0


func _physics_process(delta):
	var direction = 0

	

	if Input.is_action_pressed("move_left"):
		direction -= 1
	if Input.is_action_pressed("move_right"):
		direction += 1

	if direction != 0:
		last_direction = direction

	# Nouveau : détection du double-tap gauche/droite
	_check_double_tap(delta)


	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
	else:
		velocity.x = direction * SPEED

	$AnimatedSprite2D.flip_h = direction < 0

	# GRAVITÉ + SAUTS + FAST FALL + CROUCH
	if not is_on_floor():
		# WALL JUMP
		if Input.is_action_just_pressed("move_up") and is_touching_wall():
			velocity.y = JUMP_VELOCITY
			if is_on_wall_left():
				velocity.x = SPEED * 1.2
			else:
				velocity.x = -SPEED * 1.2
			can_double_jump = true
			has_jumped = true

		# DOUBLE JUMP
		elif Input.is_action_just_pressed("move_up") and can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false

		# FAST FALL
		if Input.is_action_pressed("move_down"):
			is_fast_falling = true
			velocity.y += FAST_FALL_SPEED * delta
		else:
			is_fast_falling = false
			velocity.y += GRAVITY * delta
	else:
		is_fast_falling = false
		has_jumped = false
		can_double_jump = false

		# SAUT
		if Input.is_action_just_pressed("move_up"):
			velocity.y = JUMP_VELOCITY
			has_jumped = true
			can_double_jump = true
			
		if Input.is_action_just_pressed("dash") and not is_dashing:
			start_dash()


		# CROUCH (au sol uniquement)
		if Input.is_action_pressed("move_down"):
			if not is_crouching:
				start_crouch()
		else:
			is_crouching = false

	# ATTAQUE
	if Input.is_action_just_pressed("kick"):
		start_attack()

	# ANIMATIONS
	var animated_sprite = $AnimatedSprite2D
	if is_attacking:
		animated_sprite.play("kick")
	elif is_dashing:
		animated_sprite.play("dash")
	elif is_crouching:
		animated_sprite.play("crouch")
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("default")

	move_and_slide()




# DASH / WAVEDASH
func start_dash():
	if last_direction == 0:
		last_direction = 1

	is_dashing = true
	dash_direction = last_direction

	# Nouvelle méthode wavedash : dans les airs + S + direction
	if not is_on_floor() and Input.is_action_pressed("move_down") and dash_direction != 0:
		print("💨 WAVEDASH déclenché (nouvelle méthode)")
		velocity.x = dash_direction * DASH_SPEED * 1.5
		velocity.y = 200
		if $WavedashSound:
			$WavedashSound.play()
	else:
		velocity.x = dash_direction * DASH_SPEED


	if $DashSound:
		$DashSound.play()

	if $DashFX:
		$DashFX.visible = true

		if $AnimatedSprite2D.flip_h:
			$DashFX.scale.x = -1
		else:
			$DashFX.scale.x = 1

		if $DashFX.has_method("restart"):
			$DashFX.restart()

		await get_tree().create_timer(0.1).timeout
		$DashFX.visible = false

	await get_tree().create_timer(DASH_DURATION).timeout
	is_dashing = false

# CROUCH
func start_crouch():
	is_crouching = true
	can_wavedash = true
	$AnimatedSprite2D.play("crouch")

	await get_tree().create_timer(WAVEDASH_WINDOW).timeout
	can_wavedash = false

# ATTAQUE
func start_attack():
	is_attacking = true
	if $AttackTimer:
		$AttackTimer.start()

func _on_attack_timer_timeout():
	is_attacking = false

# DÉTECTION MURS
func is_touching_wall() -> bool:
	return is_on_wall_left() or is_on_wall_right()

func is_on_wall_left() -> bool:
	return test_move(global_transform, Vector2(-1, 0))

func is_on_wall_right() -> bool:
	return test_move(global_transform, Vector2(1, 0))

# RESET JUMPS
func reset_jumps():
	has_jumped = false
	can_double_jump = true
	
func _check_double_tap(delta):
	var current_time = Time.get_ticks_msec() / 1000.0  # secondes

	if Input.is_action_just_pressed("move_left"):
		if current_time - last_left_tap_time < tap_time_threshold:
			last_direction = -1
			start_dash()
		last_left_tap_time = current_time

	if Input.is_action_just_pressed("move_right"):
		if current_time - last_right_tap_time < tap_time_threshold:
			last_direction = 1
			start_dash()
		last_right_tap_time = current_time
