extends Node3D

const WOOD := Color("#514039")
const BRASS := Color("#d0a56b")
const INK := Color("#303b40")
const CREAM := Color("#e8dec5")
const LEAF := Color("#447b70")
const CLAY := Color("#a84e39")
const BLUE := Color("#4d7781")
const CYAN := Color("#1ef5d7")
const VIOLET := Color("#ff48b5")
const EMBER := Color("#ff752f")
var material_cache := {}

func piece(parent: Node3D, mesh: PrimitiveMesh, at: Vector3, tint: Color) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	if not material_cache.has(tint):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = tint
		mat.roughness = 0.78
		if tint in [CYAN,VIOLET,EMBER]:
			mat.emission_enabled = true
			mat.emission = tint
			mat.emission_energy_multiplier = 3.2
		if tint==BRASS:
			mat.metallic = 0.30
			mat.roughness = 0.38
		material_cache[tint] = mat
	item.mesh = mesh
	item.material_override = material_cache[tint]
	parent.add_child(item)
	item.position = at
	return item

func box(parent: Node3D, at: Vector3, size: Vector3, tint: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return piece(parent, mesh, at, tint)

func drum(parent: Node3D, at: Vector3, bottom: float, top: float, height: float, tint: Color, sides := 12) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = bottom
	mesh.top_radius = top
	mesh.height = height
	mesh.radial_segments = sides
	return piece(parent, mesh, at, tint)

func orb(parent: Node3D, at: Vector3, size: Vector3, tint: Color) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1
	mesh.radial_segments = 12
	mesh.rings = 6
	var item := piece(parent, mesh, at, tint)
	item.scale = size
	return item

func group(at: Vector3) -> Node3D:
	var node := Node3D.new()
	add_child(node)
	node.position = at
	return node

func aura(parent: Node3D, at: Vector3, diameter: float, tint: Color) -> MeshInstance3D:
	var disk := PlaneMesh.new()
	disk.size = Vector2.ONE*diameter
	var surface := ShaderMaterial.new()
	surface.shader = preload("res://shaders/rune_aura.gdshader")
	surface.set_shader_parameter("tint",tint)
	var halo := MeshInstance3D.new()
	halo.mesh = disk
	halo.material_override = surface
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(halo)
	halo.position = at
	return halo
