class_name MagnetResolver
extends RefCounted

var magnet_range := 3


func apply_after_push(state: GameState, source_id: int, dir: Vector2i) -> void:
	var source := state.get_body_by_id(source_id)
	if source == null:
		return

	var source_pole := source.get_pole_on_face(dir)
	if source_pole == "":
		return

	var source_pos := source.pos
	var cursor := source_pos + dir

	for _step in range(magnet_range):
		if not state.is_inside_board(cursor):
			return

		if state.walls.has(cursor):
			return

		var target := state.get_body_at(cursor)
		if target != null:
			var target_pole := target.get_pole_on_face(-dir)
			if target_pole == "":
				return

			if target_pole == source_pole:
				var repel_to := target.pos + dir
				if state.is_cell_free(repel_to):
					target.pos = repel_to
			else:
				var pull_to := target.pos - dir
				if state.is_cell_free(pull_to, target.id):
					target.pos = pull_to

			return

		cursor += dir
