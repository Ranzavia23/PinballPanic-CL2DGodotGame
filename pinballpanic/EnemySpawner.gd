extends Node2D

@export var enemy_scene: PackedScene
@onready var spawn_point = $spawn_points/Marker2D

var enemy_per_wave = 5
var spawned = 0
var wave = 1
var max_wave = 30

func _ready():
	await get_tree().create_timer(1.5).timeout
	start_wave()

func start_wave():
	spawned = 0
	print("=== START WAVE", wave, "===")
	spawn_next()

func spawn_next():
	# STOP kalau sudah cukup spawn
	if spawned >= enemy_per_wave:
		print("Wave selesai")

		await get_tree().create_timer(5.0).timeout

		wave += 1
		stop_wave()
		start_wave()
		return

	# spawn enemy
	spawn_enemy()

	# lanjut lagi (INI YANG KAMU KURANG SEBELUMNYA)
	await get_tree().create_timer(1.0).timeout
	spawn_next()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_point.global_position
	add_child(enemy)

	spawned += 1
	await get_tree().create_timer(2.0).timeout
	print("enemy spawned:", spawned)

func stop_wave():
	if wave >= max_wave:
		game_over()

func game_over():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
