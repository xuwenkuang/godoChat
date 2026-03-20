# 对话系统代码示例和使用指南

## 目录
- [基础示例](#基础示例)
- [进阶示例](#进阶示例)
- [高级用法](#高级用法)
- [实战案例](#实战案例)
- [故障排除](#故障排除)
- [最佳实践](#最佳实践)

---

## 基础示例

### 示例 1：创建简单的 NPC

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue
@onready var dialogue_trigger = $DialogueTrigger

func _ready():
    _setup_npc()
    _connect_signals()

func _setup_npc():
    npc_dialogue.npc_id = "simple_npc"
    npc_dialogue.npc_name = "简单 NPC"
    npc_dialogue.npc_personality = {
        "name": "简单角色",
        "role": "游戏角色",
        "personality": "友好、乐于助人",
        "background": "这是一个简单的 NPC 示例",
        "speaking_style": "语速中等，语气亲切"
    }
    
    dialogue_trigger.trigger_radius = 3.0
    dialogue_trigger.trigger_on_proximity = true

func _connect_signals():
    npc_dialogue.dialogue_started.connect(_on_dialogue_started)
    npc_dialogue.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(npc_id: String, npc_name: String):
    print("对话开始: ", npc_name)

func _on_dialogue_ended(npc_id: String):
    print("对话结束")
```

### 示例 2：手动触发对话

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue

func _input(event):
    if event.is_action_pressed("ui_accept"):
        if not npc_dialogue.is_active:
            npc_dialogue.start_npc_dialogue()
        else:
            npc_dialogue.send_npc_message("你好！")

func _ready():
    npc_dialogue.dialogue_started.connect(_on_dialogue_started)
    npc_dialogue.message_streaming.connect(_on_message_streaming)

func _on_dialogue_started(npc_id: String, npc_name: String):
    print("与 ", npc_name, " 开始对话")

func _on_message_streaming(content: String, is_complete: bool):
    print("NPC: ", content)
```

### 示例 3：使用 NPCProfile 资源

```gdscript
extends Node3D

@export var npc_profile: NPCProfile

@onready var npc_dialogue = $NPCDialogue

func _ready():
    if npc_profile:
        _apply_profile()
    else:
        _create_default_profile()

func _apply_profile():
    npc_dialogue.npc_id = npc_profile.npc_id
    npc_dialogue.npc_name = npc_profile.display_name
    npc_dialogue.npc_personality = {
        "name": npc_profile.display_name,
        "role": npc_profile.identity,
        "personality": npc_profile.personality,
        "background": npc_profile.background_story,
        "speaking_style": npc_profile.speaking_style
    }
    npc_dialogue.enable_streaming = npc_profile.enable_streaming
    npc_dialogue.streaming_speed = npc_profile.streaming_speed
    npc_dialogue.max_memory_entries = npc_profile.max_memory_entries
    npc_dialogue.enable_context_memory = npc_profile.enable_context_memory

func _create_default_profile():
    npc_profile = NPCProfile.new()
    npc_profile.npc_id = "default_npc"
    npc_profile.display_name = "默认 NPC"
    npc_profile.identity = "默认角色"
    npc_profile.personality = "友好"
    npc_profile.background_story = "默认背景"
    npc_profile.speaking_style = "标准"
    _apply_profile()
```

### 示例 4：连接 DialogueBox

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue
@onready var dialogue_box = $DialogueUI/DialogueBox

func _ready():
    _connect_signals()

func _connect_signals():
    npc_dialogue.dialogue_started.connect(_on_dialogue_started)
    npc_dialogue.message_streaming.connect(_on_message_streaming)
    npc_dialogue.dialogue_ended.connect(_on_dialogue_ended)
    
    dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
    dialogue_box.choice_selected.connect(_on_choice_selected)

func _on_dialogue_started(npc_id: String, npc_name: String):
    dialogue_box.show_dialogue(npc_name, "你好！有什么我可以帮助你的吗？")

func _on_message_streaming(content: String, is_complete: bool):
    dialogue_box.dialogue_text_label.text = content

func _on_dialogue_ended(npc_id: String):
    dialogue_box.hide_dialogue()

func _on_dialogue_finished():
    print("对话完成")

func _on_choice_selected(choice_index: int):
    print("选择了选项: ", choice_index)
```

---

## 进阶示例

### 示例 5：多 NPC 管理

```gdscript
extends Node3D

var npc_dialogues: Array[NPCDialogue] = []
var current_dialogue: NPCDialogue = null

func _ready():
    _collect_npcs()
    _connect_all_signals()

func _collect_npcs():
    for child in get_children():
        if child is NPCDialogue:
            npc_dialogues.append(child)

func _connect_all_signals():
    for npc in npc_dialogues:
        npc.dialogue_started.connect(_on_any_dialogue_started)
        npc.dialogue_ended.connect(_on_any_dialogue_ended)

func _on_any_dialogue_started(npc_id: String, npc_name: String):
    if current_dialogue != null and current_dialogue.is_active:
        current_dialogue.interrupt_dialogue()
    
    for npc in npc_dialogues:
        if npc.npc_id == npc_id:
            current_dialogue = npc
            break

func _on_any_dialogue_ended(npc_id: String):
    if current_dialogue and current_dialogue.npc_id == npc_id:
        current_dialogue = null

func start_dialogue_with_npc(npc_name: String):
    for npc in npc_dialogues:
        if npc.npc_name == npc_name:
            npc.start_npc_dialogue()
            return
    print("未找到 NPC: ", npc_name)

func end_all_dialogues():
    for npc in npc_dialogues:
        if npc.is_active:
            npc.end_npc_dialogue()
```

### 示例 6：对话队列系统

```gdscript
extends Node3D

var dialogue_queue: Array[Dictionary] = []
var is_processing: bool = false

func _ready():
    pass

func queue_dialogue(npc: NPCDialogue, message: String = ""):
    dialogue_queue.append({
        "npc": npc,
        "message": message,
        "timestamp": Time.get_unix_time_from_system()
    })
    _process_queue()

func _process_queue():
    if is_processing or dialogue_queue.is_empty():
        return
    
    is_processing = true
    var next_dialogue = dialogue_queue.pop_front()
    var npc = next_dialogue["npc"]
    var message = next_dialogue["message"]
    
    npc.dialogue_started.connect(_on_dialogue_started.bind(npc))
    npc.dialogue_ended.connect(_on_dialogue_ended.bind(npc))
    
    npc.start_npc_dialogue()
    
    if not message.is_empty():
        npc.send_npc_message(message)

func _on_dialogue_started(npc: NPCDialogue):
    print("开始对话: ", npc.npc_name)

func _on_dialogue_ended(npc: NPCDialogue):
    npc.dialogue_started.disconnect(_on_dialogue_started)
    npc.dialogue_ended.disconnect(_on_dialogue_ended)
    
    is_processing = false
    _process_queue()

func get_queue_size() -> int:
    return dialogue_queue.size()

func clear_queue():
    dialogue_queue.clear()
```

### 示例 7：对话历史记录

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue
@onready var dialogue_manager = DialogueManager

func _ready():
    npc_dialogue.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended(npc_id: String):
    var history = dialogue_manager.get_npc_history(npc_id)
    print("与 ", npc_id, " 的对话历史:")
    for entry in history:
        print("  ", entry.dialogue_content)
        print("  时间: ", Time.get_datetime_string_from_unix_time(entry.timestamp))

func save_dialogue_history():
    var history = dialogue_manager.get_dialogue_history()
    var save_data = []
    
    for entry in history:
        save_data.append({
            "npc_id": entry.npc_id,
            "npc_name": entry.npc_name,
            "content": entry.dialogue_content,
            "timestamp": entry.timestamp,
            "choices": entry.player_choices
        })
    
    var file = FileAccess.open("user://dialogue_history.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()
        print("对话历史已保存")

func load_dialogue_history():
    var file = FileAccess.open("user://dialogue_history.json", FileAccess.READ)
    if file:
        var content = file.get_as_text()
        file.close()
        
        var json = JSON.new()
        var error = json.parse(content)
        
        if error == OK:
            var data = json.data
            print("加载了 ", data.size(), " 条对话记录")
            return data
        else:
            print("解析对话历史失败")
    
    return []
```

### 示例 8：上下文记忆管理

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue

func _ready():
    npc_dialogue.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended(npc_id: String):
    _analyze_memory()

func _analyze_memory():
    var memory_entries = npc_dialogue.get_memory_entries()
    print("记忆条目数: ", memory_entries.size())
    
    for entry in memory_entries:
        print("  角色: ", entry.role)
        print("  内容: ", entry.content)
        print("  关键词: ", entry.context_keywords)
        print("  时间: ", Time.get_datetime_string_from_unix_time(entry.timestamp))
        print("---")

func search_conversation(keyword: String):
    var results = npc_dialogue.search_memory(keyword)
    print("搜索 '", keyword, "' 的结果:")
    
    for result in results:
        print("  ", result.content)

func clear_old_memory(max_age_seconds: float = 3600):
    var memory_entries = npc_dialogue.get_memory_entries()
    var current_time = Time.get_unix_time_from_system()
    
    var entries_to_keep = []
    
    for entry in memory_entries:
        var age = current_time - entry.timestamp
        if age < max_age_seconds:
            entries_to_keep.append(entry)
    
    npc_dialogue.clear_memory()
    
    for entry in entries_to_keep:
        npc_dialogue._add_to_memory(entry.role, entry.content)
    
    print("清理了 ", memory_entries.size() - entries_to_keep.size(), " 条旧记忆")
```

### 示例 9：自定义对话触发器

```gdscript
extends Area3D

signal custom_dialogue_triggered(npc_id: String, trigger_type: String)

@export var npc_id: String = ""
@export var trigger_type: String = "default"
@export var trigger_radius: float = 3.0
@export var cooldown_time: float = 5.0

var _player_in_range: bool = false
var _last_trigger_time: float = 0.0
var _npc_dialogue: NPCDialogue

func _ready():
    _setup_collision_shape()
    _find_npc_dialogue()

func _setup_collision_shape():
    var collision_shape = CollisionShape3D.new()
    var sphere_shape = SphereShape3D.new()
    sphere_shape.radius = trigger_radius
    collision_shape.shape = sphere_shape
    add_child(collision_shape)
    
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _find_npc_dialogue():
    var parent_node = get_parent()
    if parent_node:
        for child in parent_node.get_children():
            if child is NPCDialogue:
                _npc_dialogue = child
                break

func _on_body_entered(body: Node):
    if body.is_in_group("player"):
        _player_in_range = true
        _check_trigger()

func _on_body_exited(body: Node):
    if body.is_in_group("player"):
        _player_in_range = false

func _check_trigger():
    if not _player_in_range:
        return
    
    var current_time = Time.get_unix_time_from_system()
    var time_since_last_trigger = current_time - _last_trigger_time
    
    if time_since_last_trigger < cooldown_time:
        return
    
    _last_trigger_time = current_time
    custom_dialogue_triggered.emit(npc_id, trigger_type)
    
    if _npc_dialogue and not _npc_dialogue.is_active:
        _npc_dialogue.start_npc_dialogue()

func set_npc_dialogue(npc: NPCDialogue):
    _npc_dialogue = npc
    if npc:
        npc_id = npc.npc_id
```

---

## 高级用法

### 示例 10：动态 NPC 个性

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue

var personality_states = {
    "friendly": {
        "name": "友好",
        "personality": "热情、乐于助人",
        "speaking_style": "语速快，语气亲切"
    },
    "angry": {
        "name": "愤怒",
        "personality": "暴躁、不耐烦",
        "speaking_style": "语速快，语气严厉"
    },
    "sad": {
        "name": "悲伤",
        "personality": "忧郁、低沉",
        "speaking_style": "语速慢，语气低沉"
    }
}

var current_state: String = "friendly"

func _ready():
    _apply_personality(current_state)

func change_personality_state(state: String):
    if personality_states.has(state):
        current_state = state
        _apply_personality(state)
        print("NPC 状态切换为: ", state)

func _apply_personality(state: String):
    var personality = personality_states[state]
    npc_dialogue.npc_personality = {
        "name": npc_dialogue.npc_name,
        "role": personality.name,
        "personality": personality.personality,
        "background": npc_dialogue.npc_personality.get("background", ""),
        "speaking_style": personality.speaking_style
    }
    npc_dialogue.set_npc_personality(npc_dialogue.npc_personality)

func get_current_state() -> String:
    return current_state
```

### 示例 11：对话分支系统

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue

var dialogue_branches = {
    "start": {
        "text": "你好！有什么我可以帮助你的吗？",
        "choices": [
            {"text": "询问任务", "next": "quest"},
            {"text": "询问商店", "next": "shop"},
            {"text": "告别", "next": "goodbye"}
        ]
    },
    "quest": {
        "text": "我有一个任务给你。你需要去森林里收集一些草药。",
        "choices": [
            {"text": "接受任务", "next": "quest_accepted"},
            {"text": "拒绝", "next": "quest_refused"}
        ]
    },
    "shop": {
        "text": "欢迎光临我的商店！看看有什么你需要的。",
        "choices": [
            {"text": "购买武器", "next": "buy_weapon"},
            {"text": "购买药水", "next": "buy_potion"},
            {"text": "返回", "next": "start"}
        ]
    },
    "goodbye": {
        "text": "再见！欢迎下次再来。",
        "choices": []
    }
}

var current_branch: String = "start"

func _ready():
    npc_dialogue.dialogue_started.connect(_on_dialogue_started)

func _on_dialogue_started(npc_id: String, npc_name: String):
    _show_branch(current_branch)

func _show_branch(branch_id: String):
    if not dialogue_branches.has(branch_id):
        print("未找到对话分支: ", branch_id)
        return
    
    var branch = dialogue_branches[branch_id]
    current_branch = branch_id
    
    npc_dialogue.send_npc_message(branch["text"])
    _show_choices(branch["choices"])

func _show_choices(choices: Array):
    print("可选选项:")
    for i in range(choices.size()):
        print("  ", i + 1, ". ", choices[i]["text"])

func select_choice(choice_index: int):
    var branch = dialogue_branches[current_branch]
    
    if choice_index >= 0 and choice_index < branch["choices"].size():
        var choice = branch["choices"][choice_index]
        var next_branch = choice["next"]
        _show_branch(next_branch)
    else:
        print("无效的选择")
```

### 示例 12：条件对话

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue

var player_reputation: int = 50
var has_completed_quest: bool = false
var has_special_item: bool = false

func _ready():
    npc_dialogue.dialogue_started.connect(_on_dialogue_started)

func _on_dialogue_started(npc_id: String, npc_name: String):
    var greeting = _get_conditional_greeting()
    npc_dialogue.send_npc_message(greeting)

func _get_conditional_greeting() -> String:
    if has_special_item:
        return "哦！你带着那个特殊的物品！看来你是个重要人物。"
    elif has_completed_quest:
        return "欢迎回来，英雄！你为我们做了很多。"
    elif player_reputation > 75:
        return "你好！你的名声很好，我很高兴见到你。"
    elif player_reputation > 25:
        return "你好。你看起来是个普通的冒险者。"
    else:
        return "哼，你有什么事？快说。"

func update_reputation(amount: int):
    player_reputation += amount
    player_reputation = clamp(player_reputation, 0, 100)
    print("声望更新为: ", player_reputation)

func set_quest_completed(completed: bool):
    has_completed_quest = completed

func set_has_special_item(has_item: bool):
    has_special_item = has_item
```

### 示例 13：对话动画集成

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue
@onready var animation_player = $AnimationPlayer
@onready var dialogue_box = $DialogueUI/DialogueBox

func _ready():
    _connect_signals()

func _connect_signals():
    npc_dialogue.dialogue_started.connect(_on_dialogue_started)
    npc_dialogue.dialogue_ended.connect(_on_dialogue_ended)
    npc_dialogue.message_streaming.connect(_on_message_streaming)

func _on_dialogue_started(npc_id: String, npc_name: String):
    _play_animation("talk_start")
    dialogue_box.show_dialogue(npc_name, "")

func _on_message_streaming(content: String, is_complete: bool):
    dialogue_box.dialogue_text_label.text = content
    
    if not is_complete:
        _play_animation("talking")
    else:
        _play_animation("talk_end")

func _on_dialogue_ended(npc_id: String):
    _play_animation("idle")
    dialogue_box.hide_dialogue()

func _play_animation(anim_name: String):
    if animation_player.has_animation(anim_name):
        animation_player.play(anim_name)
    else:
        print("动画不存在: ", anim_name)

func add_custom_animation(anim_name: String, anim_path: String):
    var animation = load(anim_path)
    if animation:
        animation_player.add_animation(anim_name, animation)
        print("添加动画: ", anim_name)
    else:
        print("无法加载动画: ", anim_path)
```

### 示例 14：多语言支持

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue

var current_locale: String = "zh_CN"

var localized_data = {
    "zh_CN": {
        "name": "村长",
        "greeting": "你好，年轻人。",
        "farewell": "再见。"
    },
    "en_US": {
        "name": "Village Elder",
        "greeting": "Hello, young one.",
        "farewell": "Goodbye."
    },
    "ja_JP": {
        "name": "村長",
        "greeting": "こんにちは、若者よ。",
        "farewell": "さようなら。"
    }
}

func _ready():
    _apply_localization()

func set_locale(locale: String):
    if localized_data.has(locale):
        current_locale = locale
        _apply_localization()
        print("语言切换为: ", locale)
    else:
        print("不支持的语言: ", locale)

func _apply_localization():
    var data = localized_data[current_locale]
    
    npc_dialogue.npc_personality = {
        "name": data["name"],
        "role": data["name"],
        "personality": "友好",
        "background": "村庄的长者",
        "speaking_style": "语速缓慢"
    }
    
    npc_dialogue.set_npc_personality(npc_dialogue.npc_personality)

func get_localized_text(key: String) -> String:
    if localized_data[current_locale].has(key):
        return localized_data[current_locale][key]
    return ""
```

---

## 实战案例

### 案例 1：任务系统集成

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue

var quest_data = {
    "collect_herbs": {
        "name": "收集草药",
        "description": "去森林收集10个草药",
        "reward": 100,
        "completed": false
    },
    "defeat_monster": {
        "name": "击败怪物",
        "description": "击败森林中的怪物",
        "reward": 200,
        "completed": false
    }
}

var active_quest: String = ""

func _ready():
    npc_dialogue.dialogue_started.connect(_on_dialogue_started)

func _on_dialogue_started(npc_id: String, npc_name: String):
    if active_quest.is_empty():
        _show_available_quests()
    else:
        _check_quest_progress()

func _show_available_quests():
    var message = "我有以下任务给你：\n"
    
    for quest_id in quest_data:
        var quest = quest_data[quest_id]
        if not quest["completed"]:
            message += "- " + quest["name"] + ": " + quest["description"] + "\n"
    
    message += "\n选择一个任务，或者说'不'来拒绝。"
    npc_dialogue.send_npc_message(message)

func _check_quest_progress():
    var quest = quest_data[active_quest]
    
    if quest["completed"]:
        npc_dialogue.send_npc_message("你完成了任务！这是你的奖励：" + str(quest["reward"]) + "金币。")
        active_quest = ""
    else:
        npc_dialogue.send_npc_message("你还没有完成任务。继续努力！")

func accept_quest(quest_id: String):
    if quest_data.has(quest_id):
        active_quest = quest_id
        npc_dialogue.send_npc_message("你接受了任务：" + quest_data[quest_id]["name"])
    else:
        npc_dialogue.send_npc_message("无效的任务。")

func complete_quest(quest_id: String):
    if quest_data.has(quest_id):
        quest_data[quest_id]["completed"] = true
        print("任务完成: ", quest_data[quest_id]["name"])
```

### 案例 2：商店系统

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue

var shop_items = [
    {"id": "sword", "name": "铁剑", "price": 100, "description": "一把普通的铁剑"},
    {"id": "shield", "name": "木盾", "price": 50, "description": "一个坚固的木盾"},
    {"id": "potion", "name": "治疗药水", "price": 25, "description": "恢复50点生命值"}
]

var player_gold: int = 150
var player_inventory: Array = []

func _ready():
    npc_dialogue.dialogue_started.connect(_on_dialogue_started)

func _on_dialogue_started(npc_id: String, npc_name: String):
    _show_shop_menu()

func _show_shop_menu():
    var message = "欢迎光临！我有以下商品：\n"
    message += "你的金币: " + str(player_gold) + "\n\n"
    
    for i in range(shop_items.size()):
        var item = shop_items[i]
        message += str(i + 1) + ". " + item["name"] + " - " + str(item["price"]) + "金币\n"
        message += "   " + item["description"] + "\n"
    
    message += "\n说'购买 [编号]'来购买商品，或者'离开'来退出。"
    npc_dialogue.send_npc_message(message)

func buy_item(item_index: int):
    if item_index < 0 or item_index >= shop_items.size():
        npc_dialogue.send_npc_message("无效的商品编号。")
        return
    
    var item = shop_items[item_index]
    
    if player_gold >= item["price"]:
        player_gold -= item["price"]
        player_inventory.append(item)
        npc_dialogue.send_npc_message("你购买了 " + item["name"] + "！剩余金币: " + str(player_gold))
    else:
        npc_dialogue.send_npc_message("你的金币不足！需要 " + str(item["price"]) + " 金币。")

func sell_item(item_index: int):
    if item_index < 0 or item_index >= player_inventory.size():
        npc_dialogue.send_npc_message("你没有这个物品。")
        return
    
    var item = player_inventory[item_index]
    var sell_price = int(item["price"] * 0.5)
    
    player_gold += sell_price
    player_inventory.remove_at(item_index)
    
    npc_dialogue.send_npc_message("你卖出了 " + item["name"] + "，获得 " + str(sell_price) + " 金币。")
```

### 案例 3：剧情对话系统

```gdscript
extends Node3D

@onready var npc_dialogue = $NPCDialogue

var story_chapters = [
    {
        "id": "chapter_1",
        "title": "第一章：开始",
        "dialogues": [
            "很久以前，在一个宁静的村庄里...",
            "村民们过着平静的生活，直到有一天...",
            "一个神秘的陌生人来到了村庄..."
        ]
    },
    {
        "id": "chapter_2",
        "title": "第二章：冒险",
        "dialogues": [
            "你决定跟随陌生人踏上冒险之旅。",
            "旅途中，你遇到了各种挑战。",
            "但你从未放弃..."
        ]
    },
    {
        "id": "chapter_3",
        "title": "第三章：结局",
        "dialogues": [
            "最终，你找到了真相。",
            "原来陌生人是在寻找失落的宝藏。",
            "你们一起找到了宝藏，成为了好朋友。"
        ]
    }
]

var current_chapter: int = 0
var current_dialogue: int = 0

func _ready():
    npc_dialogue.dialogue_started.connect(_on_dialogue_started)
    npc_dialogue.message_streaming.connect(_on_message_streaming)

func _on_dialogue_started(npc_id: String, npc_name: String):
    _start_chapter(current_chapter)

func _start_chapter(chapter_index: int):
    if chapter_index >= story_chapters.size():
        npc_dialogue.send_npc_message("故事结束了。感谢你的聆听！")
        return
    
    current_chapter = chapter_index
    current_dialogue = 0
    
    var chapter = story_chapters[chapter_index]
    npc_dialogue.send_npc_message(chapter["title"])
    _show_next_dialogue()

func _show_next_dialogue():
    var chapter = story_chapters[current_chapter]
    
    if current_dialogue < chapter["dialogues"].size():
        npc_dialogue.send_npc_message(chapter["dialogues"][current_dialogue])
        current_dialogue += 1
    else:
        _next_chapter()

func _next_chapter():
    current_chapter += 1
    _start_chapter(current_chapter)

func skip_to_chapter(chapter_index: int):
    if chapter_index >= 0 and chapter_index < story_chapters.size():
        current_chapter = chapter_index
        _start_chapter(chapter_index)
```

---

## 故障排除

### 问题 1：对话不触发

```gdscript
func debug_dialogue_trigger():
    var trigger = $DialogueTrigger
    
    print("触发器调试信息:")
    print("  触发半径: ", trigger.trigger_radius)
    print("  接近触发: ", trigger.trigger_on_proximity)
    print("  交互触发: ", trigger.trigger_on_interaction)
    print("  玩家在范围内: ", trigger.is_player_in_range())
    print("  对话活跃: ", trigger.is_dialogue_active())
    print("  触发次数: ", trigger.get_triggered_count())
```

### 问题 2：NPC 无响应

```gdscript
func debug_npc_dialogue():
    var npc = $NPCDialogue
    
    print("NPC 调试信息:")
    print("  NPC ID: ", npc.npc_id)
    print("  NPC 名称: ", npc.npc_name)
    print("  对话活跃: ", npc.is_active)
    print("  流式输出: ", npc._is_streaming)
    print("  中断状态: ", npc._is_interrupted)
    print("  记忆条目: ", npc.get_memory_entries().size())
    print("  系统提示: ", npc.system_prompt)
```

### 问题 3：性能问题

```gdscript
func monitor_performance():
    var manager = DialogueManager
    
    print("性能监控:")
    print("  活跃会话: ", manager.get_active_session_count())
    print("  历史记录: ", manager.get_history_count())
    print("  最大会话数: ", manager.max_active_sessions)
    print("  最大历史数: ", manager.max_history_size)
    
    for npc in get_tree().get_nodes_in_group("npc"):
        if npc is NPCDialogue:
            print("  NPC ", npc.npc_name, " 记忆: ", npc.get_memory_entries().size())
```

---

## 最佳实践

### 1. 资源管理

```gdscript
func cleanup_dialogue_resources():
    var manager = DialogueManager
    
    if manager.get_history_count() > 100:
        manager.clear_dialogue_history()
    
    for npc in get_tree().get_nodes_in_group("npc"):
        if npc is NPCDialogue:
            if npc.get_memory_entries().size() > 50:
                npc.clear_memory()
```

### 2. 错误处理

```gdscript
func safe_start_dialogue(npc: NPCDialogue) -> bool:
    if not npc:
        push_error("NPC 为空")
        return false
    
    if npc.is_active:
        push_warning("NPC 对话已活跃")
        return false
    
    try:
        npc.start_npc_dialogue()
        return true
    except:
        push_error("启动对话失败")
        return false
```

### 3. 日志记录

```gdscript
func log_dialogue_event(event_type: String, data: Dictionary):
    var log_entry = {
        "timestamp": Time.get_datetime_string_from_system(),
        "event": event_type,
        "data": data
    }
    
    print(JSON.stringify(log_entry))
```

### 4. 配置验证

```gdscript
func validate_npc_config(npc: NPCDialogue) -> bool:
    if npc.npc_id.is_empty():
        push_error("NPC ID 不能为空")
        return false
    
    if npc.npc_name.is_empty():
        push_error("NPC 名称不能为空")
        return false
    
    if npc.npc_personality.is_empty():
        push_warning("NPC 个性配置为空，使用默认配置")
    
    return true
```

---

## 总结

本文档提供了对话系统的全面代码示例和使用指南，从基础到高级，涵盖了各种实际应用场景。通过这些示例，您可以快速掌握对话系统的使用方法，并将其集成到您的游戏中。

关键要点：
- 从简单示例开始，逐步学习高级功能
- 使用 DialogueManager 管理对话会话
- 实现适当的错误处理和日志记录
- 优化性能，定期清理资源
- 根据游戏需求自定义对话系统

如有问题，请参考主文档或查看示例场景。
