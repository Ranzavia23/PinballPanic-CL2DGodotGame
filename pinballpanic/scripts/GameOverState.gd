extends Control

func _ready():
	GameManager.save_data(GameManager.score, GameManager.current_wave)

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	GameManager.reset_game()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
