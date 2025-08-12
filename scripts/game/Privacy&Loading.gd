# res://scripts/PrivacyTerms.gd
extends Control

@onready var agree := $CheckBox
@onready var btn_continue := $HBoxContainer/ContinueButton
@onready var btn_quit := $HBoxContainer/QuitButton

func _ready():
	btn_continue.disabled = true
	agree.toggled.connect(_on_agree_toggled)
	btn_continue.pressed.connect(_on_continue_pressed)
	btn_quit.pressed.connect(func(): get_tree().quit())

func _on_agree_toggled(pressed: bool) -> void:
	btn_continue.disabled = not pressed

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
