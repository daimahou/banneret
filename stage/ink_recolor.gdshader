shader_type canvas_item;

uniform vec3 ink_color : source_color;

// Each pixel moves towards ink_color as far as it is dark: ink takes the colour, light fills and paper keep theirs.
void fragment() {
	float darkness = 1.0 - dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
	COLOR.rgb = mix(COLOR.rgb, ink_color, darkness);
}
