extends StaticBody2D

@export var projectile_scene: PackedScene 
@onready var timer = $Timer
@onready var shoot_point = $ShootPoint

var player: Node2D = null

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	timer.wait_time = 4.0
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	if projectile_scene and player:
		var ball = projectile_scene.instantiate()
		get_tree().current_scene.add_child(ball)
		ball.global_position = shoot_point.global_position
		var shoot_dir = (player.global_position - shoot_point.global_position).normalized()
		if ball.has_method("launch"):
			ball.launch(shoot_dir, 400.0)

func _physics_process(delta):
	if player:
		look_at(player.global_position)
