extends CharacterBody2D

const SPEED = 300.0
const ICE_SPEED = 550.0 # DODANE: Prędkość na lodzie (możesz ją dowolnie zwiększyć)
const JUMP_VELOCITY = -400.0
var knockback_power = 300.0

var is_hurt = false
var is_dead = false # NOWA ZMIENNA

@onready var animation = get_node("AnimationPlayer")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# JEŚLI NIE ŻYJE: pozwalamy mu tylko spadać, ignorujemy resztę
	if is_dead:
		move_and_slide()
		return

	if is_hurt:
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play("Jump")
	
	# --- 1. SPRAWDZANIE CZY STOIMY NA LODZIE ---
	var on_ice = false
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().name == "lod":
				on_ice = true
				# To wyświetli się na dole w konsoli, jeśli lisek faktycznie dotyka lodu!
				print("Lisek jest na lodzie!") 

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
		
	# --- 2. RUCH LISKA (zależnie od nawierzchni) ---
	if on_ice:
		# LIS JEST NA LODZIE
		if direction:
			# ZMIANA: Używamy ICE_SPEED. Dałem tu wartość 10.0 zamiast 5.0, 
			# żeby lisek miał szansę szybko dobić do tej wyższej prędkości!
			velocity.x = move_toward(velocity.x, direction * ICE_SPEED, 10.0) 
			if velocity.y == 0:
				animation.play("Run")
		else:
			# Hamowanie zostaje bez zmian (prawie w ogóle się nie zatrzymuje)
			velocity.x = move_toward(velocity.x, 0, 0.5) 
			if velocity.y == 0:
				animation.play("Idle")
	else:
		# LIS JEST NA ZIEMI (Standardowy ruch)
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
	if is_dead: return # Nie dostajemy obrażeń, jeśli już nie żyjemy
	
	# 1. SPRAWDZAMY CZY TO ŚMIERTELNY CIOS (Zanim zrobimy cokolwiek innego)
	if Game.playerHP <= 0:
		die(knockback_dir) # Od razu wywołujemy śmierć z kierunkiem uderzenia
		return # Przerywamy czytanie reszty tej funkcji!
	
	# 2. ZWYKŁE OBRYWANIE (Jeśli lisek ma jeszcze HP)
	is_hurt = true
	animation.play("Hurt")
	
	velocity.y = -250.0 
	velocity.x = knockback_dir.x * knockback_power
	
	# Czekamy na koniec animacji bólu
	await animation.animation_finished
	is_hurt = false


# ZMIENIONA FUNKCJA ŚMIERCI (Teraz przyjmuje wektor uderzenia)
func die(knockback_dir: Vector2):
	is_dead = true
	
	if animation.has_animation("Death"):
		animation.play("Death")
	
	get_node("CollisionShape2D").set_deferred("disabled", true)
	
	# Śmiertelny odrzut od żaby - lisek leci wyżej (-400) i w tył!
	velocity.y = -400.0 
	velocity.x = knockback_dir.x * knockback_power
	
	await get_tree().create_timer(2.0).timeout
	
	Game.playerHP = 10 
	get_tree().change_scene_to_file("res://level-scenes/main.tscn")
