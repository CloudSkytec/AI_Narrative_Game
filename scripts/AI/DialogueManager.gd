extends Node
class_name DialogueManager

# 动态对话系统
# 支持上下文感知的对话生成和分支叙事管理

signal dialogue_started(character_name)
signal dialogue_choice_presented(choices)
signal dialogue_ended()

var current_character: String = ""
var dialogue_history: Array = []
var character_states: Dictionary = {}
var narrative_ai: NarrativeAI

func _ready():
	narrative_ai = get_node("/root/NarrativeAI")

# 开始对话
func start_dialogue(character_name: String, context: Dictionary = {}):
	current_character = character_name
	var character_profile = get_character_profile(character_name)
	
	# 生成开场对话
	var opening_prompt = build_opening_prompt(character_profile, context)
	var ai_response = await narrative_ai.call_openai_api(opening_prompt)
	
	if ai_response.success:
		var dialogue_data = parse_dialogue_response(ai_response.content)
		present_dialogue(dialogue_data)
		dialogue_started.emit(character_name)
	else:
		push_error("对话生成失败")

# 处理玩家选择
func process_player_choice(choice_text: String):
	# 记录选择历史
	dialogue_history.append({
		"type": "player_choice",
		"content": choice_text,
		"timestamp": Time.get_unix_time_from_system()
	})
	
	# 生成NPC响应
	var response_prompt = build_response_prompt(choice_text)
	var ai_response = await narrative_ai.call_openai_api(response_prompt)
	
	if ai_response.success:
		var response_data = parse_dialogue_response(ai_response.content)
		present_dialogue(response_data)
		
		# 更新角色状态
		update_character_state(current_character, choice_text)
	else:
		push_error("响应生成失败")

# 构建响应提示词
func build_response_prompt(player_choice: String) -> String:
	var character_profile = get_character_profile(current_character)
	var recent_history = get_recent_dialogue_history(5)
	
	var prompt = "角色信息:\n"
	prompt += "姓名: " + character_profile.name + "\n"
	prompt += "性格: " + character_profile.personality + "\n"
	prompt += "背景: " + character_profile.background + "\n\n"
	
	prompt += "对话历史:\n"
	for entry in recent_history:
		prompt += entry.type + ": " + entry.content + "\n"
	
	prompt += "\n玩家刚刚说: " + player_choice + "\n"
	prompt += "请生成这个角色的自然响应，保持角色一致性。"
	
	return prompt

# 解析对话响应
func parse_dialogue_response(content: String) -> Dictionary:
	var dialogue_data = {
		"character": current_character,
		"text": content,
		"emotion": analyze_emotion(content),
		"choices": extract_choices(content)
	}
	
	return dialogue_data

# 提取选择选项
func extract_choices(content: String) -> Array:
	var choices = []
	
	# 简化的选择提取逻辑
	# 实际应用中应使用更复杂的NLP处理
	var choice_patterns = ["1.", "2.", "3.", "选择:", "回答:"]
	
	for pattern in choice_patterns:
		var index = content.find(pattern)
		if index != -1:
			var choice_text = content.substr(index + pattern.length()).strip_edges()
			if choice_text.length() > 0:
				choices.append(choice_text)
	
	# 如果没有找到明确的选择，生成默认选项
	if choices.is_empty():
		choices = generate_default_choices()
	
	return choices

# 生成默认选择
func generate_default_choices() -> Array:
	return [
		"继续对话",
		"询问更多信息",
		"结束对话"
	]

# 更新角色状态
func update_character_state(character_name: String, player_choice: String):
	if not character_states.has(character_name):
		character_states[character_name] = {
			"relationship": 0,
			"trust": 0,
			"mood": "neutral"
		}
	
	var state = character_states[character_name]
	
	# 基于玩家选择调整角色状态
	if is_positive_choice(player_choice):
		state.relationship += 1
		state.trust += 1
		state.mood = "happy"
	elif is_negative_choice(player_choice):
		state.relationship -= 1
		state.trust -= 1
		state.mood = "sad"
	
	character_states[character_name] = state

# 获取角色档案
func get_character_profile(character_name: String) -> Dictionary:
	return narrative_ai.character_profiles.get(character_name, {
		"name": character_name,
		"personality": "友好",
		"background": "普通村民"
	})
