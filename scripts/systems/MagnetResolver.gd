class_name MagnetResolver
extends RefCounted

var magnet_range := 3


func apply_after_push(state: GameState, source_idx: int, dir: Vector2i) -> void:
	var source_pos := state.boxes[source_idx]
	var source_pole := state.box_poles[source_idx]
	var cursor := source_pos + dir

	for _step in range(magnet_range):
		if not state.is_inside_board(cursor):
			return

		if state.walls.has(cursor):
			return

		var target_idx := state.get_box_index_at(cursor)
		if target_idx != -1:
			var target_pole := state.box_poles[target_idx]

			if target_pole == source_pole:
				var repel_to := state.boxes[target_idx] + dir
				if state.is_cell_free(repel_to):
					state.boxes[target_idx] = repel_to
			else:
				var pull_to := state.boxes[target_idx] - dir
				if state.is_cell_free(pull_to, target_idx):
					state.boxes[target_idx] = pull_to

			return

		cursor += dir