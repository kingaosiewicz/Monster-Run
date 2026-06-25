extends CharacterBody2D

const SPEED = 300.0
const ICE_SPEED = 550.0
const SAND_SPEED = 100.0 # DODANE: Bardzo wolna prędkość na piasku
const JUMP_VELOCITY = -400.0
var knockback_power = 300.0

var is_hurt = false
var is_dead = false 

@onready var animation = get_node("AnimationPlayer")
@onready var game_over_screen = $CanvasLayer

func _ready() -> void:
	Game.time = 0.0          # Zerujemy zegar na starcie
	Game.timer_active = true # Uruchamiamy odliczanie
	Game.Gold = 0
	Game.playerHP = 10

func _physics_process(delta: float) -> void:
	# DODANE: Sprawdzanie wpadnięcia do wody / przepaści
	# Jeśli lisek spadnie poniżej 800 pikseli na osi Y (możesz zwiększyć tę wartość, 
	# jeśli Twoja mapa jest głębsza), ginie na miejscu bez odrzutu.
	if not is_dead and not is_hurt and Game.timer_active:
		Game.time += delta # Stoper nalicza sekundy
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play("Jump")
		$DzwiekSkoku.play() 
	
	# WYJŚCIE DO MENU (Klawisz ESC)
	if Input.is_action_just_pressed("ui_cancel"):
		# Upewnij się, że ścieżka poniżej prowadzi do Twojego menu głównego!
		get_tree().change_scene_to_file("res://level-scenes/main.tscn")
		
		
	if global_position.y > 400 and not is_dead:
		Game.playerHP = 0
		die(Vector2.ZERO) # Vector2.ZERO = śmierć w miejscu
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_dead:
		if is_on_floor():
			# Pozwala liskowi odlecieć przy uderzeniu, ale zatrzymuje go po lądowaniu.
			velocity.x = move_toward(velocity.x, 0, 2.0)
			
		move_and_slide()
		return

	if is_hurt:
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play("Jump")
	
	# --- 1. SPRAWDZANIE NAWIERZCHNI (Lód i Piasek) ---
	var on_ice = false
	var on_sand = false
	
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider() # Zapisujemy obiekt, z którym się zderzyliśmy
			
			# ZABEZPIECZENIE: Upewniamy się, że obiekt istnieje, zanim sprawdzimy jego nazwę!
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
		
	# --- 2. RUCH LISKA (zależnie od nawierzchni) ---
	if on_ice:
		# LIS JEST NA LODZIE
		if direction:
			velocity.x = move_toward(velocity.x, direction * ICE_SPEED, 10.0) 
			if velocity.y == 0:
				animation.play("Run")
		else:
			velocity.x = move_toward(velocity.x, 0, 0.5) 
			if velocity.y == 0:
				animation.play("Idle")
	elif on_sand:
		# LIS JEST NA PIASKU
		if direction:
			velocity.x = direction * SAND_SPEED # Ograniczona, powolna prędkość
			if velocity.y == 0:
				animation.play("Run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED) # Zwykłe zatrzymanie
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
	if is_dead or is_hurt: 
		return 
		
	$DzwiekBolu.play()
	
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
