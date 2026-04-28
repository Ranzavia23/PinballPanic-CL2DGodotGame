extends Node2D

@export var enemy_scene: PackedScene
@onready var spawn_point = [
	$spawn_points/Marker2D,
	$spawn_points/Marker2D2,
	$spawn_points/Marker2D3]
var enemy_per_wave = 5
var spawning = true
var spawned = 0
var wave = 15
var max_wave = 15
var spawn_amount = 1
var current_wave = 1
func _ready():
	await get_tree().create_timer(2.5).timeout
	
	start_wave()

func start_wave():
	spawned = 0
	update_jumlah_enemy()
	print(" start wave", wave, "")
	spawn_next()

func spawn_next():
	if not spawning:
		return
	# STOP kalau sudah cukup spawn
	if spawned >= enemy_per_wave:
		print("Wave end")

		await get_tree().create_timer(7.0).timeout

		wave += 1
		stop_wave()
		start_wave()
		return

	# spawn enemy
	spawn_enemy()

	await get_tree().create_timer(3.5).timeout
	spawn_next()

func spawn_enemy():
	for i in range(spawn_amount):
		if spawned >= enemy_per_wave:
			return
		var enemy = enemy_scene.instantiate()
		var points = spawn_point [i % spawn_point.size()]
		enemy.global_position = points.global_position
		add_child(enemy)

	spawned += 1
	await get_tree().create_timer(3.0).timeout
	print("enemy spawned:", spawned)

func stop_wave():
	if wave >= max_wave:
		spawning = false
		return
		print (" game selesai")
func update_jumlah_enemy():
	if wave <=3:
		spawn_amount = 1
	elif wave <= 9:
		spawn_amount = 2
	else:
		spawn_amount = 3		
