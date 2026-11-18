shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;

uniform vec4 tint : source_color;
uniform float strength = 1.0;

void fragment() {
	float pulse = pow(0.5 + 0.5 * cos(TAU * (UV.x * 1.6 - TIME * 0.72)), 7.0);
	float root = smoothstep(0.02, 0.23, UV.x);
	float tip = 1.0 - smoothstep(0.90, 1.0, UV.x);
	ALBEDO = tint.rgb * mix(0.45, 1.1, strength) * (0.70 + root * tip * pulse * 1.3);
}
