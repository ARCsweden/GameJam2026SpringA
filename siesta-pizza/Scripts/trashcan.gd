extends InteractableObject

# Called when the node enters the scene tree for the first time.
func interact_extra(player, item):
	is_source = false
	if item != null:
		player.remove_item()
	print_debug("Trashcan interacted")
	
