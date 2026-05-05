class_name LevelLoader
extends RefCounted

const MagneticBodyStateScript := preload("res://scripts/core/MagneticBodyState.gd")
const DEFAULT_BOX_STRENGTH := 3


func load_from_rows(rows: Array[String]) -> GameState:
	var state := GameState.new()
	var next_body_id := 1

	state.board_size = Vector2i(_get_max_row_width(rows), rows.size())

	for y in range(rows.size()):
		var row := rows[y]
		for x in range(row.length()):
			var ch := row.substr(x, 1)
			var pos := Vector2i(x, y)

			match ch:
				"#":
					state.walls[pos] = true
				"G":
					state.goals[pos] = true
				"P":
					state.player_pos = pos
				"+":
					state.goals[pos] = true
					state.player_pos = pos
				"N":
					state.bodies.append(_create_box(next_body_id, pos, Vector2i.RIGHT, DEFAULT_BOX_STRENGTH))
					next_body_id += 1
				"S":
					state.bodies.append(_create_box(next_body_id, pos, Vector2i.LEFT, DEFAULT_BOX_STRENGTH))
					next_body_id += 1
				">", "R":
					state.bodies.append(_create_box(next_body_id, pos, Vector2i.RIGHT, DEFAULT_BOX_STRENGTH))
					next_body_id += 1
				"<", "L":
					state.bodies.append(_create_box(next_body_id, pos, Vector2i.LEFT, DEFAULT_BOX_STRENGTH))
					next_body_id += 1
				"^", "U":
					state.bodies.append(_create_box(next_body_id, pos, Vector2i.UP, DEFAULT_BOX_STRENGTH))
					next_body_id += 1
				"v", "V", "D":
					state.bodies.append(_create_box(next_body_id, pos, Vector2i.DOWN, DEFAULT_BOX_STRENGTH))
					next_body_id += 1
				"1", "2", "3", "4", "5":
					state.bodies.append(_create_box(next_body_id, pos, Vector2i.RIGHT, ch.to_int()))
					next_body_id += 1
				"n":
					state.goals[pos] = true
					state.bodies.append(_create_box(next_body_id, pos, Vector2i.RIGHT, DEFAULT_BOX_STRENGTH))
					next_body_id += 1
				"s":
					state.goals[pos] = true
					state.bodies.append(_create_box(next_body_id, pos, Vector2i.LEFT, DEFAULT_BOX_STRENGTH))
					next_body_id += 1
				_:
					pass

	return state


func _create_box(
	body_id: int,
	pos: Vector2i,
	facing: Vector2i,
	strength: int
) -> MagneticBodyStateScript:
	return MagneticBodyStateScript.new(
		body_id,
		MagneticBodyStateScript.KIND_BOX,
		pos,
		facing,
		strength,
		true
	)


func _get_max_row_width(rows: Array[String]) -> int:
	var width := 0
	for row in rows:
		width = max(width, row.length())
	return width
