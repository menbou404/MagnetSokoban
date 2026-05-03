class_name MoveResolver
extends RefCounted

var _magnet_resolver: MagnetResolver
var _win_checker: WinChecker
var _undo_history: UndoHistory


func _init(
	magnet_resolver: MagnetResolver,
	win_checker: WinChecker,
	undo_history: UndoHistory
) -> void:
	_magnet_resolver = magnet_resolver
	_win_checker = win_checker
	_undo_history = undo_history


func try_move(state: GameState, dir: Vector2i) -> bool:
	if state.cleared:
		return false

	var next_pos := state.player_pos + dir

	if state.walls.has(next_pos):
		return false

	var body := state.get_body_at(next_pos)
	var moved_body_id := -1

	if body != null:
		if not body.movable:
			return false

		var push_to := next_pos + dir

		if not state.is_cell_free(push_to):
			return false

		_undo_history.push(state)

		body.pos = push_to
		state.player_pos = next_pos
		moved_body_id = body.id
		state.move_count += 1
	else:
		_undo_history.push(state)
		state.player_pos = next_pos
		state.move_count += 1

	if moved_body_id != -1:
		_magnet_resolver.apply_after_push(state, moved_body_id, dir)

	state.cleared = _win_checker.is_cleared(state)
	return true
