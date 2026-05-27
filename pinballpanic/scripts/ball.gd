extends CharacterBody2D

@export var hp_ball: int = 10                 
@export var damage_ball: int = 1
var score_multiplier: float = 1.0        
@export var speed_ball: float = 650.0         
@export var min_speed_ball: float = 200.0
@export var max_speed_ball: float = 1400.0
@export var speed_increase: float = 50.0      
@export var aim_assist_radius: float = 500.0
@export var aim_assist_strength: float = 0.15
@onready var bounce_sound = $BounceSound
@onready var sprite = $AnimatedSprite2D

var current_hp: int
var direction: Vector2 = Vector2.ZERO
var is_deflected: bool = false
var can_aim_assist: bool = false
var ignored_enemies: Array = []
var scored_this_bounce: bool = false

func _ready() -> void:
	current_hp = hp_ball
	add_to_group("Projectile")
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	velocity = direction * speed_ball
	var collision = move_and_collide(velocity * delta)
	if direction != Vector2.ZERO:
		rotation = direction.angle()
	if not collision:
		return
	_handle_collision(collision)

func _handle_collision(collision: KinematicCollision2D) -> void:
	var collider = collision.get_collider()
	if collider.is_in_group("Projectile"):
		add_collision_exception_with(collider)
		return

	if "Turret" in collider.name:
		if is_deflected:
			queue_free()
		else:
			add_collision_exception_with(collider)
		return

	if collider.is_in_group("Player"):
		if not is_deflected:
			if collider.has_method("take_damage"):
				collider.take_damage(damage_ball)
			queue_free()
		else:
			_bounce(collision, false) 
		return
	if collider.is_in_group("Enemy"):
		if is_deflected:
			if collider.has_method("take_damage"):
				collider.take_damage(damage_ball)
			var final_score = int(100 * score_multiplier)
			GameManager.add_score(final_score) 
			_bounce(collision, false) 
		else:
			add_collision_exception_with(collider)
			ignored_enemies.append(collider)
		return
	if "Wall" in collider.name or "Building" in collider.name or "platform" in collider.name:
		if not is_deflected:
			add_collision_exception_with(collider)
			ignored_enemies.append(collider)
			return
	_bounce(collision, true)

func _bounce(collision: KinematicCollision2D, can_trigger_aim: bool) -> void:
	direction = direction.bounce(collision.get_normal()).normalized()
	speed_ball = clamp(speed_ball + speed_increase, min_speed_ball, max_speed_ball)
	
	if is_instance_valid(bounce_sound):
		bounce_sound.play()
	if is_instance_valid(sprite):
		sprite.play("stretch")
	
	current_hp -= 1
	if is_deflected:
		damage_ball -= 1
		score_multiplier += 0.5
		print("Mantul! Damage sisa: ", damage_ball, " | Multiplier: x", score_multiplier)
		
		if can_trigger_aim:
			_apply_aim_assist_once()
			
		if current_hp <= 0 or damage_ball <= 0:
			queue_free()
			return
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(sprite):
			if is_deflected:
				sprite.play("speedup")
			else:
				sprite.play("normal")

func _apply_aim_assist_once() -> void:
	var target = _find_nearest_enemy()
	if target == null:
		return
	var to_enemy = (target.global_position - global_position).normalized()
	direction = direction.lerp(to_enemy, aim_assist_strength).normalized()

func _find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist := aim_assist_radius
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy is Node2D:
			var dist = global_position.distance_to(enemy.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = enemy
	return nearest

func launch(dir: Vector2, launch_speed: float = speed_ball) -> void:
	direction = dir.normalized()
	speed_ball = clamp(launch_speed, min_speed_ball, max_speed_ball)
	set_physics_process(true)
	

	if is_instance_valid(sprite):
		sprite.play("normal")

func on_deflected(new_dir: Vector2, player_node: Node2D) -> void:
	is_deflected = true
	can_aim_assist = false
	direction = new_dir.normalized()
	speed_ball = clamp(speed_ball * 1.15, min_speed_ball, max_speed_ball)
	
	damage_ball = 10
	score_multiplier = 1.0 
	
	if not GameManager.is_wall_active:
		GameManager.is_wall_active = true
		GameManager.walls_activated.emit()
		
	add_collision_exception_with(player_node)
	for enemy in ignored_enemies:
		if is_instance_valid(enemy):
			remove_collision_exception_with(enemy)
	ignored_enemies.clear()
	set_physics_process(true)
	
	if is_instance_valid(sprite):
		sprite.play("speedup")
