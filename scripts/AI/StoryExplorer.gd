## StoryExplorer.gd
extends Control

@onready var text_box: RichTextLabel = $MarginContainer/RichTextLabel
@onready var choice_container: VBoxContainer = $MarginContainer/ChoiceContainer

var segments: Array[String] = []
var current_index := 0

func _ready():
	# 按空行分割故事
	segments = GameState.full_story.strip_edges().split("\n\n")
	_show_current_segment()

func _show_current_segment():
	if current_index >= segments.size():
		# 完结，进入结局界面
		get_tree().change_scene_to_file("res://Ending.tscn")
		return
	text_box.clear()
	text_box.append_text(segments[current_index])
	# 清除旧选项
	for child in choice_container.get_children():
		child.queue_free()
	# 根据当前段落生成谜题/选项；这里简单展示两个分支
	var option1 = Button.new()
	option1.text = "继续调查"
	option1.pressed.connect(func(): _on_choice_selected(0))
	choice_container.add_child(option1)
	var option2 = Button.new()
	option2.text = "放弃线索"
	option2.pressed.connect(func(): _on_choice_selected(1))
	choice_container.add_child(option2)

func _on_choice_selected(choice_idx: int):
	# 根据选择修改后续流程，这里简单增加索引或跳过
	if choice_idx == 0:
		current_index += 1
	else:
		current_index += 2  # 跳过一段，产生分支
	_show_current_segment()
