extends CharacterBody2D

# Player Parameter
@export var speed := 500
@export var jump_force := -800
@export var gravity := 1280

@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $AttackHitbox
@onready var hitbox_shape = $AttackHitbox/CollisionShape2D

# State
var is_attacking := false
var facing_direction := 1  # 1 kanan | -1 kiri
var hit_targets = []

func _ready():
	add_to_group("Player")
	hitbox_shape.disabled = true
	hitbox.body_entered.connect(_on_hitbox_body_entered)

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
		hitbox.scale.x = facing_direction
	velocity.x = direction * speed
	#Gravitasi
	if not is_on_floor():
		velocity.y += gravity * delta
	#Lompatan
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()

#fungsi Attack
func handle_attack():
	if Input.is_action_just_pressed("attack"):
		execute_attack()

func execute_attack():
	is_attacking = true
	hit_targets.clear()
	sprite.play("attack_swing")
	hitbox_shape.disabled = false
	await get_tree().physics_frame
	var overlaps = hitbox.get_overlapping_bodies()
	for body in overlaps:
		_on_hitbox_body_entered(body)
	await get_tree().create_timer(0.1).timeout
	hitbox_shape.disabled = true
	is_attacking = false

func _on_hitbox_body_entered(body):
	if body in hit_targets:
		return
	hit_targets.append(body)
	if body.is_in_group("Projectile"):
		var mouse_dir = (get_global_mouse_position() - body.global_position).normalized()
		if body.has_method("on_deflected"):
			body.on_deflected(mouse_dir, self) 
			
	elif body.is_in_group("Enemy"):
		var push_dir = Vector2(facing_direction, 0)
		if body.has_method("take_damage_and_push"):
			body.take_damage_and_push(1, push_dir)

func take_damage(amount: int):
	print("awww aku kena damage sebanyak: ", amount)

#Buat animasi
func update_animation():
	sprite.flip_h = facing_direction < 0

	if is_attacking:
		return  

	if velocity.x != 0:
		sprite.play("run")
	else:
		sprite.play("idle")
