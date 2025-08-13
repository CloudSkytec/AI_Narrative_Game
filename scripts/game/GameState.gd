# res://scripts/GameState.gd
extends Node

signal module_changed(new_index: int)
signal story_changed()
signal story_finished(ending: String)

var current_keywords: Array[String] = []
var current_story: Dictionary = {}
var current_module_index: int = 0

func start_new_story(keywords: Array[String]) -> void:
	current_keywords = keywords.duplicate()
	current_story = {}
	current_module_index = 0
	_mock_build_story_from_keywords()
	emit_signal("story_changed")
	emit_signal("module_changed", current_module_index)

func _mock_build_story_from_keywords():
	var k := ", ".join(current_keywords)
	current_story = {
		"modules": [
			{"title":"序章","text":"基于关键词("+k+")，主角收到一封神秘来信...","choices":["追查","无视"]},
			{"title":"中章","text":"线索指向火山岛，冰山手稿揭示旧日秘密...","choices":["潜入","撤退"]},
			{"title":"终章","text":"真相浮现，抉择将决定结局。","choices":[]}
		],
		"ending": ""
	}

func get_current_module() -> Dictionary:
	if current_story.has("modules") and current_module_index < current_story["modules"].size():
		return current_story["modules"][current_module_index]
	return {}

func apply_choice(choice_idx: int) -> void:
	current_module_index += 1
	if current_module_index >= current_story.get("modules", []).size():
		var end := "你的选择塑造了结局。/ Your choices shaped the ending."
		current_story["ending"] = end
		emit_signal("story_finished", end)
		emit_signal("story_changed")
	emit_signal("module_changed", current_module_index)

func to_dict() -> Dictionary:
	return {
		"current_keywords": current_keywords,
		"current_story": current_story,
		"current_module_index": current_module_index
	}

func from_dict(d: Dictionary) -> void:
	current_keywords = d.get("current_keywords", [])
	current_story = d.get("current_story", {})
	current_module_index = int(d.get("current_module_index", 0))
	emit_signal("story_changed")
	emit_signal("module_changed", current_module_index)

func save_game(slot: String = "slot1.json") -> bool:
	return SaveSystem.save(slot, to_dict())

func load_game(slot: String = "slot1.json") -> bool:
	var d := SaveSystem.load(slot)
	if d.is_empty(): return false
	from_dict(d)
	return true
