shader_type spatial;
render_mode unshaded;

uniform vec4 foam_color : source_color;
uniform vec4 main_color : source_color;
uniform float edge_threshold = 1.0;
uniform float edge_grain : hint_range(0, 80) = 20.0;
uniform sampler2D displacement_guide : source_color;
uniform float displacement_amount = 1.0;
const float near = 0.15;
const float far = 300.0;
uniform float wave_height = 0.1;
uniform float wave_length = 0.2;
uniform float time_factor = 4.0;
uniform float foam_speed = 1.0;
uniform float foam_amount : hint_range(0, 1) = 2.0;
uniform float foam_size : hint_range(0, 200) = 1.0;
uniform vec2 foam_dir;
varying vec3 world_vert;
uniform float time = 0.0;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
float linearize(float c_depth) {
	c_depth = 2.0 * c_depth - 1.0;
	return near * far / (far + c_depth * (near - far));
}

void vertex() {
	world_vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y = (wave_height * sin((world_vert.x + time / time_factor) / wave_length))
	 + (wave_height * sin((world_vert.z + time / time_factor) / wave_length));
	world_vert.y = VERTEX.y;
}
void fragment()
{
	float zdepth = linearize(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float zpos = linearize(FRAGCOORD.z);
	float diff = zdepth - zpos;
	vec2 world_coords = world_vert.xz;
 	vec4 foam = texture(displacement_guide, world_coords / foam_size - TIME * foam_speed * foam_dir).rgba;
	float sum = foam.r;
	vec4 water_color = vec4(0, 0, 0, 0);

	if (sum > 1.0 - foam_amount) {
		water_color = foam_color;
	} else {
		water_color = main_color;
	}

	vec2 displ = texture(displacement_guide, world_coords/80.0 - TIME / 200.0).rg;
	displ = ((displ * 2.0) - 1.0) * displacement_amount;
	diff += displ.x;

	vec4 col = mix(water_color, foam_color, step(edge_threshold, diff));
	ALBEDO = col.rgb;
	//vec4 depth_color_adj = mix(foam_color, water_color, step(edge_threshold, diff));

	//ALBEDO = clamp(water_color + depth_color_adj,vec4(0.0),vec4(1.0)).rgb;
	//ALBEDO = water_color.rgb;
	//ALBEDO = vec3(diff, diff, diff);
	//ALPHA = col.a;
 	//ROUGHNESS = 0.1;
	//NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
}