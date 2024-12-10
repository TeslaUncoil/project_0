extends CharacterBody2D

## possible inherent flaw: every instance of zombie runs this whole script. maybe try to outsource as much code as possible to parent node in main,
## 	and signal down to each instance?

@export var run_speed = 30
@export var zhealth = 2.0
@export var target = Vector2.ZERO

@onready var anims: AnimatedSprite2D = $Anims
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hurt_cooldown: Timer = $hurt_cooldown

var _position_last_frame := Vector2()
@export var _cardinal_direction = 0
@onready var cooldown: Timer = $cooldown

@export var hurting = false
@export var attacking = false
@export var dead = false

var hugging := false
var knockback := false
var lastFacingDirection #:= Vector2(0, 1)
var direction_to_target: Vector2

func _ready() -> void:
	actor_setup.call_deferred()

func actor_setup():
	await get_tree().physics_frame #Wait for the first physics frame so the NavigationServer can sync.
	makepath()
	set_movement_target(Global.playerPosition) #Now that the navigation map is no longer empty, set the movement target.

func set_movement_target(movement_target: Vector2):
	nav_agent.target_position = movement_target

func _physics_process(_delta: float) -> void:
	#target = Global.playerPosition
	
	##my old direction:
	#var direction_to_target = self.global_position.direction_to(target) 
	
	##devworm's direction:
	direction_to_target = to_local(nav_agent.get_next_path_position()).normalized()
	
	if !hugging: 
		velocity = direction_to_target * run_speed
		move_and_slide()

	elif hugging:
		knockback = true
		direction_to_target *= -1
		velocity = direction_to_target * run_speed
		move_and_slide()

	#following code borrowed from: https://forum.godotengine.org/t/finding-facing-direction-of-a-node/17805/2
	# Get motion vector between previous and current position
	#lastFacingDirection = velocity.normalized()
	var motion = position - _position_last_frame

	# If the node actually moved, we'll recompute its direction.
	# If it didn't, we'll just the last known one.
	if motion.length() > 0.0001:
		# Now if you want a value between N.S.W.E,
		# you can use the angle of the motion.
		# I came up with this formula last time I needed it:
		_cardinal_direction = int(4.0 * (motion.rotated(PI / 4.0).angle() + PI) / TAU) #You can even use it with an array since it's like an index
	
	if knockback == false && hurting == false:
		lastFacingDirection = _cardinal_direction
		match _cardinal_direction:
			0:
				anims.play("mleft")
			1:
				anims.play("mup")
			2:
				anims.play("mright")
			3:
				anims.play("mdown")

	_position_last_frame = position #Remember our current position for next frame

func makepath() -> void:
	#nav_agent.target_position = Global.playerpos
	##use different reference
	
	nav_agent.target_position = Global.playerPosition

func _on_hurtzone_body_entered(body: Node2D) -> void:
	##this works but does not allow continous detection. fix later
	if body.name == "player":
		hugging = true
		handle_attack()

func handle_attack() -> void:
	match _cardinal_direction:
		0:
			anims.play("hitleft")
		1:
			anims.play("hitup")
		2:
			anims.play("hitright")
		3:
			anims.play("hitdown")
	cooldown.start() #attack animation cooldown

func _on_cooldown_timeout() -> void:
	#print("cooldown over")
	hugging = false
	knockback = false

func _on_hitzone_area_entered(area: Area2D) -> void:
	#if area.name.containsn("hurt"):
		#zomb_hurt()
##neither of these work <<<<<<<<
#func _on_hitzone_body_entered(body: Node2D) -> void:
	#if body.name.containsn("player"):
		#handle_hurt()
	pass

func zomb_hurt() -> void:
	print("POW")
	if !hurting:
		hurting = true
		zhealth -= 1.0
		zomb_hurt_animation()
		if zhealth <= 0.0:
			zhealth = 0.0
			dead = true
		elif !dead:
			print("GRAH - iframes - zhealth: " + str(zhealth))

		else: #shouldn't happen as queue_free() gets called too quickly to hit it again
			print("SPLORT")

func zomb_hurt_animation() -> void:
	match lastFacingDirection:
		0:
			anims.play("hurtL")
		1:
			anims.play("hurtU")
		2:
			anims.play("hurtR")
		3:
			anims.play("hurtD")
	hurt_cooldown.start()
	
func handle_death() -> void:
	print("zombie down!")
	queue_free()
	
func _on_pathtimer_timeout() -> void:
	makepath()

func _on_hurt_cooldown_timeout() -> void:
	hurting = false
	if dead == true:
		handle_death()
	
