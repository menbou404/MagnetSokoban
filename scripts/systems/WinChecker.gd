class_name WinChecker
extends RefCounted


func is_cleared(state: GameState) -> bool:
	if state.goals.size() == 0:
		return false

	for goal_pos in state.goals.keys():
		if state.get_body_at(goal_pos as Vector2i) == null:
			return false

	return true
