class_name MoveResolver
extends RefCounted

const ActionEventScript := preload("res://scripts/core/ActionEvent.gd")
const TurnResultScript := preload("res://scripts/core/TurnResult.gd")

var _magnet_resolver: MagnetResolver
var _win_checker: WinChecker
var _undo_history: UndoHistory
var _next_turn_id := 1


func _init(
	magnet_resolver: MagnetResolver,
	win_checker: WinChecker,
	undo_history: UndoHistory
) -> void:
	_magnet_resolver = magnet_resolver
	_win_checker = win_checker
	_undo_history = undo_history


func try_move(state: GameState, dir: Vector2i) -> TurnResultScript:
	if state.cleared:
		return null

	var next_pos := state.player_pos + dir

	if state.walls.has(next_pos):
		return null

	var body := state.get_body_at(next_pos)
	var moved_body_id := -1
	var pushed_body_from := Vector2i.ZERO
	var pushed_body_to := Vector2i.ZERO
	var player_from := state.player_pos

	if body != null:
		if not body.movable:
			return null

		var push_to := next_pos + dir

		if not state.is_cell_free(push_to):
			return null

		_undo_history.push(state)

		pushed_body_from = body.pos
		pushed_body_to = push_to
		body.pos = push_to
		state.player_pos = next_pos
		moved_body_id = body.id
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

	if moved_body_id != -1:
		result.add_event(ActionEventScript.body_move(
			move_phase,
			moved_body_id,
			pushed_body_from,
			pushed_body_to,
			dir,
			"push"
		))

	if moved_body_id != -1:
		_magnet_resolver.apply_after_push(state, moved_body_id, dir, result)

	state.cleared = _win_checker.is_cleared(state)
	result.did_clear = state.cleared
	result.move_count_after = state.move_count
	result.add_turn_end_event()
	return result
