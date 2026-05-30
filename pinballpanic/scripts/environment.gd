extends Node2D

func _ready():
	GameManager.walls_activated.connect(_on_walls_activated)

func _on_walls_activated():
	print("TEMBOK AKTIF!")
