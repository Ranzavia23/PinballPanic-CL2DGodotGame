extends Node

var score: int = 0
var current_wave: int = 1
var is_wall_active: bool = false
var max_hp: int = 10
var player_hp: int = 10
var high_score: int = 0
var leaderboard: Array = [] 
const SAVE_PATH = "user://leaderboard_v3.save"
signal hp_changed
signal wave_changed
signal wave_started
signal score_changed
@warning_ignore("unused_signal")
signal walls_activated

func _ready():
	load_data() 

#Sistem Healing
func next_wave():
	current_wave += 1
	
	if current_wave % 10 == 0:
		player_hp = min(player_hp + 3, max_hp)
		hp_changed.emit()
		print("BOSS WAVE HEALING! +3 HP. HP sekarang: ", player_hp)
		
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

func reset_game():
	score = 0
	current_wave = 1
	player_hp = max_hp
	is_wall_active = false
	score_changed.emit()
	wave_changed.emit()
	hp_changed.emit()

#FUNGSI SAVE/LOAD LEADERBOARD
func save_data(new_score: int, achieved_wave: int):
	if new_score > 0:
		# Sekarang kita nyimpen PAKET DATA (Score & Wave)
		leaderboard.append({"score": new_score, "wave": achieved_wave})
	
	# Urutkan berdasarkan "score" dari terbesar ke terkecil
	leaderboard.sort_custom(func(a, b): return a["score"] > b["score"])
	
	if leaderboard.size() > 5:
		leaderboard.resize(5)
		
	if leaderboard.size() > 0:
		high_score = leaderboard[0]["score"] # High score ngambil dari score tertinggi
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(leaderboard)
		file.close()

func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var data = file.get_var()
			if typeof(data) == TYPE_ARRAY:
				leaderboard = data
				if leaderboard.size() > 0 and typeof(leaderboard[0]) == TYPE_DICTIONARY:
					high_score = leaderboard[0]["score"]
			file.close()

#Game Juice
signal screen_shake_requested(intensity: float)

func trigger_screen_shake(intensity: float = 10.0):
	screen_shake_requested.emit(intensity)

func trigger_hit_pause(duration: float = 0.05):
	Engine.time_scale = 0.05 
	await get_tree().create_timer(duration, true, false, true).timeout 
	Engine.time_scale = 1.0
