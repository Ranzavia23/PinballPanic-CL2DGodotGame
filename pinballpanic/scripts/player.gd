extends CharacterBody2D

#global variabel
@export var speed := 500
@export var jump_force := -800
@export var gravity := 1500
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
	#coyottetime
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta      
		if abs(velocity.y) < 200:
			velocity.y += (gravity * 0.5) * delta
		else:
			velocity.y += gravity * delta
	#jumpbuffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_force
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.2
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
				var aim_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
				if aim_dir == Vector2.ZERO:
					aim_dir = Vector2(facing_direction, 0)
				else:
					aim_dir = Vector2.RIGHT.rotated(snapped(aim_dir.angle(), PI / 4))
				if body.has_method("on_deflected"):
					body.on_deflected(aim_dir, self) 
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

#play animasi
func update_animation():
	sprite.flip_h = facing_direction < 0
	if is_attacking:
		return  
	if velocity.x != 0:
		sprite.play("run")
	else:
		sprite.play("idle")
