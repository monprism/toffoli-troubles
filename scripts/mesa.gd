extends "res://scripts/miniature.gd"

const STRATA := [Color("#8a5042"), Color("#a16049"), Color("#77433a"), Color("#a9674d"), Color("#cb8f60"), Color("#af7553")]
const SANDSTONE := Color("#b08467")
const CORNERS := [Vector2(-1,-0.76),Vector2(-0.80,-1),Vector2(0.78,-1),Vector2(1,-0.77),
	Vector2(1,0.72),Vector2(0.82,1),Vector2(-0.79,1),Vector2(-1,0.74)]

func build(width: float, depth: float, floor_width: float, floor_depth: float, stage: int) -> void:
	build_cliff(width,depth)
	var edge := floor_width/2.0+0.58
	var rear := -floor_depth/2.0-1.97
	var front := floor_depth/2.0+0.58
	wall(Vector3(-edge,0,-0.52),depth-0.52,PI/2,1.0,stage+3)
	wall(Vector3(edge,0,-0.52),depth-0.52,PI/2,1.0,stage+7)
	wall(Vector3(0,0,rear),floor_width+0.75,0.0,1.44,stage+12)
	# Low front courses leave the square coordinates and control tray in view.
	wall(Vector3(-floor_width*0.32,0,front),floor_width*0.36,0.0,0.37,stage+19)
	wall(Vector3(floor_width*0.32,0,front),floor_width*0.36,0.0,0.37,stage+24)
	for side in [-1,1]:
		pier(Vector3(side*edge,0,rear),2.02)
		pier(Vector3(side*edge,0,front),1.13)
		pier(Vector3(side*floor_width*0.145,0,front),0.73)
		var sconce := Vector3(side*edge-side*0.57,1.33,rear+0.58)
		drum(self,sconce,0.20,0.31,0.18,WOOD,8)
		orb(self,sconce+Vector3.UP*0.24,Vector3(0.15,0.38,0.15),EMBER)
		aura(self,sconce-Vector3.UP*0.18,1.38,EMBER)

func build_cliff(width: float, depth: float) -> void:
	var wall_mesh := SurfaceTool.new()
	wall_mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	var heights := [-4.2,-3.36,-2.84,-2.14,-1.28,-0.65,-0.08]
	var ledges := [1.10,1.08,1.12,1.03,1.05,0.99,1.0]
	var rings: Array[PackedVector3Array] = []
	for level in heights.size():
		var ring := PackedVector3Array()
		for side in 4:
			var start: Vector2 = CORNERS[side*2]
			var bevel: Vector2 = CORNERS[side*2+1]
			var end: Vector2 = CORNERS[((side+1)*2)%CORNERS.size()]
			var outline := [start,bevel,bevel.lerp(end,0.29),bevel.lerp(end,0.52),bevel.lerp(end,0.77)]
			for index in outline.size():
				var offset: Vector2 = outline[index]
				var jitter := 1.0+0.024*sin(side*7.1+index*4.26)*sin(float(level)*0.59)
				var height: float = heights[level]+0.11*sin(side*8.1+index*0.94)*sin(PI*level/6.0)
				ring.append(Vector3(offset.x*width*0.5*ledges[level]*jitter,height,offset.y*depth*0.5*ledges[level]*jitter-0.65))
		rings.append(ring)
	for level in heights.size()-1:
		for i in rings[level].size():
			var next := (i+1)%rings[level].size()
			var tint: Color = STRATA[level].darkened(0.13*fposmod(sin(i*4.9+level)*21.3,1.0))
			for vertex in [rings[level][i],rings[level+1][next],rings[level][next],rings[level][i],rings[level+1][i],rings[level+1][next]]:
				wall_mesh.set_color(tint)
				wall_mesh.add_vertex(vertex)
	wall_mesh.generate_normals()
	var cliff := MeshInstance3D.new()
	cliff.mesh = wall_mesh.commit()
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.roughness = 0.94
	cliff.material_override = material
	add_child(cliff)

func wall(center: Vector3, length: float, angle: float, height: float, seed_value: int) -> void:
	var course := group(center)
	course.rotation.y = angle
	var blocks := maxi(1,roundi(length/1.42))
	var span := length/blocks
	box(course,Vector3.UP*0.08,Vector3(length,0.19,0.50),SANDSTONE.darkened(0.25))
	for index in blocks:
		var x := (index+0.5)*span-length/2.0
		var wear := fposmod(sin(index*3.19+seed_value*0.87)*17.0,1.0)
		var rise := height*(0.74+wear*0.25)
		var tone := SANDSTONE.darkened(0.23*wear)
		box(course,Vector3(x,rise*0.29+0.13,0.015),Vector3(span-0.035,rise*0.57,0.42),tone.darkened(0.11))
		var crown := box(course,Vector3(x,rise*0.77+0.13,0),Vector3(span-0.062,rise*0.41,0.39),tone)
		crown.rotation.z = (wear-0.5)*0.06
		if index%3==0:
			box(course,Vector3(x,rise+0.18,0),Vector3(span*0.94,0.17,0.47),tone.lightened(0.10))

func pier(at: Vector3, height: float) -> void:
	box(self,at+Vector3.UP*0.13,Vector3(0.84,0.27,0.83),SANDSTONE.darkened(0.22))
	for course in range(3):
		var block := box(self,at+Vector3.UP*(0.25+(course+0.5)*height/3.0),Vector3(0.59,height/3.0-0.026,0.62),SANDSTONE.darkened(0.09*course))
		block.rotation.y = 0.035*(course-1)
	box(self,at+Vector3.UP*(height+0.31),Vector3(0.76,0.18,0.78),SANDSTONE.lightened(0.13))
