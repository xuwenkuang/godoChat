# 对话系统使用文档

## 目录
- [系统概述](#系统概述)
- [核心组件](#核心组件)
- [快速开始](#快速开始)
- [详细使用说明](#详细使用说明)
- [API 参考](#api-参考)
- [常见问题](#常见问题)
- [最佳实践](#最佳实践)
- [性能优化](#性能优化)

---

## 系统概述

对话系统是一个功能强大的 NPC 交互框架，支持：
- 基于 AI 的自然对话生成
- 多 NPC 并发对话管理
- 对话历史记录和上下文记忆
- 可定制的 NPC 个性配置
- 流式文本输出效果
- 灵活的触发机制

### 主要特性

1. **AI 驱动的对话**：集成 NobodyWho AI 模型，生成自然的对话响应
2. **上下文感知**：NPC 记住之前的对话内容，提供连贯的交互体验
3. **个性化配置**：每个 NPC 都有独特的性格、背景和说话风格
4. **灵活触发**：支持接近触发、交互触发等多种触发方式
5. **视觉反馈**：提供打字机效果、淡入淡出等视觉动画
6. **历史记录**：自动保存对话历史，支持查询和分析

---

## 核心组件

### 1. NPCDialogue
负责 NPC 的对话逻辑和 AI 交互。

**主要功能：**
- 管理 NPC 的对话状态
- 处理 AI 消息生成
- 维护对话记忆
- 支持流式输出

**关键属性：**
```gdscript
@export var npc_id: String = ""
@export var npc_name: String = "NPC"
@export var npc_personality: Dictionary = {}
@export var enable_streaming: bool = true
@export var streaming_speed: float = 0.05
@export var max_memory_entries: int = 50
@export var enable_context_memory: bool = true
```

**重要信号：**
```gdscript
signal dialogue_started(npc_id: String, npc_name: String)
signal dialogue_ended(npc_id: String)
signal message_streaming(content: String, is_complete: bool)
signal dialogue_interrupted(npc_id: String)
signal dialogue_resumed(npc_id: String)
```

### 2. DialogueManager
全局单例，管理所有对话会话和历史记录。

**主要功能：**
- 管理活跃对话会话
- 维护对话历史记录
- 提供对话事件信号
- 支持多 NPC 并发对话

**关键方法：**
```gdscript
func start_dialogue(npc_id: String, npc_name: String, dialogue_data: Dictionary) -> String
func end_dialogue(session_id: String) -> bool
func get_session(session_id: String) -> DialogueSession
func get_active_sessions() -> Array[DialogueSession]
func add_dialogue_history(npc_id: String, npc_name: String, content: String, choices: Array = [])
```

### 3. DialogueBox
UI 组件，显示对话内容和选项。

**主要功能：**
- 显示 NPC 名称和对话文本
- 支持打字机效果
- 显示对话选项
- 处理用户输入

**关键属性：**
```gdscript
@export var typing_speed: float = 0.03
@export var auto_continue_delay: float = 2.0
@export var enable_typing_effect: bool = true
@export var enable_auto_continue: bool = false
```

### 4. DialogueTrigger
触发器组件，检测玩家并触发对话。

**主要功能：**
- 检测玩家接近
- 处理交互输入
- 管理对话状态
- 控制游戏暂停

**关键属性：**
```gdscript
@export var trigger_radius: float = 3.0
@export var trigger_on_proximity: bool = true
@export var trigger_on_interaction: bool = true
@export var interaction_key: String = "ui_accept"
@export var single_use: bool = false
```

### 5. NPCProfile
资源类，存储 NPC 配置信息。

**主要功能：**
- 存储 NPC 基本信息
- 配置角色设定
- 设置对话参数
- 支持多语言

**关键属性：**
```gdscript
@export var npc_id: String = ""
@export var display_name: String = "NPC"
@export var identity: String = ""
@export var personality: String = ""
@export var background_story: String = ""
@export var speaking_style: String = ""
@export var dialogue_style: DialogueStyle = DialogueStyle.FRIENDLY
```

---

## 快速开始

### 步骤 1：创建 NPC 场景

1. 在场景树中创建一个 `Node3D` 节点作为 NPC 根节点
2. 添加 `NPCDialogue` 节点作为子节点
3. 添加 `DialogueTrigger` 节点作为子节点
4. 添加 3D 模型表示 NPC 外观

### 步骤 2：配置 NPC 参数

在 `NPCDialogue` 节点中设置：
- `npc_id`：唯一标识符（如 "village_elder"）
- `npc_name`：显示名称（如 "村长"）
- `npc_personality`：个性配置字典

```gdscript
npc_personality = {
    "name": "村长",
    "role": "村庄的长者",
    "personality": "智慧、慈祥、谨慎",
    "background": "在村庄生活了60年",
    "speaking_style": "语速缓慢，用词考究"
}
```

### 步骤 3：设置触发器

在 `DialogueTrigger` 节点中设置：
- `trigger_radius`：触发半径（如 3.0）
- `trigger_on_proximity`：是否接近时触发
- `trigger_on_interaction`：是否需要按键触发
- `interaction_key`：交互按键（如 "ui_accept"）

### 步骤 4：添加对话 UI

1. 创建 `CanvasLayer` 节点
2. 添加 `DialogueBox` 实例
3. 连接信号到 NPCDialogue

```gdscript
npc_dialogue.dialogue_started.connect(_on_dialogue_started)
npc_dialogue.message_streaming.connect(_on_message_streaming)
```

### 步骤 5：测试对话

运行游戏，接近 NPC 或按下交互键，对话应该自动开始。

---

## 详细使用说明

### 创建自定义 NPC

#### 方法 1：使用代码创建

```gdscript
func create_custom_npc():
    var npc_node = Node3D.new()
    npc_node.name = "CustomNPC"
    
    var npc_dialogue = NPCDialogue.new()
    npc_dialogue.npc_id = "custom_npc"
    npc_dialogue.npc_name = "自定义 NPC"
    npc_dialogue.npc_personality = {
        "name": "自定义角色",
        "role": "游戏角色",
        "personality": "友好、乐于助人",
        "background": "这是一个自定义的 NPC",
        "speaking_style": "语速中等，语气亲切"
    }
    
    var trigger = DialogueTrigger.new()
    trigger.trigger_radius = 3.0
    trigger.trigger_on_proximity = true
    
    npc_node.add_child(npc_dialogue)
    npc_node.add_child(trigger)
    
    add_child(npc_node)
```

#### 方法 2：使用 NPCProfile 资源

```gdscript
func create_npc_from_profile():
    var profile = NPCProfile.new()
    profile.npc_id = "profile_npc"
    profile.display_name = "配置 NPC"
    profile.identity = "使用配置的角色"
    profile.personality = "温和、友善"
    profile.background_story = "通过配置创建的 NPC"
    profile.speaking_style = "语速缓慢，用词温和"
    profile.dialogue_style = NPCProfile.DialogueStyle.GENTLE
    
    var npc_dialogue = NPCDialogue.new()
    npc_dialogue.npc_id = profile.npc_id
    npc_dialogue.npc_name = profile.display_name
    npc_dialogue.npc_personality = {
        "name": profile.display_name,
        "role": profile.identity,
        "personality": profile.personality,
        "background": profile.background_story,
        "speaking_style": profile.speaking_style
    }
    
    add_child(npc_dialogue)
```

### 对话流程控制

#### 开始对话

```gdscript
func start_dialogue_with_npc(npc: NPCDialogue):
    var session_id = npc.start_npc_dialogue()
    print("对话开始，会话 ID: ", session_id)
```

#### 发送消息

```gdscript
func send_message_to_npc(npc: NPCDialogue, message: String):
    if npc.is_active:
        var response = npc.send_npc_message(message)
        print("NPC 响应: ", response)
```

#### 结束对话

```gdscript
func end_dialogue_with_npc(npc: NPCDialogue):
    npc.end_npc_dialogue()
    print("对话已结束")
```

### 处理对话事件

```gdscript
func _ready():
    var npc_dialogue = $NPCDialogue
    
    npc_dialogue.dialogue_started.connect(_on_dialogue_started)
    npc_dialogue.dialogue_ended.connect(_on_dialogue_ended)
    npc_dialogue.message_streaming.connect(_on_message_streaming)
    npc_dialogue.dialogue_interrupted.connect(_on_dialogue_interrupted)

func _on_dialogue_started(npc_id: String, npc_name: String):
    print("对话开始: ", npc_name)
    dialogue_box.show_dialogue(npc_name, "你好！")

func _on_dialogue_ended(npc_id: String):
    print("对话结束: ", npc_id)
    dialogue_box.hide_dialogue()

func _on_message_streaming(content: String, is_complete: bool):
    dialogue_box.dialogue_text_label.text = content
    if is_complete:
        print("消息传输完成")

func _on_dialogue_interrupted(npc_id: String):
    print("对话被中断: ", npc_id)
```

### 使用 DialogueManager

```gdscript
func manage_dialogues():
    var manager = DialogueManager
    
    var session_id = manager.start_dialogue("npc_1", "NPC 1", {})
    print("会话 ID: ", session_id)
    
    var session = manager.get_session(session_id)
    if session:
        print("NPC ID: ", session.npc_id)
        print("NPC 名称: ", session.npc_name)
    
    manager.add_dialogue_history("npc_1", "NPC 1", "这是一条对话记录")
    
    var history = manager.get_npc_history("npc_1")
    print("历史记录数: ", history.size())
    
    manager.end_dialogue(session_id)
```

### 自定义对话样式

```gdscript
func customize_dialogue_box():
    var dialogue_box = $DialogueUI/DialogueBox
    
    dialogue_box.typing_speed = 0.05
    dialogue_box.enable_typing_effect = true
    dialogue_box.fade_in_duration = 0.5
    dialogue_box.fade_out_duration = 0.3
    
    if dialogue_box.background_panel:
        var material = StandardMaterial3D.new()
        material.albedo_color = Color(0.2, 0.2, 0.3, 0.9)
        dialogue_box.background_panel.material_override = material
```

---

## API 参考

### NPCDialogue 类

#### 方法

```gdscript
func start_npc_dialogue() -> String
```
开始 NPC 对话，返回会话 ID。

```gdscript
func end_npc_dialogue() -> void
```
结束 NPC 对话。

```gdscript
func send_npc_message(user_message: String) -> String
```
发送用户消息给 NPC，返回 NPC 响应。

```gdscript
func set_npc_personality(personality: Dictionary) -> void
```
设置 NPC 个性配置。

```gdscript
func get_memory_entries() -> Array[Dictionary]
```
获取对话记忆条目。

```gdscript
func search_memory(keyword: String) -> Array[Dictionary]
```
搜索对话记忆中的关键词。

```gdscript
func clear_memory() -> void
```
清空对话记忆。

```gdscript
func get_npc_info() -> Dictionary
```
获取 NPC 信息。

#### 信号

```gdscript
signal dialogue_started(npc_id: String, npc_name: String)
```
对话开始时触发。

```gdscript
signal dialogue_ended(npc_id: String)
```
对话结束时触发。

```gdscript
signal message_streaming(content: String, is_complete: bool)
```
消息流式传输时触发。

```gdscript
signal dialogue_interrupted(npc_id: String)
```
对话被中断时触发。

```gdscript
signal dialogue_resumed(npc_id: String)
```
对话恢复时触发。

### DialogueManager 类

#### 方法

```gdscript
func start_dialogue(npc_id: String, npc_name: String, dialogue_data: Dictionary) -> String
```
开始新的对话会话。

```gdscript
func end_dialogue(session_id: String) -> bool
```
结束指定会话。

```gdscript
func end_all_dialogues() -> void
```
结束所有活跃对话。

```gdscript
func get_session(session_id: String) -> DialogueSession
```
获取指定会话。

```gdscript
func get_active_sessions() -> Array[DialogueSession]
```
获取所有活跃会话。

```gdscript
func get_npc_session(npc_id: String) -> DialogueSession
```
获取指定 NPC 的活跃会话。

```gdscript
func has_active_dialogue(npc_id: String) -> bool
```
检查 NPC 是否有活跃对话。

```gdscript
func add_dialogue_history(npc_id: String, npc_name: String, content: String, choices: Array = []) -> void
```
添加对话历史记录。

```gdscript
func get_dialogue_history() -> Array[DialogueHistory]
```
获取所有对话历史。

```gdscript
func get_npc_history(npc_id: String) -> Array[DialogueHistory]
```
获取指定 NPC 的对话历史。

#### 信号

```gdscript
signal dialogue_started(session_id: String, npc_id: String, npc_name: String)
```
对话开始时触发。

```gdscript
signal dialogue_ended(session_id: String, npc_id: String)
```
对话结束时触发。

```gdscript
signal dialogue_updated(session_id: String, node_id: String)
```
对话更新时触发。

```gdscript
signal dialogue_choice_selected(session_id: String, choice_index: int)
```
选择对话选项时触发。

```gdscript
signal dialogue_history_added(history: DialogueHistory)
```
添加对话历史时触发。

### DialogueBox 类

#### 方法

```gdscript
func show_dialogue(npc_name: String, text: String, choices: Array[Dictionary] = []) -> void
```
显示对话。

```gdscript
func hide_dialogue() -> void
```
隐藏对话。

```gdscript
func skip_typing() -> void
```
跳过打字效果。

#### 信号

```gdscript
signal dialogue_finished()
```
对话完成时触发。

```gdscript
signal choice_selected(choice_index: int)
```
选择选项时触发。

```gdscript
signal skip_requested()
```
请求跳过时触发。

### DialogueTrigger 类

#### 方法

```gdscript
func set_npc_dialogue(npc_dialogue: NPCDialogue) -> void
```
设置关联的 NPCDialogue。

```gdscript
func set_trigger_radius(radius: float) -> void
```
设置触发半径。

```gdscript
func is_dialogue_active() -> bool
```
检查对话是否活跃。

```gdscript
func is_player_in_range() -> bool
```
检查玩家是否在范围内。

```gdscript
func reset_trigger() -> void
```
重置触发器。

#### 信号

```gdscript
signal dialogue_triggered(npc_id: String, npc_name: String)
```
对话触发时触发。

```gdscript
signal dialogue_ended(npc_id: String)
```
对话结束时触发。

---

## 常见问题

### Q1: 对话没有触发

**可能原因：**
1. 玩家不在触发范围内
2. 触发器未正确配置
3. 碰撞层设置不正确

**解决方案：**
- 检查 `trigger_radius` 设置
- 确保 `trigger_on_proximity` 或 `trigger_on_interaction` 已启用
- 检查碰撞层和遮罩设置
- 使用 `is_player_in_range()` 调试

### Q2: NPC 没有响应

**可能原因：**
1. AI 模型未正确配置
2. 网络连接问题
3. NPCDialogue 未正确初始化

**解决方案：**
- 检查 NobodyWho 插件配置
- 确认 API 密钥已设置
- 查看日志输出错误信息
- 使用 `get_npc_info()` 检查 NPC 状态

### Q3: 对话记忆不工作

**可能原因：**
1. `enable_context_memory` 未启用
2. `max_memory_entries` 设置过小
3. 关键词提取失败

**解决方案：**
- 启用 `enable_context_memory`
- 增加 `max_memory_entries` 值
- 检查 `get_memory_entries()` 返回值

### Q4: 流式输出效果不流畅

**可能原因：**
1. `streaming_speed` 设置不当
2. 系统性能不足
3. 文本过长

**解决方案：**
- 调整 `streaming_speed` 参数
- 减少同时显示的 NPC 数量
- 缩短单次对话文本长度

### Q5: 多 NPC 对话冲突

**可能原因：**
1. 同时触发多个对话
2. DialogueManager 会话数超限
3. UI 资源竞争

**解决方案：**
- 设置 `max_active_sessions` 限制
- 实现对话队列系统
- 使用对话优先级机制

### Q6: 性能问题

**可能原因：**
1. 对话历史过多
2. 记忆条目过多
3. AI 响应时间过长

**解决方案：**
- 定期清理对话历史
- 限制 `max_memory_entries`
- 启用响应缓存
- 使用异步处理

---

## 最佳实践

### 1. NPC 设计

#### 个性鲜明
为每个 NPC 设计独特的个性、背景和说话风格：

```gdscript
var elder_personality = {
    "name": "村长",
    "role": "村庄的长者",
    "personality": "智慧、慈祥、谨慎",
    "background": "在村庄生活了60年",
    "speaking_style": "语速缓慢，用词考究"
}

var shopkeeper_personality = {
    "name": "店主",
    "role": "商店的主人",
    "personality": "热情、精明、友好",
    "background": "经营商店20年",
    "speaking_style": "语速较快，喜欢开玩笑"
}
```

#### 合理配置参数
根据 NPC 类型调整对话参数：

```gdscript
npc_dialogue.enable_streaming = true
npc_dialogue.streaming_speed = 0.05
npc_dialogue.max_memory_entries = 50
npc_dialogue.enable_context_memory = true
```

### 2. 对话管理

#### 使用 DialogueManager
集中管理所有对话会话：

```gdscript
var manager = DialogueManager

var session_id = manager.start_dialogue("npc_1", "NPC 1", {})
manager.add_dialogue_history("npc_1", "NPC 1", "对话内容")

var history = manager.get_npc_history("npc_1")
```

#### 实现对话队列
避免同时触发多个对话：

```gdscript
var dialogue_queue: Array[Dictionary] = []
var is_dialogue_active: bool = false

func queue_dialogue(npc: NPCDialogue):
    dialogue_queue.append({"npc": npc, "time": Time.get_unix_time_from_system()})
    _process_dialogue_queue()

func _process_dialogue_queue():
    if is_dialogue_active or dialogue_queue.is_empty():
        return
    
    var next_dialogue = dialogue_queue.pop_front()
    is_dialogue_active = true
    next_dialogue.npc.dialogue_ended.connect(_on_dialogue_finished)
    next_dialogue.npc.start_npc_dialogue()

func _on_dialogue_finished(npc_id: String):
    is_dialogue_active = false
    _process_dialogue_queue()
```

### 3. 性能优化

#### 限制活跃对话数
```gdscript
DialogueManager.max_active_sessions = 5
```

#### 定期清理历史
```gdscript
func _on_timeout():
    var history = DialogueManager.get_dialogue_history()
    if history.size() > 100:
        DialogueManager.clear_dialogue_history()
```

#### 使用对象池
```gdscript
var dialogue_box_pool: Array[DialogueBox] = []

func get_dialogue_box() -> DialogueBox:
    if dialogue_box_pool.is_empty():
        return DialogueBox.new()
    return dialogue_box_pool.pop_back()

func return_dialogue_box(box: DialogueBox):
    box.hide_dialogue()
    dialogue_box_pool.append(box)
```

### 4. 错误处理

#### 添加错误检查
```gdscript
func start_dialogue_safely(npc: NPCDialogue) -> bool:
    if not npc:
        LogWrapper.error(self, "NPC is null")
        return false
    
    if npc.is_active:
        LogWrapper.warn(self, "NPC dialogue already active")
        return false
    
    try:
        npc.start_npc_dialogue()
        return true
    except:
        LogWrapper.error(self, "Failed to start dialogue")
        return false
```

#### 提供回退方案
```gdscript
func get_npc_response(npc: NPCDialogue, message: String) -> String:
    var response = npc.send_npc_message(message)
    
    if response.is_empty():
        response = _get_fallback_response(npc)
    
    return response

func _get_fallback_response(npc: NPCDialogue) -> String:
    var fallbacks = {
        "village_elder": "我现在不太方便说话。",
        "shopkeeper": "欢迎下次光临！",
        "guard_captain": "我还有任务在身。"
    }
    
    return fallbacks.get(npc.npc_id, "...")
```

### 5. 用户体验

#### 提供视觉反馈
```gdscript
func _on_dialogue_started(npc_id: String, npc_name: String):
    dialogue_box.show_dialogue(npc_name, "")
    dialogue_box.modulate = Color.TRANSPARENT
    
    var tween = create_tween()
    tween.tween_property(dialogue_box, "modulate", Color.WHITE, 0.3)
```

#### 支持跳过
```gdscript
func _input(event: InputEvent):
    if event.is_action_pressed("ui_cancel"):
        if dialogue_box:
            dialogue_box.skip_typing()
```

#### 保存进度
```gdscript
func save_dialogue_progress():
    var save_data = {
        "dialogue_history": DialogueManager.get_dialogue_history(),
        "npc_states": _get_npc_states()
    }
    
    var file = FileAccess.open("user://dialogue_save.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
    file.close()
```

---

## 性能优化

### 1. 内存管理

#### 限制记忆条目
```gdscript
npc_dialogue.max_memory_entries = 30
```

#### 定期清理
```gdscript
func _on_cleanup_timer():
    for npc in get_tree().get_nodes_in_group("npc"):
        if npc is NPCDialogue:
            var memory = npc.get_memory_entries()
            if memory.size() > 20:
                npc.clear_memory()
```

### 2. 网络优化

#### 启用缓存
```gdscript
var response_cache: Dictionary = {}

func get_cached_response(npc_id: String, message: String) -> String:
    var key = npc_id + ":" + message
    return response_cache.get(key, "")

func cache_response(npc_id: String, message: String, response: String):
    var key = npc_id + ":" + message
    response_cache[key] = response
```

#### 批量处理
```gdscript
var pending_messages: Array[Dictionary] = []

func queue_message(npc: NPCDialogue, message: String):
    pending_messages.append({"npc": npc, "message": message})
    
    if pending_messages.size() >= 5:
        _process_pending_messages()

func _process_pending_messages():
    for item in pending_messages:
        item.npc.send_npc_message(item.message)
    pending_messages.clear()
```

### 3. 渲染优化

#### 减少 UI 更新
```gdscript
var _update_timer: Timer = 0.0
var _update_interval: float = 0.1

func _process(delta):
    _update_timer += delta
    if _update_timer >= _update_interval:
        _update_dialogue_ui()
        _update_timer = 0.0
```

#### 使用对象池
```gdscript
var choice_button_pool: Array[Button] = []

func get_choice_button() -> Button:
    if choice_button_pool.is_empty():
        return Button.new()
    return choice_button_pool.pop_back()
```

### 4. CPU 优化

#### 异步处理
```gdscript
func send_message_async(npc: NPCDialogue, message: String):
    var thread = Thread.new()
    thread.start(_send_message_thread.bind(npc, message))
    add_child(thread)

func _send_message_thread(npc: NPCDialogue, message: String):
    var response = npc.send_npc_message(message)
    call_deferred("_handle_response", response)
```

#### 降低更新频率
```gdscript
npc_dialogue.streaming_speed = 0.1
```

---

## 示例项目

完整的示例场景位于：
- 场景文件：`scenes/scene/example_dialogue_scene/example_dialogue_scene.tscn`
- 脚本文件：`scenes/scene/example_dialogue_scene/example_dialogue_scene.gd`
- NPC 配置：`examples/npc_profiles/npc_profile_example.gd`

### 运行示例

1. 在 Godot 编辑器中打开 `example_dialogue_scene.tscn`
2. 按 F5 运行场景
3. 使用 WASD 移动玩家
4. 接近 NPC 或按 E 键触发对话
5. 按 ESC 结束对话

### 示例 NPC

示例场景包含 4 个不同类型的 NPC：
1. **村长**：智慧、慈祥的长者
2. **店主**：热情、精明的商人
3. **神秘陌生人**：神秘的旅行者
4. **卫队长**：严肃、忠诚的卫士

---

## 更多资源

- [Godot 官方文档](https://docs.godotengine.org/)
- [NobodyWho 插件文档](addons/nobodywho/README.md)
- [示例场景](scenes/scene/example_dialogue_scene/)
- [NPC 配置示例](examples/npc_profiles/)

---

## 贡献

欢迎提交问题和改进建议！

---

## 许可证

MIT License - 详见项目根目录的 LICENSE 文件
