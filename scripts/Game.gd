# res://scripts/Game.gd
extends Control

@onready var story_text: RichTextLabel = $Margin/VBox/StoryText
@onready var choices_box: VBoxContainer = $Margin/VBox/Choices
@onready var chapter_label: Label = $Margin/VBox/Footer/ChapterLabel
@onready var progress: ProgressBar = $Margin/VBox/Footer/ProgressBar
@onready var btn_save: Button = $Margin/VBox/TopBar/SaveButton
@onready var btn_load: Button = $Margin/VBox/TopBar/LoadButton
@onready var btn_menu: Button = $Margin/VBox/TopBar/MenuButton
@onready var toast: Label = $HUD/Toast
@onready var autosave: Timer = $AutoSaveTimer
@onready var ai_request: HTTPRequest = $AIRequest # 可选

func _ready():
	# 连接 GameState 信号（如果你在 GameState.gd 定义了）
	if GameState.has_signal("module_changed"):
		GameState.module_changed.connect(_on_module_changed)
	if GameState.has_signal("story_changed"):
		GameState.story_changed.connect(_refresh_ui)
	if GameState.has_signal("story_finished"):
		GameState.story_finished.connect(_on_story_finished)

	# 顶栏按钮
	btn_save.pressed.connect(_on_save_pressed)
	btn_load.pressed.connect(_on_load_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)

	# 自动存档
	autosave.timeout.connect(func():
		if GameState.save_game("autosave.json"):
			_toast("已自动保存 Auto-saved.")
	)

	# 如使用外部AI：连接 HTTPRequest 完成信号
	if ai_request:
		ai_request.request_completed.connect(_on_request_completed)

	_refresh_ui()

func _on_module_changed(new_index: int) -> void:
	_refresh_ui()

func _on_story_finished(ending: String) -> void:
	_toast("故事已完成 / Story finished.")
	_refresh_ui()

func _refresh_ui() -> void:
	var m := GameState.get_current_module()
	if m.is_empty():
		story_text.text = "[center][b]没有可显示的章节 / No module.[/b][/center]"
		choices_box.hide()
		chapter_label.text = "Chapter: -"
		progress.value = 0
		return
	choices_box.show()
	var idx := GameState.current_module_index
	var total := GameState.current_story.get("modules", []).size()
	story_text.text = "[b]%s[/b]\n\n%s" % [m.get("title",""), m.get("text","")]
	chapter_label.text = "Chapter: %d / %d" % [idx+1, max(1,total)]
	progress.value = int(float(idx) / max(1.0, float(total)) * 100.0)

	# 重建 Choices
	for c in choices_box.get_children():
		c.queue_free()
	var arr: Array = m.get("choices", [])
	for i in arr.size():
		var b := Button.new()
		b.text = str(arr[i])
		b.focus_mode = Control.FOCUS_ALL
		b.pressed.connect(func(idx := i):
			GameState.apply_choice(idx))
		choices_box.add_child(b)
	# 如果已经没有 choices，可能是结尾
	if arr.is_empty():
		var done := Label.new()
		done.text = "（无可选项 / No choices）"
		choices_box.add_child(done)

func _on_save_pressed() -> void:
	if GameState.save_game("slot1.json"):
		_toast("保存成功 / Saved.")

func _on_load_pressed() -> void:
	if GameState.load_game("slot1.json"):
		_toast("读取成功 / Loaded.")
		_refresh_ui()
	else:
		_toast("没有存档 / No save.")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _toast(msg: String) -> void:
	toast.text = msg
	toast.visible = true
	toast.modulate.a = 1.0
	create_tween().tween_property(toast, "modulate:a", 0.0, 1.2).set_delay(1.2)

# （可选）AI HTTP 回调
func _on_request_completed(result, response_code, headers, body):
	# 解析响应并写回 GameState，然后发 signal 刷新
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) == OK:
		var data := json.get_data()
		# 假设解析到故事结构后：
		GameState.current_story = data
		GameState.current_module_index = 0
		if GameState.has_signal("story_changed"):
			GameState.emit_signal("story_changed")
