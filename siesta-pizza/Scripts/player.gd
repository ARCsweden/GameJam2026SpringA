extends CharacterBody2D

@export var speed = 90

var packed_scene: PackedScene = preload("res://Scenes/Items/milk.tscn")
var scene_root = packed_scene.instantiate()

var heldItemL: PackedScene
var heldItemR: PackedScene

var lastInteractL = false
var lastInteractR = false
var lastInteractable:Node2D = null

func add_item(item: PackedScene):
	print_debug("Item added")
	
	if(lastInteractL and !heldItemL):
		heldItemL = item
		var sprite: Sprite2D = scene_root.get_node("Sprite")
		$Sprite2DL.texture = sprite.texture
		
	if(lastInteractR and !heldItemR):
		heldItemR = item
		
	print("ItemL: {LItem}\nItemR: {RItem}".format({"LItem": heldItemL, "RItem": heldItemR}))

func remove_item() -> PackedScene:
	if(lastInteractL and heldItemL):
		var temp = heldItemR
		heldItemL = null
		return temp
		
	if(lastInteractR and heldItemR):
		var temp = heldItemR
		heldItemR = null
		return temp
		
	else:
		return null
	
func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * speed

func _ready():
	$AnimatedSprite2D.play()

func _physics_process(delta: float):
	get_input()
	move_and_slide()

func _process(delta: float):

	
	if(Input.is_action_just_released("L Action") or Input.is_action_just_released("R Action")):
		lastInteractL = Input.is_action_just_released("L Action")
		lastInteractR = Input.is_action_just_released("R Action")
		
		if(lastInteractable != null):
			if((lastInteractL and !heldItemL) or (lastInteractR and !heldItemR)):
				lastInteractable.interact(self)
			else:
				print_debug("Hand is full")
	
# Animation controller	
	if(velocity.length() > 0):
		$AnimatedSprite2D.speed_scale = velocity.length()/15;
		if(abs(velocity.x) >= abs(velocity.y)):
			$AnimatedSprite2D.animation = "walk_right"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
			
		elif(abs(velocity.y) > abs(velocity.x)):
			$AnimatedSprite2D.flip_h = false
			if(velocity.y < 0):
				$AnimatedSprite2D.animation = "walk_up"
			else:
				$AnimatedSprite2D.animation = "walk_down"
	else:
		$AnimatedSprite2D.speed_scale = 1.0;
		if(Input.is_action_pressed("Action")):
			$AnimatedSprite2D.animation = "tbag"
		else:
			$AnimatedSprite2D.animation = "idle_down"


func _on_interact_2d_body_entered(body: Node2D):
	var tempBody = body.get_parent()	
	if(tempBody.has_method("interact")):
		print_debug("Interactable entered")
		tempBody.set_highlight(true)
		lastInteractable = tempBody	


func _on_interact_2d_body_exited(body: Node2D) -> void:
	if(body.get_parent() == lastInteractable):
		print_debug("Interactable exited")
		lastInteractable.set_highlight(false)
		lastInteractable = null
