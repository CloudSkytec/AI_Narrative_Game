# res://scripts/GameState.gd
extends Node

# 运行期状态
var current_keywords: Array[String] = []
var current_story: Dictionary = {}   # { "modules": [ {...}, ... ], "ending": "" }
var current_module_index: int = 0

# 例：是否已完成、难度、玩家名等也可放这里
var player_name := "Player"

func start_new_story(keywords: Array[String]) -> void:
	current_keywords = keywords.duplicate()
	current_story = {} 
	current_module_index = 0
	# 在这里触发 AI 生成完整故事（如果你使用 HTTPRequest 调用外部 API）
	# 亦可先用本地占位生成，方便离线调试
	_mock_build_story_from_keywords()  # 替换为真实AI流程

func _mock_build_story_from_keywords():
	# 简化：把关键词组合成三段“模块”
	var k := ", ".join(current_keywords)
	current_story = {
		"modules": [
			{"title":"序章","text":"基于关键词("+k+")，主角收到一封神秘来信...","choices":["追查","无视"]},
			{"title":"中章","text":"线索指向一座火山岛，冰山记录揭示旧日秘密...","choices":["潜入","撤退"]},
			{"title":"终章","text":"真相浮现，傲慢与懒惰造成的悲剧如何收场？","choices":["救赎","复仇"]}
		],
		"ending": ""
	}

func get_current_module() -> Dictionary:
	if current_story.has("modules") and current_module_index < current_story["modules"].size():
		return current_story["modules"][current_module_index]
	return {}

func apply_choice(choice_idx: int) -> void:
	# 根据选择推进；真实项目里可把选择写回“因果状态机”
	current_module_index += 1
	if current_module_index >= current_story["modules"].size():
		current_story["ending"] = "根据你的抉择，故事在此告一段落。"
		# 结束后可回主菜单或生成 AI 画作

func to_dict() -> Dictionary:
	return {
		"current_keywords": current_keywords,
		"current_story": current_story,
		"current_module_index": current_module_index,
		"player_name": player_name
	}

func from_dict(d: Dictionary) -> void:
	current_keywords = d.get("current_keywords", [])
	current_story = d.get("current_story", {})
	current_module_index = int(d.get("current_module_index", 0))
	player_name = d.get("player_name", "Player")

func save_game(slot: String = "slot1.json") -> bool:
	return SaveSystem.save(slot, to_dict())

func load_game(slot: String = "slot1.json") -> bool:
	var d := SaveSystem.load(slot)
	if d.is_empty(): return false
	from_dict(d)
	return true
