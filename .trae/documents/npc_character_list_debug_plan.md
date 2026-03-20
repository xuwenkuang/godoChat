# NPC角色列表调试计划

## 问题描述
测试时发现NPC菜单没有NPC信息，需要进行白盒测试。

## 调试目标
在关键代码位置添加调试日志，追踪NPC数据从加载到显示的完整流程。

## 关键代码位置

### 1. NPC角色列表栏位置
**文件**: [animal_chatroom_scene.gd](file:///Users/mac/project/godot/slg-takin-game-template/scenes/scene/animal_chatroom_scene/animal_chatroom_scene.gd)

**调试点1**: 变量定义 (第17行)
```gdscript
var animal_character_list: AnimalCharacterList
```

**调试点2**: 节点引用初始化 (第47行)
```gdscript
animal_character_list = $ChatroomScreen/ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/AnimalCharacterListPanel/AnimalCharacterList
```

**调试点3**: 信号连接 (第94-95行)
```gdscript
if animal_character_list:
    animal_character_list.character_selected.connect(_on_character_selected)
```

---

### 2. NPCList相关代码
**文件**: [animal_character_list.gd](file:///Users/mac/project/godot/slg-takin-game-template/scenes/component/chatroom/animal_character_list/animal_character_list.gd)

**调试点4**: 添加NPC方法 (第35-52行)
```gdscript
func add_character(npc_id: String, npc_name: String, avatar_texture: Texture2D = DEFAULT_AVATAR) -> void:
    if _character_items.has(npc_id):
        LogWrapper.warning(name, "Character with ID %s already exists in the list" % npc_id)
        return

    var character_item: CharacterItem = character_item_scene.instantiate() if character_item_scene else null
    if not character_item:
        LogWrapper.error(name, "Failed to instantiate character item scene")
        return

    character_item.set_character_data(npc_id, npc_name, avatar_texture)
    character_item.item_clicked.connect(_on_character_item_clicked.bind(npc_id))

    if character_list_container:
        character_list_container.add_child(character_item)
        _character_items[npc_id] = character_item

        LogWrapper.debug(name, "Added character %s to the list" % npc_id)
```

**调试点5**: 选择NPC方法 (第70-83行)
```gdscript
func select_character(npc_id: String) -> void:
    if not _character_items.has(npc_id):
        LogWrapper.warning(name, "Character with ID %s not found in the list" % npc_id)
        return

    _deselect_current_character()

    var character_item: CharacterItem = _character_items[npc_id]
    character_item.set_selected(true)
    _selected_npc_id = npc_id

    character_selected.emit(npc_id)

    LogWrapper.debug(name, "Selected character %s" % npc_id)
```

---

### 3. 添加NPC资源的位置
**文件**: [animal_chatroom_scene.gd](file:///Users/mac/project/godot/slg-takin-game-template/scenes/scene/animal_chatroom_scene/animal_chatroom_scene.gd)

**调试点6**: 加载NPC Profile (第98-122行)
```gdscript
func _load_animal_profiles() -> void:
    _animal_profiles.clear()

    var profile_files: Array[String] = [
        "res://resources/dialogue/animal_profiles/panda_profile.gd",
        "res://resources/dialogue/animal_profiles/elephant_profile.gd",
        "res://resources/dialogue/animal_profiles/giraffe_profile.gd",
        "res://resources/dialogue/animal_profiles/hippo_profile.gd",
        "res://resources/dialogue/animal_profiles/monkey_profile.gd",
        "res://resources/dialogue/animal_profiles/parrot_profile.gd",
        "res://resources/dialogue/animal_profiles/penguin_profile.gd",
        "res://resources/dialogue/animal_profiles/pig_profile.gd",
        "res://resources/dialogue/animal_profiles/rabbit_profile.gd",
        "res://resources/dialogue/animal_profiles/snake_profile.gd"
    ]

    for profile_file: String in profile_files:
        var profile_script: GDScript = load(profile_file) as GDScript
        if profile_script:
            var profile: NPCProfile = profile_script.create_profile()
            if profile and profile.is_valid():
                _animal_profiles[profile.npc_id] = profile
                _character_dialogue_history[profile.npc_id] = []

    LogWrapper.debug(self, "Loaded ", _animal_profiles.size(), " animal profiles")
```

**调试点7**: 设置NPC列表 (第130-152行)
```gdscript
func _setup_animal_character_list() -> void:
    if not animal_character_list:
        return

    animal_character_list.clear_list()

    if _animal_profiles.is_empty():
        _load_animal_profiles()

    for npc_id: String in _animal_profiles.keys():
        var profile: NPCProfile = _animal_profiles[npc_id]
        if profile and profile.is_valid():
            animal_character_list.add_character(
                profile.npc_id,
                profile.display_name,
                profile.avatar_texture
            )

    if _animal_profiles.size() > 0:
        var first_npc_id: String = _animal_profiles.keys()[0]
        animal_character_list.select_character(first_npc_id)

    LogWrapper.debug(self, "Setup animal character list with ", _animal_profiles.size(), " characters")
```

**调试点8**: 场景初始化 (第67-71行)
```gdscript
func _enter_tree() -> void:
    if not _is_initialized:
        _load_animal_profiles()
        _preload_animal_avatars()
        LogWrapper.info(self, "Scene initialized on enter_tree")
```

**调试点9**: _ready方法调用 (第42-64行)
```gdscript
func _ready() -> void:
    start_screen = $StartScreen
    chatroom_screen = $ChatroomScreen
    title_label = $StartScreen/StartScreenCenterContainer/StartScreenVBoxContainer/TitleLabel
    start_button = $StartScreen/StartScreenCenterContainer/StartScreenVBoxContainer/StartButton
    animal_character_list = $ChatroomScreen/ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/AnimalCharacterListPanel/AnimalCharacterList
    character_info_panel = $ChatroomScreen/ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomContentHBoxContainer/CharacterInfoPanelPanel/CharacterInfoPanel
    dialogue_history_panel = $ChatroomScreen/ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomContentHBoxContainer/DialogueHistoryPanel/DialogueHistoryScrollContainer
    dialogue_history_label = $ChatroomScreen/ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomContentHBoxContainer/DialogueHistoryPanel/DialogueHistoryScrollContainer/DialogueHistoryLabel
    dialogue_history_container = $ChatroomScreen/ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomContentHBoxContainer/DialogueHistoryPanel/DialogueHistoryScrollContainer/DialogueHistoryContainer
    message_input_box = $ChatroomScreen/ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/MessageInputHBoxContainer/MessageInputBox
    send_button = $ChatroomScreen/ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/MessageInputHBoxContainer/SendButton
    back_button = $ChatroomScreen/ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomTopHBoxContainer/BackButton

    DialogueManager = get_node("/root/DialogueManager")
    message_send_audio = $MessageSendAudio
    message_receive_audio = $MessageReceiveAudio

    _connect_signals()
    _setup_animal_character_list()
    _refresh_labels()

    LogWrapper.debug(self, "Scene ready: ", scene_name)
```

---

## 调试步骤

### 步骤1: 在调试点6添加调试日志
在 `_load_animal_profiles()` 方法中添加详细日志：
- 记录每个profile文件的加载状态
- 记录profile是否成功创建
- 记录profile是否有效
- 记录最终加载的profile数量

### 步骤2: 在调试点7添加调试日志
在 `_setup_animal_character_list()` 方法中添加详细日志：
- 记录animal_character_list是否存在
- 记录_animal_profiles是否为空
- 记录每个NPC的添加过程
- 记录最终添加的NPC数量

### 步骤3: 在调试点4添加调试日志
在 `add_character()` 方法中添加详细日志：
- 记录传入的npc_id和npc_name
- 记录character_item_scene是否存在
- 记录character_item是否成功实例化
- 记录character_list_container是否存在
- 记录是否成功添加到容器

### 步骤4: 在调试点5添加调试日志
在 `select_character()` 方法中添加详细日志：
- 记录选中的npc_id
- 记录_character_items中是否有该npc_id
- 记录是否成功设置选中状态
- 记录是否成功发射信号

### 步骤5: 在调试点9添加调试日志
在 `_ready()` 方法中添加详细日志：
- 记录animal_character_list节点是否成功获取
- 记录_setup_animal_character_list()是否被调用

---

## 预期调试输出

### 正常流程的日志输出：
```
[INFO] Scene initialized on enter_tree
[DEBUG] Loaded 10 animal profiles
[DEBUG] Scene ready: Animal Chatroom Scene
[DEBUG] Setup animal character list with 10 characters
[DEBUG] Added character panda to the list
[DEBUG] Added character elephant to the list
...
[DEBUG] Selected character panda
```

### 可能的异常情况：
1. 如果profile文件加载失败，会看到加载失败的日志
2. 如果animal_character_list为null，会看到节点获取失败的日志
3. 如果character_item_scene为null，会看到实例化失败的日志
4. 如果character_list_container为null，会看到容器不存在的日志

---

## 测试检查清单

- [ ] 启动游戏，进入动物聊天室场景
- [ ] 检查控制台日志，确认 `_enter_tree()` 被调用
- [ ] 检查控制台日志，确认 `_load_animal_profiles()` 被调用
- [ ] 检查控制台日志，确认加载了10个animal profiles
- [ ] 检查控制台日志，确认 `_ready()` 被调用
- [ ] 检查控制台日志，确认 `animal_character_list` 节点成功获取
- [ ] 检查控制台日志，确认 `_setup_animal_character_list()` 被调用
- [ ] 检查控制台日志，确认所有NPC都被添加到列表
- [ ] 检查控制台日志，确认第一个NPC被选中
- [ ] 检查UI界面，确认NPC列表中有10个角色
- [ ] 点击NPC角色，确认可以正常选中

---

## 可能的问题和解决方案

### 问题1: animal_character_list为null
**原因**: 节点路径错误或节点不存在
**解决方案**: 检查.tscn文件中的节点路径是否正确

### 问题2: _animal_profiles为空
**原因**: profile文件加载失败或profile创建失败
**解决方案**: 检查profile文件路径是否正确，profile.create_profile()是否正常工作

### 问题3: character_item_scene为null
**原因**: 场景文件中未设置character_item_scene
**解决方案**: 检查.tscn文件中是否正确导出了character_item_scene

### 问题4: character_list_container为null
**原因**: find_child()未找到容器节点
**解决方案**: 检查节点名称是否正确，节点是否存在于场景中

---

## NPC Profile文件列表

所有profile文件位于: `res://resources/dialogue/animal_profiles/`

1. panda_profile.gd
2. elephant_profile.gd
3. giraffe_profile.gd
4. hippo_profile.gd
5. monkey_profile.gd
6. parrot_profile.gd
7. penguin_profile.gd
8. pig_profile.gd
9. rabbit_profile.gd
10. snake_profile.gd
