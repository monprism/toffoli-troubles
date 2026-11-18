class_name Diorama extends "res://scripts/miniature.gd"

const TILE := [Color("#bb9171"), Color("#a88d76"), Color("#bd8160"), Color("#a59e76"), Color("#aa8c83")]
const Mesa := preload("res://scripts/mesa.gd")
const START := Vector2i(1,9)
const BOARD_SIZE := Vector2i(12,12)
const CELL := 1.85
const WINCHES := [Vector2i(2,9),Vector2i(6,6)]
const FIRST_SPAN := Vector2i(3,9)
const FAR_SPANS := [Vector2i(7,2),Vector2i(7,6)]
const PAULI := Vector2i(10,6)
const GRID_WIDTH := BOARD_SIZE.x*CELL
const GRID_DEPTH := BOARD_SIZE.y*CELL
const REAR := -GRID_DEPTH*0.5
const FRONT := GRID_DEPTH*0.5
const EXITS := [PAULI,Vector2i(11,2),Vector2i(10,1),Vector2i(11,10),Vector2i(11,5)]
# Low walls leave several crossings between the ranks.
const BARRIERS := [
	[Rect2i(1,5,2,1),Rect2i(5,3,1,2),Rect2i(9,9,2,1)],
	[Rect2i(2,5,3,1),Rect2i(4,7,1,4),Rect2i(7,2,1,5),Rect2i(9,8,2,1)],
	[Rect2i(3,7,1,4),Rect2i(5,4,3,1),Rect2i(9,6,1,4),Rect2i(2,1,2,1)],
	[Rect2i(3,2,1,4),Rect2i(3,8,1,3),Rect2i(6,4,1,5),Rect2i(9,1,1,5),Rect2i(9,8,1,3)],
	[Rect2i(2,3,3,1),Rect2i(3,7,1,4),Rect2i(5,5,3,1),Rect2i(8,2,1,2),Rect2i(8,7,1,4)]
]
var blocked: Array
var exit_cell: Vector2i
var move_tween: Tween

static func square(cell: Vector2i) -> Vector3:
	return Vector3((cell.x+0.5)*CELL-GRID_WIDTH/2,0,(cell.y+0.5)*CELL-GRID_DEPTH/2)

func walkable(cell: Vector2i) -> bool:
	return Rect2i(Vector2i.ZERO,BOARD_SIZE).has_point(cell) and not blocked.has(cell)

func move_hero(cell: Vector2i) -> void:
	if move_tween:
		move_tween.kill()
	var offset := square(cell)-hero.position
	if offset.length_squared()>0.01:
		hero_body.rotation.y = atan2(offset.x,offset.z)
	if hero_stride:
		hero_stride.kill()
	hero_body.position.y = 0.0
	hero_stride = hero_body.create_tween().set_trans(Tween.TRANS_SINE)
	hero_stride.tween_property(hero_body,"position:y",0.16,0.09)
	hero_stride.tween_property(hero_body,"position:y",0.0,0.10)
	move_tween = create_tween()
	move_tween.tween_property(hero,"position",square(cell),0.19).set_trans(Tween.TRANS_SINE)

const SHORTCUTS := [Vector2i.ZERO,Vector2i(7,5),Vector2i(5,4),Vector2i(6,7),Vector2i(5,5)]
var shortcut: Node3D
var bridges := {}
var puppy_tail: Node3D
var puppy_calm := false
var yard_time := 0.0
var guide_spot := Vector3(-1.7,0,0.7)
var collar_tags: Array[Node3D] = []
var landing: Node3D
var pennants: Array[Node3D] = []
var coordinate_labels: Array[Label3D] = []
var hero: Node3D
var hero_body: Node3D
var hero_stride: Tween
var creature: Node3D
var treasure: Node3D
const QuantumFork := preload("res://scripts/quantum_fork.gd")
var quantum_fork: QuantumFork
var rune_station := Vector3.ZERO
func coordinate(caption: String, at: Vector3) -> void:
	var engraving := Label3D.new()
	engraving.text = caption
	engraving.font_size = 30
	engraving.pixel_size = 0.011
	engraving.outline_size = 0
	engraving.modulate = CREAM
	add_child(engraving)
	engraving.rotation.x = -PI/2
	engraving.position = at
	engraving.hide()
	coordinate_labels.append(engraving)

func set_coordinates_visible(enabled: bool) -> void:
	for engraving in coordinate_labels:
		engraving.visible = enabled

func build(stage: int) -> void:
	for rect: Rect2i in BARRIERS[stage]:
		for x in range(rect.position.x,rect.end.x):
			for y in range(rect.position.y,rect.end.y):
				blocked.append(Vector2i(x,y))
	exit_cell = EXITS[stage]
	var width := GRID_WIDTH+1.6
	var depth := GRID_DEPTH+2.3
	var mesa := Mesa.new()
	add_child(mesa)
	mesa.build(width,depth,GRID_WIDTH,GRID_DEPTH,stage)
	box(self,Vector3(0,-0.23,-0.65),Vector3(width-0.18,0.31,depth-0.16),Color("#a37354"))
	var field := PlaneMesh.new()
	field.size = Vector2(GRID_WIDTH,GRID_DEPTH)
	var stone := ShaderMaterial.new()
	stone.shader = preload("res://shaders/inlaid_stone.gdshader")
	stone.set_shader_parameter("grid_size",Vector2(BOARD_SIZE))
	stone.set_shader_parameter("cell_size",CELL)
	stone.set_shader_parameter("light_stone",TILE[stage].lightened(0.16))
	stone.set_shader_parameter("dark_stone",TILE[stage].darkened(0.45))
	var slab := MeshInstance3D.new()
	slab.mesh = field
	slab.material_override = stone
	add_child(slab)
	for file in BOARD_SIZE.x:
		coordinate(String.chr(65+file),square(Vector2i(file,BOARD_SIZE.y-1))+Vector3(0,0.025,CELL/2+0.19))
	for rank_index in BOARD_SIZE.y:
		coordinate(str(BOARD_SIZE.y-rank_index),square(Vector2i(0,rank_index))+Vector3(-CELL/2-0.22,0.025,0))
	for cell: Vector2i in blocked:
		build_obstacle(cell,stage)
	landing = group(square(exit_cell))
	landing.scale = Vector3.ONE*(CELL*0.90)
	for side in [-1,1]:
		box(landing,Vector3(side*0.47,0.04,0),Vector3(0.035,0.06,0.96),BRASS)
		box(landing,Vector3(0,0.04,side*0.47),Vector3(0.96,0.06,0.035),BRASS)
	# The back edge holds the room's landmark, leaving the path visible.
	match stage:
		0:
			build_crossings()
			for side in [-9.1,-4.25]:
				drum(self,Vector3(side,1.07,REAR-1.345),0.07,0.05,2.14,WOOD)
			box(self,Vector3(-6.675,2.05,REAR-1.345),Vector3(4.85,0.045,0.045),BRASS)
			for i in range(3):
				var flag := group(Vector3(-8.8+i*1.95,2.05,REAR-1.345))
				var cloth := box(flag,Vector3.DOWN*0.43,Vector3(0.42,0.86,0.12),INK)
				cloth.scale.z = 0.18
				pennants.append(flag)
			for x in [-8.4,-6.7,-5.0]:
				box(self, Vector3(x,0.55,REAR-0.875), Vector3(0.16,1.1,0.16), WOOD)
				for i in range(3):
					var ring := drum(self,Vector3(x,1.2,REAR-0.875+i*0.06),0.51-i*0.15,0.51-i*0.15,0.08,[CREAM,CLAY,BRASS][i])
					ring.rotation.x = PI/2
			for i in range(4):
				box(self,Vector3(5.6+i,0.32,REAR-1.225),Vector3(0.15,0.64,0.15),WOOD)
			box(self,Vector3(7.1,0.48,REAR-1.225),Vector3(3.3,0.14,0.1),CREAM)
		1:
			var wheel := group(Vector3(-6.7,1.1,REAR-0.745))
			create_tween().set_loops().tween_property(wheel,"rotation:z",TAU,12.0).from(0.0)
			for i in range(16):
				box(wheel,Vector3(sin(i*PI/8),cos(i*PI/8),0.30),Vector3(0.42,0.12,0.09),BRASS).rotation.z = -i*PI/8
			for i in range(8):
				box(wheel,Vector3.ZERO,Vector3(0.13,2.1,0.25),WOOD).rotation.z = i*PI/8
				box(wheel,Vector3(sin(i*PI/4),cos(i*PI/4),0),Vector3(0.52,0.2,0.6),BLUE).rotation.z = -i*PI/4
			box(self,Vector3(0,0.04,REAR-0.745),Vector3(19.8,0.1,1.15),BLUE)
			drum(wheel,Vector3.ZERO,0.22,0.22,0.8,BRASS).rotation.x = PI/2
		2:
			for i in range(3):
				var kiln := group(Vector3(-7.5+i*6.1,0,REAR-0.745))
				drum(kiln,Vector3.UP*0.55,0.73,0.64,1.1,CLAY)
				drum(kiln,Vector3.UP*1.32,0.65,0.23,0.45,CREAM)
				drum(kiln,Vector3.UP*1.7,0.22,0.24,0.35,INK)
				orb(kiln,Vector3(0,0.42,0.62),Vector3(0.56,0.63,0.14),INK)
				for j in range(3):
					box(kiln,Vector3(-0.14+j*0.14,0.39,0.70),Vector3(0.07,0.30,0.04),Color("#ed9963"))
				for height in [0.18,0.91]:
					drum(kiln,Vector3.UP*height,0.74-height*0.08,0.74-height*0.08,0.065,BRASS)
		3:
			for i in range(5):
				var x := -8.6+i*4.1
				drum(self,Vector3(x,0.65,REAR-0.925),0.17,0.1,1.3,WOOD)
				orb(self,Vector3(x,1.4,REAR-0.925),Vector3(1.45,1.35,1.2),LEAF)
				for side in [-1,1]:
					drum(self,Vector3(x+side*0.34,1.03,REAR-0.95),0.09,0.055,0.92,WOOD,7).rotation.z = -side*0.77
					orb(self,Vector3(x+side*0.65,1.43,REAR-0.95),Vector3(0.92,0.86,0.92),LEAF.lightened(0.04))
				for j in range(3):
					orb(self,Vector3(x-0.42+j*0.4,1.3+0.22*(j%2),REAR-0.475),Vector3.ONE*0.27,BRASS)
		4:
			for i in range(7):
				var t := i*PI/6
				box(self,Vector3(-1+2.3*cos(t),0.32+2.3*sin(t),REAR-0.925),Vector3(1.12,0.54,0.8),[BRASS,CREAM][i%2]).rotation.z=t+PI/2
	if stage!=0:
		rune_station = square(SHORTCUTS[stage])+Vector3(-2.6,0,0.65)
		var socket := group(rune_station)
		drum(socket,Vector3.UP*0.15,0.46,0.39,0.30,INK,8)
		drum(socket,Vector3.UP*0.32,0.38,0.31,0.11,BRASS,8)
		drum(socket,Vector3.UP*0.52,0.125,0,0.27,CYAN,5)
	quantum_fork = QuantumFork.new()
	add_child(quantum_fork)
	build_hero()
	creature = group(Vector3(2,0,-0.55))
	if stage == 4:
		creature.scale = Vector3.ONE*1.52
		for side in [-1,1]:
			var horn := drum(creature,Vector3(side*0.43,1.35,-0.13),0.20,0.024,0.82,BRASS,6)
			horn.rotation.z = -side*0.39
			orb(creature,Vector3(side*0.46,0.57,0.10),Vector3(0.41,0.48,0.54),Color("#423450"))
		orb(creature,Vector3(0,0.58,0.59),Vector3(0.36,0.40,0.14),VIOLET)
	if stage==0:
		creature.scale=Vector3.ONE*1.30
		orb(creature,Vector3.UP*0.40,Vector3(0.72,0.66,0.83),Color("#ba8061"))
		orb(creature,Vector3(0.02,0.45,0.34),Vector3(0.46,0.58,0.29),CREAM)
		var scarf := drum(creature,Vector3(0,0.63,0.14),0.29,0.32,0.11,Color("#35736e"),9)
		scarf.rotation.x=-0.20
		box(creature,Vector3(-0.30,0.57,0.10),Vector3(0.13,0.27,0.07),Color("#35736e")).rotation.z=-0.39
		orb(creature,Vector3(0,0.93,0.13),Vector3(0.86,0.83,0.72),Color("#ddb289"))
		orb(creature,Vector3(0,0.81,0.45),Vector3(0.52,0.36,0.37),CREAM)
		orb(creature,Vector3(0,0.91,0.63),Vector3(0.17,0.11,0.09),INK)
		for side in [-1,1]:
			var ear := orb(creature,Vector3(side*0.40,0.98,0.12),Vector3(0.27,0.62,0.33),WOOD)
			ear.rotation.z=side*0.25
			orb(creature,Vector3(side*0.19,1.03,0.43),Vector3.ONE*0.16,INK)
			orb(creature,Vector3(side*0.19-0.025,1.065,0.50),Vector3.ONE*0.046,CREAM)
	elif stage==2:
		orb(creature,Vector3.UP*0.48,Vector3(0.86,0.65,0.7),CLAY)
		orb(creature,Vector3(0,0.84,0.2),Vector3(0.53,0.55,0.64),INK)
		box(creature,Vector3(0,0.78,0.51),Vector3(0.30,0.20,0.33),INK)
		for side in [-1,1]:
			drum(creature,Vector3(side*0.24,1.21,0.16),0.16,0,0.42,CLAY,3)
	else:
		drum(creature,Vector3.UP*0.48,0.65,0.44,0.90,BLUE,7)
		drum(creature,Vector3.UP*0.95,0.44,0.27,0.17,INK,7)
		for i in range(3):
			drum(creature,Vector3(-0.35+i*0.35,1.04,0),0.15,0.025,0.48,BRASS,5)
	if stage!=0:
		for side in [-1,1]:
			box(creature,Vector3(side*0.14,0.87,0.46),Vector3(0.13,0.036,0.07),BRASS)
	if stage==0:
		guide_spot = square(PAULI)+Vector3(0.25,0,-0.14)
		creature.position = guide_spot
		puppy_tail = box(creature,Vector3(0.46,0.51,-0.1),Vector3(0.4,0.12,0.13),CREAM)
		collar_tags.append(orb(creature,Vector3(0,0.62,0.49),Vector3.ONE*0.26,LEAF))
		var diamond := drum(creature,Vector3(0,0.62,0.49),0.17,0.17,0.12,CLAY,4)
		diamond.rotation.x = PI/2
		collar_tags.append(diamond)
		for side in [-1,1]:
			orb(creature,Vector3(side*0.28,0.12,0.18),Vector3(0.24,0.24,0.32),CREAM)
	else:
		var bob := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
		bob.tween_property(creature,"position:y",0.07,0.8)
		bob.tween_property(creature,"position:y",0.0,0.8)
	spawn_roamers(stage)
	treasure = group(Vector3.ZERO)
	treasure.visible = false
	for i in range(3):
		var x := -3.6+i*3.6
		drum(treasure,Vector3(x,0.3,0.9),0.66,0.52,0.6,WOOD)
		match i:
			0: # A split-face coin
				drum(treasure,Vector3(x,1,0.9),0.45,0.45,0.15,BRASS).rotation.x=PI/2
				orb(treasure,Vector3(x,1,1),Vector3(0.36,0.36,0.1),CLAY)
			1: # Glazed phase lens in a brass bezel
				drum(treasure,Vector3(x,1,0.9),0.54,0.54,0.12,BRASS).rotation.x=PI/2
				orb(treasure,Vector3(x,1,0.99),Vector3(0.88,0.88,0.18),BLUE)
			2: # Pair of enamel dice
				for j in range(2):
					box(treasure,Vector3(x-0.22+j*0.45,0.85+j*0.15,0.9),Vector3.ONE*0.48,CREAM)
					for k in range(j+1):
						orb(treasure,Vector3(x-0.23+j*0.4+k*0.13,0.83+j*0.15+k*0.12,1.15),Vector3.ONE*0.09,INK)

func build_crossings() -> void:
	for file: int in [FIRST_SPAN.x,FAR_SPANS[0].x]:
		var x := square(Vector2i(file,0)).x
		var water := box(self,Vector3(x,0.018,0),Vector3(CELL,0.032,GRID_DEPTH),BLUE)
		var current := ShaderMaterial.new()
		current.shader = preload("res://shaders/channel_water.gdshader")
		water.material_override = current
		for side in [-1,1]:
			for rank_index in BOARD_SIZE.y:
				var bank := Vector3(x+side*CELL*0.48,0.064,square(Vector2i(file,rank_index)).z)
				var coping := INK.lightened(0.07+0.027*((rank_index*3+file)%4))
				box(self,bank,Vector3(0.19,0.145,CELL-0.045),coping)
		for rank_index in BOARD_SIZE.y:
			var cell := Vector2i(file,rank_index)
			blocked.append(cell)
	for cell: Vector2i in [FIRST_SPAN,FAR_SPANS[0],FAR_SPANS[1]]:
		var hinge := group(square(cell)+Vector3(-CELL/2,0.16,0))
		bridges[cell] = hinge
		var deck := box(hinge,Vector3(CELL/2,0,0),Vector3(CELL,0.15,CELL*0.72),WOOD)
		for j in range(7):
			box(deck,Vector3((j-3)*CELL/7,0.09,0),Vector3(CELL/7-0.027,0.07,CELL*0.78),CREAM.darkened(0.28))
		for side in [-1,1]:
			box(hinge,Vector3(CELL/2,0.15,side*CELL*0.38),Vector3(CELL,0.10,0.075),BRASS)
		box(hinge,Vector3(CELL/2,0.18,0),Vector3(CELL,0.05,0.07),CYAN if cell!=FAR_SPANS[1] else VIOLET)
		hinge.rotation.z = deg_to_rad(78)
	for cell: Vector2i in WINCHES:
		var winch := group(square(cell)+Vector3(-0.40,0,-0.47))
		aura(winch,Vector3.UP*0.08,2.15,CYAN)
		drum(winch,Vector3.UP*0.85,0.12,0,0.37,CYAN,5)
		drum(winch,Vector3.UP*0.23,0.38,0.29,0.45,WOOD,8)
		var spindle := drum(winch,Vector3.UP*0.60,0.24,0.24,0.54,BRASS)
		spindle.rotation.z = PI/2
		box(winch,Vector3(0.34,0.70,0),Vector3(0.08,0.35,0.08),INK)
		box(winch,Vector3(0.43,0.86,0),Vector3(0.26,0.08,0.10),BRASS)
	# The fork at the relay physically connects it to the two possible decks.
	var relay := square(WINCHES[1])
	var far := square(FAR_SPANS[0])
	box(self,Vector3(relay.x+0.63,0.06,(relay.z+far.z)/2),Vector3(0.065,0.045,relay.z-far.z),BRASS)
	for cell: Vector2i in FAR_SPANS:
		var bank := square(cell)-Vector3.RIGHT*(CELL/2)
		var badge := drum(self,bank+Vector3(-0.28,0.20,-0.66),0.24,0.24,0.12,LEAF if cell==FAR_SPANS[0] else CLAY,12 if cell==FAR_SPANS[0] else 4)
		badge.rotation.x = PI/4

func open_shortcut(stage: int) -> void:
	discharge(rune_station,square(SHORTCUTS[stage]),CYAN)
	blocked.erase(SHORTCUTS[stage])
	create_tween().set_trans(Tween.TRANS_SINE).tween_property(shortcut,"position:y",-2.35,0.55)

func lower_bridge(cell: Vector2i) -> void:
	discharge(square(WINCHES[0] if cell==FIRST_SPAN else WINCHES[1]),square(cell),VIOLET if cell==FAR_SPANS[1] else CYAN)
	blocked.erase(cell)
	create_tween().set_trans(Tween.TRANS_SINE).tween_property(bridges[cell],"rotation:z",0.0,0.62)

func show_register(active: bool, origin: Vector3, yin: Vector2, yang: Vector2) -> void:
	quantum_fork.update_state(active,origin,yin,yang)

func _process(delta: float) -> void:
	if not puppy_tail:
		return
	yard_time += delta
	var stride := sin(yard_time*3.3)
	var destination := guide_spot
	if not puppy_calm:
		destination.x += 0.48*stride
	creature.position = creature.position.lerp(destination,1.0-exp(-delta*5.0))
	creature.position.y = absf(stride)*(0.012 if puppy_calm else 0.045)
	creature.rotation.y = lerp_angle(creature.rotation.y,0.7 if puppy_calm else 0.65*cos(yard_time*3.3),minf(1,delta*6))
	puppy_tail.rotation.y = sin(yard_time*6.2)*0.52
	for i in pennants.size():
		pennants[i].rotation.x = 0.13+0.20*sin(yard_time*2.6+i*0.45)

const Roamer := preload("res://scripts/roamer.gd")
const DIRECTIONS := [Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]
var roamers: Array[Roamer] = []
var training_wildlife := false
var ambush_turns := 0

func rock(parent: Node3D, at: Vector3, size: Vector3, tint: Color, seed_value: int) -> MeshInstance3D:
	var outcrop := drum(parent,at,0.56,0.39,1.0,tint,5+posmod(seed_value,3))
	outcrop.scale=size
	outcrop.rotation=Vector3(0.08*sin(seed_value),seed_value*0.7,0.12*cos(seed_value))
	return outcrop

func fern(parent: Node3D, at: Vector3, size: float) -> void:
	for i in range(5):
		var blade := drum(parent,at+Vector3(sin(i*1.26)*0.16,0.18,cos(i*1.26)*0.16)*size,0.115*size,0,0.72*size,LEAF.lightened(0.05*i),3)
		blade.rotation=Vector3(0.7*cos(i*1.26),i*1.26,0.7*sin(i*1.26))

func ruined_gate(parent: Node3D, scale_factor: float, tint: Color) -> void:
	var arch := Node3D.new()
	parent.add_child(arch)
	arch.scale=Vector3.ONE*scale_factor
	for side in [-1,1]:
		box(arch,Vector3(side*0.53,0.14,0),Vector3(0.56,0.28,0.76),INK)
		for j in range(2):
			box(arch,Vector3(side*0.53,0.49+j*0.44,0),Vector3(0.41,0.42,0.62),tint.lightened(0.035*j))
	for j in range(5):
		var t := j*PI/6+PI/6
		var block := box(arch,Vector3(0.57*cos(t),1.02+0.54*sin(t),0),Vector3(0.37,0.43,0.67),tint.lightened(0.08 if j==2 else 0.0))
		block.rotation.z=t-PI/2
	rock(arch,Vector3(-0.50,1.25,0.08),Vector3(0.58,0.11,0.71),LEAF,3)

func build_obstacle(cell: Vector2i, stage: int) -> void:
	var prop := group(square(cell))
	var seed_value := cell.x*31+cell.y*13
	var stone: Color = TILE[stage].darkened(0.37)
	if cell==SHORTCUTS[stage] and stage!=0:
		shortcut=prop
		ruined_gate(prop,1.10,stone)
		box(prop,Vector3(0,0.65,0.1),Vector3(0.82,1.28,0.25),INK)
		box(prop,Vector3(0,0.70,0.25),Vector3(0.08,0.85,0.04),CYAN)
		aura(prop,Vector3.UP*0.08,2.15,CYAN)
		return
	if (seed_value+stage)%4==0:
		ruined_gate(prop,0.96+0.12*(seed_value%3),stone)
		fern(prop,Vector3(0.55,0,0.43),0.65)
	elif stage==2 or (stage==4 and seed_value%3==0):
		rock(prop,Vector3.UP*0.09,Vector3(1.64,0.18,1.58),EMBER,seed_value)
		for j in range(4):
			var t:=j*PI/2+seed_value
			var h:=0.55+0.38*(1+sin(seed_value+j))
			rock(prop,Vector3(0.46*sin(t),h*0.5,0.43*cos(t)),Vector3(0.78,h,0.79),INK.lightened(j*0.035),j+seed_value)
		aura(prop,Vector3.UP*0.12,2.4,EMBER)
	else:
		for j in range(3):
			var t := j*TAU/3+seed_value
			var h := 0.44+0.40*(1+cos(t))
			var at := Vector3(0.42*sin(t),h*0.5,0.35*cos(t))
			var boulder := rock(prop,at,Vector3(0.94,h,1.02),stone.lightened(j*0.08),seed_value+j)
			rock(boulder,Vector3(0,0.50,0),Vector3(0.82,0.12,0.84),LEAF.darkened(j*0.08),seed_value+j)
		fern(prop,Vector3(-0.46,0,0.38),0.76)

func spawn_roamers(stage: int) -> void:
	training_wildlife = stage==0
	var homes := [Vector2i(2,2),Vector2i(5,8),Vector2i(9,3)]
	if training_wildlife:
		homes=[Vector2i(FIRST_SPAN.x,2),Vector2i(FAR_SPANS[0].x,9)]
	for i in homes.size():
		var start: Vector2i = homes[i]
		if not training_wildlife:
			while not walkable(start):
				start.y=(start.y+1)%BOARD_SIZE.y
		var mob := Roamer.new()
		add_child(mob)
		mob.build((i+stage)%3,start)
		mob.position = square(start)
		mob.scale=Vector3.ONE*(0.94 if training_wildlife else 1.25)
		roamers.append(mob)

func monster_at(cell: Vector2i) -> Roamer:
	for mob in roamers:
		if cell==mob.cell:
			return mob
	return null

func adjacent_monster(cell: Vector2i) -> Roamer:
	if not training_wildlife:
		for direction: Vector2i in DIRECTIONS:
			var mob := monster_at(cell+direction)
			if mob:
				return mob
	return null

func advance_roamers(player: Vector2i, guard: Vector2i, blocking: bool) -> int:
	ambush_turns+=1
	var hits := 0
	for mob in roamers:
		var offset := (player-mob.cell).abs()
		var distance := offset.x+offset.y
		if not training_wildlife and distance==1:
			if ambush_turns%2==0 and not blocking:
				hits+=1
			continue
		var best := mob.cell
		var best_score := -100
		for i in DIRECTIONS.size():
			var direction: Vector2i = DIRECTIONS[(i+mob.heading)%4]
			var candidate := mob.cell+direction
			if candidate==player or candidate==guard or candidate==exit_cell or monster_at(candidate):
				continue
			if training_wildlife:
				if candidate.x!=mob.home.x or absi(candidate.y-mob.home.y)>1:
					continue
			elif not walkable(candidate):
				continue
			var delta_cell := (candidate-player).abs()
			var score := -i
			if not training_wildlife and distance<=3:
				score = -(delta_cell.x+delta_cell.y)*5-i
			if score>best_score:
				best_score=score
				best=candidate
		if best!=mob.cell:
			mob.heading=(DIRECTIONS.find(best-mob.cell)+1)%4
			mob.move_to(best,square(best))
	return hits

func dismiss_monster(mob: Roamer) -> void:
	roamers.erase(mob)
	var fade := mob.create_tween()
	fade.tween_property(mob,"scale",Vector3.ONE*0.02,0.19)
	fade.tween_callback(mob.queue_free)

func discharge(origin: Vector3, destination: Vector3, tint: Color) -> void:
	var spark := group(origin+Vector3.UP*0.65)
	orb(spark,Vector3.ZERO,Vector3.ONE*0.34,tint)
	aura(spark,Vector3.ZERO,1.8,tint)
	var start := spark.position
	var finish := destination+Vector3.UP*0.38
	var height := clampf(start.distance_to(finish)*0.28,0.6,2.8)
	var flight := spark.create_tween()
	flight.tween_method(func(t: float) -> void:
		spark.position = start.lerp(finish,t)+Vector3.UP*(sin(t*PI)*height)
	,0.0,1.0,0.46)
	flight.tween_property(spark,"scale",Vector3.ONE*1.8,0.15)
	flight.tween_callback(spark.queue_free)
const CAVE_ENTRY := Vector2i(8,2)

func build_field() -> void:
	exit_cell=CAVE_ENTRY
	var green := Color("#68845b")
	box(self,Vector3.DOWN*0.50,Vector3(GRID_WIDTH+1.0,0.95,GRID_DEPTH+1.0),Color("#605246"))
	var turf := PlaneMesh.new()
	turf.size=Vector2(GRID_WIDTH+1,GRID_DEPTH+1)
	var grass := ShaderMaterial.new()
	grass.shader=preload("res://shaders/meadow.gdshader")
	var pattern := FastNoiseLite.new()
	pattern.frequency=0.045
	var map := NoiseTexture2D.new()
	map.width=256
	map.height=256
	map.seamless=true
	map.noise=pattern
	grass.set_shader_parameter("meadow_noise",map)
	turf.material=grass
	var ground := MeshInstance3D.new()
	ground.mesh=turf
	add_child(ground)
	var mouth := group(square(CAVE_ENTRY)-Vector3(0,0,1.45))
	# The dark recess sits behind the arch and opens toward the approach.
	orb(mouth,Vector3(0,1.1,-0.55),Vector3(3.65,3.35,1.4),Color("#141f23"))
	for i in range(9):
		var theta := i*PI/8
		var center := Vector3(2.17*cos(theta),0.18+2.7*sin(theta),-0.20)
		rock(mouth,center,Vector3(1.56,1.30,2.35),Color("#677268").darkened(0.045*(i%3)),i)
		if i%2==0:
			rock(mouth,center+Vector3.UP*0.58,Vector3(1.21,0.26,1.72),green,i)
	for side in [-1,1]:
		for j in range(3):
			var at := Vector3(side*(2.65+j*0.84),0.48,-1.05-j*0.37)
			rock(mouth,at,Vector3(2.05,1.95-j*0.37,2.46),INK.lightened(0.11*j),j)
		drum(mouth,Vector3(side*1.38,0.57,0.90),0.10,0.07,1.10,WOOD)
		orb(mouth,Vector3(side*1.38,1.20,0.90),Vector3(0.24,0.40,0.24),EMBER)
	for x in range(4,12):
		for y in range(2):
			blocked.append(Vector2i(x,y))
	for i in range(10):
		var cell: Vector2i = [Vector2i(0,2),Vector2i(1,4),Vector2i(0,5),Vector2i(1,6),Vector2i(0,9),Vector2i(11,3),Vector2i(10,5),Vector2i(11,6),Vector2i(10,8),Vector2i(11,11)][i]
		blocked.append(cell)
		var tree := group(square(cell))
		tree.scale=Vector3.ONE*(0.82+0.14*(i%4))
		tree.rotation.y=i*0.61
		drum(tree,Vector3.UP*0.64,0.17,0.11,1.28,WOOD,7)
		for tier in range(3):
			drum(tree,Vector3.UP*(1.14+tier*0.59),1.00-tier*0.22,0.04,1.32,green.darkened(0.26-tier*0.10),7)
	var rng := RandomNumberGenerator.new()
	rng.seed=8921
	for i in range(105):
		var patch := Vector3(rng.randf_range(-10.9,10.9),0,rng.randf_range(-10.9,10.9))
		var tuft := drum(self,patch+Vector3.UP*0.10,0.10,0,0.34,green.lightened(0.14),3)
		tuft.rotation.z=rng.randf_range(-0.5,0.5)
		if i%4==0:
			orb(self,patch+Vector3.UP*0.26,Vector3(0.16,0.10,0.16),CREAM if i%8==0 else BRASS)
	for i in range(19):
		var t := i/18.0
		var at := square(START).lerp(square(CAVE_ENTRY),t)
		at.x+=0.48*sin(t*TAU)
		rock(self,at+Vector3.UP*0.02,Vector3(0.80,0.08,0.54),Color("#a69b81"),i)
	build_hero()

func build_hero() -> void:
	hero = group(square(START))
	hero_body = Node3D.new()
	hero.add_child(hero_body)
	var cloak := Color("#28685f")
	var leather := Color("#443338")
	var armor := Color("#b3aaa1")
	drum(hero,Vector3.UP*0.071,0.45,0.43,0.14,INK,10)
	drum(hero,Vector3.UP*0.146,0.43,0.39,0.05,BRASS,10)
	for side in [-1,1]:
		orb(hero_body,Vector3(side*0.15,0.26,0.06),Vector3(0.26,0.23,0.39),leather)
		box(hero_body,Vector3(side*0.14,0.40,-0.015),Vector3(0.18,0.35,0.18),INK)
	drum(hero_body,Vector3.UP*0.62,0.31,0.22,0.55,cloak,7)
	var cape := drum(hero_body,Vector3(0,0.63,-0.14),0.39,0.22,0.77,cloak.darkened(0.28),7)
	cape.scale.z = 0.59
	cape.rotation.x = -0.19
	box(hero_body,Vector3(0,0.63,0.235),Vector3(0.52,0.10,0.11),leather)
	box(hero_body,Vector3(0,0.63,0.298),Vector3(0.14,0.12,0.06),BRASS)
	for side in [-1,1]:
		orb(hero_body,Vector3(side*0.26,0.84,0.00),Vector3(0.27,0.22,0.33),armor)
		orb(hero_body,Vector3(side*0.30,0.66,0.085),Vector3(0.18,0.31,0.19),cloak)
	orb(hero_body,Vector3(0,1.04,0.08),Vector3(0.46,0.49,0.43),INK)
	var visor := box(hero_body,Vector3(0,1.041,0.288),Vector3(0.34,0.115,0.08),armor)
	visor.rotation.x = -0.13
	box(hero_body,Vector3(0,1.057,0.334),Vector3(0.24,0.031,0.019),INK)
	drum(hero_body,Vector3(0.45,0.73,0.15),0.045,0.035,1.05,WOOD,8)
	drum(hero_body,Vector3(0.45,1.25,0.15),0.13,0.145,0.14,BRASS,8)
	orb(hero_body,Vector3(0.45,1.36,0.15),Vector3(0.13,0.17,0.13),CYAN)

func build_hadamard(at: Vector3) -> Node3D:
	var wizard := group(at)
	var robe := Color("#4a3e75")
	drum(wizard,Vector3.UP*0.09,0.65,0.63,0.17,INK,10)
	drum(wizard,Vector3.UP*0.62,0.53,0.31,1.05,robe,9)
	var mantle := drum(wizard,Vector3.UP*1.05,0.50,0.27,0.40,robe.lightened(0.10),9)
	mantle.scale.z = 0.80
	orb(wizard,Vector3(0,1.43,0.06),Vector3(0.52,0.59,0.52),Color("#d7a17c"))
	var beard := drum(wizard,Vector3(0,1.22,0.25),0.07,0.30,0.57,CREAM,7)
	beard.rotation.x = 0.21
	for side in [-1,1]:
		orb(wizard,Vector3(side*0.12,1.49,0.30),Vector3.ONE*0.064,INK)
		orb(wizard,Vector3(side*0.34,0.94,0.13),Vector3(0.30,0.34,0.30),robe)
	drum(wizard,Vector3.UP*1.67,0.60,0.54,0.10,robe,12)
	var hat := drum(wizard,Vector3(-0.05,1.99,0),0.34,0.02,0.67,robe,9)
	hat.rotation.z = 0.19
	drum(wizard,Vector3.UP*1.74,0.38,0.34,0.09,BRASS,10)
	drum(wizard,Vector3(0.68,0.96,0.21),0.069,0.055,1.80,WOOD,9)
	drum(wizard,Vector3(0.68,1.84,0.21),0.173,0.11,0.18,BRASS,8)
	orb(wizard,Vector3(0.68,2.02,0.21),Vector3(0.26,0.36,0.26),CYAN)
	aura(wizard,Vector3(0.68,2.02,0.21),1.25,CYAN)
	return wizard
