extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


func _play_footstep():
	FootstepManager.play_footstep(global_position)


func _on_frame_changed() -> void:
	if animation == "walk_right":
		match frame:
			1,4:
				_play_footstep()
	elif animation == "walk_down":
		match frame:
			2,5:
				_play_footstep()
	elif animation == "walk_up":
		match frame:
			2,5:
				_play_footstep()
