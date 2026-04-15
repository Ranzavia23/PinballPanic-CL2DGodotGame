extends CharacterBody2D

#parameter
@export var speed := 500
@export var jump_force := -800
@export var gravity := 1280

@onready var sprite = $AnimatedSprite2D
@onready var shapecast = $AttackCast 

#state
var is_attacking := false
var facing_direction := 1  # 1 kanan | -1 kiri

func _ready():
	add_to_group("Player")
	shapecast.enabled = false 

func _physics_process(delta):
	handle_movement(delta)
	if not is_attacking:
		handle_attack()
	update_animation()

#moveset
func handle_movement(delta):
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		facing_direction = direction
		shapecast.scale.x = facing_direction
	velocity.x = direction * speed
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	move_and_slide()
func handle_attack():
	if Input.is_action_just_pressed("attack"):
		execute_attack()

func execute_attack():
	is_attacking = true
	sprite.play("attack_swing")
	shapecast.force_shapecast_update()
	var hit_projectile = false
	if shapecast.is_colliding():
		for i in range(shapecast.get_collision_count()):
			var body = shapecast.get_collider(i)
			
			if body.is_in_group("Projectile"):
				var mouse_dir = (get_global_mouse_position() - body.global_position).normalized()
				if body.has_method("on_deflected"):
					body.on_deflected(mouse_dir, self) 
				hit_projectile = true
				break 
		if not hit_projectile:
			for i in range(shapecast.get_collision_count()):
				var body = shapecast.get_collider(i)
				if body.is_in_group("Enemy"):
					var push_dir = Vector2(facing_direction, 0)
					if body.has_method("take_damage_and_push"):
						body.take_damage_and_push(1, push_dir)
	
	await get_tree().create_timer(0.1).timeout
	is_attacking = false

func take_damage(amount: int):
	print("Awww aku kena damage sebanyak: ", amount)

#buat animasi
func update_animation():
	sprite.flip_h = facing_direction < 0
	if is_attacking:
		return  
	if velocity.x != 0:
		sprite.play("run")
	else:
		sprite.play("idle")
