shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;
uniform vec4 tint : source_color;
void fragment() {
	float radius=length(UV-0.5)*2.0;
	float mist=pow(max(0.,1.-radius),2.6);
	float ring=exp(-abs(radius-0.53)*32.);
	ALBEDO=tint.rgb*1.4;
	ALPHA=(mist*0.85+ring*0.30)*(0.9+0.1*sin(TIME*2.4));
}
