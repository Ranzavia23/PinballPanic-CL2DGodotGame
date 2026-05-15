extends Node
#untuk config Global Setting

var score: int = 0
var current_wave: int = 1

signal wave_changed
signal wave_started
signal score_changed

func next_wave():
    current_wave += 1
    wave_started.emit()

func add_score(value: int) -> void:
    score += value
    score_changed.emit()