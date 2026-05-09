class_name InteractableObject
extends Node2D

signal interact_finished(item, player)

@onready var sprite: AnimatedSprite2D  = $Sprite
@onready var idle_audio: AudioStreamPlayer2D = $IdleAudio
@onready var audio: AudioStreamPlayer2D = $Audio

@export var interaction_name: String = "Interact"
@export var highlight_color: Color = Color(1.4, 1.4, 0.0, 1.0)

@export var item_to_give: PackedScene
@export var processing_time: float = 2.0
@export var parallelism  = false

#AudioPlayer
@export var idle_sounds: Array[AudioStream]
@export var interaction_sound: AudioStream

@export var idle_min_delay: float = 5.0
@export var idle_max_delay: float = 15.0
@export var idle_volume_db: float = -10.0
@export var idle_pitch_min: float = 0.5
@export var idle_pitch_max: float = 1.0
@export var play_idle_sound: bool = true

@export var volume_db: float = 0.0
@export var pitch_min: float = 1.0
@export var pitch_max: float = 1.0
@export var play_sound_on_interact: bool = true

var highlighted := false
var is_processing := false

var _idle_timer := 0.0
var _next_idle_time := 0.0


var processing_timer := 0.0
var pending_player = null

func interact_extra(player):
	pass

func interact(player):
	
	if is_processing:
		return
		
	if play_sound_on_interact and interaction_sound:
		audio.stream = interaction_sound
		audio.pitch_scale = randf_range(pitch_min, pitch_max)
		audio.play()

	if processing_time > 0.0:
		is_processing = true
		processing_timer = 0.0
		pending_player = player
	else:
		_give_item(player)
		
	interact_extra(player)
	
func _give_item(player):

	if item_to_give:
		var item = item_to_give.instantiate()
		player.add_item(item)
	
func _ready():
	
	if sprite.material:
		sprite.material = sprite.material.duplicate()
		
	_idle_timer = 0.0
	_next_idle_time = randf_range(idle_min_delay, idle_max_delay)
	audio.volume_db = volume_db
	
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
		
func _process(delta):

	_idle_timer += delta

	if _idle_timer >= _next_idle_time:

		_play_idle_sound()

		_idle_timer = 0.0
		_next_idle_time = randf_range(idle_min_delay, idle_max_delay)
		
	_idle_timer += delta

	if is_processing:
		processing_timer += delta

		if processing_timer >= processing_time:
			is_processing = false
			_give_item(pending_player)
			emit_signal("interact_finished", item_to_give, pending_player)
			pending_player = null
			
		

func _play_idle_sound():

	if idle_sounds.is_empty():
		return

	var sound = idle_sounds.pick_random()

	idle_audio.stream = sound
	idle_audio.volume_db = idle_volume_db
	idle_audio.pitch_scale = randf_range(idle_pitch_min, idle_pitch_max)
	idle_audio.play()

func set_highlight(enabled: bool):

	highlighted = enabled

	var material := sprite.material as ShaderMaterial

	if material:
		material.set_shader_parameter("enabled", enabled)

func is_true_parallelism():
	return parallelism
