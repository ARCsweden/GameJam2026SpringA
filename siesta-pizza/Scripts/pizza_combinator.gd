extends InteractableObject

var tomato_sauce_count = 0
var cheese_count = 0
var dough_count = 0

# Called when the node enters the scene tree for the first time.
func interact_extra(player, item):
	if item != null:
		if item.item_name == "tomato_sauce":
			tomato_sauce_count = tomato_sauce_count + 1
		if item.item_name == "dough":
			dough_count = dough_count + 1
		if item.item_name == "cheese":
			cheese_count = cheese_count + 1
		player.remove_item()
		if ((dough_count > 0) && (tomato_sauce_count > 0) && (cheese_count > 0)):
			storage_out_empty = false
			$ItemSprite.visible = true;
			tomato_sauce_count = tomato_sauce_count - 1
			dough_count = dough_count - 1
			cheese_count = cheese_count - 1
	
