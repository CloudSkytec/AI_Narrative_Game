extends Node
class_name PCGManager

# 程序化内容生成管理器
# 负责动态生成游戏场景、谜题和互动元素

signal content_generated(content_type, content_data)

var noise: FastNoiseLite
var random_generator: RandomNumberGenerator
var content_templates: Dictionary = {}

func _ready():
	setup_noise_generator()
	setup_random_generator()
	load_content_templates()

# 设置噪声生成器
func setup_noise_generator():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

# 设置随机数生成器
func setup_random_generator():
	random_generator = RandomNumberGenerator.new()
	random_generator.randomize()

# 生成场景布局
func generate_scene_layout(width: int, height: int, scene_type: String) -> Array:
	var layout = []
	
	for x in range(width):
		layout.append([])
		for y in range(height):
			var noise_value = noise.get_noise_2d(x, y)
			var tile_type = determine_tile_type(noise_value, scene_type)
			layout[x].append(tile_type)
	
	# 应用场景特定的规则
	layout = apply_scene_rules(layout, scene_type)
	
	content_generated.emit("scene_layout", {
		"layout": layout,
		"width": width,
		"height": height,
		"type": scene_type
	})
	
	return layout

# 确定瓦片类型
func determine_tile_type(noise_value: float, scene_type: String) -> String:
	match scene_type:
		"forest":
			if noise_value > 0.3:
				return "tree"
			elif noise_value > 0.0:
				return "grass"
			else:
				return "path"
		"dungeon":
			if noise_value > 0.2:
				return "wall"
			elif noise_value > -0.2:
				return "floor"
			else:
				return "corridor"
		_:
			return "default"

# 应用场景规则
func apply_scene_rules(layout: Array, scene_type: String) -> Array:
	match scene_type:
		"dungeon":
			layout = ensure_connectivity(layout)
			layout = add_rooms(layout)
		"forest":
			layout = add_clearings(layout)
			layout = create_paths(layout)
	
	return layout

# 生成谜题
func generate_puzzle(difficulty: int, puzzle_type: String) -> Dictionary:
	var puzzle_data = {}
	
	match puzzle_type:
		"logic":
			puzzle_data = generate_logic_puzzle(difficulty)
		"pattern":
			puzzle_data = generate_pattern_puzzle(difficulty)
		"sequence":
			puzzle_data = generate_sequence_puzzle(difficulty)
	
	content_generated.emit("puzzle", puzzle_data)
	return puzzle_data

# 生成逻辑谜题
func generate_logic_puzzle(difficulty: int) -> Dictionary:
	var symbols = ["A", "B", "C", "D", "E"]
	var rules = []
	var solution = []
	
	# 根据难度生成不同复杂度的逻辑规则
	var rule_count = 2 + difficulty
	
	for i in range(rule_count):
		var rule = {
			"condition": symbols[random_generator.randi() % symbols.size()],
			"relation": ["before", "after", "not_adjacent"][random_generator.randi() % 3],
			"target": symbols[random_generator.randi() % symbols.size()]
		}
		rules.append(rule)
	
	# 生成符合规则的解决方案
	solution = solve_logic_puzzle(rules, symbols)
	
	return {
		"type": "logic",
		"difficulty": difficulty,
		"symbols": symbols,
		"rules": rules,
		"solution": solution,
		"description": generate_puzzle_description(rules)
	}

# 动态调整难度
func adjust_difficulty(player_performance: Dictionary) -> int:
	var success_rate = player_performance.get("success_rate", 0.5)
	var average_time = player_performance.get("average_time", 60.0)
	
	var new_difficulty = 1
	
	if success_rate > 0.8 and average_time < 30:
		new_difficulty = 3  # 提高难度
	elif success_rate > 0.6 and average_time < 45:
		new_difficulty = 2  # 中等难度
	elif success_rate < 0.3 or average_time > 120:
		new_difficulty = 1  # 降低难度
	
	return new_difficulty
