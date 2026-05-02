extends CharacterBody2D

var base_speed: float = 400.0
var current_damage: int = 10
var is_deflected: bool = false

func _ready():
	add_to_group("Projectile")
	velocity = Vector2(-1, 0.5).normalized() * base_speed

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.name == "Player" or collider.is_in_group("Player"):
			if not is_deflected:
				if collider.has_method("take_damage"):
					collider.take_damage(1)
				queue_free()
			else:
				position += velocity * delta 
			return 
		velocity = velocity.bounce(collision.get_normal())
		current_damage -= 1
		print("ball damage:", current_damage)
		
		if current_damage <= 0:
			print("bola hancur")
			queue_free()
func on_deflected(new_direction: Vector2, player_node: Node2D):
	is_deflected = true
	velocity = new_direction * (base_speed * 1.5)
	current_damage = 10
	add_collision_exception_with(player_node)
