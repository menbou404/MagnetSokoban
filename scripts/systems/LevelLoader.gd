class_name LevelLoader
extends RefCounted


func load_from_rows(rows: Array[String]) -> GameState:
	var state := GameState.new()

	state.board_size = Vector2i(rows[0].length(), rows.size())

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
					state.player = pos
				"+":
					state.goals[pos] = true
					state.player = pos
				"N":
					state.boxes.append(pos)
					state.box_poles.append(GameState.POLE_N)
				"S":
					state.boxes.append(pos)
					state.box_poles.append(GameState.POLE_S)
				"n":
					state.goals[pos] = true
					state.boxes.append(pos)
					state.box_poles.append(GameState.POLE_N)
				"s":
					state.goals[pos] = true
					state.boxes.append(pos)
					state.box_poles.append(GameState.POLE_S)
				_:
					pass

	return state