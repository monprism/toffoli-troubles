shader_type spatial;

varying vec2 channel_pos;

void vertex() {
	channel_pos = VERTEX.xz;
}

void fragment() {
	float across = abs(channel_pos.x);
	float bank = smoothstep(0.62, 0.93, across);
	float drift = cos(channel_pos.y * 0.52 + channel_pos.x * 1.2 - TIME * 0.19);
	float reflection = exp(-pow((channel_pos.x - 0.20 + 0.055 * drift) * 2.7, 2.0));
	float ripple = cos(channel_pos.y * 5.0 + channel_pos.x + 0.35 * drift - TIME * 0.75);
	vec3 water = vec3(0.020, 0.086, 0.107);
	water += vec3(0.024, 0.045, 0.049) * reflection * (0.78 + 0.09 * ripple);
	ALBEDO = mix(water, vec3(0.009, 0.033, 0.037), bank * 0.74);
	ROUGHNESS = 0.42;
	SPECULAR = 0.32;
}
