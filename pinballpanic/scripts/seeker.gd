extends CharacterBody2D

@export var speed: float = 120.0
var hp: int = 5
var player: Node2D = null
@onready var sprite = $AnimatedSprite2D

var facing_direction := 1  

func _ready():
	add_to_group("Enemy") 
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta):
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
		velocity = direction * speed
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
					global_position -= direction * 50 
					
		update_animation()

func take_damage(amount: int, push_dir: Vector2 = Vector2.ZERO):
	hp -= amount
	if push_dir != Vector2.ZERO:
		print("Swing! kena pukul Player! Sisa HP: ", hp)
		global_position += push_dir * 50 
	else:
		print("Bamm! kena pantulan Bola! Sisa HP: ", hp)
	
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
