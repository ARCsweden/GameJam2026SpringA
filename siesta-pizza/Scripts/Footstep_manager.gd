extends Node

var tilemaps: Array[TileMapLayer] = []

const footstep_sounds = {
	"Dirt": [
		preload("res://Assets/Music/Feet_sounds/Dirt_1.wav"),
		preload("res://Assets/Music/Feet_sounds/Dirt_2.wav")
	],
	"Grass": [
		preload("res://Assets/Music/Feet_sounds/Grass_1.wav"),
		preload("res://Assets/Music/Feet_sounds/Grass_2.wav")
	],
	"Wood": [
		preload("res://Assets/Music/Feet_sounds/Wood_1.wav"),
		preload("res://Assets/Music/Feet_sounds/Wood_2.wav")
	],
	"Stone": [
		preload("res://Assets/Music/Feet_sounds/Stone_1.wav"),
		preload("res://Assets/Music/Feet_sounds/Stone_2.wav")
	]
}

func play_footstep(position: Vector2):
	var tile_data = []
	for tilemap in tilemaps:
		var tile_position = tilemap.local_to_map(position)
		var data = tilemap.get_cell_tile_data(tile_position)
		if data:
			tile_data.push_back(data)
	
	if tile_data.size() > 0:
		#maybe swap
		var tile_type = tile_data.front().get_custom_data("footstep_sound")
		
		if footstep_sounds.has(tile_type):
			var audio_player = AudioStreamPlayer2D.new()
			audio_player.stream = footstep_sounds[tile_type].pick_random()
			audio_player.volume_linear = 0.1
			get_tree().root.add_child(audio_player)
			audio_player.global_position = position
			audio_player.play()
			await audio_player.finished
			audio_player.queue_free()
