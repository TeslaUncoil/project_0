extends Node

var current_wave: int
var moving_to_next_wave: bool
@export var playerPosition := Vector2.ZERO


func game_start():
	
	print("game started!")
