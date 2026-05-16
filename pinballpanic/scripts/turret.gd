extends StaticBody2D

@export var projectile_scene: PackedScene 
@onready var timer = $Timer
@onready var shoot_point = $ShootPoint

var player: Node2D = null
var is_waiting_wave: bool = false

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	timer.wait_time = 4.0
	timer.timeout.connect(_on_timer_timeout)
	GameManager.wave_started.connect(_on_wave_started)
	_on_wave_started()

func _on_wave_started():
	is_waiting_wave = true
	timer.stop() 
	print("Turret puasa 3 detik nunggu UI...")
	await get_tree().create_timer(3.0).timeout
	is_waiting_wave = false
	timer.start() 
	print("Turret mulai nembak lagi!")

func _on_timer_timeout():
	if is_waiting_wave:
		return
	if projectile_scene and player:
		var ball = projectile_scene.instantiate()
		get_tree().current_scene.add_child(ball)
		ball.global_position = shoot_point.global_position
		var shoot_dir = (player.global_position - shoot_point.global_position).normalized()
		if ball.has_method("launch"):
			ball.launch(shoot_dir, 400.0)

func _physics_process(_delta):
	if player:
		look_at(player.global_position)
