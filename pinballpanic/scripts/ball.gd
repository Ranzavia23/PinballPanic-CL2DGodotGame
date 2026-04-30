extends CharacterBody2D

@export var hp_ball: int = 10
@export var damage_ball: int = 1
@export var speed_ball: float = 650.0
@export var min_speed_ball: float = 200.0
@export var max_speed_ball: float = 800.0

@export var aim_assist_radius: float = 500.0
@export var aim_assist_strength: float = 0.35

var current_hp: int
var bounce_count: int = 0
var direction: Vector2 = Vector2.ZERO
var active: bool = false               
var is_deflected: bool = false
var can_aim_assist: bool = false
var ignored_enemies: Array = []

func _ready() -> void:
	current_hp = hp_ball
	add_to_group("Projectile")
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if not active:
		return
	if can_aim_assist:
		var target = find_nearest_enemy()
		if target:
			var to_enemy = (target.global_position - global_position).normalized()
			direction = direction.lerp(to_enemy, aim_assist_strength).normalized()
	velocity = direction * speed_ball
	var collision = move_and_collide(velocity * delta)
	if not collision:
		return
	var collider = collision.get_collider()
	if collider and collider.is_in_group("Player") and not is_deflected:
		if collider.has_method("take_damage"):
			collider.take_damage(damage_ball)
		queue_free()
		return
	elif collider and collider.is_in_group("Enemy"):
		if is_deflected:
			if collider.has_method("take_damage"):
				collider.take_damage(damage_ball)
			queue_free()
		else:
			add_collision_exception_with(collider)
			ignored_enemies.append(collider)
		return
	else:
		direction = direction.bounce(collision.get_normal())
		current_hp -= damage_ball
		if is_deflected:
			can_aim_assist = true 
	if current_hp <= 0:
		queue_free()

func launch(dir: Vector2, launch_speed: float = speed_ball) -> void:
	direction = dir.normalized()
	speed_ball = clamp(launch_speed, min_speed_ball, max_speed_ball)
	active = true
	set_physics_process(true)

func on_deflected(new_dir: Vector2, player_node: Node2D) -> void:
	is_deflected = true
	can_aim_assist = false
	direction = new_dir.normalized()
	speed_ball = clamp(speed_ball * 1.2, min_speed_ball, max_speed_ball)
	add_collision_exception_with(player_node)
	active = true
	for enemy in ignored_enemies:
		if is_instance_valid(enemy):
			remove_collision_exception_with(enemy)
	ignored_enemies.clear()

func find_nearest_enemy() -> Node2D:
	var nearest_enemy: Node2D = null
	var nearest_distance: float = aim_assist_radius
	
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy is Node2D:
			var distance: float = global_position.distance_to(enemy.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_enemy = enemy
				
	return nearest_enemy
