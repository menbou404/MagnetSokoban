class_name UndoHistory
extends RefCounted

var _stack: Array[Dictionary] = []


func clear() -> void:
	_stack.clear()


func push(state: GameState) -> void:
	_stack.append(state.snapshot())


func can_undo() -> bool:
	return not _stack.is_empty()


func pop() -> Dictionary:
	if _stack.is_empty():
		return {}
	return _stack.pop_back() as Dictionary