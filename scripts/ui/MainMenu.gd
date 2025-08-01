extends Control

@onready var new_game_button = $VBoxContainer/NewGameButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	new_game_button.pressed.connect(_on_new_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	GameManager.start_new_game()

func _on_quit_pressed():
	get_tree().quit()
