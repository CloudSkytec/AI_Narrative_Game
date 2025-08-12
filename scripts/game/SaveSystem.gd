# res://scripts/SaveSystem.gd
extends Node
class_name SaveSystem

const SAVE_DIR := "user://saves/"
const DEFAULT_SLOT := "slot1.json"

static func ensure_dir():
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		var d := DirAccess.open("user://")
		d.make_dir_recursive("saves")

static func save(slot_name: String, data: Dictionary) -> bool:
	ensure_dir()
	var path := SAVE_DIR + slot_name
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()
		return true
	return false

static func load(slot_name: String) -> Dictionary:
	var path := SAVE_DIR + slot_name
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		var txt := f.get_as_text()
		f.close()
		var p := JSON.parse_string(txt)
		return p if typeof(p) == TYPE_DICTIONARY else {}
	return {}
