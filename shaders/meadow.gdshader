shader_type spatial;
uniform sampler2D meadow_noise : repeat_enable;
void fragment(){
	float meadow=texture(meadow_noise,UV*1.8).r;
	float blades=texture(meadow_noise,UV*21.).r;
	vec3 grass=mix(vec3(0.064,0.18,0.09),vec3(0.36,0.48,0.14),meadow);
	ALBEDO=grass*(0.76+blades*0.45);
	ROUGHNESS=0.96;
}
