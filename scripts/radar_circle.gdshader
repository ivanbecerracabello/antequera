shader_type canvas_item;

uniform vec2 texture_offset = vec2(0.0);

void fragment() {
	vec2 center = vec2(0.5);
	vec2 to_center = UV - center;
	float dist = length(to_center);
	
	// Sample texture
	vec2 sample_uv = UV - texture_offset;
	COLOR = texture(TEXTURE, sample_uv);
	
	// Circular mask - fade alpha outside circle
	if (dist > 0.5) {
		COLOR.a = 0.0;
	}
}
