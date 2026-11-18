extends "res://scripts/miniature.gd"

var cell: Vector2i
var home: Vector2i
var kind: int
var heading := 0
var travel: Tween
var body := Node3D.new()
const NAMES := ["Mossback", "Cinder newt", "Bell Moth"]

func build(species: int, start: Vector2i) -> void:
	kind = species
	cell = start
	home = start
	heading = posmod(start.x+start.y,4)
	add_child(body)
	var feet := Color("#513c32")
	match kind:
		0:
			orb(body,Vector3.UP*0.43,Vector3(0.92,0.56,1.12),INK)
			for i in range(3):
				var plate := drum(body,Vector3(0,0.58,-0.36+i*0.31),0.45-i*0.035,0.30,0.32,LEAF.lightened(i*0.055),7)
				plate.scale.z = 0.79
				orb(body,Vector3(0,0.75,-0.36+i*0.31),Vector3(0.17,0.14,0.23),Color("#a8b071"))
			for side in [-1,1]:
				for j in range(3):
					box(body,Vector3(side*0.48,0.21,-0.35+j*0.32),Vector3(0.36,0.13,0.12),feet).rotation.z=side*0.4
				drum(body,Vector3(side*0.18,0.52,0.65),0.11,0.0,0.39,BRASS,5).rotation.x=0.55
				for j in range(3):
					orb(body,Vector3(side*0.59,0.12,-0.35+j*0.32),Vector3(0.18,0.12,0.19),INK)
		1:
			orb(body,Vector3.UP*0.35,Vector3(0.63,0.50,1.24),CLAY)
			orb(body,Vector3(0,0.44,0.54),Vector3(0.65,0.34,0.51),INK)
			for i in range(4):
				var ridge := drum(body,Vector3(0,0.62,-0.50+i*0.27),0.17,0.01,0.32+0.055*i,INK,4)
				ridge.rotation.x=-0.28
				orb(body,Vector3(0.08,0.62,-0.46+i*0.27),Vector3(0.11,0.12,0.16),EMBER)
			for side in [-1,1]:
				for j in [-0.32,0.32]:
					box(body,Vector3(side*0.36,0.19,j),Vector3(0.37,0.14,0.17),CLAY).rotation.y=side*0.65
			drum(body,Vector3(0,0.27,-0.80),0.19,0.01,0.75,CLAY,6).rotation.x=-PI/2
		2:
			orb(body,Vector3.UP*0.70,Vector3(0.36,0.43,0.85),INK)
			for side in [-1,1]:
				var wing := drum(body,Vector3(side*0.49,0.83,0),0.54,0.12,0.16,Color("#75668a"),3)
				wing.scale.z=1.30
				wing.rotation.z=side*0.37
				var lower := orb(body,Vector3(side*0.47,0.77,-0.34),Vector3(0.58,0.13,0.58),Color("#4c4968"))
				lower.rotation.y = side*0.47
				var eye_spot := orb(body,Vector3(side*0.58,0.96,-0.12),Vector3(0.29,0.07,0.28),Color("#c88a70"))
				orb(eye_spot,Vector3(0,0.43,0),Vector3(0.56,0.23,0.58),INK)
				orb(body,Vector3(side*0.51,0.98,0.03),Vector3(0.19,0.07,0.25),CREAM)
				box(body,Vector3(side*0.11,0.90,0.40),Vector3(0.045,0.41,0.045),BRASS).rotation.z=-side*0.38
	for side in [-1,1]:
		orb(body,Vector3(side*0.14,0.58 if kind!=2 else 0.77,0.62 if kind!=2 else 0.35),Vector3.ONE*0.095,EMBER if kind==1 else BRASS)

func move_to(target: Vector2i, at: Vector3) -> void:
	var delta_cell := target-cell
	cell = target
	if travel:
		travel.kill()
	body.position.y = 0
	body.rotation.y = atan2(delta_cell.x,delta_cell.y)
	travel = create_tween().set_parallel(true)
	travel.tween_property(self,"position",at,0.22)
	travel.tween_property(body,"position:y",0.13,0.10)
	travel.chain().tween_property(body,"position:y",0.0,0.12)
