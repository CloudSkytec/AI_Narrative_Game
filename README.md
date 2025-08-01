# AI Story Game - AI驱动的2D叙述类解谜游戏

## 项目简介

基于Godot 4.4.1构建的2D AI叙述类游戏，结合AI驱动的动态故事生成、解谜元素和探索玩法。

## 游戏特色

- **AI驱动的故事生成**: 支持OpenAI API和本地大模型API
- **动态关键词系统**: 玩家选择影响故事走向
- **解谜破案元素**: 收集线索、分析证据、推理真相
- **动态地图生成**: 基于关键词生成探索场景
- **智能线索系统**: AI自动生成相关线索

## 快速开始

### 1. 环境要求
- **Godot Engine**: 4.4.1 Stable
- **操作系统**: Windows 10/11, macOS 10.15+, Ubuntu 20.04+
- **内存**: 最少4GB RAM（推荐8GB+）

### 2. 安装运行
1. 下载项目文件
2. 打开Godot 4.4.1
3. 导入项目（选择project.godot文件）
4. 按F5运行游戏

### 3. AI配置

#### 方式一：本地模型（推荐）
```bash
# 安装Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# 下载中文模型
ollama pull qwen:7b

# 启动服务
ollama serve
```

#### 方式二：OpenAI API
1. 获取OpenAI API Key
2. 在游戏设置中配置API信息

## 项目结构

```
AIStoryGame/
├── project.godot              # Godot项目配置
├── scenes/                   # 游戏场景
│   ├── MainMenu.tscn        # 主菜单
│   └── ui/                  # UI场景
├── scripts/                 # 脚本文件
│   ├── managers/           # 核心管理器
│   │   ├── AIManager.gd    # AI接口管理
│   │   ├── GameManager.gd  # 游戏主控制
│   │   ├── StoryManager.gd # 故事管理
│   │   ├── UIManager.gd    # 界面管理
│   │   ├── MapManager.gd   # 地图管理
│   │   └── InventoryManager.gd # 物品管理
│   └── ui/                 # UI控制脚本
└── resources/              # 游戏资源
	├── images/             # 图片资源
	├── audio/              # 音频资源
	└── fonts/              # 字体资源
```

## 核心功能

### AI系统
- 支持多种AI提供商（OpenAI、本地模型）
- 智能故事生成和分支
- 动态线索生成
- 离线后备模式

### 游戏机制
- 关键词驱动的故事生成
- 多分支剧情系统
- 线索收集和分析
- 解谜推理机制
- 动态地图探索

### 存档系统
- 多存档槽位支持
- 自动保存功能
- 游戏进度追踪

## 开发扩展

### 添加新AI提供商
在`AIManager.gd`中扩展Provider枚举和对应的请求函数。

### 自定义故事模板
修改`AIManager.gd`中的提示生成函数来自定义AI交互。

### 添加新游戏机制
创建新的系统脚本并在相应管理器中注册。

## 故障排除

### 常见问题
1. **AI无法连接**: 检查网络和API配置
2. **游戏无法启动**: 确认Godot版本为4.4.1
3. **存档问题**: 检查用户目录写入权限

### 调试方法
- 查看Godot编辑器控制台输出
- 检查`user://`目录下的配置文件
- 启用详细日志输出

## 更新日志

### v1.0.0 (2024-07-30)
- 初始版本发布
- 实现基础AI驱动故事生成
- 支持OpenAI和本地模型API
- 完整的解谜和探索系统

## 许可证

本项目基于MIT许可证开源。

## 联系方式

如有问题或建议，请通过GitHub Issues提交。

---

**开始你的AI冒险之旅！** 🚀
