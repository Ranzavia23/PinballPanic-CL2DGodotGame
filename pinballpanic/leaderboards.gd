extends Node2D
var leaderboard = []
@onready var highscore = $Label
@onready var score1= $VBoxContainer/Label4
@onready var score2=$VBoxContainer/Label2
@onready var score3= $VBoxContainer/Label3
@onready var score4= $VBoxContainer/Label5
@onready var score5=$VBoxContainer/Label6



func _ready() -> void:
	highscore.text = str (GameManager.high_score)
	
	if leaderboard.size()>0:
		score1.text = str(GameManager.leaderboard[0])
	if leaderboard.size()>1:
		score1.text = str(GameManager.leaderboard[1])	
	if leaderboard.size()>2:
		score1.text = str(GameManager.leaderboard[2])
	if leaderboard.size()>3:
		score1.text = str(GameManager.leaderboard[3])
	if leaderboard.size()>4:
		score1.text = str(GameManager.leaderboard[4])			
	
	


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
