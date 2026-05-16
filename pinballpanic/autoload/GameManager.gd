extends Node

var score: int = 0
var current_wave: int = 1

var max_hp: int = 10
var player_hp: int = 10
var high_score: int = 0
const SAVE_PATH = "user://highscore.save"

signal hp_changed
signal wave_changed
signal wave_started
signal score_changed

func _ready():
	# Begitu game dibuka, langsung bongkar file save-nya!
	load_high_score()
#Wave
func next_wave():
	current_wave += 1
	wave_started.emit()

#Score
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
	score_changed.emit()
	wave_changed.emit()
	hp_changed.emit()

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score) # Simpan angkanya
		file.close()

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32() # Ambil angkanya
			file.close()
			print("High Score berhasil diload: ", high_score)
#GAME JUICE
signal screen_shake_requested(intensity: float)

func trigger_screen_shake(intensity: float = 10.0):
	screen_shake_requested.emit(intensity)

func trigger_hit_pause(duration: float = 0.05):
	Engine.time_scale = 0.05 
	await get_tree().create_timer(duration, true, false, true).timeout 
	Engine.time_scale = 1.0
