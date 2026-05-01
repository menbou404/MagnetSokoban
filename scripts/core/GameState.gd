class_name GameState
extends RefCounted

const POLE_N := "N"
const POLE_S := "S"

var board_size := Vector2i.ZERO
var walls := {}
var goals := {}

var boxes: Array[Vector2i] = []
var box_poles: Array[String] = []

var player := Vector2i.ZERO
var move_count := 0
var cleared := false


func snapshot() -> Dictionary:
	return {
		"player": player,
		"boxes": boxes.duplicate(),
		"box_poles": box_poles.duplicate(),
		"move_count": move_count,
		"cleared": cleared,
	}


func restore_from_snapshot(state: Dictionary) -> void:
	player = state["player"] as Vector2i

	var restored_boxes: Array = (state["boxes"] as Array).duplicate()
	boxes.clear()
	for box_pos in restored_boxes:
		boxes.append(box_pos as Vector2i)

	var restored_poles: Array = (state["box_poles"] as Array).duplicate()
	box_poles.clear()
	for pole in restored_poles:
		box_poles.append(pole as String)

	move_count = state["move_count"] as int
	cleared = state["cleared"] as bool


func get_box_index_at(pos: Vector2i) -> int:
	return boxes.find(pos)


func is_inside_board(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < board_size.x and pos.y >= 0 and pos.y < board_size.y


func is_cell_free(pos: Vector2i, ignore_box_index: int = -1) -> bool:
	if not is_inside_board(pos):
		return false

	if walls.has(pos):
		return false

	for i in range(boxes.size()):
		if i == ignore_box_index:
			continue
		if boxes[i] == pos:
			return false

	return true