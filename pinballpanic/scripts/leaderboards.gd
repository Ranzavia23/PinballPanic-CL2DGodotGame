extends Node2D
var leaderboard = []
@onready var highscore = $Label
@onready var score1= $VBoxContainer/Label4
@onready var score2=$VBoxContainer/Label2
@onready var score3= $VBoxContainer/Label3
@onready var score4= $VBoxContainer/Label5
@onready var score5=$VBoxContainer/Label6

func _ready() -> void:
	var lb = GameManager.leaderboard
	
	if lb.size() > 0:
		highscore.text = "High Score: " + str(lb[0]["score"]) + "          Wave: " + str(lb[0]["wave"])
	else:
		highscore.text = "High Score: 0          Wave: 0"
	
	var format_lb = func(index):
		if index < lb.size():
			return "Score: " + str(lb[index]["score"]) + "          Wave: " + str(lb[index]["wave"])
		else:
			return "Score: 0          Wave: 0"
			
	score1.text = format_lb.call(0)
	score2.text = format_lb.call(1)
	score3.text = format_lb.call(2)
	score4.text = format_lb.call(3)
	score5.text = format_lb.call(4)


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
