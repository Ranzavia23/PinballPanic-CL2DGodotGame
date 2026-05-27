extends Node

var score: int = 0
var current_wave: int = 1
var is_wall_active: bool = false
var max_hp: int = 10
var player_hp: int = 10
var high_score: int = 0
const SAVE_PATH = "user://highscore.save"

signal hp_changed
signal wave_changed
signal wave_started
signal score_changed
@warning_ignore("unused_signal")
signal walls_activated

func _ready():
	load_high_score()

#Sisitem Healing
func next_wave():
	current_wave += 1
	
	#Healing 3 Hati tiap kelipatan Wave 10
	if current_wave % 10 == 0:
		player_hp = min(player_hp + 3, max_hp)
		hp_changed.emit()
		print("BOSS WAVE HEALING! +3 HP. HP sekarang: ", player_hp)
		
	#Healing 1 Hati tiap kelipatan Wave 3
	elif current_wave % 3 == 0:
		player_hp = min(player_hp + 1, max_hp)
		hp_changed.emit()
		print("MILESTONE HEALING! +1 HP. HP sekarang: ", player_hp)

	wave_started.emit()

func add_score(value: int) -> void:
	score += value
	score_changed.emit()
	if score > high_score:
		high_score = score
		save_high_score()
	
func reset_game():
	score = 0
	current_wave = 1
	player_hp = max_hp
	is_wall_active = false
	score_changed.emit()
	wave_changed.emit()
	hp_changed.emit()

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)
		file.close()

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32()
			file.close()
			print("High Score berhasil diload: ", high_score)

#Game Juice
signal screen_shake_requested(intensity: float)

func trigger_screen_shake(intensity: float = 10.0):
	screen_shake_requested.emit(intensity)

func trigger_hit_pause(duration: float = 0.05):
	Engine.time_scale = 0.05 
	await get_tree().create_timer(duration, true, false, true).timeout 
	Engine.time_scale = 1.0
