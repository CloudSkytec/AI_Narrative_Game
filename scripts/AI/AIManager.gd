extends Node
class_name NarrativeAI

# AI叙事引擎核心类
# 基于深度学习的故事生成系统

signal story_generated(story_data)
signal dialogue_updated(character, dialogue)

var openai_api_key: String = ""
var current_story_context: Dictionary = {}
var character_profiles: Dictionary = {}
var narrative_templates: Array = []

# 初始化AI系统
func _ready():
	load_character_profiles()
	load_narrative_templates()
	setup_ai_connection()

# 加载角色配置文件
func load_character_profiles():
	var file = FileAccess.open("res://data/character_profiles.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			character_profiles = json.data
		file.close()

# 生成故事情节
func generate_story_segment(player_choice: String, current_context: Dictionary):
	var prompt = build_story_prompt(player_choice, current_context)
	var ai_response = await call_openai_api(prompt)
	
	if ai_response.success:
		var story_data = parse_story_response(ai_response.content)
		current_story_context.merge(story_data)
		story_generated.emit(story_data)
		return story_data
	else:
		push_error("AI故事生成失败: " + ai_response.error)
		return null

# 构建故事提示词
func build_story_prompt(player_choice: String, context: Dictionary) -> String:
	var prompt = "基于以下上下文和玩家选择，生成下一段故事情节：\n"
	prompt += "当前场景: " + context.get("scene", "未知场景") + "\n"
	prompt += "玩家选择: " + player_choice + "\n"
	prompt += "故事风格: " + context.get("style", "冒险") + "\n"
	prompt += "请生成200字以内的故事段落，包含对话和场景描述。"
	return prompt

# 调用OpenAI API
func call_openai_api(prompt: String) -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + openai_api_key
	]
	
	var request_body = {
		"model": "gpt-3.5-turbo",
		"messages": [
			{"role": "system", "content": "你是一个专业的游戏叙事AI助手"},
			{"role": "user", "content": prompt}
		],
		"max_tokens": 500,
		"temperature": 0.7
	}
	
	var json_string = JSON.stringify(request_body)
	var response = await http_request.request_completed
	
	http_request.queue_free()
	
	if response[1] == 200:
		var json = JSON.new()
		var parse_result = json.parse(response[3].get_string_from_utf8())
		if parse_result == OK:
			return {
				"success": true,
				"content": json.data.choices[0].message.content
			}
	
	return {"success": false, "error": "API调用失败"}

# 解析AI响应
func parse_story_response(content: String) -> Dictionary:
	# 简化的解析逻辑，实际应用中需要更复杂的NLP处理
	var story_data = {
		"narrative": content,
		"timestamp": Time.get_unix_time_from_system(),
		"emotional_tone": analyze_emotional_tone(content)
	}
	return story_data

# 情感分析
func analyze_emotional_tone(text: String) -> String:
	# 简化的情感分析，实际应用中应使用专门的NLP库
	var positive_words = ["快乐", "兴奋", "希望", "成功", "美好"]
	var negative_words = ["悲伤", "恐惧", "失望", "危险", "困难"]
	
	var positive_count = 0
	var negative_count = 0
	
	for word in positive_words:
		if text.find(word) != -1:
			positive_count += 1
	
	for word in negative_words:
		if text.find(word) != -1:
			negative_count += 1
	
	if positive_count > negative_count:
		return "positive"
	elif negative_count > positive_count:
		return "negative"
	else:
		return "neutral"
