shader_type canvas_item;

// The illustrated boss sources contain a neutral checker backdrop. Remove it
// at render time while preserving the saturated armor, cloaks and highlights.
void fragment() {
	vec3 rgb = texture(TEXTURE, UV).rgb;
	float minimum = min(rgb.r, min(rgb.g, rgb.b));
	float maximum = max(rgb.r, max(rgb.g, rgb.b));
	float neutral = 1.0 - smoothstep(0.018, 0.075, maximum - minimum);
	float bright = smoothstep(0.65, 0.76, minimum);
	COLOR.a *= 1.0 - neutral * bright;
}
