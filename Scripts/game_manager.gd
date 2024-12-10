extends Node

@onready var player: CharacterBody2D = $player
@onready var resettimer: Timer = $resettimer
@onready var zombie_scene = preload("res://Scenes/zombie.tscn")

# ? @export var zombie_scene = PackedScene
@export var gameActive = true
#@export var playerPosition := Vector2.ZERO
@export var current_wave: int

var starting_nodes: int
var current_nodes: int
var wave_spawn_ended

#all wave & spawn code instructed by https://www.youtube.com/watch?v=RYKWMlxQCB0 \ DevWorm on YT

func _ready() -> void:
	##maybe call_deferred some of this?
	current_wave = 0
	Global.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	position_to_next_wave()
	Global.game_start()

func position_to_next_wave():
	if current_nodes == starting_nodes:
		if current_wave != 0:
			Global.moving_to_next_wave = true
		Global.current_wave = current_wave
		## animation
		current_wave += 1
		wave_spawn_ended = false
		
		prepare_spawn("zombie", 4.0, 4.0) #monster type, multiplier, number of spawns
		print("current wave: " + str(current_wave))

func prepare_spawn(monster, multiplier, mob_spawns):
	var mob_amount = float(current_wave) * multiplier
	var mob_wait_time: float = 2.0
	print("mob_amount: ", mob_amount)
	var mob_spawn_rounds = mob_amount / mob_spawns
	spawn_type(monster, mob_spawn_rounds, mob_wait_time)
	
func spawn_type(monster, mob_spawn_rounds, mob_wait_time):
	if monster == "zombie":
		
		var zomb_spawn1 = $ZombieSpawn1
		var zomb_spawn2 = $ZombieSpawn2
		var zomb_spawn3 = $ZombieSpawn3
		var zomb_spawn4 = $ZombieSpawn4
		
		if mob_spawn_rounds >= 1:
			for i in mob_spawn_rounds:
				
				var zombie1 = zombie_scene.instantiate()
				zombie1.global_position = zomb_spawn1.global_position
				var zombie2 = zombie_scene.instantiate()
				zombie2.global_position = zomb_spawn2.global_position
				var zombie3 = zombie_scene.instantiate()
				zombie3.global_position = zomb_spawn3.global_position
				var zombie4 = zombie_scene.instantiate()
				zombie4.global_position = zomb_spawn4.global_position
				add_child(zombie1)
				
				zombie1.name = "zombie" + str(0 + mob_spawn_rounds)
				add_child(zombie2)
				zombie2.name = "zombie" + str(1 + mob_spawn_rounds)
				add_child(zombie3)
				zombie3.name = "zombie" + str(2 + mob_spawn_rounds)
				add_child(zombie4)
				zombie4.name = "zombie" + str(3 + mob_spawn_rounds)
				print(zombie1.name)
				print(zombie2.name)
				
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
				
		
	#elif monster == "other":
		#other_spawn1 - $OtherSpawnPoint1
		##and so on, copy for loop and zombie code
		wave_spawn_ended = true

func _process(_delta: float) -> void:
	
	#Global.playerPosition = player.position
	#is this an efficient way to do this?
	
	if player.get("dead") and gameActive:
		player_death()
		
	current_nodes = get_child_count()
	if wave_spawn_ended:
		position_to_next_wave()


func player_death():
	##some kind of bug occasionally breaking death animation? / i think it's gone?
	print("You died!")
	Engine.time_scale = 0.3
	gameActive = false
	resettimer.start()

func _on_resettimer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


	
