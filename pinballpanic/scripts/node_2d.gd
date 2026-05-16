extends Node2D

@export var enemy_scene: PackedScene

@onready var spawn_points = [
	$spawn_points/Marker2D,
	$spawn_points/Marker2D2,
]

var enemy_per_wave = 5
var spawning = true
var spawned = 0
var max_wave = 15
var spawn_amount = 1

func _ready():
	await get_tree().create_timer(2.5).timeout
	start_wave()

func start_wave():
	spawned = 0
	update_jumlah_enemy()
	print("Menunggu pop-up tulisan Wave selesai...")
	await get_tree().create_timer(3.0).timeout
	print("Start Wave: ", GameManager.current_wave)
	spawn_next()

func spawn_next():
	if not spawning:
		return
	if spawned >= enemy_per_wave:
		print("Selesai nge-spawn pasukan. Menunggu Player menghabisi musuh...")
		check_enemies_dead()
		return

	spawn_enemy()
	
	await get_tree().create_timer(3.5).timeout
	spawn_next()

func spawn_enemy():
	for i in range(spawn_amount):
		if spawned >= enemy_per_wave:
			break 
		var enemy = enemy_scene.instantiate()
		var point = spawn_points.pick_random() 
		add_child(enemy)
		enemy.global_position = point.global_position
		spawned += 1
	print("Enemy spawned: ", spawned)

func update_jumlah_enemy():
	if GameManager.current_wave <= 3:
		spawn_amount = 1
	elif GameManager.current_wave <= 9:
		spawn_amount = 2
	else:
		spawn_amount = 3

#Enemy checker
func check_enemies_dead():
	while get_tree().get_nodes_in_group("Enemy").size() > 0:
		await get_tree().create_timer(1.0).timeout
	print("Semua musuh mati! Wave End!")
	GameManager.next_wave()
	if GameManager.current_wave > max_wave:
		print("Game Selesai! You Win!")
		spawning = false
		return
		
	await get_tree().create_timer(3.0).timeout
	start_wave()
