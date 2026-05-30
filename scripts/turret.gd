extends StaticBody2D

@export var projectile_scene: PackedScene 
@onready var timer = $Timer
@onready var shoot_point = $ShootPoint
@onready var sprite = $AnimatedSprite2D
@onready var fire_effect = $AnimatedSprite2D/FireEffect

var player: Node2D = null
var is_waiting_wave: bool = false 

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	timer.wait_time = 4.0
	timer.timeout.connect(_on_timer_timeout)
	
	GameManager.wave_started.connect(_on_wave_started)
	_on_wave_started()
	
	if is_instance_valid(sprite):
		sprite.play("idle")
	if is_instance_valid(fire_effect):
		fire_effect.visible = false

func _on_wave_started():
	is_waiting_wave = true
	timer.stop() 
	await get_tree().create_timer(3.0).timeout
	is_waiting_wave = false
	timer.start() 

func _on_timer_timeout():
	if is_waiting_wave:
		return
		
	if projectile_scene and player:
		if is_instance_valid(sprite):
			sprite.play("fire")
		if is_instance_valid(fire_effect):
			fire_effect.visible = true
			
		var ball = projectile_scene.instantiate()
		get_tree().current_scene.add_child(ball)
		ball.global_position = shoot_point.global_position
		
		var shoot_dir = (player.global_position - shoot_point.global_position).normalized()
		
		if ball.has_method("launch"):
			ball.launch(shoot_dir, 400.0)
			
		await get_tree().create_timer(0.1).timeout
		
		if is_instance_valid(fire_effect):
			fire_effect.visible = false
		if is_instance_valid(sprite):
			sprite.play("idle")

func _physics_process(_delta):
	if player:
		look_at(player.global_position)
		if player.global_position.x < global_position.x:
			if is_instance_valid(sprite):
				sprite.flip_v = true 
			if is_instance_valid(fire_effect):
				fire_effect.flip_v = true
		
		else:
			if is_instance_valid(sprite):
				sprite.flip_v = false
			if is_instance_valid(fire_effect):
				fire_effect.flip_v = false
