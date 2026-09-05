shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(1.0, 0.17, 0.84, 1.0);
uniform float radius = 0.50;
uniform float border_width = 0.02;

void fragment() {
	vec2 center = vec2(0.5);
	float dist = distance(UV, center);

	if (dist >= radius - border_width && dist <= radius) {
		COLOR = border_color;
	} else {
		COLOR = vec4(0.0);
	}
}