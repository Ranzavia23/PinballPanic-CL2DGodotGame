extends Node2D
#var score_history = []
#var current_game = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func finish_game(score):
	#score_history.append({
		#"game": current_game,
		#"score": score
	#})
	#current_game += 1
	#save_history()
	#
#func save_history():
	#var data = {"current_game" :current_game
		#"history":score_history }	


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
