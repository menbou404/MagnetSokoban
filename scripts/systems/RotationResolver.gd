class_name RotationResolver
extends RefCounted


func apply_rotation_tiles(state: GameState, moved_bodies: Array) -> void:
	for body in moved_bodies:
		var moved_body := body as MagneticBodyState
		if moved_body == null:
			continue

		if not moved_body.movable:
			continue

		var rotation := state.get_rotation_at(moved_body.pos)
		if rotation == "":
			continue

		moved_body.facing = rotate_facing(moved_body.facing, rotation)


func rotate_facing(facing: Vector2i, rotation: String) -> Vector2i:
	if rotation == "right":
		if facing == Vector2i.UP:
			return Vector2i.RIGHT
		if facing == Vector2i.RIGHT:
			return Vector2i.DOWN
		if facing == Vector2i.DOWN:
			return Vector2i.LEFT
		if facing == Vector2i.LEFT:
			return Vector2i.UP

	if rotation == "left":
		if facing == Vector2i.UP:
			return Vector2i.LEFT
		if facing == Vector2i.LEFT:
			return Vector2i.DOWN
		if facing == Vector2i.DOWN:
			return Vector2i.RIGHT
		if facing == Vector2i.RIGHT:
			return Vector2i.UP

	return facing
