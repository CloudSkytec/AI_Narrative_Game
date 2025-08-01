extends Node

signal game_state_changed(new_state: GameState)

enum GameState { MENU, KEYWORD_SELECTION, STORY_READING, MAP_EXPLORATION }

var current_state: GameState = GameState.MENU
var game_data: Dictionary = {}
var current_session: Dictionary = {}

func _ready():
	print("[Game Manager] Initialized")

func change_state(new_state: GameState):
	current_state = new_state
	game_state_changed.emit(new_state)

func start_new_game():
	change_state(GameState.KEYWORD_SELECTION)

func on_keywords_selected(keywords: Dictionary):
	current_session["selected_keywords"] = keywords
	change_state(GameState.STORY_READING)
	AIManager.generate_story(keywords.get("characters", []))
