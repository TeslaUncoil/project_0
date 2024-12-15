extends Node2D

@onready var downtime: Node2D = $Downtime
@onready var heart_1: Node2D = $heart1
@onready var heart_2: Node2D = $heart2
@onready var heart_3: Node2D = $heart3
@onready var round_wait: Timer = $"../../EnemySpawners/RoundWait"
@onready var seconds: Label = $Downtime/Seconds

@export var target: Vector2
var sec := 0
#var healthcount = 0

func _ready() -> void:
	SignalBus.on_round_change.connect(downtime_on)
	SignalBus.on_enemies_spawned.connect(downtime_off)
	heart_1.swap_state("full")
	heart_2.swap_state("full")
	heart_3.swap_state("full")

func _process(_delta: float) -> void:
	sec = round(round_wait.time_left)
	seconds.text = str(sec)

func downtime_on() -> void:
	downtime.visible = true

func downtime_off() -> void:
	downtime.visible = false

func health_subtract(playerhealth: int) -> void:
	print("run health_subtract")
	match playerhealth:
		3:
			pass
			#heart_4.swap_state("empty")
			
		2:
			heart_3.swap_state("empty")
			
		1:
			heart_2.swap_state("empty")
			
		0:
			heart_1.swap_state("empty")
			
	##target = (-10, -8)
	##hp.set_cell() - use this later for more scaleable UI editing, takes some understanding though
	#pass


func health_add(playerhealth: int) -> void:
	print("run health_add")
	match playerhealth:
		3:
			pass
			heart_3.swap_state("full")

		2:
			heart_2.swap_state("full")

		1:
			heart_1.swap_state("full")
