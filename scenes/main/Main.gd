extends Node2D

var levels: Array[Dictionary] = [
	{
		"name": "01 Basic Push",
		"purpose": "basic move, box push, clear, undo, reset",
		"rows": [
			"########",
			"#......#",
			"#.P>G..#",
			"#......#",
			"########",
		],
	},
	{
		"name": "02 Attraction",
		"purpose": "equal strength attraction and simultaneous one-step movement",
		"rows": [
			"###########",
			"#.........#",
			"#.P>..G>..#",
			"#.........#",
			"###########",
		],
	},
	{
		"name": "03 Repulsion",
		"purpose": "repulsion and stronger source priority",
		"rows": [
			"###########",
			"#.........#",
			"#.P4.<G...#",
			"#.........#",
			"###########",
		],
	},
	{
		"name": "04 Chain",
		"purpose": "magnet chain from moved body to next target",
		"rows": [
			"############",
			"#..........#",
			"#.P4...4<G.#",
			"#..........#",
			"############",
		],
	},
	{
		"name": "05 Direction Check",
		"purpose": "up/down/left/right facing markers and strength display",
		"rows": [
			"###########",
			"#...^.....#",
			"#.P>..G<..#",
			"#...v.....#",
			"###########",
		],
	},
]

var level_index := 0
var original_level_rows: Array[String] = []

@onready var board_view: BoardView = $BoardView

var game_state: GameState
var level_loader := LevelLoader.new()
var undo_history := UndoHistory.new()
var win_checker := WinChecker.new()
var magnet_resolver := MagnetResolver.new()
var move_resolver: MoveResolver


func _ready() -> void:
	move_resolver = MoveResolver.new(magnet_resolver, win_checker, undo_history)
	_load_current_level()


func _unhandled_input(event: InputEvent) -> void:
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


func _load_level(rows: Array[String]) -> void:
	undo_history.clear()
	game_state = level_loader.load_from_rows(rows)
	game_state.cleared = win_checker.is_cleared(game_state)

	_resize_window()
	board_view.set_state(game_state)
	_print_level_status()


func _resize_window() -> void:
	var size_px := Vector2i(
		game_state.board_size.x * board_view.cell_size,
		game_state.board_size.y * board_view.cell_size
	)
	get_window().size = size_px


func _try_move(dir: Vector2i) -> void:
	var moved := move_resolver.try_move(game_state, dir)
	if not moved:
		return

	board_view.set_state(game_state)

	if game_state.cleared:
		print("CLEAR: moves = %d" % game_state.move_count)
		print("Press N for next level, R to reset, Z to undo.")


func _undo() -> void:
	if not undo_history.can_undo():
		return

	game_state.restore_from_snapshot(undo_history.pop())
	board_view.set_state(game_state)


func _reset_level() -> void:
	_load_level(original_level_rows)


func _load_current_level() -> void:
	original_level_rows = _get_current_level_rows()
	_load_level(original_level_rows)


func _load_next_level() -> void:
	level_index = (level_index + 1) % levels.size()
	_load_current_level()


func _load_previous_level() -> void:
	level_index = (level_index - 1 + levels.size()) % levels.size()
	_load_current_level()


func _get_current_level_rows() -> Array[String]:
	var rows: Array[String] = []
	var source_rows := levels[level_index]["rows"] as Array
	for row in source_rows:
		rows.append(row as String)
	return rows


func _print_level_status() -> void:
	var level_name := levels[level_index]["name"] as String
	var purpose := levels[level_index]["purpose"] as String
	print("LEVEL %d/%d: %s" % [level_index + 1, levels.size(), level_name])
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
