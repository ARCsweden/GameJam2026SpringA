extends CharacterBody2D

@export var speed = 200

func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * speed

func _ready():
	$AnimatedSprite2D.play()

func _physics_process(delta):
	get_input()
	move_and_slide()

func _process(delta):
	if abs(velocity.x) > abs(velocity.y):
		$AnimatedSprite2D.animation = "walk_right"
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
		
	elif abs(velocity.y) > abs(velocity.x):
		if velocity.y < 0:
			$AnimatedSprite2D.animation = "walk_up"
		else:
			$AnimatedSprite2D.animation = "walk_down"
	
	else:
		$AnimatedSprite2D.animation = "idle_down"
