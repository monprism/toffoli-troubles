extends Node3D

const Board = preload("res://scripts/diorama.gd")
const Register = preload("res://scripts/register.gd")
const TITLES := ["The Practice Yard", "Tidemark Mill", "Ember Kilns", "The Glaze Orchard", "The Gilt Conservatory"]
const PLACES := ["Training ground", "Dungeon I", "Dungeon II", "Dungeon III", "Boss vault"]
const INTENTS := ["Pauli is stranded across two channels.", "The mill sluice is split. Gather both currents into yin.", "A kiln puppy bars the flue. Recombine the fire into yang.", "Split Slime covers both lanes. Route the wisp into yang.", "The Crowned Split Slime guards the vault with two seals."]
const HINTS := ["Use Invert to turn yin into yang.", "The flow is already split. Apply H to recombine it.", "The flame is split. Apply P(π), then H.", "Apply H, then P(π), then H.", "Invert the first seal. For the split second seal, apply P(π) and then H."]
const RELICS := ["Noisy Lucky Coin", "Phase Lens", "Deutsch’s Dice"]
const RELIC_TEXT := ["A brass moon with a mischievous second face.", "Sea-green glass that catches both paths of a wisp.", "Two ivory cubes, each face engraved with a rune."]
const XR_BOARD_SCALE := 0.078
const SAVE := "user://trail.cfg"
const ANGLE_NAMES := ["π/4","π/2","π"]
const ANGLES := [PI/4, PI/2, PI]
var in_field := false
var story := "Title"
var briefing_page := 0
var can_continue := false
var prefer_gestures := false
var wizard: Node3D
var story_set: Node3D
var title_runes: Board.QuantumFork
var show_coordinates := false
var voices := AudioStreamPlayer.new()
const CALLS := [
	preload("res://audio/mossback_call.wav"),
	preload("res://audio/cinder_call.wav"),
	preload("res://audio/veil_call.wav"),
	preload("res://audio/guardian_call.wav")
]
var stage := 0
var phase := "Observe"
var beat := 0
var shield := 0
var coins := 0
var lens_ready := false
var scale_index := 1
var tilt_index := 1
var first_tracking := true
var seal := 0
const MAX_HEALTH := 5
const TONIC_HEAL := 2
const TONIC_CELLS := {1: Vector2i(10,3),3: Vector2i(5,7)}
var health := MAX_HEALTH
var guard_defeated := false
var tonic: Node3D
var hero_cell := Board.START
var guard_cell: Vector2i
var moves := {}
var ambience := AudioStreamPlayer.new()
var angle := 2
var selected := false
var paused := false
var hint := false
var idle_time := 0.0
var message := ""
var relic := -1
var program: Array[String] = []
var rng := RandomNumberGenerator.new()
var table := Node3D.new()
var board: Diorama
var ui := Node3D.new()
var camera: Camera3D
var xr := false
var pinch := [true,true]
var tracked := false
var hand_beams: Array[MeshInstance3D] = []
var focus := ""
var buttons := {}
var button_areas := {}

func _ready() -> void:
	add_child(table)
	table.add_child(ui)
	var sun := DirectionalLight3D.new()
	add_child(sun)
	sun.rotation_degrees = Vector3(-41,-38,0)
	sun.light_color = Color("#fff0d9")
	sun.light_energy = 1.18
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 48.0
	var env := Environment.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#c1d0e0")
	env.ambient_light_energy = 0.71
	env.glow_enabled = true
	env.glow_intensity = 1.15
	env.glow_hdr_threshold = 1.15
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#182227")
	var surroundings := WorldEnvironment.new()
	surroundings.environment = env
	add_child(surroundings)
	var interface := XRServer.find_interface("OpenXR")
	xr = interface != null and interface.is_initialized()
	if xr:
		var origin := XROrigin3D.new()
		add_child(origin)
		camera = XRCamera3D.new()
		origin.add_child(camera)
		get_viewport().use_xr = true
		table.scale = Vector3.ONE*XR_BOARD_SCALE
		for hand_index in range(2):
			var beam := MeshInstance3D.new()
			var mesh := BoxMesh.new()
			mesh.size = Vector3(0.0014,0.0014,1)
			beam.mesh = mesh
			var material := StandardMaterial3D.new()
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			material.albedo_color = Board.BRASS
			beam.material_override = material
			beam.visible = false
			add_child(beam)
			hand_beams.append(beam)
	else:
		get_viewport().msaa_3d = Viewport.MSAA_2X
		var desk := MeshInstance3D.new()
		var surface := PlaneMesh.new()
		surface.size = Vector2(130,130)
		var felt := StandardMaterial3D.new()
		felt.albedo_color = Color("#354043")
		felt.roughness = 1.0
		surface.material = felt
		desk.mesh = surface
		desk.position.y = -4.26
		add_child(desk)
		camera = Camera3D.new()
		add_child(camera)
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.position = Vector3(0,18,22)
		camera.look_at(Vector3(0,0.32,-0.35))
		get_viewport().size_changed.connect(fit_camera)
		fit_camera()
	add_child(ambience)
	add_child(voices)
	voices.volume_db = -12.0
	ambience.stream = preload("res://audio/night_air.wav")
	ambience.volume_db = -16
	if DisplayServer.get_name()!="headless":
		ambience.play()
	var checkpoint := ConfigFile.new()
	can_continue = checkpoint.load(SAVE)==OK
	if can_continue:
		show_coordinates = bool(checkpoint.get_value("settings","coordinates",false))
		prefer_gestures = bool(checkpoint.get_value("settings","gestures",false))
		coins = clampi(int(checkpoint.get_value("run","coins",0)),0,1)
		lens_ready = bool(checkpoint.get_value("run","lens",false))
		stage = clampi(int(checkpoint.get_value("run","stage",0)),0,4)
		in_field = stage==0 and bool(checkpoint.get_value("run","in_field",false))
		health = clampi(int(checkpoint.get_value("run","health",MAX_HEALTH)),1,MAX_HEALTH)
		relic = clampi(int(checkpoint.get_value("run","relic",-1)),-1,2)
	build_stage()
	if stage>0 and relic<0 and checkpoint.has_section("crossing"):
		var cell: Vector2i = checkpoint.get_value("crossing","cell",Board.START)
		if checkpoint.get_value("crossing","passage_open",false):
			board.open_shortcut(stage)
		if board.walkable(cell):
			hero_cell = cell
			board.hero.position = Board.square(cell)
		guard_defeated = bool(checkpoint.get_value("crossing","guard_defeated",false))
		shield = 0 if guard_defeated else int(checkpoint.get_value("crossing","shield",0))
		if tonic:
			tonic.visible = bool(checkpoint.get_value("crossing","tonic_available",true))
		phase = "Achieve" if hero_cell==board.exit_cell else "Navigate"
		refresh()
	if xr:
		call_deferred("recenter")

func fit_camera() -> void:
	var size := get_viewport().get_visible_rect().size
	camera.size = maxf(22.0,(Board.GRID_WIDTH+5.0)*size.y/maxf(size.x,1))

func recenter() -> void:
	if xr:
		var front := -camera.global_basis.z
		front.y = 0
		if front.length_squared() < 0.001:
			return
		front = front.normalized()
		table.rotation.y = atan2(-front.x,-front.z)
		table.position = camera.global_position + front*1.63 - Vector3.UP*0.59

func save_boundary(resume_crossing := false) -> void:
	var file := ConfigFile.new()
	can_continue = true
	file.set_value("settings","coordinates",show_coordinates)
	file.set_value("settings","gestures",prefer_gestures)
	file.set_value("run","coins",coins)
	file.set_value("run","lens",lens_ready)
	file.set_value("run","stage",stage)
	file.set_value("run","in_field",in_field)
	file.set_value("run","health",health)
	file.set_value("run","relic",relic)
	if resume_crossing:
		file.set_value("crossing","cell",hero_cell)
		file.set_value("crossing","passage_open",board.walkable(Board.SHORTCUTS[stage]))
		file.set_value("crossing","guard_defeated",guard_defeated)
		file.set_value("crossing","shield",shield)
		file.set_value("crossing","tonic_available",is_instance_valid(tonic) and tonic.visible)
	if file.save(SAVE) != OK:
		push_warning("Could not save the room checkpoint.")

func build_stage() -> void:
	if board:
		table.remove_child(board)
		board.queue_free()
	board = Board.new()
	table.add_child(board)
	if in_field:
		board.build_field()
	else:
		board.build(stage)
	tonic = null
	if TONIC_CELLS.has(stage):
		tonic = board.group(Board.square(TONIC_CELLS[stage]))
		board.drum(tonic,Vector3.UP*0.12,0.38,0.34,0.24,Board.INK,8)
		board.orb(tonic,Vector3.UP*0.44,Vector3(0.48,0.64,0.48),Color("#f0ae4e"))
		board.drum(tonic,Vector3.UP*0.77,0.14,0.14,0.19,Board.BRASS,8)
	hero_cell = Board.START
	guard_cell = board.exit_cell+Vector2i.LEFT
	beat = 0
	shield = 0
	guard_defeated = false
	seal = 0
	begin_observe()
	if in_field:
		phase="Navigate"
	if relic >= 0:
		phase = "Collected"
	refresh()

func begin_observe() -> void:
	phase = "Observe"
	program.clear()
	angle = 2
	selected = false
	message = ""
	hint = false
	idle_time = 0

func starts_split() -> bool:
	return stage in [1,2] or (stage==4 and seal==1)

func state() -> RuneRegister:
	var reg := Register.new()
	if starts_split():
		reg.apply("H")
	for rune in program:
		if rune.begins_with("P"):
			reg.apply("P",ANGLES[int(rune.right(1))])
		else:
			reg.apply(rune)
	return reg

func label(parent: Node3D, caption: String, at: Vector3, font_size: int, tint: Color) -> Label3D:
	var node := Label3D.new()
	node.text = caption
	node.font_size = font_size
	node.pixel_size = 0.012
	node.modulate = tint
	# A strong dark edge keeps pale lettering legible against the miniature and room.
	node.outline_size = 7
	node.outline_modulate = Color("#241e19")
	node.double_sided = false
	parent.add_child(node)
	node.position = at
	return node

# Build the visible token separately from its forgiving selection volume.
func action(id: String, caption: String, at: Vector3, width: float, finish: Color) -> void:
	var area := Area3D.new()
	ui.add_child(area)
	area.position = at
	area.rotation.x = -0.56
	var hit := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(width,0.76,0.32)
	hit.shape = shape
	area.add_child(hit)
	var ink := Board.CREAM
	var glyph := ""
	match id:
		"H","X","P","angle","read":
			var glaze: Color = {"H":Color("#385e61"),"X":Color("#804836"),"P":Color("#515778"),"angle":Board.INK,"read":Color("#466049")}[id]
			glyph = {"H":"H","X":"X","P":"P("+str(ANGLE_NAMES[angle])+")","angle":"θ","read":"Z basis"}[id]
			var foot := board.drum(area,Vector3.ZERO,0.49,0.50,0.16,Board.WOOD,8)
			foot.rotation.x = PI/2
			foot.scale.x = width*0.95
			var tile := board.drum(area,Vector3(0,0,0.09),0.48,0.43,0.12,glaze,8)
			tile.rotation.x = PI/2
			tile.scale.x = width*0.95
			label(area,glyph,Vector3(0,0.16,0.165),22,Board.BRASS)
		"hint":
			# A stitched field notebook rests on the left corner.
			board.box(area,Vector3.ZERO,Vector3(width,0.65,0.14),Board.WOOD)
			board.box(area,Vector3(0,0,0.09),Vector3(width-0.08,0.58,0.07),Board.CREAM)
			board.box(area,Vector3(-width*0.38,0,0.14),Vector3(0.10,0.60,0.045),Board.CLAY)
			ink = Board.INK
		"pause":
			var knob := board.drum(area,Vector3.ZERO,0.51,0.46,0.18,Board.BRASS,16)
			knob.rotation.x = PI/2
			ink = Board.INK
		_:
			board.box(area,Vector3.ZERO,Vector3(width,0.57,0.17),Board.WOOD)
			board.box(area,Vector3(0,0,0.085),Vector3(width-0.09,0.47,0.05),finish)
			for side in [-1,1]:
				board.orb(area,Vector3(side*(width/2-0.11),0,0.123),Vector3.ONE*0.067,Board.BRASS)
	var title := label(area,caption,Vector3(0,-0.13 if glyph!="" else 0.0,0.18),22,ink)
	title.font_size = 28
	title.set_meta("ink",ink)
	area.set_meta("command",id)
	buttons[id] = title
	button_areas[id] = area

func station_sign(id: String, caption: String, at: Vector3) -> void:
	board.box(ui,Vector3(at.x,at.y*0.5,at.z-0.1),Vector3(0.12,at.y,0.14),Board.WOOD)
	action(id,caption,at,2.12,Color("#495b4a"))

func row(ids: Array, captions: Array, base_z: float = Board.FRONT) -> void:
	var width := minf(2.55,10.3/ids.size())
	var spaced_choices := ids.has("coords_off") or ids.has("coords_on") or ids.has("gestures_yes") or ids.has("gestures_no")
	var spacing := width*1.65 if spaced_choices else width
	# Put the tray in front of the low mesa wall so it cannot hide pause or resolve actions.
	var offset := 2.24 if (phase=="Resolve" and selected and not paused) or (phase=="Navigate" and not paused) else 0.0
	var front_clearance := 2.10 if paused or (phase=="Observe" and stage>0) else 0.0
	var tray_width := width+spacing*(ids.size()-1)+0.21
	board.box(ui,Vector3(0,-0.32,base_z+0.69+offset+front_clearance),Vector3(tray_width,0.30,1.04),Board.WOOD)
	board.box(ui,Vector3(0,-0.19,base_z+1.15+offset+front_clearance),Vector3(tray_width,0.10,0.085),Board.BRASS)
	for i in ids.size():
		action(ids[i],captions[i],Vector3((i-(ids.size()-1)*0.5)*spacing,0.04,base_z+0.65+offset+front_clearance),width-0.12,Board.INK)

func circuit_strip(reg: RuneRegister) -> void:
	var gates := PackedStringArray(["|+⟩" if starts_split() else "|0⟩"])
	for rune in program:
		gates.append("P(%s)" % ANGLE_NAMES[int(rune.right(1))] if rune.begins_with("P") else rune)
	var path := " → ".join(gates)
	var relative := "—"
	if reg.yin.length_squared()>0.000001 and reg.yang.length_squared()>0.000001:
		relative = "%d°" % posmod(roundi(rad_to_deg(reg.yin.angle_to(reg.yang))),360)
	var readout := "Round |0⟩  %.1f%%      Diamond |1⟩  %.1f%%      Relative phase  %s" % [
		100*reg.yin.length_squared(),100*reg.yang.length_squared(),relative]
	var slate := board.box(ui,Vector3(0,0.03,Board.FRONT+1.14),Vector3(10.5,0.94,0.18),Board.INK)
	slate.rotation.x = -0.65
	label(slate,path,Vector3(0,0.20,0.11),mini(25,int(1490.0/path.length())),Board.CREAM)
	label(slate,readout,Vector3(0,-0.19,0.11),20,Board.BRASS)

func field_notes() -> void:
	action("hint","Hint",Vector3(-7.35,0.82,Board.FRONT+0.32),1.18,Board.CREAM)

# Keep the clickable area stationary while the figure inside it moves.
func yard_target(id: String, at: Vector3, size: Vector3) -> void:
	var area := Area3D.new()
	var hit := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	hit.shape = shape
	area.add_child(hit)
	ui.add_child(area)
	area.position = at
	area.set_meta("command",id)

func yard_hint(reg: RuneRegister) -> String:
	if phase=="Observe":
		return "Walk to the glowing %s." % ("bridge winch" if seal==0 else "fork relay")
	if is_equal_approx(reg.yang.length_squared(),1.0):
		return "Measure 1 to lower the first bridge." if seal==0 else "Measure now to lower the diamond bridge beside Pauli."
	if program.size()>=8:
		return "The rune tray is full. Undo the last rune."
	if seal==0:
		return "The winch lowers on 1. Invert flips its input from 0 to 1."
	if is_zero_approx(reg.yang.length_squared()):
		return "Apply Hadamard: H takes |0⟩ to equal, in-phase paths."
	if is_equal_approx(reg.yang.length_squared(),0.5):
		var relative := reg.yin.angle_to(reg.yang)
		if is_equal_approx(absf(relative),PI):
			return "Apply H again. The round amplitudes cancel and the diamond amplitudes add."
		if is_zero_approx(relative):
			if angle!=2:
				return "Set angle to 180°, then tap Apply phase to add P(π)."
			return "Apply P(π). The diamond amplitude changes sign; both odds stay at 50%."
	return "Undo the last rune to return to the previous arrangement."

func square_name(cell: Vector2i) -> String:
	return String.chr(65+cell.x)+str(Board.BOARD_SIZE.y-cell.y)

func near_guard(cell: Vector2i) -> bool:
	var offset := (guard_cell-cell).abs()
	return offset.x+offset.y==1

func mark_moves() -> void:
	for direction: Vector2i in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
		var cell := hero_cell+direction
		var closed_bridge := stage==0 and not in_field and cell in [Board.FIRST_SPAN,Board.FAR_SPANS[0],Board.FAR_SPANS[1]] and board.blocked.has(cell)
		if closed_bridge:
			# Show the intended crossing even while its raised deck is still impassable.
			var bridge_center := Board.square(cell)
			var halo := board.aura(ui,bridge_center+Vector3.UP*2.15,Board.CELL*1.25,Color("#35f3ef"))
			halo.rotation.x = -PI/2
			var bridge_text := label(ui,"BRIDGE",bridge_center+Vector3.UP*2.42,32,Board.CREAM)
			bridge_text.outline_size = 10
		if not board.walkable(cell) or board.monster_at(cell) or (shield>0 and (cell==guard_cell or (stage==4 and cell==board.exit_cell))):
			continue
		var id := square_name(cell)
		moves[id] = cell
		var center := Board.square(cell)
		yard_target(id,center+Vector3.UP*0.12,Vector3(Board.CELL-0.04,0.27,Board.CELL-0.04))
		var inlay := board.box(ui,center+Vector3.UP*0.04,Vector3(Board.CELL-0.15,0.04,Board.CELL-0.15),Color("#536e67"))
		var marker := id if show_coordinates else ""
		if stage==0 and not in_field and phase=="Observe" and cell==Board.WINCHES[seal]:
			marker = "Winch" if seal==0 else "Relay"
		var text := label(inlay,marker,Vector3.UP*0.045,36,Board.CREAM)
		text.rotation.x = -PI/2
		text.set_meta("ink",Board.CREAM)
		buttons[id] = text

func take_beat(id: String) -> void:
	var checkpoint_needed := false
	if moves.has(id):
		hero_cell = moves[id]
		board.move_hero(hero_cell)
	elif id=="attack" and shield>0 and near_guard(hero_cell):
		shield -= 1
		if shield==0:
			guard_defeated = true
			checkpoint_needed = true
			message = "Guardian defeated."
	elif id=="attack":
		var enemy := board.adjacent_monster(hero_cell)
		if enemy:
			board.dismiss_monster(enemy)
	if not in_field:
		health-=board.advance_roamers(hero_cell,guard_cell,id=="block")
		if stage>0 and ambience.playing and beat%6==3:
			var nearby := board.adjacent_monster(hero_cell)
			if nearby:
				voices.stream = CALLS[nearby.kind]
				voices.play()
			elif shield>0 and near_guard(hero_cell):
				voices.stream = CALLS[3]
				voices.play()
	if shield>0 and near_guard(hero_cell) and beat%2==0 and id!="block":
		health -= 1
	if tonic and tonic.visible and health<MAX_HEALTH and hero_cell==TONIC_CELLS[stage]:
		var recovered := mini(TONIC_HEAL,MAX_HEALTH-health)
		health += recovered
		tonic.hide()
		message = "Tonic restored %d HP." % recovered
		checkpoint_needed = true
	beat += 1
	if hero_cell==board.exit_cell:
		phase = "Achieve"
	if checkpoint_needed and health>0:
		save_boundary(true)

func refresh() -> void:
	focus = ""
	for child in ui.get_children():
		ui.remove_child(child)
		child.queue_free()
	buttons.clear()
	button_areas.clear()
	moves.clear()
	if story!="":
		refresh_story()
		return
	if story_set:
		story_set.hide()
	board.show()
	board.set_coordinates_visible(show_coordinates)
	if in_field:
		refresh_field()
		return
	for x in [-2.55,2.55]:
		board.box(ui,Vector3(x,1.28,Board.REAR-1.65),Vector3(0.14,2.56,0.16),Board.WOOD)
	board.box(ui,Vector3(0,2.54,Board.REAR-1.65),Vector3(6.1,0.83,0.19),Board.WOOD)
	label(ui,TITLES[stage],Vector3(0,2.54,Board.REAR-1.54),37,Board.CREAM)
	label(ui,"%s   ·   %d/%d HP" % [phase,health,MAX_HEALTH],Vector3(0,3.21,Board.REAR-1.60),20,Board.CREAM)
	var preview := state()
	board.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
	var emitter := Board.square(Board.WINCHES[seal])+Vector3(-0.40,1.0,-0.47) if stage==0 else board.rune_station+Vector3.UP*0.57
	board.show_register(phase=="Resolve" and selected and not paused,emitter,preview.yin,preview.yang)
	if stage==0 and phase=="Resolve" and not paused:
		if seal==0:
			label(ui,"Lower: %d%%" % roundi(100*preview.yang.length_squared()),Board.square(Board.FIRST_SPAN)+Vector3.UP*2.15,25,Board.BRASS)
		else:
			for bit in range(2):
				var weight := preview.yin.length_squared() if bit==0 else preview.yang.length_squared()
				var route := "Detour" if bit==0 else "Shortcut"
				var odds_label := label(ui,"%s: %d%%" % [route,roundi(100*weight)],Board.square(Board.FAR_SPANS[bit])+Vector3(0,2.15,0.30),25,Board.CREAM)
				odds_label.outline_size = 6
	if stage!=0 and phase=="Resolve" and selected and not paused and (stage!=4 or seal==0):
		var weight := preview.yin.length_squared() if stage==1 else preview.yang.length_squared()
		var odds_label := label(ui,"Clear passage: %d%%" % roundi(weight*100),Board.square(Board.SHORTCUTS[stage])+Vector3(0,2.65,0.27),24,Board.CREAM)
		odds_label.outline_size = 6
	var line := message
	board.treasure.visible = phase in ["Treasure","Collected"]
	board.hero.visible = not board.treasure.visible
	board.creature.visible = not guard_defeated and not board.treasure.visible and (phase in ["Observe","Resolve"] or (phase=="Navigate" and shield>0))
	if stage==0:
		board.creature.visible = true
		board.puppy_calm = phase=="Achieve"
		board.collar_tags[0].visible = true
		board.collar_tags[1].visible = false
		label(ui,"Pauli",Board.square(Board.PAULI)+Vector3.UP*4.1,36,Board.CREAM)
	if stage!=0 and phase=="Navigate":
		board.creature.position = Board.square(guard_cell)
	board.landing.visible = stage==0 or phase in ["Navigate","Achieve"]
	if tonic and tonic.visible:
		label(ui,"Tonic +2 HP",tonic.position+Vector3.UP*1.05,24,Board.CREAM)
	if paused:
		line = "Trail paused"
		row(["resume","center","scale","tilt","coords_toggle","sound","quit"],["Resume","Recenter","Scale","Tilt","Labels off" if show_coordinates else "Labels on","Mute" if ambience.playing else "Unmute","Quit"])
	else:
		match phase:
			"Observe":
				line = HINTS[stage] if hint else INTENTS[stage]
				if stage==0:
					var winch: Vector2i = Board.WINCHES[seal]
					var nameplate := "Bridge winch" if seal==0 else "Fork relay"
					var at := Board.square(winch)
					mark_moves()
					if hero_cell==winch:
						station_sign("plan",nameplate,at+Vector3(-0.55,1.1,-0.77))
						yard_target("plan",at+Vector3(-0.40,0.50,-0.47),Vector3(0.85,1.0,0.85))
						line = "Select Bridge winch. Its 1 output lowers the deck." if seal==0 else "Select Fork relay. Its two outputs feed different bridges."
					else:
						label(ui,nameplate+(" (%s)" % square_name(winch) if show_coordinates else ""),at+Vector3.UP*1.18,28,Board.BRASS)
						line = "Pauli is stranded. Walk to the bridge winch." if seal==0 else "Cross the lowered bridge and walk to the fork relay."
						if hint:
							line = "Select the green squares to reach the glowing mechanism."
					field_notes()
				elif stage==1:
					line = "Choose: solve the sluice for a shorter route, or fight and evade the creatures."
					if hint:
						line = HINTS[stage]
					row(["fight_route","plan","hint"],["Fight through","Resolve sluice","Hint"])
				else:
					station_sign("plan","Resolve",Vector3(3.35,1.10,-0.36))
					field_notes()
			"Resolve":
				if not selected:
					line = "Choose the mechanism to prepare."
					var target: String = ["Bridge winch","Mill sluice","Kiln core","Wisp router","Vault seal"][stage]
					station_sign("target",target,Vector3(3.35,1.10,-0.36))
					yard_target("target",board.creature.position+Vector3.UP*0.7,Vector3(1.4,1.45,1.10))
				else:
					if coins > 0:
						action("coin_read","Lucky coin",Vector3(-3.85,1.82,0.1),2.1,Board.INK)
					if lens_ready:
						action("lens_shift","Lens +180°",Vector3(-1.6,1.82,0.1),2.15,Board.INK)
					circuit_strip(preview)
					var odds := roundi(preview.yang.length_squared()*100)
					line = "Aim for the round exit, then measure." if stage==1 else "Aim for the diamond outcome, then measure."
					var ids := ["X"] if stage in [0,4] and seal==0 else ["H"]
					var names := ["Invert"] if ids[0]=="X" else ["Hadamard"]
					if (stage >= 2 or stage == 0) and ids[0]=="H":
						ids.append_array(["angle","P"])
						names.append_array(["Set angle %d°" % roundi(rad_to_deg(ANGLES[angle])),"Apply phase"])
					ids.append_array(["undo","read"])
					names.append_array(["Undo","Measure"])
					row(ids,names)
					if stage==0:
						field_notes()
						var cue := "Winch: 0 holds the bridge up. 1 lowers it. Try X." if seal==0 else "Round lowers the upstream detour. Diamond lowers the bridge to Pauli."
						if not program.is_empty():
							match program.back():
								"X": cue = "Measure the winch to set the bridge."
								"H": cue = "H mixes the paths. Their relative phase sets the output odds."
								_: cue = "P rotates the |1⟩ amplitude. Apply H to turn phase into exit odds."
						if odds==100:
							cue = "Measure to lower the first bridge." if seal==0 else "Measure to lower the diamond bridge."
						if hint:
							cue = yard_hint(preview)
						line = cue
					if message!="":
						line = message
			"Navigate":
				mark_moves()
				line = "The passage is clear. Reach the brass-framed exit."
				if stage in [1,2,3] and board.blocked.has(Board.SHORTCUTS[stage]):
					line = "The shortcut is optional. Follow the open stones around it to reach the exit."
				if stage==1 and message!="":
					line = message
				if message.begins_with("Tonic") or guard_defeated:
					line = "%s Reach the brass-framed exit." % (message if message!="" else "Guardian defeated.")
				if stage==0:
					line = "%s Walk across to Pauli." % message
					if seal==1 and hero_cell==Board.WINCHES[1] and (board.blocked.has(Board.FAR_SPANS[0]) or board.blocked.has(Board.FAR_SPANS[1])):
						station_sign("plan","Use fork relay",Board.square(Board.WINCHES[1])+Vector3(-0.55,1.1,-0.77))
						line = "Optional crossing: select the relay to lower the other bridge."
				if shield>0:
					line = "The guardian is active. Approach to strike."
					if near_guard(hero_cell):
						line = "Guard will strike." if beat%2==0 else "Guard is between strikes. Strike or move."
						row(["attack","block"],["Strike","Block"])
				var attacker := board.adjacent_monster(hero_cell)
				if attacker and not (shield>0 and near_guard(hero_cell)):
					line = "%s nearby. Strike, block or move." % attacker.NAMES[attacker.kind]
					row(["attack","block"],["Strike","Block"])

			"Achieve":
				line = "The vault seals are open." if stage==4 else "Room cleared. The next trail marker is lit."
				if stage==0:
					line = "Pauli is safe. The other crossing is optional; return to the relay to lower it before leaving."
				elif stage==1:
					line = "Mill treasure: a Lucky Coin. Spend it for a noisy read."
				elif stage==2:
					line = "Kiln treasure: a Phase Lens. Add one half-turn to a core."
				if stage==0 and (board.blocked.has(Board.FAR_SPANS[0]) or board.blocked.has(Board.FAR_SPANS[1])):
					row(["explore","next"],["Try other bridge","To the meadow"])
				else:
					row(["next"],["Open treasury" if stage==4 else ("To the meadow" if stage==0 else "Next room")])
			"Treasure":
				line = "Choose a keepsake from the vault."
				row(["coin","lens","dice"],RELICS)
			"Collected":
				line = RELICS[relic]+"   ·   "+RELIC_TEXT[relic]
				row(["restart","quit"],["Play again","Quit"])
			"Lost":
				line = "The trail has claimed your last heart."
				row(["restart","quit"],["Try again","Quit"])
		action("pause","Pause",Vector3(7.35,0.82,Board.FRONT+2.35),1.22,Board.BRASS)
	var plaque_z := Board.FRONT+2.10 if paused else Board.FRONT+0.28
	var plaque := board.box(ui,Vector3(0,1.23,plaque_z),Vector3(10.35,0.63,0.1),Board.CREAM)
	plaque.rotation.x = -0.38
	var plaque_text := label(plaque,plaque_copy(line),Vector3(0,0,0.062),mini(28, int(1850.0/maxi(1,line.length()))),Board.INK)
	if plaque_text.text.contains("\n"):
		(plaque.mesh as BoxMesh).size.y = 0.9
		plaque_text.font_size = 26

func build_story_set() -> void:
	story_set = Node3D.new()
	table.add_child(story_set)
	var at := Vector3(-8.1,0,-0.75)
	wizard = board.build_hadamard(at)
	wizard.reparent(story_set,false)
	wizard.scale = Vector3.ONE*1.95
	board.drum(story_set,at-Vector3.UP*0.22,1.60,1.31,0.40,Color("#a37354"),8)
	for side in [-1,1]:
		var column := Vector3(side*10.5,-1.25,-3.3)
		board.drum(story_set,column,1.2,0.95,2.8,Color("#9c6047"),6)
		board.drum(story_set,column+Vector3.UP*1.45,0.94,0.62,0.75,Color("#bc8c62"),6)
	title_runes = Board.QuantumFork.new()
	story_set.add_child(title_runes)
	title_runes.scale = Vector3.ONE*1.35

func refresh_story() -> void:
	board.hide()
	if not story_set:
		build_story_set()
	story_set.show()
	var speaker := "Hadamard the Archemage"
	var line_one := ""
	var line_two := ""
	var story_phase := story
	if story_phase=="Title":
		speaker = "Toffoli Troubles"
		line_one = "The observatory above Tidemark Mill has gone dark."
		line_two = "A descent through the sandstone ruins awaits."
		var ids := ["continue_run","new_run","quit"] if can_continue else ["new_run","quit"]
		var captions := ["Continue","New run","Quit"] if can_continue else ["Begin","Quit"]
		row(ids,captions,4.25)
	elif story_phase=="Briefing":
		if briefing_page==0:
			line_one = "The Crowned Slime sealed the vault and stole its light."
			line_two = "If the vault stays dark, the mill will run dry."
		elif briefing_page==1:
			line_one = "Start in the Practice Yard. Pauli is stranded across the channels."
			line_two = "Learn to lower the bridges there. The dungeon gates answer to the same runes."
		elif briefing_page==2:
			line_one = "Would you like letters and numbers around the board?"
			line_two = "The board starts with coordinates hidden. You can change this in Pause."
		elif briefing_page==3:
			line_one = "Would you use hand gestures if they were available?"
			line_two = "Choose your preference. Gestures are not ready to test yet."
		else:
			line_one = "Planned: point ahead/right/back/left to move; pinch to select."
			line_two = "Thumbs-up advances; open palm blocks; flick strikes. Not testable yet."
		if briefing_page<2:
			row(["story_next"],["Continue"],4.25)
		elif briefing_page==2:
			row(["coords_off","coords_on"],["Hide coordinates","Show coordinates"],4.25)
		elif briefing_page==3:
			row(["gestures_yes","gestures_no"],["Yes, gestures","Buttons for now"],4.25)
		else:
			row(["gesture_done"],["Enter Practice Yard"],4.25)
	else:
		speaker = "The vault is open"
		line_one = "The Crowned Slime has fallen. Light is returning to the mill."
		line_two = "Hadamard entrusts you with %s." % RELICS[relic]
		row(["restart","quit"],["Play again","Quit"],4.25)
	wizard.visible = story_phase!="Title"
	title_runes.update_state(story_phase=="Title",Vector3(0,2.0,-4.9),Vector2.RIGHT*0.707,Vector2.UP*0.707)
	var tablet := board.box(ui,Vector3(0.0 if story_phase=="Title" else 1.8,2.24,0.4),Vector3(16.6,3.8,0.22),Board.INK)
	tablet.rotation.x = -0.54
	board.box(tablet,Vector3(0,1.70,0.13),Vector3(16.1,0.027,0.027),Board.BRASS)
	board.box(tablet,Vector3(0,-1.70,0.13),Vector3(16.1,0.027,0.027),Board.BRASS)
	label(tablet,speaker,Vector3(0,0.76,0.14),56 if story_phase=="Title" else 41,Board.BRASS)
	label(tablet,line_one,Vector3(0,-0.19,0.14),25,Board.CREAM)
	label(tablet,line_two,Vector3(0,-0.73,0.14),25,Board.CREAM)

func refresh_field() -> void:
	board.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
	board.hero.show()
	if wizard:
		wizard.hide()
	label(ui,"Cave meadow",Vector3(-4.3,2.4,Board.REAR),44,Board.CREAM)
	label(ui,"Dungeon entrance",Board.square(Board.CAVE_ENTRY)+Vector3.UP*3.45,28,Board.CREAM)
	var line := "Cross the meadow. Follow the stones to the torchlit cave."
	if paused:
		line="Trail paused"
		row(["resume","center","scale","tilt","coords_toggle","sound","quit"],["Resume","Recenter","Scale","Tilt","Labels off" if show_coordinates else "Labels on","Mute" if ambience.playing else "Unmute","Quit"])
	else:
		action("pause","Pause",Vector3(7.35,0.82,Board.FRONT+2.35),1.22,Board.BRASS)
		if phase=="Achieve":
			line="Cold air rises from Tidemark Mill."
			row(["next"],["Enter cave"])
		else:
			mark_moves()
	var plaque_z := Board.FRONT+2.10 if paused else Board.FRONT+0.28
	var plaque := board.box(ui,Vector3(0,1.23,plaque_z),Vector3(10.35,0.63,0.1),Board.CREAM)
	plaque.rotation.x=-0.38
	var plaque_text := label(plaque,plaque_copy(line),Vector3(0,0,0.065),mini(28, int(1850.0/maxi(1,line.length()))),Board.INK)
	if plaque_text.text.contains("\n"):
		(plaque.mesh as BoxMesh).size.y = 0.9
		plaque_text.font_size = 26

func plaque_copy(line: String) -> String:
	if line.length()<=54:
		return line
	var split_at := 54
	while split_at>30 and line[split_at] != " ":
		split_at -= 1
	if split_at<=30:
		return line
	return line.substr(0,split_at)+"\n"+line.substr(split_at+1)

func activate(id: String) -> void:
	if not buttons.has(id):
		return
	idle_time = 0.0
	if id in ["X","P","H","angle","undo","hint"]:
		message = ""
	if moves.has(id):
		take_beat(id)
	match id:
		"continue_run":
			story = "Ending" if relic>=0 else ""
		"new_run","restart":
			paused = false
			story = "Briefing"
			briefing_page = 0
			stage = 0
			in_field = false
			health = MAX_HEALTH
			relic = -1
			coins = 0
			lens_ready = false
			build_stage()
			return
		"story_next":
			briefing_page += 1
		"coords_off","coords_on":
			show_coordinates = id=="coords_on"
			briefing_page = 3
			save_boundary()
		"gestures_yes","gestures_no":
			prefer_gestures = id=="gestures_yes"
			briefing_page = 4
			save_boundary()
		"gesture_done":
			story = ""
			save_boundary()
		"coords_toggle":
			show_coordinates = not show_coordinates
			var checkpoint := ConfigFile.new()
			if checkpoint.load(SAVE)==OK:
				checkpoint.set_value("settings","coordinates",show_coordinates)
				if checkpoint.save(SAVE)!=OK:
					push_warning("Could not save the coordinate preference.")
		"sound":
			if ambience.playing:
				ambience.stop()
				voices.stop()
			else:
				ambience.play()
		"pause": paused = true
		"resume": paused = false
		"center": recenter()
		"scale":
			scale_index = (scale_index+1)%3
			table.scale = Vector3.ONE * (XR_BOARD_SCALE if xr else 1.0) * [0.85,1.0,1.08][scale_index]
		"tilt":
			tilt_index = (tilt_index+1)%3
			table.rotation.x = deg_to_rad([-8,0,8][tilt_index])
		"quit":
			get_tree().quit()
			return
		"plan":
			phase = "Resolve"
			selected = stage in [0,1]
			program.clear()
			angle = 2
			message = ""
			if stage==0:
				hint = false
		"explore":
			phase = "Navigate"
			message = "The open bridge leads back to the fork relay."
		"fight_route":
			phase = "Navigate"
			message = "Long route chosen. Fight or evade the mill creatures."
		"hint": hint = true
		"target": selected = true
		"angle":
			angle = (angle+1)%3
			message = "Angle set. Tap Apply phase to append P(%s)." % ANGLE_NAMES[angle]
		"H","X","P":
			if program.size()>=8:
				message = "Eight gates prepared. Undo a gate or measure."
			else:
				program.append("P"+str(angle) if id=="P" else id)
				var input_point := Board.square(Board.WINCHES[seal]) if stage==0 else board.rune_station
				var color := Board.VIOLET if id=="P" else Board.CYAN
				board.discharge(input_point-Vector3.RIGHT*1.1,input_point,color)
		"undo":
			if not program.is_empty():
				program.pop_back()
		"lens_shift":
			if program.size()<8:
				program.append("P2")
				lens_ready = false
		"read","coin_read":
			var prepared := state()
			if id=="coin_read":
				coins -= 1
				if rng.randf()<0.5:
					prepared.apply("X")
			var outcome := prepared.measure(rng)
			var correct := outcome == (0 if stage==1 else 1)
			message = "Measured "+("yang" if outcome==1 else "yin")
			if stage in [0,4] and seal==0 and correct:
				if stage==0:
					board.lower_bridge(Board.FIRST_SPAN)
				else:
					board.open_shortcut(stage)
				seal = 1
				begin_observe()
				hint = stage!=0
			elif id=="coin_read" and not correct:
				begin_observe()
				hint = true
			elif stage==0 and seal==0 and not correct:
				program.clear()
				hint = true
				message = "Measured 0: the bridge stays raised. Invert, then measure 1."
			elif stage==4 and not correct:
				health -= 1
				begin_observe()
				hint = true
			else:
				if stage in [1,2,3]:
					if stage==1:
						message = "Sluice open. The shortcut passes most mill creatures." if correct else "Sluice closed. Fight or evade the creatures on the long route."
					else:
						message = "Shortcut open; the open stones also reach the exit." if correct else "Shortcut sealed; take the open stones around it to the exit."
				shield = 0 if correct or stage==0 else 3
				if stage in [1,2,3] and correct:
					board.open_shortcut(stage)
				if stage==4:
					shield = 1
					message = "Crown exposed. Strike once."
				if stage==0:
					board.lower_bridge(Board.FAR_SPANS[outcome])
					message = "Upstream bridge down." if outcome==0 else "Diamond bridge down."
				phase = "Navigate"
		"attack","block":
			take_beat(id)
		"next":
			if stage==0 and not in_field:
				in_field=true
				save_boundary()
				build_stage()
				return
			elif stage==4:
				phase = "Treasure"
			else:
				if stage==1:
					coins = 1
				if stage==2:
					lens_ready = true
				in_field=false
				stage += 1
				save_boundary()
				build_stage()
				return
		"coin","lens","dice":
			relic = ["coin","lens","dice"].find(id)
			phase = "Collected"
			story = "Ending"
			save_boundary()
	if health<=0:
		phase = "Lost"
	refresh()

func cast(from: Vector3, direction: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from,from+direction*100)
	query.collide_with_areas = true
	return get_world_3d().direct_space_state.intersect_ray(query)

func highlight(id: String) -> void:
	if buttons.has(focus):
		buttons[focus].modulate = buttons[focus].get_meta("ink")
		buttons[focus].outline_size = 7
		button_areas[focus].scale = Vector3.ONE
	focus = id
	if buttons.has(id):
		buttons[id].modulate = Color("#ffe08a")
		buttons[id].outline_size = 11
		button_areas[id].scale = Vector3.ONE*1.10

func aim(from: Vector3, direction: Vector3, press: bool) -> void:
	var hit := cast(from,direction)
	var id := ""
	if hit.has("collider"):
		id = hit.collider.get_meta("command","")
	highlight(id)
	if press:
		activate(id)

func _unhandled_input(event: InputEvent) -> void:
	if xr or not camera:
		return
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		var pos: Vector2 = event.position
		aim(camera.project_ray_origin(pos),camera.project_ray_normal(pos),event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed)
	if story=="" and event.is_action_pressed("ui_cancel"):
		paused = not paused
		refresh()

func _process(delta: float) -> void:
	if story=="" and (phase=="Observe" or (stage==0 and phase=="Resolve")) and not paused and not hint:
		idle_time += delta
		if idle_time>(6.0 if stage==0 else 12.0):
			hint = true
			refresh()

func _physics_process(_delta: float) -> void:
	if not xr:
		return
	var found := false
	var aimed := false
	for i in range(2):
		hand_beams[i].visible = false
		var hand := XRServer.get_tracker(["/user/hand_tracker/left","/user/hand_tracker/right"][i]) as XRHandTracker
		if not hand or not hand.has_tracking_data:
			pinch[i] = true
			continue
		var joints := [XRHandTracker.HAND_JOINT_WRIST,XRHandTracker.HAND_JOINT_INDEX_FINGER_PHALANX_PROXIMAL,XRHandTracker.HAND_JOINT_INDEX_FINGER_TIP,XRHandTracker.HAND_JOINT_THUMB_TIP]
		var valid := true
		for joint in joints:
			valid = valid and bool(hand.get_hand_joint_flags(joint) & XRHandTracker.HAND_JOINT_FLAG_POSITION_VALID)
		if not valid:
			pinch[i] = true
			continue
		found = true
		if first_tracking:
			first_tracking = false
			recenter()
		var wrist := hand.get_hand_joint_transform(joints[0]).origin
		var knuckle := hand.get_hand_joint_transform(joints[1]).origin
		var tip := hand.get_hand_joint_transform(joints[2]).origin
		var thumb := hand.get_hand_joint_transform(joints[3]).origin
		var dist := tip.distance_to(thumb)
		var pressed := dist<0.023 and not bool(pinch[i])
		if dist>0.035 or pressed:
			pinch[i] = pressed
		var direction := (knuckle-wrist).normalized()
		var hit := cast(knuckle,direction)
		if direction.length_squared()<0.5:
			continue
		var reach := knuckle.distance_to(hit.position) if not hit.is_empty() else 0.8
		var beam := hand_beams[i]
		beam.visible = true
		beam.position = knuckle+direction*reach*0.5
		beam.look_at(beam.position+direction,Vector3.UP if absf(direction.y)<0.99 else Vector3.RIGHT)
		beam.scale.z = reach
		if not hit.is_empty() and (pressed or not aimed):
			aimed = true
			highlight(hit.collider.get_meta("command",""))
			if pressed:
				activate(focus)
				break
	if not aimed:
		highlight("")
	if story=="" and tracked and not found and not paused:
		paused = true
		refresh()
	tracked = found

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and board and not paused and story=="":
		paused = true
		refresh()
