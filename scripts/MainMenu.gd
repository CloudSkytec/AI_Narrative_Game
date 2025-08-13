# res://scripts/MainMenu.gd
extends Control

@onready var btn_new := $VBoxContainer/NewGameButton
@onready var btn_load := $VBoxContainer/LoadGameButton
@onready var btn_quit := $VBoxContainer/QuitButton
@onready var no_save_dialog: AcceptDialog = $NoSaveDialog 

func _ready():	
	btn_new.pressed.connect(_on_new_game)
	btn_load.pressed.connect(_on_load_game)
	btn_quit.pressed.connect(func(): get_tree().quit())

func _on_new_game():
	get_tree().change_scene_to_file("res://scenes/WordCloud.tscn")

func _on_load_game():
	if GameState.load_game("slot1"):
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
	else:
		# 可弹提示：“没有存档”
		no_save_dialog.dialog_text = "No saved game found."
		no_save_dialog.popup_centered()
