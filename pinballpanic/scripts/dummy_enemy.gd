extends CharacterBody2D

@export var hp_enemy: int = 10
@export var move_speed: float = 100.0
@export var move_range: float = 150.0

var current_hp: int = 0
var _start_y: float
var _direction: float = 1.0  


func _ready() -> void:
    current_hp = hp_enemy
    add_to_group("enemies")

func _physics_process(_delta: float) -> void:
    position.y += move_speed * _direction * _delta
    if position.y > _start_y + move_range:
        _direction = -1.0
    elif position.y < _start_y - move_range:
        _direction = 1.0

func take_damage(amount: int) -> void:
    current_hp -= amount
    print("Enemy HP: %d" % current_hp)
    if current_hp <= 0:
        queue_free()