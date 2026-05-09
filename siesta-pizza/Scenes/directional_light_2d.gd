extends DirectionalLight2D

@export var day_length := 600

@export var min_energy := 0.02
@export var max_energy := 0.60

@export var day_color := Color(1.0, 1.0, 1.0)
@export var sunset_color := Color(1.0, 0.553, 0.18, 1.0)
@export var sunset_color_strength := 0.85

var time := 0.0

func _process(delta: float) -> void:
	time = fmod(time + delta, day_length)

	var t: float = time / day_length

	rotation = t * TAU + PI

	var brightness: float = (sin(t * TAU - PI / 2.0) + 1.0) / 2.0
	brightness = smoothstep(0.0, 1.0, brightness)

	energy = lerp(min_energy, max_energy, brightness)

	# Yellow strongest when brightness is around sunrise/sunset level
	var sunset_amount: float = 1.0 - abs(brightness - 0.35) / 0.35
	sunset_amount = clamp(sunset_amount, 0.0, 1.0)
	sunset_amount = pow(sunset_amount, 2.0) * sunset_color_strength

	color = day_color.lerp(sunset_color, sunset_amount)
