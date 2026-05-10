extends Node2D

const AnimationDirectorScript := preload("res://scripts/systems/AnimationDirector.gd")

var level_index := 0
var level_entries: Array[Dictionary] = []

@onready var board_view: BoardView = $BoardView

var game_state: GameState
var level_loader := LevelLoader.new()
var undo_history := UndoHistory.new()
var win_checker := WinChecker.new()
var magnet_resolver := MagnetResolver.new()
var animation_director := AnimationDirectorScript.new()
var move_resolver: MoveResolver
var is_animating := false


func _ready() -> void:
	move_resolver = MoveResolver.new(magnet_resolver, win_checker, undo_history)
	level_entries = level_loader.get_level_entries("test")
	_load_current_level()


func _unhandled_input(event: InputEvent) -> void:
	if is_animating:
		return

	if event.is_action_pressed("move_left"):
		_try_move(Vector2i.LEFT)
	elif event.is_action_pressed("move_right"):
		_try_move(Vector2i.RIGHT)
	elif event.is_action_pressed("move_up"):
		_try_move(Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		_try_move(Vector2i.DOWN)
	elif event.is_action_pressed("undo"):
		_undo()
	elif event.is_action_pressed("reset"):
		_reset_level()
	elif _is_next_level_event(event):
		_load_next_level()
	elif _is_previous_level_event(event):
		_load_previous_level()


func _load_level(entry: Dictionary) -> void:
	undo_history.clear()
	game_state = level_loader.load_state_from_entry(entry)
	if game_state == null:
		push_error("Failed to load level: %s" % str(entry))
		return

	game_state.cleared = win_checker.is_cleared(game_state)

	_resize_window()
	board_view.set_state(game_state)
	_print_level_status(entry)


func _resize_window() -> void:
	var size_px := Vector2i(
		game_state.board_size.x * board_view.cell_size,
		game_state.board_size.y * board_view.cell_size
	)
	get_window().size = size_px


func _try_move(dir: Vector2i) -> void:
	var turn_result := move_resolver.try_move(game_state, dir)
	if turn_result == null:
		return

	is_animating = true
	await animation_director.play_turn(turn_result, board_view)
	board_view.set_state(game_state)
	is_animating = false

	if game_state.cleared:
		print("CLEAR: moves = %d" % game_state.move_count)
		print("Press N for next level, R to reset, Z to undo.")


func _undo() -> void:
	if not undo_history.can_undo():
		return

	game_state.restore_from_snapshot(undo_history.pop())
	board_view.set_state(game_state)


func _reset_level() -> void:
	_load_current_level()


func _load_current_level() -> void:
	if level_entries.is_empty():
		push_error("No level entries found.")
		return

	level_index = clampi(level_index, 0, level_entries.size() - 1)
	_load_level(level_entries[level_index])


func _load_next_level() -> void:
	if level_entries.is_empty():
		return

	level_index = (level_index + 1) % level_entries.size()
	_load_current_level()


func _load_previous_level() -> void:
	if level_entries.is_empty():
		return

	level_index = (level_index - 1 + level_entries.size()) % level_entries.size()
	_load_current_level()


func _print_level_status(entry: Dictionary) -> void:
	var level_name := entry.get("name", entry.get("id", "")) as String
	var purpose := entry.get("purpose", "") as String
	print("LEVEL %d/%d: %s" % [level_index + 1, level_entries.size(), level_name])
	print("Purpose: %s" % purpose)
	print("Controls: arrows/WASD move, Z undo, R reset, N next, B previous.")


func _is_next_level_event(event: InputEvent) -> bool:
	var key_event := event as InputEventKey
	if key_event == null:
		return false
	return key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_N


func _is_previous_level_event(event: InputEvent) -> bool:
	var key_event := event as InputEventKey
	if key_event == null:
		return false
	return key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_B
