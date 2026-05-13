extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var knockback_power = 300.0 # Siła odrzutu w osi X

var is_hurt = false # Zmienna sprawdzająca, czy lisek właśnie obrywa

@onready var animation = get_node("AnimationPlayer")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# JEŚLI DOSTAJE OBRAŻENIA: ignorujemy sterowanie i tylko go przesuwamy
	if is_hurt:
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play("Jump")
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
		
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

# NOWA FUNKCJA OTRZYMYWANIA OBRAŻEŃ
func take_damage(knockback_dir: Vector2):
	is_hurt = true # Blokujemy sterowanie
	
	animation.play("Hurt") # Upewnij się, że w AnimationPlayer animacja nazywa się dokładnie tak
	
	# Ustawiamy prędkość odrzutu: w górę i w przeciwną stronę od potwora
	velocity.y = -250.0 
	velocity.x = knockback_dir.x * knockback_power
	
	# Czekamy, aż animacja bólu się skończy
	await animation.animation_finished
	
	is_hurt = false # Przywracamy sterowanie
	
	# Sprawdzamy, czy lisek zginął
	if Game.playerHP <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://main.tscn")
