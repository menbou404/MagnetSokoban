class_name WinChecker
extends RefCounted


func is_cleared(state: GameState) -> bool:
	if state.goals.size() == 0:
		return false

	for goal_pos in state.goals.keys():
		if not state.boxes.has(goal_pos as Vector2i):
			return false

	return true