extends Camera2D

var shake_strength: float = 0.0
var shake_fade: float = 5.0 #Seberapa cepat getarannya berhenti

func _ready():
	GameManager.screen_shake_requested.connect(apply_shake)

func apply_shake(intensity: float):
	shake_strength = intensity

func _process(delta):
	if shake_strength > 0:
		#Kurangi kekuatan getaran secara halus
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		
		#Acak posisi kamera
		offset = Vector2(
			randf_range(-shake_strength, shake_strength), 
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = Vector2.ZERO # Balik ke tengah kalau udah selesai
