extends SceneTree

# Run with an isolated user data directory; the route writes checkpoints.
const Register = preload("res://scripts/register.gd")
var game
var failures := 0

func check(condition: bool, detail: String) -> void:
	if not condition:
		failures += 1
		push_error(detail)

func command(id: String) -> void:
	check(game.buttons.has(id),"Missing action %s in %s" % [id,game.phase])
	game.activate(id)

func solve(sequence: Array) -> void:
	command("plan")
	if not game.selected:
		command("target")
	for id in sequence:
		command(id)
	command("read")

func cross_board() -> void:
	if game.stage==4:
		walk_to(game.guard_cell+Vector2i.DOWN)
		command("block")
		command("attack")
		check(game.guard_defeated and not game.board.creature.visible,"A killed guard disappears")
		var guard_save = load("res://world.tscn").instantiate()
		root.add_child(guard_save)
		guard_save.activate("continue_run")
		check(guard_save.guard_defeated and guard_save.shield==0 and not guard_save.board.creature.visible,"Reload preserves guard defeat")
		guard_save.queue_free()
	walk_to(game.board.exit_cell)

func walk_to(destination: Vector2i) -> void:
	var frontier: Array[Vector2i] = [game.hero_cell]
	var parent := {game.hero_cell:game.hero_cell}
	while not frontier.is_empty():
		var cell: Vector2i = frontier.pop_front()
		if cell==destination:
			break
		for direction: Vector2i in [Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT]:
			var neighbor := cell+direction
			if game.board.walkable(neighbor) and not parent.has(neighbor) and neighbor!=game.guard_cell and (game.shield==0 or neighbor!=game.board.exit_cell):
				parent[neighbor] = cell
				frontier.append(neighbor)
	var cursor := destination
	check(parent.has(cursor),"Room exit reachable around obstacles")
	if not parent.has(cursor):
		return
	var path: Array[Vector2i] = []
	while cursor!=game.hero_cell:
		path.push_front(cursor)
		cursor = parent[cursor]
	for cell in path:
		while game.board.adjacent_monster(game.hero_cell) and game.buttons.has("attack") and game.shield==0:
			command("attack")
		if game.board.monster_at(cell) and game.buttons.has("attack"):
			command("attack")
		command(game.square_name(cell))

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var register := Register.new()
	register.apply("H")
	register.apply("P",PI/2)
	register.apply("H")
	check(is_equal_approx(register.yang.length_squared(),0.5),"Interference odds")
	register.measure(RandomNumberGenerator.new())
	check(is_equal_approx(register.yin.length_squared()+register.yang.length_squared(),1.0),"Collapsed norm")
	game = load("res://world.tscn").instantiate()
	root.add_child(game)
	check(game.story=="Title" and not game.board.visible,"Title hides the playable board")
	command("new_run")
	check(game.story=="Briefing" and game.wizard.visible,"Hadamard presents the briefing")
	command("story_next")
	command("story_next")
	command("coords_off")
	check(game.story=="" and game.phase=="Observe" and game.board.visible,"Briefing leads into the Practice Yard")
	check(not game.show_coordinates and not game.board.coordinate_labels[0].visible,"Coordinates default to hidden")
	game.stage = 0
	game.relic = -1
	check(game.health==5,"A fresh run starts at 5 HP")
	game.build_stage()
	await physics_frame
	await physics_frame
	check(not game.buttons.has("plan"),"The bridge controls are operated at the winch")
	var wildlife_start: Vector2i = game.board.roamers[0].cell
	walk_to(game.board.WINCHES[0])
	check(game.board.roamers[0].cell!=wildlife_start,"Yard wildlife advances with the hero")
	await physics_frame
	await physics_frame
	var area: Area3D = game.buttons["plan"].get_parent()
	var screen: Vector2 = game.camera.unproject_position(area.global_position)
	game.aim(game.camera.project_ray_origin(screen),game.camera.project_ray_normal(screen),true)
	check(game.phase=="Resolve","Mouse ray selects the Resolve button")
	check(game.selected,"The yard opens the clicked core directly")
	var circuit_cell: Vector2i = game.board.roamers[0].cell
	command("X")
	check(game.board.roamers[0].cell==circuit_cell,"Planning preserves monster positions")
	command("undo")
	command("read")
	check(game.health==5 and game.phase=="Resolve","Practice read allows a safe retry")
	check(not game.board.walkable(game.board.FIRST_SPAN),"Readout 0 keeps the first crossing blocked")
	command("X")
	command("read")
	check(game.board.walkable(game.board.FIRST_SPAN),"Readout 1 lowers a traversable bridge")
	walk_to(game.board.WINCHES[1])
	command("plan")
	command("H")
	check(not game.board.walkable(game.board.FAR_SPANS[1]),"Gate previews preserve terrain until measurement")
	var before_dial = game.state()
	command("angle")
	check(game.program.size()==1 and game.state().yang.is_equal_approx(before_dial.yang),"Angle selection only configures the next gate")
	check("Set angle" in game.yard_hint(game.state()),"Hint accounts for a changed dial")
	command("P")
	command("H")
	check(is_equal_approx(game.state().yang.length_squared(),pow(sin(PI/8),2)),"H P(pi/4) H gives sin²(pi/8) at the diamond exit")
	command("undo")
	command("undo")
	command("angle")
	command("angle")
	command("P")
	check(is_equal_approx(game.state().yang.length_squared(),0.5) and is_equal_approx(absf(game.state().yin.angle_to(game.state().yang)),PI),"P(pi) changes relative phase at fixed odds")
	check("H again" in game.yard_hint(game.state()),"Hint explains recombination")
	command("H")
	command("read")
	check(game.board.walkable(game.board.FAR_SPANS[1]) and not game.board.walkable(game.board.FAR_SPANS[0]),"Interference opens only the diamond crossing")
	for stage in range(5):
		check(game.stage==stage,"Room order")
		match stage:
			1: solve(["H"])
			2: solve(["P","H"])
			3: solve(["H","P","H"])
			4:
				solve(["X"])
				solve(["P","H"])
		check(game.phase=="Navigate","Route opens")
		if stage!=0:
			check(game.board.roamers.size()==3,"Dungeon has three additional roaming monsters")
			check(game.board.walkable(game.board.SHORTCUTS[stage]),"Measurement clears the dungeon passage")
		command("pause")
		command("resume")
		check(game.moves.size()>=2,"More than one direction is available from the starting square")
		var start: Vector2i = game.hero_cell
		game.activate(game.square_name(game.board.exit_cell))
		check(game.hero_cell==start,"A distant exit cannot be selected directly")
		if stage==0:
			await physics_frame
			await physics_frame
			var tile: Vector2i = start+Vector2i.RIGHT
			var world_point: Vector3 = game.table.to_global(game.board.square(tile)+Vector3.UP*0.15)
			var mouse_pos: Vector2 = game.camera.unproject_position(world_point)
			game.aim(game.camera.project_ray_origin(mouse_pos),game.camera.project_ray_normal(mouse_pos),true)
			check(game.hero_cell==tile,"Desktop ray picks an adjacent board square")
		if stage==1:
			game.health = 4
			walk_to(game.TONIC_CELLS[stage])
			check(game.health==5 and not game.tonic.visible,"Tonic is consumed and caps health at 5")
		cross_board()
		check(game.phase=="Achieve","Room completion")
		if stage==4:
			check(not game.board.creature.visible,"Guard stays down at the exit")
		command("next")
		if stage==0:
			check(game.in_field,"The yard opens onto a walkable meadow")
			var meadow_save = load("res://world.tscn").instantiate()
			root.add_child(meadow_save)
			check(meadow_save.in_field,"Meadow checkpoint restores the field")
			meadow_save.queue_free()
			walk_to(game.board.CAVE_ENTRY)
			command("next")
			check(game.stage==1 and not game.in_field,"Entering the cave opens Tidemark Mill")
		await process_frame
	command("lens")
	check(game.phase=="Collected" and game.relic==1 and game.story=="Ending","Treasure collection triggers the ending")
	var restored = load("res://world.tscn").instantiate()
	root.add_child(restored)
	restored.activate("continue_run")
	check(restored.story=="Ending" and restored.phase=="Collected" and restored.relic==1,"Continue restores the ending")
	command("restart")
	command("story_next")
	command("story_next")
	command("coords_on")
	check(game.show_coordinates and game.board.coordinate_labels[0].visible,"The briefing can enable board coordinates")
	check(game.health==5,"Restart restores 5 HP")
	walk_to(game.board.WINCHES[0])
	solve(["X"])
	walk_to(game.board.WINCHES[1])
	solve([])
	check(game.board.walkable(game.board.FAR_SPANS[0]) and not game.board.walkable(game.board.FAR_SPANS[1]),"Round result opens only the detour")
	walk_to(game.board.PAULI)
	check(game.phase=="Achieve","The detour also reaches Pauli")
	game.stage = 4
	game.build_stage()
	game.health = 1
	solve([])
	check(game.phase=="Lost","Defeat condition")
	print("World smoke test: %d failures" % failures)
	quit(1 if failures else 0)
