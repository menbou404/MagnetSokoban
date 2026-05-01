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

	var next_pos := state.player + dir

	if state.walls.has(next_pos):
		return false

	var box_index := state.get_box_index_at(next_pos)
	var moved_box_index := -1

	if box_index != -1:
		var push_to := next_pos + dir

		if not state.is_cell_free(push_to):
			return false

		_undo_history.push(state)

		state.boxes[box_index] = push_to
		state.player = next_pos
		moved_box_index = box_index
		state.move_count += 1
	else:
		_undo_history.push(state)
		state.player = next_pos
		state.move_count += 1

	if moved_box_index != -1:
		_magnet_resolver.apply_after_push(state, moved_box_index, dir)

	state.cleared = _win_checker.is_cleared(state)
	return true