extends CharacterBody2D


@export var hp_ball: int = 10                 
@export var damage_ball: int = 1             
@export var speed_ball: float = 650.0         
@export var min_speed_ball: float = 200.0
@export var max_speed_ball: float = 1400.0

@export var speed_increase: float = 50.0      

# AIM ASSIST 
@export var aim_assist_radius: float = 500.0
@export var aim_assist_strength: float = 0.15


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
	# Hilangkan aim assist dari sini biar nggak muterin musuh!
	velocity = direction * speed_ball
	var collision = move_and_collide(velocity * delta)

	if not collision:
		return

	_handle_collision(collision)

func _handle_collision(collision: KinematicCollision2D) -> void:
	var collider = collision.get_collider()
	
	# Skenario A: Nabrak Player
	if collider.is_in_group("Player"):
		if not is_deflected:
			if collider.has_method("take_damage"):
				collider.take_damage(damage_ball)
			queue_free()
		else:
			_bounce(collision, false) # Mantul biasa, jangan aim assist
		return

	# Skenario B: Nabrak Musuh
	if collider.is_in_group("Enemy"):
		if is_deflected:
			if collider.has_method("take_damage"):
				collider.take_damage(damage_ball)
				
			# SKOR HANYA DITAMBAH DI SINI (Saat berhasil mukul musuh)
			GameManager.add_score(100) 
			
			_bounce(collision, false) # Mantul random, jangan aim assist
		else:
			# Kalau belum dipukul, tembus aja!
			add_collision_exception_with(collider)
			ignored_enemies.append(collider)
		return
		
	# Skenario C: Nabrak Tembok / Objek Lain
	# Nah, di sini baru boleh aktifin Aim Assist SEKALI tembak setelah mantul!
	_bounce(collision, true)
	

# Tambahkan parameter `can_trigger_aim` biar kita bisa atur kapan magnetnya nyala
func _bounce(collision: KinematicCollision2D, can_trigger_aim: bool) -> void:
	# Bikin pantulan
	direction = direction.bounce(collision.get_normal()).normalized()

	# Tambah kecepatan tiap kali mantul (Fitur barunya Reva)
	speed_ball = clamp(speed_ball + speed_increase, min_speed_ball, max_speed_ball)

	# Kurangi HP/Nyawa bola
	current_hp -= 1

	# Aktifkan Aim Assist HANYA JIKA udah dipukul dan diizinkan (nabrak tembok)
	if is_deflected and can_trigger_aim:
		_apply_aim_assist_once()

	# Hancur kalau HP habis
	if current_hp <= 0:
		queue_free()

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
	speed_ball = clamp(
		launch_speed,
		min_speed_ball,
		max_speed_ball
	)
	set_physics_process(true)


func on_deflected(new_dir: Vector2, player_node: Node2D) -> void:
	is_deflected = true
	can_aim_assist = false
	direction = new_dir.normalized()

	speed_ball = clamp(
		speed_ball * 1.15,
		min_speed_ball,
		max_speed_ball
	)
	add_collision_exception_with(player_node)

	for enemy in ignored_enemies:
		if is_instance_valid(enemy):
			remove_collision_exception_with(enemy)

	ignored_enemies.clear()

	set_physics_process(true)
