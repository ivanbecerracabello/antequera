shader_type canvas_item;

uniform float radius = 0.5;
uniform float border_size = 0.02;

void fragment() {
	vec2 center = vec2(0.5);
	float dist = distance(UV, center);
	
	// Check if we're inside the circle
	if (dist <= radius) {
		COLOR = texture(TEXTURE, UV);
	} else if (dist <= radius + border_size) {
		// Border area - make it black
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// Outside - transparent
		discard;
	}
}
