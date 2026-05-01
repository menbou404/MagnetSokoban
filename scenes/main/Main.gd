extends Node2D

var level_rows: Array[String] = [
	"###########",
	"#.........#",
	"#.P.N..NG.#",
	"#.........#",
	"###########",
]

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
	original_level_rows = level_rows.duplicate()
	_load_level(original_level_rows)


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


func _load_level(rows: Array[String]) -> void:
	undo_history.clear()
	game_state = level_loader.load_from_rows(rows)
	game_state.cleared = win_checker.is_cleared(game_state)

	_resize_window()
	board_view.set_state(game_state)


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


func _undo() -> void:
	if not undo_history.can_undo():
		return

	game_state.restore_from_snapshot(undo_history.pop())
	board_view.set_state(game_state)


func _reset_level() -> void:
	_load_level(original_level_rows)