extends Node2D
@onready var heart_state: AnimatedSprite2D = $heartState


func swap_state(state: String) -> void:
	if state == "full" or "empty":
		heart_state.animation = state
	else:
		print("invalid heart state")
