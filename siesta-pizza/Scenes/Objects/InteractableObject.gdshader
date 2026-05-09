shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float outline_size = 1.0;
uniform bool enabled = false;

void fragment() {

    vec4 color = texture(TEXTURE, UV);

    if (enabled) {

        vec2 ps = TEXTURE_PIXEL_SIZE * outline_size;

        float outline = 0.0;

        outline += texture(TEXTURE, UV + vec2(ps.x, 0.0)).a;
        outline += texture(TEXTURE, UV - vec2(ps.x, 0.0)).a;
        outline += texture(TEXTURE, UV + vec2(0.0, ps.y)).a;
        outline += texture(TEXTURE, UV - vec2(0.0, ps.y)).a;

        if (color.a <= 0.0 && outline > 0.0) {
            COLOR = outline_color;
        }
        else {
            COLOR = color;
        }
    }
    else {
        COLOR = color;
    }
}