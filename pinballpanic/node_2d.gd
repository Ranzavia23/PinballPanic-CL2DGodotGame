extends Node2D

@export var enemy_scene: PackedScene

@onready var spawn_point = [
	$spawn_points/Marker2D,
	$spawn_points/Marker2D2,
	$spawn_points/Marker2D3
]

var enemy_per_wave = 5
var spawning = true
var spawned = 0
var max_wave = 15
var spawn_amount = 1

#Tambahan biar fake wave sama spawn loop gak tabrakan(By:Reva)
var wave_active = false


func _ready():
	await get_tree().create_timer(2.5).timeout
	
	start_wave()


func start_wave():
	spawned = 0
	
	#Tambahan:
	#nandain wave lagi aktif
	wave_active = true
	
	update_jumlah_enemy()
	
	print(" start wave", GameManager.current_wave, "")
	
	spawn_next()

	#Tambahan fake scenario end wave buat cek waveannouncer(by:Reva)
	await get_tree().create_timer(10.0).timeout
	
	#Kode lama
	#end_wave()

	if wave_active:
		end_wave()


func spawn_next():
	if not spawning:
		return

	#Tambahan:
	#stop loop spawn kalau wave udah selesai
	if not wave_active:
		return

	# STOP kalau sudah cukup spawn
	if spawned >= enemy_per_wave:
		print("Wave end")

		await get_tree().create_timer(7.0).timeout

		GameManager.next_wave()
		
		if GameManager.current_wave > max_wave:
			stop_wave()
			return
		
		await get_tree().create_timer(5.0).timeout
		
		#start_wave()
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
		
		var points = spawn_point[i % spawn_point.size()]
		
		enemy.global_position = points.global_position
		
		add_child(enemy)

		spawned += 1

	await get_tree().create_timer(3.0).timeout
	
	print("enemy spawned:", spawned)


func stop_wave():
	if GameManager.current_wave > max_wave:
		
		spawning = false

		#Tambahan:
		#biar spawn loop ikut berhenti
		wave_active = false

		#Kode lama
		#return
		#print (" game selesai")

		#FIX:
		#print dipindah sebelum return
		print (" game selesai")
		
		return


func update_jumlah_enemy():
	if GameManager.current_wave <=3:
		spawn_amount = 1
		
	elif GameManager.current_wave <= 9:
		spawn_amount = 2
		
	else:
		spawn_amount = 3		


#Tambahan fake scenario end wave buat cek waveannouncer(by:Reva)
func end_wave():
	print("Wave end")

	#Tambahan:
	#biar spawn_next lama berhenti
	wave_active = false

	GameManager.next_wave()

	if GameManager.current_wave > max_wave:
		stop_wave()
		return

	await get_tree().create_timer(10.0).timeout

	start_wave()