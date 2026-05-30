extends CharacterBody2D

@export var speed: float = 120.0
var hp: int = 5
var player: Node2D = null
@onready var sprite = $AnimatedSprite2D
var facing_direction := 1  
var knockback: Vector2 = Vector2.ZERO 
@onready var hit_sound = $HitSound
@onready var death_sound = $DeathSound


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
		if GameManager.current_wave == 1:
			velocity = knockback 
		else:
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
	sprite.play("damaged")
	
	if push_dir != Vector2.ZERO:
		print("Swing! kena pukul Player! Sisa HP: ", hp)
		knockback = push_dir * 600 
		GameManager.trigger_hit_pause(0.08) 
		GameManager.add_score(10)
	else:
		print("Bamm! kena pantulan Bola! Sisa HP: ", hp)
		GameManager.trigger_hit_pause(0.03) 
		GameManager.trigger_screen_shake(8.0) 
	
	if hp <= 0:
		if push_dir != Vector2.ZERO:
			print("Melee Kill")
		else:
			print("Pinball Kill")
		GameManager.add_score(100)
		GameManager.trigger_screen_shake(4.0)
		if is_instance_valid(death_sound):
			death_sound.reparent(get_tree().current_scene)
			death_sound.play()
			
		queue_free()
	else:
		if is_instance_valid(hit_sound):
			hit_sound.play()
			
		await get_tree().create_timer(0.2).timeout
		if is_instance_valid(sprite): 
			sprite.play("hover")

func update_animation():

	
	if sprite.animation != "damaged":
		sprite.play("hover")
	if GameManager.current_wave <= 1:
		sprite.flip_h = false
		return
	else: 
		sprite.flip_h = facing_direction >0 	
		
		
		
		
		
			
		
