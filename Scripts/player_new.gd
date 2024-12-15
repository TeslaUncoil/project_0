extends CharacterBody2D

#constant exports, fluid or modifiable player characteristics
@export var minSpeed = 10.0
@export var speed = 100.0
@export var friction = 1
@export var acceleration = 0.5
@export var health = 3.0

#flag exports, use to control animations and hit/health detection
#these probably dont need to be exports? couldn't hurt??
@export var hurting = false
@export var attacking = false
@export var dead = false
@export var invincible = false
@export var idle = true


#other node references
@onready var player: CharacterBody2D = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hurt_cooldown: Timer = $HurtCooldown
@onready var invincible_cooldown: Timer = $InvincibleCooldown
@onready var attack_cooldown: Timer = $AttackCooldown

var direction := Vector2.ZERO
var lastFacingDirection := Vector2(0, 1)

func _ready() -> void:
	
	actor_setup.call_deferred()

func actor_setup():
	animation_tree.active = true
	
	# Wait for the first physics frame so ...
	await get_tree().physics_frame
	

func get_input_motion():
	var vertical = Input.get_axis("up", "down")
	var horizontal = Input.get_axis("left", "right")
	return Vector2(horizontal, vertical)

func _physics_process(_delta: float) -> void:
	
	if !dead:
		direction = get_input_motion() #retrieve direction as Vector2 based on input buttons
	
	if direction.length() > 0: #so long as a direction is being actively pressed...
		#calculates velocity according to direction being pressed and allows for physics acceleration
		velocity = velocity.lerp(direction.normalized() * speed, acceleration) 
	else:
		#calculates stopping velocity and allows for frictional ramp-down
		velocity = velocity.lerp(Vector2.ZERO, friction)
	
	move_and_slide() #run movement function according to all velocity calculations done above
	
	#animation tree initial understandings courtesy of Jon Topielski: https://youtu.be/Xf2RduncoNU?si=IzwLiThvs-j7jusX
	#implemented animation tree code and relationships courtesy of Bitlytic: https://youtu.be/iElHZhOxGYA?si=OoJR6MF5TKAoaYbj
	
	idle = !player.velocity #taking ! of velocity returns a bool, allowing to check for movement
	if !idle: #so long as player is moving....
		#lFD gets set to "previous" (current) vector (normalized) in order to set blend position for animations
		#this way, if input ceases, anims return to idle, but stores the direction player was last moving
		lastFacingDirection = player.velocity.normalized()
	
	#sending latest direction into blend positions of each animation state
	## - can this be done conditionally?
	animation_tree.set("parameters/playerStates/move/blend_position", lastFacingDirection)
	animation_tree.set("parameters/playerStates/idle/blend_position", lastFacingDirection)
	animation_tree.set("parameters/playerStates/attack/blend_position", lastFacingDirection)
	animation_tree.set("parameters/playerStates/hurt/blend_position", lastFacingDirection)
	

func _on_hit_origin_body_entered(body: Node2D) -> void:
	
	if body.name.containsn("zomb") and !invincible:
		handle_hurt()
	elif body.name.containsn("zomb") and invincible: 
		print("cant touch me!")
		
		
func _on_hurt_origin_body_entered(body: Node2D) -> void:
	if body.has_method("zomb_hurt"):
		body.zomb_hurt()

#func _on_hit_origin_area_entered(area: Area2D) -> void:
##disconnect before deleting
	#if area.name.containsn("zone") and !invincible:
		#handle_hurt()
	#elif area.name.containsn("zone") and invincible: 
		#handle_invincibility()

func handle_hurt() -> void:
	if !hurting:
		hurting = true
		health -= 1.0
		if health <= 0.0:
			health = 0.0
			handle_death()
		elif !dead:
			hurt_cooldown.start()
			print("ow! - iframes - health: " + str(health))
			handle_invincibility()
		else:
			print("hit - but already dead!")

func _on_hurt_cooldown_timeout() -> void:
	hurting = false
	print("no more ouch!")


func handle_death() -> void:
	dead = true
	##bug where you slide really far after dying sometimes, not a problem but looks weird
	#game reset handled in game_manager.gd


func handle_attack() -> void:
	if !attacking:
			attacking = true
			attack_cooldown.start()

func _on_attack_cooldown_timeout() -> void:
	attacking = false


func handle_invincibility() -> void:
	if !invincible:
		invincible = true
		invincible_cooldown.start()
		print("im invincible!")
		animation_tree.set("parameters/TimeSeek/seek_request", 0)

func _on_invincible_cooldown_timeout() -> void:
	invincible = false
	print("no more invincibility!")
	animation_tree.set("parameters/TimeSeek/seek_request", -1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("basic"):
		handle_attack()
	
	if event.is_action_pressed("dev"):
		handle_invincibility()
		
	if event.is_action_pressed("selfsuck"):
		handle_hurt()

func _on_position_timer_timeout() -> void:
	Global.playerPosition = position
	
