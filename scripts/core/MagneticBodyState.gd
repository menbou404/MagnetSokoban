class_name MagneticBodyState
extends RefCounted

const KIND_BOX := "box"
const KIND_FIXED_MAGNET := "fixed_magnet"

const POLE_N := "N"
const POLE_S := "S"

var id := 0
var kind := KIND_BOX
var pos := Vector2i.ZERO
var facing := Vector2i.RIGHT
var strength := 3
var movable := true


func _init(
	body_id: int = 0,
	body_kind: String = KIND_BOX,
	body_pos: Vector2i = Vector2i.ZERO,
	body_facing: Vector2i = Vector2i.RIGHT,
	body_strength: int = 3,
	body_movable: bool = true
) -> void:
	id = body_id
	kind = body_kind
	pos = body_pos
	facing = body_facing
	strength = body_strength
	movable = body_movable


func snapshot() -> Dictionary:
	return {
		"id": id,
		"kind": kind,
		"pos": pos,
		"facing": facing,
		"strength": strength,
		"movable": movable,
	}


func restore_from_snapshot(state: Dictionary) -> void:
	id = state["id"] as int
	kind = state["kind"] as String
	pos = state["pos"] as Vector2i
	facing = state["facing"] as Vector2i
	strength = state["strength"] as int
	movable = state["movable"] as bool


static func from_snapshot(state: Dictionary) -> RefCounted:
	var body := preload("res://scripts/core/MagneticBodyState.gd").new()
	body.restore_from_snapshot(state)
	return body


func get_pole_on_face(face_direction: Vector2i) -> String:
	if facing == Vector2i.RIGHT:
		if face_direction == Vector2i.LEFT:
			return POLE_N
		if face_direction == Vector2i.RIGHT:
			return POLE_S
	elif facing == Vector2i.LEFT:
		if face_direction == Vector2i.LEFT:
			return POLE_S
		if face_direction == Vector2i.RIGHT:
			return POLE_N
	elif facing == Vector2i.UP:
		if face_direction == Vector2i.UP:
			return POLE_N
		if face_direction == Vector2i.DOWN:
			return POLE_S
	elif facing == Vector2i.DOWN:
		if face_direction == Vector2i.UP:
			return POLE_S
		if face_direction == Vector2i.DOWN:
			return POLE_N

	# TODO: PHASE_03 以降で、棒磁石の軸と直交する面の扱いを確定する。
	return ""


func get_opposite_face(face_direction: Vector2i) -> Vector2i:
	return -face_direction


func is_fixed_magnet() -> bool:
	return kind == KIND_FIXED_MAGNET
