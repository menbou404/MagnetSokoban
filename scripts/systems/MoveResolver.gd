class_name MoveResolver
extends RefCounted

const ActionEventScript := preload("res://scripts/core/ActionEvent.gd")
const RotationResolverScript := preload("res://scripts/systems/RotationResolver.gd")
const TurnResultScript := preload("res://scripts/core/TurnResult.gd")

var _magnet_resolver: MagnetResolver
var _win_checker: WinChecker
var _undo_history: UndoHistory
var _rotation_resolver: RefCounted
var _next_turn_id := 1


func _init(
	magnet_resolver: MagnetResolver,
	win_checker: WinChecker,
	undo_history: UndoHistory,
	rotation_resolver: RefCounted = null
) -> void:
	_magnet_resolver = magnet_resolver
	_win_checker = win_checker
	_undo_history = undo_history
	if rotation_resolver == null:
		_rotation_resolver = RotationResolverScript.new()
	else:
		_rotation_resolver = rotation_resolver


func try_move(state: GameState, dir: Vector2i) -> TurnResultScript:
	if state.cleared or dir == Vector2i.ZERO:
		return null

	var next_pos := state.player_pos + dir

	if not state.is_inside_board(next_pos):
		return null

	if state.walls.has(next_pos):
		return null

	var body := state.get_body_at(next_pos)
	var pushed_body_moves: Array[Dictionary] = []
	var player_from := state.player_pos

	if body != null:
		var push_line := _build_push_line(state, next_pos, dir)
		if push_line.is_empty():
			return null

		var front_body: MagneticBodyState = push_line[push_line.size() - 1]
		var push_to: Vector2i = front_body.pos + dir

		if not state.is_cell_free(push_to):
			return null

		_undo_history.push(state)

		pushed_body_moves = _build_body_move_events(push_line, dir)

		for index in range(push_line.size() - 1, -1, -1):
			var pushed_body: MagneticBodyState = push_line[index]
			pushed_body.pos += dir

		_rotation_resolver.apply_rotation_tiles(state, push_line)

		state.player_pos = next_pos
		state.move_count += 1
	else:
		_undo_history.push(state)
		state.player_pos = next_pos
		state.move_count += 1

	var result := TurnResultScript.new()
	result.turn_id = _next_turn_id
	_next_turn_id += 1
	result.did_change_state = true

	var move_phase := result.allocate_phase()
	result.add_event(ActionEventScript.player_move(
		move_phase,
		player_from,
		state.player_pos,
		dir
	))

	for pushed_body_move in pushed_body_moves:
		result.add_event(ActionEventScript.body_move(
			move_phase,
			pushed_body_move["body_id"] as int,
			pushed_body_move["from"] as Vector2i,
			pushed_body_move["to"] as Vector2i,
			dir,
			"push"
		))

	_magnet_resolver.settle_magnetic_field(state, result)

	state.cleared = _win_checker.is_cleared(state)
	result.did_clear = state.cleared
	result.move_count_after = state.move_count
	result.add_turn_end_event()
	return result


func _build_push_line(state: GameState, start_pos: Vector2i, dir: Vector2i) -> Array:
	var push_line: Array = []
	var cursor := start_pos

	while state.is_inside_board(cursor):
		var body := state.get_body_at(cursor)
		if body == null:
			break

		if not body.movable:
			return []

		push_line.append(body)
		cursor += dir

	return push_line


func _build_body_move_events(push_line: Array, dir: Vector2i) -> Array[Dictionary]:
	var moves: Array[Dictionary] = []

	for body in push_line:
		var pushed_body := body as MagneticBodyState
		moves.append({
			"body_id": pushed_body.id,
			"from": pushed_body.pos,
			"to": pushed_body.pos + dir,
		})

	return moves
