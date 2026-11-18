extends "res://scripts/miniature.gd"

const SEGMENTS := 28
const SIDES := 6
var ribbons: Array[MeshInstance3D] = []
var crests: Array[Node3D] = []

func _ready() -> void:
	for branch in range(2):
		var tint := CYAN if branch==0 else VIOLET
		var ribbon := MeshInstance3D.new()
		ribbon.mesh = build_ribbon(branch)
		var material := ShaderMaterial.new()
		material.shader = preload("res://shaders/quantum_ribbon.gdshader")
		material.set_shader_parameter("tint",tint)
		ribbon.material_override = material
		ribbon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(ribbon)
		ribbons.append(ribbon)

		var crest := group(arc(branch,0.92))
		crests.append(crest)
		aura(crest,Vector3.ZERO,1.07,tint)
		if branch==0:
			orb(crest,Vector3.ZERO,Vector3.ONE*0.29,tint)
		else:
			drum(crest,Vector3.UP*0.072,0.158,0,0.18,tint,4)
			drum(crest,Vector3.DOWN*0.072,0,0.158,0.18,tint,4)
		box(crest,Vector3(0.17,0.035,0.04),Vector3(0.32,0.036,0.043),CREAM)
	hide()

func arc(branch: int, t: float) -> Vector3:
	var outward := sin(t*PI/2.0)
	return Vector3((branch*2-1)*1.36*outward*outward,2.47*t-0.18*t*t,-0.42*t)

func build_ribbon(branch: int) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for segment in range(SEGMENTS+1):
		var t := float(segment)/SEGMENTS
		var tangent := (arc(branch,t+0.002)-arc(branch,t-0.002)).normalized()
		var right := tangent.cross(Vector3.FORWARD).normalized()
		var depth := right.cross(tangent)
		var radius := lerpf(0.069,0.022,t)*smoothstep(0.0,0.15,t)
		for side in range(SIDES):
			var theta := side*TAU/SIDES
			var offset := right*cos(theta)+depth*sin(theta)
			surface.set_uv(Vector2(t,float(side)/SIDES))
			surface.add_vertex(arc(branch,t)+offset*radius)
	for segment in range(SEGMENTS):
		for side in range(SIDES):
			var here := segment*SIDES+side
			var next := segment*SIDES+(side+1)%SIDES
			for index in [here,next,here+SIDES,next,next+SIDES,here+SIDES]:
				surface.add_index(index)
	return surface.commit()

func update_state(active: bool, origin: Vector3, yin: Vector2, yang: Vector2) -> void:
	visible = active
	position = origin
	if not active:
		return
	for branch in range(2):
		var amplitude := yin if branch==0 else yang
		var magnitude := amplitude.length()
		ribbons[branch].visible = magnitude>0.0316
		crests[branch].visible = ribbons[branch].visible
		ribbons[branch].material_override.set_shader_parameter("strength",magnitude)
		crests[branch].rotation.y = amplitude.angle()
		crests[branch].scale = Vector3.ONE*lerpf(0.58,1.0,magnitude)
