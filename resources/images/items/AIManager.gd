extends Node

signal story_generated(story_content: String)
signal clue_generated(clue_data: Dictionary)
signal map_generated(map_data: Dictionary)

enum AIProvider { OPENAI, LOCAL_MODEL, OFFLINE }

var current_provider: AIProvider = AIProvider.OFFLINE
var openai_api_key: String = ""
var model_name: String = "gpt-3.5-turbo"
var game_context: Dictionary = {}

func _ready():
	print("[AI Manager] Initialized")

func generate_story(keywords: Array, story_type: String = "main"):
	# 离线后备故事生成
	var fallback_story = {
		"story_text": "在这个神秘的" + str(keywords) + "中，你感受到了不寻常的氛围...",
		"choices": [
			{"id": 1, "text": "仔细观察周围", "consequence": "发现隐藏线索"},
			{"id": 2, "text": "寻找出口", "consequence": "探索新区域"}
		],
		"hidden_clues": ["神秘符号", "古老文字"],
		"mood": "神秘"
	}
	story_generated.emit(JSON.stringify(fallback_story))

func generate_clue(context: Dictionary):
	var fallback_clue = {
		"clue_name": "重要线索",
		"description": "一个包含重要信息的神秘物品",
		"hidden_meaning": "这可能是解开谜题的关键",
		"related_keywords": ["谜题", "关键", "秘密"]
	}
	clue_generated.emit(fallback_clue)

func update_context(key: String, value):
	game_context[key] = value
