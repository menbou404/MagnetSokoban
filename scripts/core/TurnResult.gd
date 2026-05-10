class_name TurnResult
extends RefCounted

const ActionEventScript := preload("res://scripts/core/ActionEvent.gd")

var events: Array[ActionEventScript] = []
var did_change_state := false
var did_clear := false
var move_count_after := 0
var turn_id := 0

var _next_phase := 1


func add_event(event: ActionEventScript) -> void:
	events.append(event)
	if event.phase >= _next_phase:
		_next_phase = event.phase + 1


func allocate_phase() -> int:
	var phase := _next_phase
	_next_phase += 1
	return phase


func add_turn_end_event() -> void:
	add_event(ActionEventScript.turn_end(
		allocate_phase(),
		did_clear,
		move_count_after
	))
