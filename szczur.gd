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
		velocity.x = SPEED_IDLE
		
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
	#if body.name == "Player":
		#death()
		pass
