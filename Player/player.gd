extends CharacterBody2D

const SPEED = 300.0
const ICE_SPEED = 550.0
const SAND_SPEED = 100.0 # DODANE: Bardzo wolna prędkość na piasku
const JUMP_VELOCITY = -400.0
var knockback_power = 300.0

var is_hurt = false
var is_dead = false 
var on_ladder = false

@onready var animation = get_node("AnimationPlayer")
@onready var game_over_screen = $CanvasLayer

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://level-scenes/main.tscn")
		
	if global_position.y > 400 and not is_dead:
		Game.playerHP = 0
		die(Vector2.ZERO)
		return

	# DRABINKA — musi być PRZED grawitacją
	if on_ladder:
		velocity.y = 0
		var vertical = Input.get_axis("ui_up", "ui_down")
		if vertical != 0:
			velocity.y = vertical * 150.0
		else:
			animation.play("Idle")
		var horizontal = Input.get_axis("ui_left", "ui_right")
		if horizontal != 0:
			velocity.x = horizontal * 100.0
		else:
			velocity.x = 0
		var pos_przed = global_position.y
		move_and_slide()
		print("Y przed: ", pos_przed, "  Y po: ", global_position.y)
		return

	# Grawitacja
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_dead:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, 2.0)
		move_and_slide()
		return

	if is_hurt:
		move_and_slide()
		return

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play("Jump")
	
	var on_ice = false
	var on_sand = false
	
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider != null:
				var collider_name = collider.name
				if collider_name == "lod":
					on_ice = true
				elif collider_name == "piasek":
					on_sand = true

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
		
	if on_ice:
		if direction:
			velocity.x = move_toward(velocity.x, direction * ICE_SPEED, 10.0) 
			if velocity.y == 0:
				animation.play("Run")
		else:
			velocity.x = move_toward(velocity.x, 0, 0.5) 
			if velocity.y == 0:
				animation.play("Idle")
	elif on_sand:
		if direction:
			velocity.x = direction * SAND_SPEED
			if velocity.y == 0:
				animation.play("Run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if velocity.y == 0:
				animation.play("Idle")
	else:
		if direction:
			velocity.x = direction * SPEED
			if velocity.y == 0:
				animation.play("Run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED) 
			if velocity.y == 0:
				animation.play("Idle")
	
	if velocity.y > 0:
		animation.play("Fall")

	move_and_slide()

# ZMIENIONA FUNKCJA OTRZYMYWANIA OBRAŻEŃ
func take_damage(knockback_dir: Vector2):
	if is_dead or is_hurt: 
		return 
	
	if Game.playerHP <= 0:
		die(knockback_dir) 
		return 
	
	is_hurt = true
	animation.play("Hurt")
	
	velocity.y = -250.0 
	velocity.x = knockback_dir.x * knockback_power
	
	await get_tree().create_timer(0.6).timeout
	is_hurt = false


# ZMIENIONA FUNKCJA ŚMIERCI
func die(knockback_dir: Vector2):
	is_dead = true
	animation.play("Death")
	
	# TA LINIJKA POKAZUJE NAPIS GAME OVER:
	game_over_screen.visible = true
	
	# Jeśli wektor uderzenia to ZERO (czyli woda), lisek po prostu opada w dół
	if knockback_dir == Vector2.ZERO:
		get_node("CollisionShape2D").set_deferred("disabled", true)
		velocity.y = 1.0 # powolne opadanie w dół
		velocity.x = 0
	else:
		velocity.y = -200.0 
		velocity.x = knockback_dir.x * (knockback_power / 2.0)
	
	await get_tree().create_timer(1.0).timeout
	
	Game.playerHP = 10 
	get_tree().change_scene_to_file("res://level-scenes/main.tscn")
	
func _on_drabinka_body_entered(body):
	print("ENTERED: ", body.name)
	if body == self:
		on_ladder = true
		print("ON LADDER TRUE")

func _on_drabinka_body_exited(body):
	print("EXITED: ", body.name)
	if body == self:
		on_ladder = false
