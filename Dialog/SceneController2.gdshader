shader_type canvas_item;
render_mode unshaded;
 
uniform float circle_size : hint_range(-0.2, 1.2);
uniform float screen_width;
uniform float screen_height;
 
uniform sampler2D noise;
uniform float speed = 0.1;
uniform float scale = 1.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float BIAS = 1.0;

float getLuminance(vec4 argb) {
    float lum = (   77.0  * argb.r
               + 150.0 * argb.g 
               + 29.0 * argb.b);
    return lum;
}
void fragment() {
	vec2 uv_offset = (
		texture(noise, (SCREEN_UV + vec2(1.0, 0.0)), BIAS).rb - 
		texture(noise, (SCREEN_UV + vec2(0.0, 1.0)), BIAS).rb
	);
	COLOR = vec4(0.0);
	//texture(noise, UV);
	float ratio = screen_width / screen_height;
	float dist = distance(vec2(0.5, 0.5), vec2(mix(0.5, UV.x, ratio), UV.y));
	COLOR.a = step(circle_size, dist*1.3);
	vec4 texture_color = texture(noise, UV);
	float luminosity = getLuminance(texture(noise, UV) * vec4(1.0 - smoothstep(circle_size, circle_size + 0.2, dist)));
	if (luminosity > 150.0) {
		COLOR.a = 0.0;
	}
	//uv_offset* round(2.0 * cos(TIME * 4.0) + 0.0) * scale
}