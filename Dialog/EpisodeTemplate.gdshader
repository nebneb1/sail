shader_type canvas_item;

uniform sampler2D noise;
uniform float speed = 0.1;
uniform float scale = 1.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform float BIAS = 1.0;

void fragment() {
	vec2 uv_offset = (
		texture(noise, (SCREEN_UV + vec2(1.0, 0.0)), BIAS).rb -
		texture(noise, (SCREEN_UV + vec2(0.0, 1.0)), BIAS).rb
	);
	COLOR = texture(screen_texture, SCREEN_UV + uv_offset * round(2.0 * cos(TIME * 4.0) + 0.0) * scale / 10.0);
	//COLOR = texture(noise, (SCREEN_UV + vec2(TIME * 100.0, 0.0)), BIAS);
}