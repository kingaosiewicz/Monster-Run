extends CharacterBody2D

var SPEED_IDLE = 30
var SPEED_CHASE = 100
var player
var chase = false

func _ready():
	get_node("AnimatedSprite2D").play("Idle")

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	
	if chase == true and player != null:
		if get_node("AnimatedSprite2D").animation != "Death":
			get_node("AnimatedSprite2D").play("Attack")
		var direction = (player.global_position - self.global_position).normalized()
		
		if direction.x > 0:
			get_node("AnimatedSprite2D").flip_h = true
		else:
			get_node("AnimatedSprite2D").flip_h = false
			
		velocity.x = direction.x * SPEED_CHASE
		
	else:
		if get_node("AnimatedSprite2D").animation != "Death":
			get_node("AnimatedSprite2D").play("Idle")
		velocity.x = -SPEED_IDLE
		get_node("AnimatedSprite2D").flip_h = false
		
	move_and_slide()


func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true
		player = body 


func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false
		player = null


func _on_player_death_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		death()

func _on_player_collision_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Game.is_invincible:
			return
		Game.playerHP -= 3

		
		# Obliczamy wektor kierunku - z której strony żaba uderzyła gracza
		var knockback_dir = (body.global_position - self.global_position).normalized()
			
		# Zamiast death(), wywołujemy nową funkcję w graczu:
		body.take_damage(knockback_dir)

func death():
	Game.Gold += 3
	Utils.saveGame()
	chase = false
	velocity.x = 0 
	get_node("CollisionShape2D").set_deferred("disabled", true)
	get_node("AnimatedSprite2D").play("Death")
	$DzwiekZgniatania.play()
	await get_node("AnimatedSprite2D").animation_finished
	self.queue_free()
