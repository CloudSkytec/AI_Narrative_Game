# res://scripts/Game.gd
extends Control

@onready var btn_save := $TopBar/SaveButton
@onready var btn_load := $TopBar/LoadButton
@onready var btn_menu := $TopBar/MenuButton
@onready var txt := $StoryText
@onready var choices := $Choices

func _ready():
	btn_save.pressed.connect(func():
		if GameState.save_game("slot1.json"):
			print("Saved.")
	)
	btn_load.pressed.connect(func():
		if GameState.load_game("slot1.json"):
			_refresh_ui()
	)
	btn_menu.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)
	_refresh_ui()

func _refresh_ui():
	var m := GameState.get_current_module()
	if m.is_empty():
		txt.text = "（没有可显示的模块）"
		choices.hide()
		return
	txt.text = "[%s]\n\n%s" % [m.get("title",""), m.get("text","")]
	# 根据 choices 构建选项按钮
	for c in choices.get_children():
		c.queue_free()
	var arr := m.get("choices", [])
	for i in arr.size():
		var b := Button.new()
		b.text = str(arr[i])
		b.pressed.connect(func(idx := i):
			GameState.apply_choice(idx)
			_refresh_ui())
		choices.add_child(b)
