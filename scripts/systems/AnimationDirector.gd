class_name AnimationDirector
extends RefCounted

const ActionEventScript := preload("res://scripts/core/ActionEvent.gd")
const TurnResultScript := preload("res://scripts/core/TurnResult.gd")

signal playback_finished(turn_result: TurnResultScript)


func play_turn(turn_result: TurnResultScript, board_view: BoardView) -> void:
	if turn_result == null or board_view == null:
		return

	var index := 0
	while index < turn_result.events.size():
		var phase := turn_result.events[index].phase
		var phase_events: Array[ActionEventScript] = []

		while index < turn_result.events.size() and turn_result.events[index].phase == phase:
			phase_events.append(turn_result.events[index])
			index += 1

		await _play_phase(phase_events, board_view)

	playback_finished.emit(turn_result)


func _play_phase(phase_events: Array[ActionEventScript], board_view: BoardView) -> void:
	var player_move := {}
	var body_moves: Array[Dictionary] = []
	var magnet_triggers: Array[Dictionary] = []
	var movement_duration := 0.0
	var trigger_duration := 0.0

	for event in phase_events:
		match event.type:
			ActionEventScript.TYPE_PLAYER_MOVE:
				player_move = {
					"from": event.from_cell,
					"to": event.to_cell,
					"direction": event.direction,
				}
				movement_duration = maxf(movement_duration, event.duration)
			ActionEventScript.TYPE_BODY_MOVE:
				body_moves.append({
					"body_id": event.body_id,
					"from": event.from_cell,
					"to": event.to_cell,
					"direction": event.direction,
				})
				movement_duration = maxf(movement_duration, event.duration)
			ActionEventScript.TYPE_SIMULTANEOUS_MOVE:
				var moves := event.meta.get("moves", []) as Array
				for move in moves:
					body_moves.append(move as Dictionary)
				movement_duration = maxf(movement_duration, event.duration)
			ActionEventScript.TYPE_MAGNET_TRIGGER:
				magnet_triggers.append({
					"body_id": event.body_id,
					"direction": event.direction,
					"target_id": event.meta.get("target_id", -1),
					"source_face": event.meta.get("source_face", event.direction),
					"target_face": event.meta.get("target_face", -event.direction),
					"interaction_type": event.meta.get("interaction_type", ""),
				})
				trigger_duration = maxf(trigger_duration, event.duration)
			ActionEventScript.TYPE_TURN_END:
				pass

	if not magnet_triggers.is_empty():
		await board_view.show_magnet_triggers(magnet_triggers, trigger_duration)

	if not player_move.is_empty() or not body_moves.is_empty():
		await board_view.animate_movement_batch(player_move, body_moves, movement_duration)
