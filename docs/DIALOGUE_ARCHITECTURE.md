# 对话系统架构文档

## 目录
- [系统架构概述](#系统架构概述)
- [核心组件架构](#核心组件架构)
- [数据流设计](#数据流设计)
- [事件系统](#事件系统)
- [状态管理](#状态管理)
- [扩展性设计](#扩展性设计)
- [性能考虑](#性能考虑)
- [安全设计](#安全设计)

---

## 系统架构概述

### 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        游戏场景层                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  NPC 节点     │  │  玩家节点     │  │  环境节点     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                        触发层                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              DialogueTrigger (触发器)                 │   │
│  │  - 碰撞检测                                           │   │
│  │  - 输入处理                                           │   │
│  │  - 触发条件判断                                        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                        对话层                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              NPCDialogue (NPC 对话)                   │   │
│  │  - 对话状态管理                                        │   │
│  │  - AI 消息生成                                         │   │
│  │  - 记忆管理                                            │   │
│  │  - 流式输出                                            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      管理层                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │            DialogueManager (对话管理器)               │   │
│  │  - 会话管理                                            │   │
│  │  - 历史记录                                            │   │
│  │  - 事件分发                                            │   │
│  │  - 资源协调                                            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      AI 集成层                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              NobodyWhoChat (AI 核心)                  │   │
│  │  - API 通信                                           │   │
│  │  - 消息处理                                           │   │
│  │  - 上下文管理                                          │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      表现层                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              DialogueBox (对话 UI)                    │   │
│  │  - 文本显示                                            │   │
│  │  - 动画效果                                            │   │
│  │  - 用户交互                                            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 设计原则

1. **分层架构**：清晰的职责分离，每层专注于特定功能
2. **松耦合**：组件之间通过信号和接口通信，减少依赖
3. **可扩展**：支持添加新的 NPC 类型、对话风格和功能
4. **高性能**：优化内存使用和计算效率
5. **易维护**：代码结构清晰，便于理解和修改

---

## 核心组件架构

### 1. NPCDialogue 组件

#### 类图

```
┌─────────────────────────────────────────┐
│           NPCDialogue                   │
├─────────────────────────────────────────┤
│ + npc_id: String                       │
│ + npc_name: String                     │
│ + npc_personality: Dictionary           │
│ + enable_streaming: bool               │
│ + streaming_speed: float               │
│ + max_memory_entries: int              │
│ + enable_context_memory: bool          │
├─────────────────────────────────────────┤
│ + start_npc_dialogue(): String         │
│ + end_npc_dialogue(): void             │
│ + send_npc_message(msg): String        │
│ + set_npc_personality(p): void         │
│ + get_memory_entries(): Array           │
│ + search_memory(kw): Array             │
│ + clear_memory(): void                 │
│ + get_npc_info(): Dictionary           │
├─────────────────────────────────────────┤
│ - _dialogue_manager: DialogueManager   │
│ - _streaming_timer: Timer              │
│ - _memory_entries: Array               │
│ - _context_keywords: Array             │
├─────────────────────────────────────────┤
│ + dialogue_started(npc_id, npc_name)   │
│ + dialogue_ended(npc_id)               │
│ + message_streaming(content, complete)  │
│ + dialogue_interrupted(npc_id)         │
│ + dialogue_resumed(npc_id)             │
│ + npc_personality_changed(id, p)       │
└─────────────────────────────────────────┘
                    ↓
            extends
┌─────────────────────────────────────────┐
│         NobodyWhoChat                   │
├─────────────────────────────────────────┤
│ + is_active: bool                      │
│ + conversation_history: Array           │
│ + system_prompt: String                 │
├─────────────────────────────────────────┤
│ + start_chat(): void                   │
│ + end_chat(): void                     │
│ + send_message(msg): String            │
│ + set_system_prompt(p): void           │
└─────────────────────────────────────────┘
```

#### 职责

- **对话状态管理**：跟踪对话的活跃状态、中断状态和流式传输状态
- **AI 交互**：与 NobodyWhoChat 通信，发送用户消息并接收 AI 响应
- **记忆管理**：维护对话历史记录，支持上下文记忆和关键词提取
- **流式输出**：控制文本的逐步显示，提供打字机效果
- **个性配置**：根据 NPC 的个性设置生成合适的系统提示词

#### 关键方法

```gdscript
func start_npc_dialogue() -> String:
    if npc_id == "":
        npc_id = "npc_" + str(get_instance_id())
    
    _is_interrupted = false
    _is_streaming = false
    _current_stream_content = ""
    
    start_chat()
    
    if _dialogue_manager:
        var session_id: String = _dialogue_manager.start_dialogue(
            npc_id, npc_name, {}
        )
        dialogue_started.emit(npc_id, npc_name)
        return session_id
    
    dialogue_started.emit(npc_id, npc_name)
    return ""
```

### 2. DialogueManager 组件

#### 类图

```
┌─────────────────────────────────────────┐
│        DialogueManager                  │
├─────────────────────────────────────────┤
│ + max_history_size: int                 │
│ + max_active_sessions: int              │
│ + auto_save_history: bool               │
├─────────────────────────────────────────┤
│ + start_dialogue(nid, nname, data): Str │
│ + end_dialogue(sid): bool               │
│ + end_all_dialogues(): void             │
│ + get_session(sid): DialogueSession     │
│ + get_active_sessions(): Array          │
│ + get_npc_session(nid): DialogueSession │
│ + has_active_dialogue(nid): bool        │
│ + update_dialogue_node(sid, nid): bool  │
│ + select_choice(sid, idx): bool         │
│ + add_dialogue_history(...): void        │
│ + get_dialogue_history(): Array          │
│ + get_npc_history(nid): Array           │
│ + clear_dialogue_history(): void         │
├─────────────────────────────────────────┤
│ - _active_sessions: Dictionary           │
│ - _dialogue_history: Array               │
│ - _session_counter: int                  │
├─────────────────────────────────────────┤
│ + dialogue_started(sid, nid, nname)     │
│ + dialogue_ended(sid, nid)              │
│ + dialogue_updated(sid, nid)            │
│ + dialogue_choice_selected(sid, idx)    │
│ + dialogue_history_added(history)        │
│ + all_dialogues_ended()                 │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│       DialogueSession (内部类)          │
├─────────────────────────────────────────┤
│ + session_id: String                    │
│ + npc_id: String                        │
│ + npc_name: String                      │
│ + dialogue_data: Dictionary             │
│ + current_node: String                  │
│ + is_active: bool                       │
│ + started_at: float                     │
│ + last_updated: float                   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│      DialogueHistory (内部类)           │
├─────────────────────────────────────────┤
│ + history_id: String                    │
│ + npc_id: String                        │
│ + npc_name: String                      │
│ + dialogue_content: String              │
│ + timestamp: float                      │
│ + player_choices: Array                 │
└─────────────────────────────────────────┘
```

#### 职责

- **会话管理**：创建、跟踪和销毁对话会话
- **历史记录**：保存和检索对话历史，支持持久化
- **事件分发**：广播对话事件给所有订阅者
- **资源协调**：管理活跃会话数量，防止资源耗尽
- **数据持久化**：自动保存对话历史到文件

#### 关键方法

```gdscript
func start_dialogue(npc_id: String, npc_name: String, dialogue_data: Dictionary) -> String:
    if _active_sessions.size() >= max_active_sessions:
        LogWrapper.warn(self, "Maximum active sessions reached: ", max_active_sessions)
        return ""

    var session_id: String = "dialogue_%d" % _session_counter
    _session_counter += 1

    var session: DialogueSession = DialogueSession.new(
        session_id, npc_id, npc_name, dialogue_data
    )
    _active_sessions[session_id] = session

    dialogue_started.emit(session_id, npc_id, npc_name)
    LogWrapper.debug(self, "Dialogue started: ", session_id, " with NPC: ", npc_name)

    return session_id
```

### 3. DialogueBox 组件

#### 类图

```
┌─────────────────────────────────────────┐
│          DialogueBox                    │
├─────────────────────────────────────────┤
│ + typing_speed: float                   │
│ + auto_continue_delay: float            │
│ + enable_typing_effect: bool            │
│ + enable_auto_continue: bool            │
│ + skip_on_key_press: bool               │
│ + fade_in_duration: float               │
│ + fade_out_duration: float             │
├─────────────────────────────────────────┤
│ + show_dialogue(name, text, choices)    │
│ + show_dialogue_with_session(sid, ...)  │
│ + hide_dialogue(): void                 │
│ + skip_typing(): void                   │
├─────────────────────────────────────────┤
│ - _current_text: String                 │
│ - _typing_timer: Timer                  │
│ - _auto_continue_timer: Timer           │
│ - _is_typing: bool                     │
│ - _is_skipped: bool                     │
│ - _current_choices: Array               │
│ - _dialogue_manager: DialogueManager   │
│ - _current_session_id: String           │
│ - _tween: Tween                        │
├─────────────────────────────────────────┤
│ + dialogue_finished()                   │
│ + choice_selected(idx)                  │
│ + skip_requested()                     │
└─────────────────────────────────────────┘
```

#### 职责

- **UI 显示**：渲染对话文本、NPC 名称和选项
- **动画效果**：提供淡入淡出、滑动等视觉效果
- **打字机效果**：逐步显示文本，增强沉浸感
- **用户交互**：处理点击、键盘输入等用户操作
- **自动继续**：支持自动跳到下一条对话

### 4. DialogueTrigger 组件

#### 类图

```
┌─────────────────────────────────────────┐
│        DialogueTrigger                  │
├─────────────────────────────────────────┤
│ + npc_id: String                        │
│ + npc_name: String                      │
│ + npc_dialogue_node: NodePath           │
│ + trigger_radius: float                 │
│ + trigger_on_proximity: bool            │
│ + trigger_on_interaction: bool          │
│ + interaction_key: String               │
│ + single_use: bool                      │
│ + pause_game_on_dialogue: bool         │
│ + pause_player_movement: bool           │
│ + pause_player_camera: bool             │
│ + show_trigger_area: bool               │
│ + trigger_area_color: Color             │
├─────────────────────────────────────────┤
│ + set_npc_dialogue(nd): void            │
│ + set_trigger_radius(r): void           │
│ + is_dialogue_active(): bool            │
│ + is_player_in_range(): bool           │
│ + get_triggered_count(): int            │
│ + reset_trigger(): void                 │
├─────────────────────────────────────────┤
│ - _npc_dialogue: NPCDialogue            │
│ - _player_in_range: bool                │
│ - _dialogue_active: bool                │
│ - _triggered_count: int                 │
│ - _player_node: Node3D                  │
│ - _collision_shape: CollisionShape3D    │
│ - _mesh_instance: MeshInstance3D        │
├─────────────────────────────────────────┤
│ + dialogue_triggered(npc_id, npc_name)  │
│ + dialogue_ended(npc_id)               │
└─────────────────────────────────────────┘
```

#### 职责

- **碰撞检测**：使用 Area3D 检测玩家是否在触发范围内
- **输入处理**：监听交互按键，处理玩家输入
- **触发控制**：根据配置决定何时触发对话
- **游戏暂停**：对话时暂停游戏、玩家移动和相机
- **视觉反馈**：显示触发区域，提供视觉提示

### 5. NPCProfile 资源

#### 类图

```
┌─────────────────────────────────────────┐
│         NPCProfile                      │
├─────────────────────────────────────────┤
│ + npc_id: String                        │
│ + display_name: String                  │
│ + avatar_texture: Texture2D             │
│ + is_enabled: bool                      │
│ + identity: String                      │
│ + personality: String                   │
│ + background_story: String              │
│ + speaking_style: String               │
│ + dialogue_style: DialogueStyle         │
│ + enable_streaming: bool                │
│ + streaming_speed: float                │
│ + max_memory_entries: int               │
│ + enable_context_memory: bool           │
│ + temperature: float                    │
│ + max_tokens: int                      │
│ + localized_names: Dictionary           │
│ + localized_identity: Dictionary        │
│ + localized_personality: Dictionary     │
│ + localized_background: Dictionary      │
│ + localized_speaking_style: Dictionary  │
│ + custom_keywords: Array                │
│ + forbidden_words: Array                │
│ + response_templates: Array            │
│ + initial_greeting: String              │
├─────────────────────────────────────────┤
│ + is_valid(): bool                      │
│ + get_localized_name(locale): String    │
│ + get_localized_identity(locale): Str   │
│ + get_dialogue_style_name(): String     │
│ + get_summary(): String                 │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│        DialogueStyle (枚举)             │
├─────────────────────────────────────────┤
│ FRIENDLY, FORMAL, CASUAL, MYSTERIOUS    │
│ HUMOROUS, SERIOUS, AGGRESSIVE, GENTLE   │
└─────────────────────────────────────────┘
```

#### 职责

- **配置存储**：集中存储 NPC 的所有配置信息
- **多语言支持**：提供本地化名称和描述
- **参数验证**：验证配置的有效性
- **资源导出**：支持导出为 .tres 文件

---

## 数据流设计

### 对话启动流程

```
玩家接近 NPC
    ↓
DialogueTrigger 检测到玩家
    ↓
触发条件判断（proximity 或 interaction）
    ↓
调用 NPCDialogue.start_npc_dialogue()
    ↓
NPCDialogue 调用 DialogueManager.start_dialogue()
    ↓
创建 DialogueSession
    ↓
NPCDialogue 调用 start_chat()
    ↓
NPCDialogue 发射 dialogue_started 信号
    ↓
DialogueBox 显示对话 UI
    ↓
NPC 准备接收玩家输入
```

### 消息处理流程

```
玩家发送消息
    ↓
NPCDialogue.send_npc_message(message)
    ↓
添加到记忆 (_add_to_memory)
    ↓
调用 NobodyWhoChat.send_message(message)
    ↓
发送请求到 AI API
    ↓
接收 AI 响应
    ↓
如果启用流式输出：
    ├─ 启动 _streaming_timer
    ├─ 逐步显示文本
    └─ 发射 message_streaming 信号
    ↓
添加到记忆
    ↓
更新上下文关键词
    ↓
返回完整响应
```

### 对话结束流程

```
玩家结束对话或离开范围
    ↓
NPCDialogue.end_npc_dialogue()
    ↓
停止流式输出
    ↓
调用 NobodyWhoChat.end_chat()
    ↓
调用 DialogueManager.end_dialogue(session_id)
    ↓
移除 DialogueSession
    ↓
发射 dialogue_ended 信号
    ↓
DialogueBox 隐藏对话 UI
    ↓
恢复游戏状态（如果暂停）
```

---

## 事件系统

### 信号架构

```
┌─────────────────────────────────────────┐
│         NPCDialogue                    │
├─────────────────────────────────────────┤
│ dialogue_started → DialogueTrigger      │
│ dialogue_ended → DialogueTrigger       │
│ message_streaming → DialogueBox         │
│ dialogue_interrupted → DialogueManager │
│ dialogue_resumed → DialogueManager     │
│ npc_personality_changed → DialogueBox   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│       DialogueManager                  │
├─────────────────────────────────────────┤
│ dialogue_started → 所有订阅者          │
│ dialogue_ended → 所有订阅者            │
│ dialogue_updated → 所有订阅者          │
│ dialogue_choice_selected → DialogueBox  │
│ dialogue_history_added → 所有订阅者    │
│ all_dialogues_ended → 所有订阅者       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│        DialogueTrigger                 │
├─────────────────────────────────────────┤
│ dialogue_triggered → 场景管理器        │
│ dialogue_ended → 场景管理器            │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│          DialogueBox                   │
├─────────────────────────────────────────┤
│ dialogue_finished → 场景管理器          │
│ choice_selected → DialogueManager       │
│ skip_requested → NPCDialogue           │
└─────────────────────────────────────────┘
```

### 事件传播机制

1. **自底向上**：事件从底层组件向上传播
2. **广播模式**：使用信号实现一对多通信
3. **异步处理**：信号调用是异步的，不会阻塞
4. **解耦设计**：组件之间不直接依赖，通过信号通信

---

## 状态管理

### 对话状态机

```
┌─────────────┐
│   IDLE      │ ← 初始状态
└──────┬──────┘
       │ start_dialogue()
       ↓
┌─────────────┐
│  STARTING   │ ← 正在初始化
└──────┬──────┘
       │ 初始化完成
       ↓
┌─────────────┐
│   ACTIVE    │ ← 等待玩家输入
└──────┬──────┘
       │ send_message()
       ↓
┌─────────────┐
│ STREAMING   │ ← 正在显示响应
└──────┬──────┘
       │ 流式输出完成
       ↓
┌─────────────┐
│   ACTIVE    │ ← 等待下一次输入
└──────┬──────┘
       │ interrupt_dialogue()
       ↓
┌─────────────┐
│ INTERRUPTED │ ← 暂停状态
└──────┬──────┘
       │ resume_dialogue()
       ↓
┌─────────────┐
│   ACTIVE    │ ← 恢复对话
└──────┬──────┘
       │ end_dialogue()
       ↓
┌─────────────┐
│   IDLE      │ ← 回到初始状态
└─────────────┘
```

### 会话状态

每个 DialogueSession 维护以下状态：
- `session_id`：唯一标识符
- `npc_id`：关联的 NPC ID
- `npc_name`：NPC 显示名称
- `dialogue_data`：对话数据
- `current_node`：当前对话节点
- `is_active`：是否活跃
- `started_at`：开始时间
- `last_updated`：最后更新时间

---

## 扩展性设计

### 自定义 NPC 类型

```gdscript
class_name CustomNPCDialogue
extends NPCDialogue

@export var custom_property: String = ""
@export var custom_behavior: bool = false

func _ready() -> void:
    super._ready()
    _setup_custom_behavior()

func _setup_custom_behavior() -> void:
    pass

func custom_method() -> void:
    pass
```

### 自定义对话风格

```gdscript
class_name CustomDialogueBox
extends DialogueBox

func show_dialogue(npc_name: String, text: String, choices: Array[Dictionary] = []) -> void:
    super.show_dialogue(npc_name, text, choices)
    _apply_custom_style()

func _apply_custom_style() -> void:
    pass
```

### 插件系统

```gdscript
class_name DialoguePlugin
extends Resource

var plugin_id: String = ""
var plugin_name: String = ""

func on_dialogue_started(npc_id: String, npc_name: String) -> void:
    pass

func on_dialogue_ended(npc_id: String) -> void:
    pass

func on_message_sent(message: String) -> String:
    return message

func on_response_received(response: String) -> String:
    return response
```

---

## 性能考虑

### 内存管理

1. **记忆限制**：每个 NPC 限制记忆条目数量
2. **会话限制**：限制同时活跃的对话会话数
3. **历史清理**：定期清理旧的对话历史
4. **对象池**：重用 UI 组件和临时对象

### CPU 优化

1. **异步处理**：AI 响应在后台线程处理
2. **批量更新**：减少 UI 更新频率
3. **延迟加载**：按需加载 NPC 配置
4. **事件节流**：避免频繁触发事件

### 网络优化

1. **响应缓存**：缓存常见问题的响应
2. **批量请求**：合并多个请求
3. **超时处理**：设置合理的超时时间
4. **重试机制**：实现智能重试策略

---

## 安全设计

### 输入验证

```gdscript
func send_npc_message(user_message: String) -> String:
    if not is_active:
        LogWrapper.warn(self, "Cannot send message - dialogue not active")
        return ""
    
    if _is_interrupted:
        LogWrapper.warn(self, "Cannot send message - dialogue interrupted")
        return ""
    
    if user_message.length() > 1000:
        LogWrapper.warn(self, "Message too long, truncating")
        user_message = user_message.substr(0, 1000)
    
    _add_to_memory("user", user_message)
    
    if enable_streaming:
        return _send_message_with_streaming(user_message)
    else:
        return send_message(user_message)
```

### 数据过滤

```gdscript
func _extract_keywords(text: String) -> Array[String]:
    var keywords: Array[String] = []
    var words: PackedStringArray = text.to_lower().split(" ", false)
    
    for word in words:
        if word.length() > 3:
            keywords.append(word)
    
    return keywords
```

### 权限控制

```gdscript
func _on_body_entered(body: Node) -> void:
    if body is Player or body.is_in_group("player"):
        _player_in_range = true
        _player_node = body as Node3D
        
        if trigger_on_proximity and not _dialogue_active:
            if single_use and _triggered_count > 0:
                return
            _trigger_dialogue()
```

---

## 总结

对话系统采用分层架构设计，各组件职责明确，通过信号系统实现松耦合通信。系统具有良好的扩展性和性能优化，支持多种自定义和插件机制。安全设计确保了系统的稳定性和可靠性。

关键设计亮点：
- 清晰的分层架构
- 灵活的事件系统
- 完善的状态管理
- 良好的扩展性
- 全面的性能优化
- 健壮的安全设计
