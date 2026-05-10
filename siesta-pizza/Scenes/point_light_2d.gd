extends PointLight2D

@export var day_length := 30.0

@export var min_energy := 0.10
@export var max_energy := 1.0

# Optional fire flicker
@export var flicker_strength := 0.08
@export var flicker_speed := 10.0

var time := 0.0

func _process(delta: float) -> void:
	time = fmod(time + delta, day_length)

	var t: float = time / day_length

	# Same curve as the sun
	var daylight: float = (sin(t * TAU - PI / 2.0) + 1.0) / 2.0
	daylight = smoothstep(0.0, 1.0, daylight)

	# Reverse it for fire
	var night_amount: float = 1.0 - daylight

	# Base energy
	var target_energy: float = lerp(min_energy, max_energy, night_amount)

	# Add subtle flicker
	var flicker: float = sin(Time.get_ticks_msec() * 0.001 * flicker_speed) * flicker_strength

	energy = target_energy + flicker
