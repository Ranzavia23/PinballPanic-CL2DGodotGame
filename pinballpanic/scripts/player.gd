extends CharacterBody2D

#global variabel
@export var speed := 500
@export var jump_force := -800
@export var gravity := 1280
@export var attack_buffer_window: float = 0.15 
@export var coyote_time: float = 0.15     
@export var jump_buffer_time: float = 0.1 

@onready var sprite = $AnimatedSprite2D
@onready var shapecast = $AttackCast 

#global state var
var is_attacking := false
var facing_direction := 1  # 1 kanan | -1 kiri
var attack_buffer_timer: float = 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func _ready():
	add_to_group("Player")
	shapecast.enabled = false 

func _physics_process(delta):
	handle_movement(delta)
	handle_attack(delta)
	update_animation()

#moveset
func handle_movement(delta):
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		facing_direction = direction
		shapecast.scale.x = facing_direction
	velocity.x = direction * speed
	#COYOTETIME
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta      
		velocity.y += gravity * delta
	#JUMPBUFFER
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_force
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
	move_and_slide()

#fungsiattack
func handle_attack(delta):
	if attack_buffer_timer > 0:
		attack_buffer_timer -= delta
	if Input.is_action_just_pressed("attack"):
		attack_buffer_timer = attack_buffer_window
	if attack_buffer_timer > 0 and not is_attacking:
		attack_buffer_timer = 0.0 
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
	
	await sprite.animation_finished
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
