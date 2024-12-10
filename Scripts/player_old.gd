extends CharacterBody2D

@export var speed = 100
@export var friction = 0.2
@export var acceleration = 0.5
@onready var anims: AnimatedSprite2D = $Anims
@onready var top_anims: AnimatedSprite2D = $TopAnims
@onready var player_fx: AnimationPlayer = $playerFX

func _ready() -> void:
	player_fx.stop()
	
#movement controller borrowed by: https://www.reddit.com/r/godot/comments/tefk75/best_top_down_movement_in_godot_4/
func get_input_motion():
	
	var vert = Input.get_axis("up", "down")
	var hori = Input.get_axis("left", "right")
	
	return Vector2(hori, vert)
	
func _physics_process(_delta: float) -> void:
	
	var dirVect = get_input_motion()
	
	if dirVect.length() > 0:
		velocity = velocity.lerp(dirVect.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	move_and_slide()
	#move_and_collide(velocity * delta)
	#end borrowing
	
	if Global.player_invincible == true:
		
		player_fx.play("flicker_and_hit")
		
	var direction = get_direction()
	anims.play(direction)
	
func _process(_delta: float) -> void:
	if Global.player_health <= 0:
		player_fx.play("hit_sprite") ##change to proper death sprite / animation

func get_direction():
	
	var facing := ""
	
	if Input.is_action_pressed("down"):
		facing = "mdown"
	elif Input.is_action_pressed("up"):
		facing = "mup"
	elif Input.is_action_pressed("left"):
		facing = "mleft"
	elif Input.is_action_pressed("right"):
		facing = "mright"

	if Input.is_action_just_released("down"):
		facing = "idle_down"
	elif Input.is_action_just_released("up"):
		facing = "idle_up"
	elif Input.is_action_just_released("left"):
		facing = "idle_left"
	elif Input.is_action_just_released("right"):
		facing = "idle_right"
	
	return facing 
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("basic"):
		
		##player animation handler needs to be fixed before adding directional attack anims - borrow from zombie.gd
		top_anims.play("strike_down")
		
		
