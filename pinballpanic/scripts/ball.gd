extends CharacterBody2D

@export var hp_ball: int = 10
@export var damage_ball: int = 1
@export var speed_ball: float = 6+500.0
@export var min_speed_ball: float = 200.0
@export var max_speed_ball: float = 800.0

@export var aim_assist_radius: float = 500.0
@export var aim_assist_strength: float = 0.35

var current_hp: int
var bounce_count: int = 0
var direction: Vector2 = Vector2.ZERO
var active: bool = false               
var is_deflected: bool = false

func _ready() -> void:
	current_hp = hp_ball
	add_to_group("balls")
	set_physics_process(false)
	launch(Vector2(1, 1))

func _physics_process(delta: float) -> void:
	if not active:
		return

	velocity = direction * speed_ball
	var collision = move_and_collide(velocity * delta)

	if not collision:
		return

	var collider = collision.get_collider()

	if collider and collider.is_in_group("enemies"):
		collider.take_damage(damage_ball)
		direction = direction.bounce(collision.get_normal())
		current_hp -= damage_ball
	else:
		direction = direction.bounce(collision.get_normal())
		current_hp -= damage_ball
		print("HP sisa: %d" % current_hp)

	if current_hp <= 0:
		queue_free()
		return

	var target = find_nearest_enemy()
	if target:
		var to_enemy = (target.global_position - global_position).normalized()
		direction = direction.lerp(to_enemy, aim_assist_strength).normalized()

func launch(dir: Vector2, launch_speed: float = speed_ball) -> void:
	direction = dir.normalized()
	speed_ball = clamp(launch_speed, min_speed_ball, max_speed_ball)
	active = true
	set_physics_process(true)

func find_nearest_enemy() -> Node2D:
	var nearest_enemy: Node2D = null
	var nearest_distance: float = aim_assist_radius

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node2D:
			var distance: float = position.distance_to(enemy.position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_enemy = enemy

	return nearest_enemy
