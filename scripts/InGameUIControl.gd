extends Control

@onready var score_label = $HboxContainer/Score
@onready var wave_label = $HboxContainer/Wave

func _process(_delta):
	score_label.text = "Score: " + str(GameManager.score)
	wave_label.text = "Wave: " + str(GameManager.current_wave)
