class_name LevelLoader
extends RefCounted

const MagneticBodyStateScript := preload("res://scripts/core/MagneticBodyState.gd")
const DEFAULT_BOX_STRENGTH := 3
const DEFAULT_CATALOG_PATH := "res://levels/level_catalog.json"


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
				"]":
					state.rotate_right_tiles[pos] = true
				"[":
					state.rotate_left_tiles[pos] = true
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


func load_level_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open level file: %s" % path)
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid level file JSON: %s" % path)
		return {}

	var level_data := parsed as Dictionary
	if not level_data.has("rows"):
		push_error("Level file has no rows: %s" % path)
		return {}

	level_data["path"] = path
	return level_data


func load_state_from_file(path: String) -> GameState:
	var level_data := load_level_file(path)
	if level_data.is_empty():
		return null

	return load_from_level_data(level_data)


func load_catalog(path: String = DEFAULT_CATALOG_PATH) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open level catalog: %s" % path)
		return {
			"default_group": "test",
			"levels": [],
		}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid level catalog JSON: %s" % path)
		return {
			"default_group": "test",
			"levels": [],
		}

	var catalog := parsed as Dictionary
	if not catalog.has("levels"):
		catalog["levels"] = []
	if not catalog.has("default_group"):
		catalog["default_group"] = "test"

	return catalog


func get_level_entries(group: String = "", catalog_path: String = DEFAULT_CATALOG_PATH) -> Array[Dictionary]:
	var catalog := load_catalog(catalog_path)
	var selected_group := group
	if selected_group == "":
		selected_group = catalog.get("default_group", "test") as String

	var entries: Array[Dictionary] = []
	var source_entries := catalog.get("levels", []) as Array

	for source_entry in source_entries:
		var entry := source_entry as Dictionary
		if entry.is_empty():
			continue

		var entry_group := entry.get("group", "") as String
		if selected_group != "" and entry_group != selected_group:
			continue

		entries.append(_normalize_catalog_entry(entry))

	return entries


func load_level_entry(entry: Dictionary) -> Dictionary:
	if not entry.has("path"):
		push_error("Level entry has no path: %s" % str(entry))
		return {}

	var level_data := load_level_file(entry["path"] as String)
	if level_data.is_empty():
		return {}

	level_data["id"] = level_data.get("id", entry.get("id", ""))
	level_data["name"] = level_data.get("name", entry.get("name", ""))
	level_data["purpose"] = level_data.get("purpose", entry.get("purpose", ""))
	level_data["description"] = level_data.get("description", entry.get("description", ""))
	level_data["tags"] = level_data.get("tags", entry.get("tags", []))
	level_data["group"] = entry.get("group", level_data.get("group", ""))
	return level_data


func load_state_from_entry(entry: Dictionary) -> GameState:
	var level_data := load_level_entry(entry)
	if level_data.is_empty():
		return null

	return load_from_level_data(level_data)


func load_from_level_data(level_data: Dictionary) -> GameState:
	var state := load_from_rows(_rows_from_level_data(level_data))
	var next_body_id := _get_next_body_id(state)
	var fixed_magnets := level_data.get("fixed_magnets", []) as Array

	for source_fixed_magnet in fixed_magnets:
		var fixed_magnet := source_fixed_magnet as Dictionary
		if fixed_magnet.is_empty():
			continue

		var pos := _vector2i_from_array(fixed_magnet.get("pos", []))
		var facing := _facing_from_string(fixed_magnet.get("facing", "right") as String)
		var strength := fixed_magnet.get("strength", DEFAULT_BOX_STRENGTH) as int
		state.bodies.append(_create_fixed_magnet(next_body_id, pos, facing, strength))
		next_body_id += 1

	return state


func load_level_by_id(
	level_id: String,
	catalog_path: String = DEFAULT_CATALOG_PATH
) -> Dictionary:
	var catalog := load_catalog(catalog_path)
	var source_entries := catalog.get("levels", []) as Array

	for source_entry in source_entries:
		var entry := _normalize_catalog_entry(source_entry as Dictionary)
		if entry.get("id", "") == level_id:
			return load_level_entry(entry)

	push_error("Level id not found: %s" % level_id)
	return {}


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


func _create_fixed_magnet(
	body_id: int,
	pos: Vector2i,
	facing: Vector2i,
	strength: int
) -> MagneticBodyStateScript:
	return MagneticBodyStateScript.new(
		body_id,
		MagneticBodyStateScript.KIND_FIXED_MAGNET,
		pos,
		facing,
		strength,
		false
	)


func _get_max_row_width(rows: Array[String]) -> int:
	var width := 0
	for row in rows:
		width = max(width, row.length())
	return width


func _rows_from_level_data(level_data: Dictionary) -> Array[String]:
	var rows: Array[String] = []
	var source_rows := level_data.get("rows", []) as Array

	for row in source_rows:
		rows.append(row as String)

	return rows


func _get_next_body_id(state: GameState) -> int:
	var next_body_id := 1
	for body in state.bodies:
		next_body_id = maxi(next_body_id, body.id + 1)
	return next_body_id


func _vector2i_from_array(value: Variant) -> Vector2i:
	var array_value := value as Array
	if array_value.size() < 2:
		return Vector2i.ZERO

	return Vector2i(array_value[0] as int, array_value[1] as int)


func _facing_from_string(value: String) -> Vector2i:
	match value:
		"left":
			return Vector2i.LEFT
		"up":
			return Vector2i.UP
		"down":
			return Vector2i.DOWN
		_:
			return Vector2i.RIGHT


func _normalize_catalog_entry(entry: Dictionary) -> Dictionary:
	return {
		"id": entry.get("id", ""),
		"name": entry.get("name", entry.get("id", "")),
		"group": entry.get("group", ""),
		"path": entry.get("path", ""),
		"purpose": entry.get("purpose", ""),
		"description": entry.get("description", ""),
		"tags": entry.get("tags", []),
	}
