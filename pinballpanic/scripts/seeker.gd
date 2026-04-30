extends CharacterBody2D

@export var speed: float = 120.0
var hp: int = 5
var player: Node2D = null
@onready var sprite = $AnimatedSprite2D
var facing_direction := 1  

func _ready():
	add_to_group("Enemy") 
	
	# Cari target (Player)
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta):
	# Kalau Player ada, terus kejar posisinya
	if player:
		var direction = global_position.direction_to(player.global_position)
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
		print("Seeker kena pukul Player! Sisa HP: ", hp)
		global_position += push_dir * 50 
	else:
		print("Bamm! Seeker kena pantulan Bola! Sisa HP: ", hp)
	
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
