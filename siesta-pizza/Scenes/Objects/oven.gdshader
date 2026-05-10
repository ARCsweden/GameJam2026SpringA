shader_type canvas_item;

// Pixel-art Pizza Oven Fire Shader
// Wide, low flames for an oven mouth.
// Uses tapered flame licks instead of glowing orb particles.

uniform float speed : hint_range(0.1, 5.0) = 0.7;
uniform float pixelSize : hint_range(0.001, 0.1) = 0.055;
uniform float alpha : hint_range(0.0, 1.0) = 0.75;
uniform float flickerStrength : hint_range(0.0, 0.5) = 0.18;

uniform vec3 fromColor : source_color = vec3(1.0, 0.48, 0.05);
uniform vec3 toColor : source_color = vec3(0.55, 0.08, 0.02);
uniform vec3 coreColor : source_color = vec3(1.0, 0.85, 0.25);

uniform float hueShift : hint_range(-1.0, 1.0) = 0.0;
uniform float saturationFactor : hint_range(0.0, 2.0) = 1.15;

uniform float particleCount : hint_range(16.0, 512.0) = 70.0;
uniform vec2 size = vec2(1.05, 0.42);

uniform float fireShift : hint_range(0.0, 1.5) = 0.55;
uniform float fireShiftFrequency : hint_range(1.0, 10.0) = 4.0;

uniform float sparkCount : hint_range(0.0, 50.0) = 4.0;
uniform float sparkSize : hint_range(0.0005, 0.01) = 0.004;
uniform float sparkSpeed : hint_range(0.1, 3.0) = 0.12;
uniform vec3 sparkColor : source_color = vec3(1.0, 0.75, 0.15);

uniform float smokeCount : hint_range(0.0, 50.0) = 2.0;
uniform float smokeSize : hint_range(0.001, 0.08) = 0.025;
uniform float smokeDrift : hint_range(0.0, 0.5) = 0.08;
uniform vec3 smokeColor : source_color = vec3(0.08, 0.065, 0.055);

uniform float windForce : hint_range(-0.5, 0.5) = 0.0;
uniform float aspectRatio : hint_range(0.01, 5.0) = 1.0;
uniform vec2 posOffset = vec2(0.0, -0.58);

uniform float ovenWidth : hint_range(0.1, 2.0) = 1.25;
uniform float ovenHeight : hint_range(0.1, 1.5) = 0.62;

float Hash1(float t) {
	return fract(cos(t * 124.97) * 248.842) - 0.5;
}

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;

	return vec3(
		abs(q.w - q.y) / (6.0 * d + e) + q.z,
		d / (q.x + e),
		q.x
	);
}

vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.w);

	return c.z * mix(
		K.xxx,
		clamp(p - K.x, 0.0, 1.0),
		c.y
	);
}

float OvenMask(vec2 uv) {
	float x = abs(uv.x) / ovenWidth;
	float y = uv.y / ovenHeight;

	float arch = 1.0 - x * x;
	float inside_arch = step(0.0, arch) * step(y, arch);
	float above_floor = step(-0.08, y);

	return inside_arch * above_floor;
}

vec3 SimulateFire(vec2 uv, float t) {
	vec3 res = vec3(0.0);

	for (float i = 0.0; i < particleCount; i++) {
		float id = i + 1.0;

		float seed = Hash1(id * 91.7);
		float seed2 = Hash1(id * 37.2);

		float ct = fract(t * mix(0.55, 1.25, abs(seed)) + id / particleCount);

		float base_x = seed * size.x;

		float y = ct * size.y * mix(0.75, 1.15, abs(seed2));

		float width = mix(0.16, 0.025, ct);

		float wobble =
			sin(t * fireShiftFrequency + seed * 10.0 + ct * 5.0)
			* fireShift
			* ct
			* 0.18;

		float x = base_x + wobble + windForce * ct;

		vec2 p = uv - vec2(x, y);

		float body = 1.0 - abs(p.x) / width;
		float vertical = smoothstep(0.12, 0.0, abs(p.y));
		float height_fade = 1.0 - ct;

		float flame = saturate(body) * vertical * height_fade;
		flame = pow(flame, 1.8);

		vec3 col = mix(fromColor, toColor, ct);

		float core_mask =
			saturate(1.0 - abs(p.x) / (width * 0.42))
			* saturate(1.0 - ct * 1.8);

		col = mix(col, coreColor, core_mask);

		res += col * flame * 2.2;
	}

	return res;
}

vec3 SimulateSparks(vec2 uv, float t) {
	vec3 sparkRes = vec3(0.0);

	t *= sparkSpeed;

	for (float i = 0.0; i < sparkCount; i++) {
		float particleId = (i + 1.0) * 133.0;
		float ct = fract(t + particleId / 100.0);
		float seed = Hash1(particleId);

		vec2 dir = vec2(seed * 0.22 + windForce, size.y * 1.5);
		vec2 particle_center = vec2(seed * size.x * 0.9, 0.02) + dir * ct;

		float dist = length(uv - particle_center);
		float particle_influence = saturate(1.0 - dist / (sparkSize * 5.0));
		float glow_falloff = pow(particle_influence, 15.0);
		float lifespan_fade = saturate(1.0 - ct * 2.4);

		sparkRes += sparkColor * glow_falloff * lifespan_fade * 60.0;
	}

	return sparkRes;
}

vec3 SimulateSmoke(vec2 uv, float t) {
	vec3 smokeRes = vec3(0.0);

	for (float i = 0.0; i < smokeCount; i++) {
		float particleId = (i + 1.0) * 111.0;
		float ct = fract(t * 0.35 + particleId / 100.0);
		float seed = Hash1(particleId);

		vec2 dir = vec2(seed * smokeDrift + windForce * 0.4, size.y * 1.1);
		vec2 off = vec2(seed * size.x * 0.75, size.y * 0.35);

		float dist = length(uv - off - dir * ct);
		float puff = smoothstep(smokeSize, 0.0, dist);
		float fade = saturate(1.0 - ct);

		smokeRes += smokeColor * puff * fade * 0.35;
	}

	return smokeRes;
}

void fragment() {
	vec2 frag_coords = UV * 2.0 - 1.0;

	frag_coords.x *= aspectRatio;
	frag_coords.y *= -1.0;
	frag_coords -= posOffset;

	vec2 pixelated_frag = floor(frag_coords / pixelSize) * pixelSize;

	float base_time = TIME + 100.0;

	vec3 fire_color = SimulateFire(pixelated_frag, base_time * speed);
	vec3 spark_color = SimulateSparks(pixelated_frag, base_time);
	vec3 smoke_color = SimulateSmoke(pixelated_frag, base_time);

	float oven_mask = OvenMask(pixelated_frag);

	vec3 result_color = fire_color + spark_color + smoke_color;
	result_color *= oven_mask;

	vec3 hsv = rgb_to_hsv(result_color);
	hsv.x = fract(hsv.x + hueShift);
	hsv.y *= saturationFactor;
	result_color = hsv_to_rgb(hsv);

	float flicker = (Hash1(base_time * 5.0) + 0.5) * flickerStrength;
	vec3 final_color = result_color * (1.0 + flicker);

	float intensity = max(max(result_color.r, result_color.g), result_color.b);
	float final_alpha = smoothstep(0.015, 0.35, intensity) * alpha * oven_mask;

	COLOR = vec4(final_color * alpha, final_alpha);
}