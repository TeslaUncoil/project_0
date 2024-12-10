
extends Node2D

# Node refs
@onready var spawned_enemies: Node2D = $SpawnedEnemies
@onready var tilemap = get_tree().root.get_node("./layer_decorations") 

@onready var zombie_scene = preload("res://Scenes/zombie.tscn")
# Enemy stats
@export var max_enemies = 20 

var enemy_count = 0 
var rng = RandomNumberGenerator.new()

func spawn_enemy():
	
	
	var attempts = 0
	var max_attempts = 100
	var spawned = false
	while not spawned and attempts < max_attempts:
		var enemy = zombie_scene.instantiate
		#enemy.position = Vector2(0.0, 0.0)
		spawned_enemies.add_child(enemy)
		spawned = true
		print("spawned!")
	#(0,5)

func _on_timer_timeout() -> void:
	if enemy_count < max_enemies:
		spawn_enemy()
		enemy_count = enemy_count + 1
