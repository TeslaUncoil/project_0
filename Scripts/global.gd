extends Node


var moving_to_next_wave: bool
@export var playerPosition := Vector2.ZERO
@export var current_wave: int
@export var kills: int
@export var roundKills: int
@export var playerhealth: int
@export var coins: int
@export var time_to_wave: float

func game_start():
	kills = 0
	roundKills = 0
	coins = 0
	time_to_wave = 5.0
	#current_wave = 1
	
	print("game started!")
