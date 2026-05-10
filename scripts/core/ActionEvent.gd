class_name ActionEvent
extends RefCounted

const TYPE_PLAYER_MOVE := "player_move"
const TYPE_BODY_MOVE := "body_move"
const TYPE_MAGNET_TRIGGER := "magnet_trigger"
const TYPE_SIMULTANEOUS_MOVE := "simultaneous_move"
const TYPE_TURN_END := "turn_end"

var type := ""
var phase := 0
var body_id := -1
var body_ids: Array[int] = []
var from_cell := Vector2i.ZERO
var to_cell := Vector2i.ZERO
var direction := Vector2i.ZERO
var duration := 0.0
var meta := {}


static func player_move(
	event_phase: int,
	from_pos: Vector2i,
	to_pos: Vector2i,
	move_direction: Vector2i,
	event_duration: float = 0.14
) -> ActionEvent:
	var event := ActionEvent.new()
	event.type = TYPE_PLAYER_MOVE
	event.phase = event_phase
	event.from_cell = from_pos
	event.to_cell = to_pos
	event.direction = move_direction
	event.duration = event_duration
	return event


static func body_move(
	event_phase: int,
	event_body_id: int,
	from_pos: Vector2i,
	to_pos: Vector2i,
	move_direction: Vector2i,
	reason: String,
	event_duration: float = 0.16
) -> ActionEvent:
	var event := ActionEvent.new()
	event.type = TYPE_BODY_MOVE
	event.phase = event_phase
	event.body_id = event_body_id
	event.from_cell = from_pos
	event.to_cell = to_pos
	event.direction = move_direction
	event.duration = event_duration
	event.meta = {
		"reason": reason,
	}
	return event


static func magnet_trigger(
	event_phase: int,
	source_id: int,
	trigger_direction: Vector2i,
	target_id: int,
	interaction_type: String,
	event_duration: float = 0.18
) -> ActionEvent:
	var event := ActionEvent.new()
	event.type = TYPE_MAGNET_TRIGGER
	event.phase = event_phase
	event.body_id = source_id
	event.direction = trigger_direction
	event.duration = event_duration
	event.meta = {
		"target_id": target_id,
		"source_face": trigger_direction,
		"target_face": -trigger_direction,
		"interaction_type": interaction_type,
	}
	return event


static func simultaneous_move(
	event_phase: int,
	moves: Array[Dictionary],
	event_duration: float = 0.16
) -> ActionEvent:
	var event := ActionEvent.new()
	event.type = TYPE_SIMULTANEOUS_MOVE
	event.phase = event_phase
	event.duration = event_duration
	event.meta = {
		"moves": moves,
	}

	for move in moves:
		event.body_ids.append(move["body_id"] as int)

	return event


static func turn_end(
	event_phase: int,
	did_clear: bool,
	move_count_after: int
) -> ActionEvent:
	var event := ActionEvent.new()
	event.type = TYPE_TURN_END
	event.phase = event_phase
	event.meta = {
		"did_clear": did_clear,
		"move_count_after": move_count_after,
	}
	return event
