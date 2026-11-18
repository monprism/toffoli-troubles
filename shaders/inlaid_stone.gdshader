shader_type spatial;

uniform vec4 light_stone : source_color;
uniform vec4 dark_stone : source_color;
uniform float cell_size;
uniform vec2 grid_size;
varying vec2 board_pos;

float hash(vec2 p) {
	vec3 q = fract(vec3(p.xyx) * vec3(0.1031,0.1030,0.0973));
	q += dot(q,q.yzx+33.33);
	return fract((q.x+q.y)*q.z);
}
float grain(vec2 p) {
	vec2 i=floor(p), f=smoothstep(vec2(0.),vec2(1.),fract(p));
	return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),
	           mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
void vertex() { board_pos=VERTEX.xz/cell_size+grid_size*0.5; }
void fragment() {
	vec2 id=floor(board_pos), uv=fract(board_pos)-0.5;
	float seed=hash(id);
	float broad=grain(board_pos*1.7), grit=grain(board_pos*35.);
	vec2 edge=0.483-abs(uv);
	float joint=min(min(edge.x,edge.y),(edge.x+edge.y-0.065-seed*0.09)*0.707);
	joint+=(grit-0.5)*0.025+(grain(board_pos*7.0)-0.5)*0.021;
	float stone=smoothstep(-0.01,0.018,joint);
	vec3 slab=mix(dark_stone.rgb,light_stone.rgb,0.34+0.25*seed+0.32*broad);
	float bedding = grain(vec2(board_pos.x*2.2,board_pos.y*17.0+grain(board_pos*2.4)*1.9));
	slab*=0.79+0.15*grit+0.14*bedding;
	slab=mix(slab,slab*vec3(0.75,0.54,0.42),smoothstep(0.54,0.89,bedding)*0.37);
	// Split flagstones along a natural fracture, with lichen caught in the joint.
	float crack=abs(uv.x+uv.y*(seed-0.5)+(grain(board_pos*5.)-0.5)*0.20-seed*0.53);
	float split=(1.-smoothstep(0.003,0.024,crack))*step(0.58,seed);
	slab*=1.-split*0.48;
	float moss=(1.-smoothstep(0.01,0.10,joint))*smoothstep(0.42,0.75,broad+grit*0.20);
	slab=mix(slab,vec3(0.22,0.21,0.11),moss*0.62);
	float bevel=smoothstep(0.,0.05,joint);
	slab*=0.73+0.27*bevel;
	// Mineral flecks and patches of worn stone catch the light near the bevel.
	float chips = smoothstep(0.76,0.91,grain(board_pos*28.0))*smoothstep(0.40,0.76,broad);
	slab += vec3(0.06,0.045,0.028)*chips;
	float worn_edge = smoothstep(0.014,0.028,joint)*(1.0-smoothstep(0.029,0.049,joint));
	slab += vec3(0.10,0.071,0.045)*worn_edge*(0.65+0.35*grit);
	ALBEDO=mix(vec3(0.072,0.049,0.037),slab,stone);
	vec2 slope=sign(uv)*(1.-bevel);
	NORMAL_MAP=normalize(vec3(slope.x*0.7,-slope.y*0.7,1.0))*0.5+0.5;
	ROUGHNESS=0.84;
}
