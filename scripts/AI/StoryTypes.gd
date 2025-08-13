# res://scripts/StoryTypes.gd
extends Resource
class_name StoryValidator

static func is_valid_story(d: Dictionary) -> bool:
	if not d.has("modules"): return false
	if typeof(d["modules"]) != TYPE_ARRAY: return false
	for m in d["modules"]:
		if typeof(m) != TYPE_DICTIONARY: return false
		if not m.has("title") or not m.has("text"): return false
		if not m.has("choices"): m["choices"] = []
	return true
