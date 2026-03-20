# 对话系统文档索引

欢迎使用对话系统！本系统提供了完整的 NPC 对话交互解决方案，支持 AI 驱动的自然对话、多 NPC 管理、对话历史记录等功能。

## 📚 文档导航

### 快速开始
- **[对话系统使用文档](README_DIALOGUE.md)** - 完整的使用指南，包含快速开始、API 参考、常见问题和最佳实践
  - 系统概述和主要特性
  - 核心组件介绍
  - 快速开始教程
  - 详细的 API 参考
  - 常见问题解答
  - 性能优化建议

### 深入了解
- **[对话系统架构文档](docs/DIALOGUE_ARCHITECTURE.md)** - 系统架构设计和技术细节
  - 整体架构图
  - 核心组件类图
  - 数据流设计
  - 事件系统
  - 状态管理
  - 扩展性设计
  - 性能考虑
  - 安全设计

### 实战指南
- **[代码示例和使用指南](docs/DIALOGUE_EXAMPLES.md)** - 丰富的代码示例和实战案例
  - 基础示例（14 个）
  - 进阶示例（9 个）
  - 高级用法（5 个）
  - 实战案例（3 个）
  - 故障排除
  - 最佳实践

## 🎯 示例场景

### 示例对话场景
位置：`scenes/scene/example_dialogue_scene/`

包含 4 个不同类型的 NPC：
1. **村长** - 智慧、慈祥的长者
2. **店主** - 热情、精明的商人
3. **神秘陌生人** - 神秘的旅行者
4. **卫队长** - 严肃、忠诚的卫士

### NPC 配置示例
位置：`examples/npc_profiles/npc_profile_example.gd`

提供 8 种不同类型的 NPC 配置模板：
- 村长
- 店主
- 神秘陌生人
- 卫队长
- 友好向导
- 幽默小丑
- 正式学者
- 激进强盗

## 🚀 快速开始

### 1. 运行示例场景

```bash
# 在 Godot 编辑器中打开示例场景
scenes/scene/example_dialogue_scene/example_dialogue_scene.tscn

# 按 F5 运行场景
```

### 2. 创建自己的 NPC

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue
@onready var dialogue_trigger = $DialogueTrigger

func _ready():
    npc_dialogue.npc_id = "my_npc"
    npc_dialogue.npc_name = "我的 NPC"
    npc_dialogue.npc_personality = {
        "name": "我的角色",
        "role": "游戏角色",
        "personality": "友好、乐于助人",
        "background": "这是一个自定义的 NPC",
        "speaking_style": "语速中等，语气亲切"
    }
    
    dialogue_trigger.trigger_radius = 3.0
    dialogue_trigger.trigger_on_proximity = true
```

### 3. 使用 NPC 配置

```gdscript
var profile = NPCProfileExample.create_village_elder_profile()
npc_dialogue.npc_id = profile.npc_id
npc_dialogue.npc_name = profile.display_name
npc_dialogue.npc_personality = {
    "name": profile.display_name,
    "role": profile.identity,
    "personality": profile.personality,
    "background": profile.background_story,
    "speaking_style": profile.speaking_style
}
```

## 📖 核心组件

### NPCDialogue
负责 NPC 的对话逻辑和 AI 交互
- 管理对话状态
- 处理 AI 消息生成
- 维护对话记忆
- 支持流式输出

### DialogueManager
全局单例，管理所有对话会话和历史记录
- 管理活跃对话会话
- 维护对话历史记录
- 提供对话事件信号
- 支持多 NPC 并发对话

### DialogueBox
UI 组件，显示对话内容和选项
- 显示 NPC 名称和对话文本
- 支持打字机效果
- 显示对话选项
- 处理用户输入

### DialogueTrigger
触发器组件，检测玩家并触发对话
- 检测玩家接近
- 处理交互输入
- 管理对话状态
- 控制游戏暂停

### NPCProfile
资源类，存储 NPC 配置信息
- 存储 NPC 基本信息
- 配置角色设定
- 设置对话参数
- 支持多语言

## 🔧 主要特性

1. **AI 驱动的对话**：集成 NobodyWho AI 模型，生成自然的对话响应
2. **上下文感知**：NPC 记住之前的对话内容，提供连贯的交互体验
3. **个性化配置**：每个 NPC 都有独特的性格、背景和说话风格
4. **灵活触发**：支持接近触发、交互触发等多种触发方式
5. **视觉反馈**：提供打字机效果、淡入淡出等视觉动画
6. **历史记录**：自动保存对话历史，支持查询和分析
7. **多语言支持**：支持本地化配置
8. **扩展性强**：支持自定义 NPC 类型和对话风格

## 💡 使用建议

### 初学者
1. 先阅读 [对话系统使用文档](README_DIALOGUE.md) 的快速开始部分
2. 运行示例场景，体验对话系统
3. 尝试修改示例中的 NPC 配置
4. 参考基础示例创建自己的 NPC

### 进阶用户
1. 阅读 [对话系统架构文档](docs/DIALOGUE_ARCHITECTURE.md) 了解系统设计
2. 学习 [代码示例和使用指南](docs/DIALOGUE_EXAMPLES.md) 中的进阶示例
3. 实现自定义对话触发器和 UI
4. 集成任务系统、商店系统等游戏机制

### 高级用户
1. 研究系统架构，实现自定义扩展
2. 优化性能，处理大量 NPC
3. 实现复杂的对话分支和条件逻辑
4. 集成多语言支持和本地化

## 📞 获取帮助

### 常见问题
查看 [对话系统使用文档](README_DIALOGUE.md) 中的常见问题部分

### 故障排除
查看 [代码示例和使用指南](docs/DIALOGUE_EXAMPLES.md) 中的故障排除部分

### 最佳实践
查看 [对话系统使用文档](README_DIALOGUE.md) 中的最佳实践部分

## 📝 文档更新

- 2026-03-17: 初始版本发布
  - 创建示例对话场景
  - 编写使用文档
  - 创建架构文档
  - 添加代码示例

## 🎓 学习路径

### 第一阶段：基础（1-2 天）
- 阅读使用文档的快速开始部分
- 运行示例场景
- 创建简单的 NPC
- 理解核心组件

### 第二阶段：进阶（3-5 天）
- 学习 API 参考
- 实现多 NPC 管理
- 添加对话历史记录
- 自定义对话 UI

### 第三阶段：高级（1-2 周）
- 研究系统架构
- 实现复杂对话系统
- 优化性能
- 集成游戏机制

## 🔗 相关资源

- [Godot 官方文档](https://docs.godotengine.org/)
- [NobodyWho 插件文档](addons/nobodywho/README.md)
- [示例场景](scenes/scene/example_dialogue_scene/)
- [NPC 配置示例](examples/npc_profiles/)

## 📄 许可证

MIT License - 详见项目根目录的 LICENSE 文件

---

**祝您使用愉快！如有任何问题或建议，欢迎反馈。**
