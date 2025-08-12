## StoryManager.gd
extends Node

@onready var http_request: HTTPRequest = HTTPRequest.new()

# 将在 _ready 中添加到场景树
var api_url := "https://api.openai.com/v1/chat/completions"
var api_key := "YOUR_API_KEY"  # 生产环境请加密存储

var story_text := ""

func _ready():
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	_send_story_request(GameState.selected_keywords)

func _send_story_request(words: Array[String]):
	# 构建 prompt：将关键词拼接成提示，引导模型生成故事
	var prompt = "请使用以下关键词创作一个悬疑解谜故事：" + String.join(words, ",")
	var messages = [
		{"role": "system", "content": "你是一个擅长写悬疑故事的小说家。"},
		{"role": "user", "content": prompt}
	]
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer %s" % api_key
	]
	var body_dict = {
		"model": "gpt-4",  # 模型名称可根据需要修改
		"messages": messages,
		"max_tokens": 1024,
		"temperature": 0.7
	}
	var body = JSON.new().stringify(body_dict)
	var err = http_request.request(api_url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		push_error("HTTP request failed")

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		push_error("API error: %s" % response_code)
		return
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()
	# 解析返回的 story
	story_text = data["choices"][0]["message"]["content"]
	GameState.full_story = story_text
	# 切分故事并进入探索界面
	get_tree().change_scene_to_file("res://StoryExplorer.tscn")
