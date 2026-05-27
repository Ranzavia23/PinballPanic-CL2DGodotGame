extends CharacterBody2D

var hp: int = 5

func _ready():
	add_to_group("Enemy")
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += 1400.0 * delta
	else:
		velocity.y = 0
		velocity.x = 0
	
	move_and_slide()

func take_damage(amount: int, push_dir: Vector2 = Vector2.ZERO):
	if amount <= 5 and push_dir == Vector2.ZERO:
		print("TING! Tameng Bumper menangkis bola! (Damage kurang dari 5)")
		GameManager.trigger_screen_shake(5.0)
		return 
		
	hp -= amount
	
	if push_dir != Vector2.ZERO:
		print("Bumper digebuk player! Sisa HP: ", hp)
		GameManager.trigger_hit_pause(0.08)
		GameManager.trigger_screen_shake(15.0)
		GameManager.add_score(10) 
	else:
		print("BOOM! Tameng Bumper hancur tertembus bola! Sisa HP: ", hp)
		GameManager.trigger_hit_pause(0.05)
		GameManager.trigger_screen_shake(10.0)
		
	if hp <= 0:
		print("Bumper Hancur!")
		GameManager.add_score(250)
		queue_free()
