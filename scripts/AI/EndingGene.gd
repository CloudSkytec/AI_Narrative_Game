## Ending.gd
extends Control

@onready var story_view: RichTextLabel = $VBoxContainer/StoryText
@onready var image_view: TextureRect = $VBoxContainer/Art
@onready var generate_btn: Button = $VBoxContainer/GenerateArt
@onready var back_btn: Button = $VBoxContainer/BackToMenu

func _ready():
	story_view.text = GameState.full_story
	generate_btn.pressed.connect(_on_generate_art)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))

func _on_generate_art():
	# 调用 AI 绘画 API
	var art_prompt = "根据以下故事绘制一幅氛围图：" + GameState.full_story
	# 请替换为实际的绘图请求；示例使用伪函数
	_call_image_api(art_prompt)

func _call_image_api(prompt: String):
	# 类似于故事请求，构造 HTTPRequest 发送到图像生成服务
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, code, headers, body):
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var data = json.get_data()
		# 假设返回字段为 url
		var url = data["data"][0]["url"]
		# 使用 ImageTexture 加载网络图像
		var img = Image.new()
		img.load_from_file(url)  # 若 Godot 无法直接加载远程图片，可先下载到缓存
		var tex = ImageTexture.create_from_image(img)
		image_view.texture = tex)
	var headers = ["Content-Type: application/json", "Authorization: Bearer YOUR_API_KEY"]
	var body_dict = {"prompt": prompt, "n": 1, "size": "512x512"}
	var body = JSON.new().stringify(body_dict)
	http.request("https://api.ai-draw.com/v1/generate", headers, HTTPClient.METHOD_POST, body)
