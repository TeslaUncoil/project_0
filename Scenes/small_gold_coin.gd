extends Node2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		Global.coins += 1
		queue_free()
