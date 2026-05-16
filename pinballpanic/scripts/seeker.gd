extends CharacterBody2D

@export var speed: float = 120.0
var hp: int = 5
var player: Node2D = null
@onready var sprite = $AnimatedSprite2D
var facing_direction := 1  
var knockback: Vector2 = Vector2.ZERO 

func _ready():
	add_to_group("Enemy") 
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	if player:
		var direction = global_position.direction_to(player.global_position)
		if is_on_floor() and player.global_position.y > global_position.y:
			direction.y = 0 
			direction.x = facing_direction
			direction = direction.normalized()
		elif is_on_ceiling() and player.global_position.y < global_position.y:
			direction.y = 0
			direction.x = facing_direction
			direction = direction.normalized()
		if is_on_wall():
			facing_direction *= -1
			direction.x = facing_direction
		velocity = (direction * speed) + knockback
		knockback = knockback.move_toward(Vector2.ZERO, 1500 * delta)
		if velocity.x > 0:
			facing_direction = 1  
		elif velocity.x < 0:
			facing_direction = -1 
			
		move_and_slide()
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider and collider.is_in_group("Player"):
				if collider.has_method("take_damage"):
					collider.take_damage(1)
					knockback = -direction * 400 
					
		update_animation()

func take_damage(amount: int, push_dir: Vector2 = Vector2.ZERO):
	hp -= amount
	if push_dir != Vector2.ZERO:
		print("Swing! kena pukul Player! Sisa HP: ", hp)
		knockback = push_dir * 600 
		GameManager.trigger_hit_pause(0.08) # Waktu berhenti agak lama biar dramatis!
		GameManager.trigger_screen_shake(15.0) # Layar getar keras!
	else:
		print("Bamm! kena pantulan Bola! Sisa HP: ", hp)
		GameManager.trigger_hit_pause(0.03) # Waktu berhenti sebentar
		GameManager.trigger_screen_shake(8.0) # Getar lumayan
	
	if hp <= 0:
		if push_dir != Vector2.ZERO:
			print("Melee Kill")
		else:
			print("Pinball Kill")
		queue_free()

func update_animation():
	sprite.flip_h = facing_direction < 0
	if velocity.length() > 0:
		sprite.play("run")
	else:
		sprite.play("idle")
