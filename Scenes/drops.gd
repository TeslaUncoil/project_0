extends Node2D
@onready var coin1 = preload("res://Scenes/small_gold_coin.tscn")
@export var coinNum := 0


func _ready() -> void:
	SignalBus.on_zombie_killed.connect(item_spawner)
	coinNum = 0

func item_spawner(target: Vector2) -> void:
	
	var drop = coin1.instantiate()
	drop.global_position = target
	add_child(drop)
	drop.name = "coin" + str(coinNum)
	
	coinNum += 1
