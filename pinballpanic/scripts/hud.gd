extends Control

@onready var wave_announcer = $WaveAnnouncer
@onready var wave_incoming_label = $WaveAnnouncer/ColorRect/Label
@onready var wave_label = $Wave
@onready var score_label = $Score
@onready var hearts_container = $HBoxContainer2/Hearts
@onready var game_manager = get_node("/root/GameManager")


func _ready():
	wave_announcer.visible = false
	game_manager.wave_started.connect(show_wave_incoming)
	game_manager.wave_changed.connect(update_wave)
	game_manager.score_changed.connect(update_score)
	update_score()
	show_wave_incoming()
	update_wave()
	update_hearts()

func _process(_delta):
	# Update label teks
	score_label.text = "Score: " + str(GameManager.score)
	
	# Update Hati
	var current_hp = GameManager.player_hp
	var heart_nodes = hearts_container.get_children()
	
	for i in range(heart_nodes.size()):
		if i < current_hp:
			heart_nodes[i].show()
		else:
			heart_nodes[i].hide()

func show_wave_incoming():
	wave_announcer.visible = true
	wave_incoming_label.text = "WAVE " + str(game_manager.current_wave) + " IS COMING"
	await get_tree().create_timer(3.0).timeout
	wave_announcer.visible = false

func update_wave():
	wave_label.text = "Wave: " + str(game_manager.current_wave)

func update_score():
	score_label.text = "Score: " + str(game_manager.score)

func update_hearts():
	var current_hp = game_manager.player_hp
	var heart_nodes = hearts_container.get_children()
	for i in range(heart_nodes.size()):
		if i < current_hp:
			heart_nodes[i].show()  
		else:
			heart_nodes[i].hide()  
