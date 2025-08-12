# res://scripts/WordSphere.gd
extends Control

var keywords := ["傲慢","懒惰","生气","火山","冰山","活力","忠诚","背叛","孤独","救赎"]
var nodes: Array[Label] = []
var phi := 0.0   # 水平角
var theta := 0.6 # 俯仰角
var radius := 240.0
var dragging := false
var last_mouse := Vector2.ZERO

@onready var container := $Node2D

func _ready():
	# 生成标签
	for i in keywords.size():
		var lbl := Label.new()
		lbl.text = keywords[i]
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		lbl.gui_input.connect(func(e):
			if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
				_on_keyword_picked(lbl.text))
		container.add_child(lbl)
		nodes.append(lbl)

func _process(delta):
	# 简易旋转交互
	if dragging:
		var m := get_viewport().get_mouse_position()
		var d := m - last_mouse
		phi -= d.x * 0.01
		theta = clamp(theta - d.y * 0.01, -1.2, 1.2)
		last_mouse = m

	# 将关键字分布在球面（经纬均匀近似）
	var N := max(nodes.size(), 1)
	for i in N:
		var a := float(i) / float(N) * TAU  # 经度
		var b := lerp(-0.9, 0.9, float(i)/float(N-1)) if N>1 else 0.0 # 纬度
		var x := cos(phi + a) * cos(theta + b)
		var y := sin(theta + b)
		var z := sin(phi + a) * cos(theta + b)
		# 投影到屏幕（z 用于远近缩放/透明）
		var screen := Vector2(x, y) * radius + get_viewport_rect().size * 0.5
		var scale := 0.7 + 0.3 * (z * 0.5 + 0.5)
		nodes[i].position = screen
		nodes[i].scale = Vector2.ONE * scale
		nodes[i].modulate.a = clamp(0.4 + 0.6 * (z*0.5+0.5), 0.4, 1.0)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse = get_viewport().get_mouse_position()

func _on_keyword_picked(word: String):
	# 把选择的关键词交给 GameState（后续它会调 AI 生成完整故事）
	GameState.start_new_story([word])
	# 去掉主菜单的毛玻璃：在 Game 场景中展示真实文字云或进入解谜模块
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
