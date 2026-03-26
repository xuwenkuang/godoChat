class_name ItemConfigScene
extends Control

signal back_requested()

@export_category("UI References")
@onready var item_list_container: ScrollContainer = %ItemListContainer
@onready var item_list_vbox: VBoxContainer = %ItemListVBox
@onready var add_item_button: Button = %AddItemButton
@onready var back_button: Button = %BackButton

var item_profile_manager: ItemProfileManager = null
var _item_panels: Dictionary = {}
var _model_manager: ModelManager = null
var _is_generating: bool = false
const ITEM_CONFIG_FILE_PATH = "user://items.json"

func _ready() -> void:
	_connect_signals()
	_setup_initial_state()

func _connect_signals() -> void:
	if add_item_button:
		add_item_button.pressed.connect(_on_add_item_button_pressed)
	
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)

func _setup_initial_state() -> void:
	_initialize_item_manager()
	_initialize_model_manager()
	_refresh_item_list()

func _initialize_model_manager() -> void:
	_model_manager = get_node("/root/ModelManager")
	if not _model_manager:
		print("警告: ModelManager 未找到")

func _initialize_item_manager() -> void:
	if not item_profile_manager:
		item_profile_manager = ItemProfileManager.new()
		add_child(item_profile_manager)
		_load_default_items()

func _load_default_items() -> void:
	if _load_items_from_file():
		print("成功从文件加载物品配置")
		return
	
	print("文件不存在，加载默认物品")
	var banana: ItemProfile = ItemProfile.new()
	banana.item_id = "banana"
	banana.item_name = "香蕉"
	banana.description = "一种美味的热带水果，富含钾元素"
	banana.usage = "食用可恢复体力"
	banana.rarity = ItemProfile.ItemRarity.COMMON
	banana.item_type = ItemProfile.ItemType.CONSUMABLE
	banana.value = 5
	banana.weight = 0.2
	banana.is_consumable = true
	banana.properties = {"恢复体力": 20, "饱食度": 10}
	banana.custom_tags = ["水果", "食物"]
	banana._post_validate()
	item_profile_manager.register_item_profile(banana)
	
	var apple: ItemProfile = ItemProfile.new()
	apple.item_id = "apple"
	apple.item_name = "苹果"
	apple.description = "红彤彤的苹果，清脆可口"
	apple.usage = "食用可恢复少量体力"
	apple.rarity = ItemProfile.ItemRarity.COMMON
	apple.item_type = ItemProfile.ItemType.CONSUMABLE
	apple.value = 3
	apple.weight = 0.15
	apple.is_consumable = true
	apple.properties = {"恢复体力": 15, "饱食度": 8}
	apple.custom_tags = ["水果", "食物"]
	apple._post_validate()
	item_profile_manager.register_item_profile(apple)
	
	var water_bottle: ItemProfile = ItemProfile.new()
	water_bottle.item_id = "water_bottle"
	water_bottle.item_name = "水壶"
	water_bottle.description = "一个便携的水壶，可以储存饮用水"
	water_bottle.usage = "在旅途中提供水源"
	water_bottle.rarity = ItemProfile.ItemRarity.UNCOMMON
	water_bottle.item_type = ItemProfile.ItemType.GENERAL
	water_bottle.value = 20
	water_bottle.weight = 0.5
	water_bottle.properties = {"容量": 500, "耐久度": 100}
	water_bottle.custom_tags = ["容器", "生存"]
	water_bottle._post_validate()
	item_profile_manager.register_item_profile(water_bottle)
	
	_save_items_to_file()

func _load_items_from_file() -> bool:
	if not FileAccess.file_exists(ITEM_CONFIG_FILE_PATH):
		return false
	
	var file: FileAccess = FileAccess.open(ITEM_CONFIG_FILE_PATH, FileAccess.READ)
	if not file:
		print("无法打开物品配置文件: %s" % ITEM_CONFIG_FILE_PATH)
		return false
	
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)
	if parse_result != OK:
		print("解析物品配置文件失败")
		return false
	
	if json.data is Array:
		for item_data: Dictionary in json.data:
			var profile: ItemProfile = ItemProfile.new()
			profile.import_from_dict(item_data)
			if profile.is_valid():
				item_profile_manager.register_item_profile(profile)
		return true
	
	return false

func _save_items_to_file() -> bool:
	if not item_profile_manager:
		return false
	
	return item_profile_manager.save_all_profiles_to_json_file(ITEM_CONFIG_FILE_PATH)

func _refresh_item_list() -> void:
	if not item_list_vbox:
		return
	
	for child in item_list_vbox.get_children():
		child.queue_free()
	
	_item_panels.clear()
	
	if not item_profile_manager:
		return
	
	var item_ids: Array[String] = item_profile_manager.get_all_item_ids()
	
	if item_ids.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "暂无物品配置"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 16)
		empty_label.modulate = Color(0.6, 0.6, 0.6, 1)
		item_list_vbox.add_child(empty_label)
	else:
		for item_id: String in item_ids:
			var item_profile: ItemProfile = item_profile_manager.get_item_profile(item_id)
			if item_profile:
				var item_panel: Panel = _create_item_panel(item_profile)
				item_list_vbox.add_child(item_panel)
				_item_panels[item_id] = item_panel

func _create_item_panel(item_profile: ItemProfile) -> Panel:
	var panel: Panel = Panel.new()
	panel.custom_minimum_size = Vector2(0, 100)
	
	var margin_container: MarginContainer = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 16)
	margin_container.add_theme_constant_override("margin_right", 16)
	margin_container.add_theme_constant_override("margin_top", 12)
	margin_container.add_theme_constant_override("margin_bottom", 12)
	
	var main_hbox: HBoxContainer = HBoxContainer.new()
	main_hbox.add_theme_constant_override("separation", 15)
	
	var info_container: VBoxContainer = VBoxContainer.new()
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_container.add_theme_constant_override("separation", 8)
	
	var header_hbox: HBoxContainer = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 12)
	
	var name_label: Label = Label.new()
	name_label.text = item_profile.item_name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.modulate = item_profile.get_rarity_color()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	var type_label: Label = Label.new()
	type_label.text = item_profile.get_type_name()
	type_label.add_theme_font_size_override("font_size", 12)
	type_label.modulate = Color(0.6, 0.6, 0.6, 1)
	type_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	var rarity_label: Label = Label.new()
	rarity_label.text = item_profile.get_rarity_name()
	rarity_label.add_theme_font_size_override("font_size", 12)
	rarity_label.modulate = item_profile.get_rarity_color()
	rarity_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	header_hbox.add_child(name_label)
	header_hbox.add_child(type_label)
	header_hbox.add_child(rarity_label)
	
	var details_hbox: HBoxContainer = HBoxContainer.new()
	details_hbox.add_theme_constant_override("separation", 20)
	
	var description_label: Label = Label.new()
	description_label.text = item_profile.description
	description_label.add_theme_font_size_override("font_size", 12)
	description_label.modulate = Color(0.8, 0.8, 0.8, 1)
	description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	description_label.clip_contents = true
	description_label.custom_minimum_size = Vector2(0, 15)
	
	var value_label: Label = Label.new()
	value_label.text = "价值: %d" % item_profile.value
	value_label.add_theme_font_size_override("font_size", 11)
	value_label.modulate = Color(0.7, 0.7, 0.7, 1)
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	var weight_label: Label = Label.new()
	weight_label.text = "重量: %.1f" % item_profile.weight
	weight_label.add_theme_font_size_override("font_size", 11)
	weight_label.modulate = Color(0.7, 0.7, 0.7, 1)
	weight_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	var usage_label: Label = Label.new()
	usage_label.text = "用途: %s" % item_profile.usage
	usage_label.add_theme_font_size_override("font_size", 11)
	usage_label.modulate = Color(0.7, 0.7, 0.7, 1)
	usage_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	details_hbox.add_child(description_label)
	details_hbox.add_child(value_label)
	details_hbox.add_child(weight_label)
	details_hbox.add_child(usage_label)
	
	var tags_hbox: HBoxContainer = HBoxContainer.new()
	tags_hbox.add_theme_constant_override("separation", 6)
	
	if not item_profile.custom_tags.is_empty():
		for tag: String in item_profile.custom_tags:
			var tag_label: Label = Label.new()
			tag_label.text = tag
			tag_label.add_theme_font_size_override("font_size", 10)
			tag_label.modulate = Color(0.5, 0.7, 0.9, 1)
			tags_hbox.add_child(tag_label)
	
	info_container.add_child(header_hbox)
	info_container.add_child(details_hbox)
	info_container.add_child(tags_hbox)
	
	var delete_button: Button = Button.new()
	delete_button.text = "删除"
	delete_button.custom_minimum_size = Vector2(60, 30)
	delete_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	delete_button.pressed.connect(_on_delete_item_pressed.bind(item_profile.item_id))
	
	main_hbox.add_child(info_container)
	main_hbox.add_child(delete_button)
	margin_container.add_child(main_hbox)
	panel.add_child(margin_container)
	
	return panel

func _on_add_item_button_pressed() -> void:
	print("点击新增物品按钮")
	_show_add_item_dialog()

func _on_delete_item_pressed(item_id: String) -> void:
	print("删除物品: %s" % item_id)
	if item_profile_manager:
		item_profile_manager.unregister_item_profile(item_id)
		_refresh_item_list()
		_save_items_to_file()

func _on_back_button_pressed() -> void:
	back_requested.emit()

func _show_add_item_dialog() -> void:
	if _is_generating:
		print("正在生成中，请稍候...")
		return
	
	print("创建新增物品对话框")
	var dialog: Window = Window.new()
	dialog.title = "新增物品"
	dialog.unresizable = false
	dialog.size = Vector2i(400, 200)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	var name_container: HBoxContainer = HBoxContainer.new()
	var name_label: Label = Label.new()
	name_label.text = "物品名称: "
	name_label.custom_minimum_size = Vector2(80, 0)
	var name_line_edit: LineEdit = LineEdit.new()
	name_line_edit.placeholder_text = "请输入物品名称（AI将自动生成属性）"
	name_line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_container.add_child(name_label)
	name_container.add_child(name_line_edit)
	
	var hint_label: Label = Label.new()
	hint_label.text = "提示：输入物品名称后，AI 将自动生成物品的描述、用途、稀有度等属性"
	hint_label.add_theme_font_size_override("font_size", 12)
	hint_label.modulate = Color(0.6, 0.6, 0.6, 1)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	vbox.add_child(name_container)
	vbox.add_child(hint_label)
	
	var button_container: HBoxContainer = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 10)
	
	var confirm_button: Button = Button.new()
	confirm_button.text = "确定"
	confirm_button.custom_minimum_size = Vector2(100, 40)
	confirm_button.pressed.connect(func() -> void:
		print("确定按钮被点击")
		var item_name: String = name_line_edit.text
		print("输入的物品名称: %s" % item_name)
		
		if item_name.is_empty():
			print("错误: 物品名称不能为空")
			return
		
		_generate_item_with_ai(item_name)
		dialog.queue_free()
	)
	
	var cancel_button: Button = Button.new()
	cancel_button.text = "取消"
	cancel_button.custom_minimum_size = Vector2(100, 40)
	cancel_button.pressed.connect(func() -> void:
		print("取消按钮被点击")
		dialog.queue_free()
	)
	
	button_container.add_child(confirm_button)
	button_container.add_child(cancel_button)
	vbox.add_child(button_container)
	
	dialog.add_child(vbox)
	add_child(dialog)
	dialog.popup_centered()
	
	print("对话框已显示，等待用户输入")
	print("对话框类型: %s" % dialog.get_class())


func _generate_item_with_ai(item_name: String) -> void:
	print("=== 开始 AI 生成物品 ===")
	print("物品名称: %s" % item_name)
	
	if not _model_manager:
		print("错误: ModelManager 未找到")
		return
	
	_is_generating = true
	
	print("ModelManager 类型: %s" % _model_manager.get_class())
	print("ModelManager 路径: %s" % _model_manager.get_path())
	
	var model_settings: Dictionary = _model_manager.get_model_settings() if _model_manager.has_method("get_model_settings") else {}
	print("ModelManager 当前配置:")
	print("  model_type: %s" % model_settings.get("model_type", "未设置"))
	print("  api_url: %s" % model_settings.get("api_url", "未设置"))
	print("  api_key: %s" % ("***已设置***" if not model_settings.get("api_key", "").is_empty() else "未设置"))
	print("  model_name: %s" % model_settings.get("model_name", "未设置"))
	
	var model_node: NobodyWhoModel = null
	
	var model_type: int = model_settings.get("model_type", 0)
	print("尝试创建远程模型，类型: %d" % model_type)
	
	if model_type == 1:  # REMOTE_OPENAI
		print("创建 OpenAI 远程模型")
		model_node = _model_manager.create_remote_model({
			"api_url": model_settings.get("api_url", ""),
			"api_key": model_settings.get("api_key", ""),
			"model_name": model_settings.get("model_name", "")
		})
	elif model_type == 2:  # REMOTE_CLAUDE
		print("创建 Claude 远程模型")
		model_node = _model_manager.create_remote_model({
			"api_url": model_settings.get("api_url", ""),
			"api_key": model_settings.get("api_key", ""),
			"model_name": model_settings.get("model_name", "")
		})
	elif model_type == 3:  # REMOTE_KIMI
		print("创建 Kimi 远程模型")
		model_node = _model_manager.create_remote_model({
			"api_url": model_settings.get("api_url", ""),
			"api_key": model_settings.get("api_key", ""),
			"model_name": model_settings.get("model_name", "")
		})
	else:
		print("创建本地模型或自定义远程模型")
		model_node = _model_manager.create_remote_model({
			"api_url": model_settings.get("api_url", ""),
			"api_key": model_settings.get("api_key", ""),
			"model_name": model_settings.get("model_name", "")
		})
	
	if not model_node:
		print("错误: 无法创建模型节点")
		_is_generating = false
		return
	
	add_child(model_node)
	print("模型节点已创建并添加到场景")
	
	var prompt: String = _create_item_generation_prompt(item_name)
	
	if model_node.has_signal("generation_finished"):
		model_node.generation_finished.connect(_on_item_generation_finished, CONNECT_ONE_SHOT)
	else:
		print("警告: 模型节点没有 generation_finished 信号")
		_is_generating = false
		return
	
	if model_node.has_signal("generation_error"):
		model_node.generation_error.connect(_on_item_generation_error, CONNECT_ONE_SHOT)
	
	print("发送生成请求到模型...")
	model_node.generate_async(prompt)


func _create_item_generation_prompt(item_name: String) -> String:
	return """你是一个游戏物品设计专家。请根据物品名称生成物品的详细配置。

物品名称：%s

请以 JSON 格式返回物品配置，包含以下字段：
{
  "item_id": "物品的唯一ID（小写字母和下划线）",
  "item_name": "物品名称",
  "description": "物品的详细描述（20-50字）",
  "usage": "物品的用途（10-30字）",
  "effect": "物品的效果（可选，10-30字）",
  "rarity": "稀有度（可选值：COMMON, UNCOMMON, RARE, EPIC, LEGENDARY）",
  "item_type": "物品类型（可选值：GENERAL, WEAPON, ARMOR, CONSUMABLE, MATERIAL, QUEST, KEY）",
  "value": "物品价值（整数）",
  "weight": "物品重量（浮点数）",
  "properties": {
    "属性名": "属性值"
  },
  "custom_tags": ["标签1", "标签2"]
}

要求：
1. item_id 使用小写字母和下划线，例如：magic_sword
2. rarity 根据物品名称合理选择，普通物品用 COMMON，稀有物品用 RARE 或更高
3. item_type 根据物品名称合理选择
4. properties 包含 2-4 个相关属性
5. custom_tags 包含 2-3 个相关标签
6. 只返回 JSON，不要包含其他文字

请直接返回 JSON 格式，不要包含任何解释或说明。""" % item_name


func _on_item_generation_finished(result: String) -> void:
	print("物品生成完成")
	print("生成结果: %s" % result)
	
	_is_generating = false
	
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(result)
	
	if parse_result != OK:
		print("错误: 无法解析 AI 生成的 JSON: %s" % result)
		return
	
	var item_data: Dictionary = json.data
	
	if not item_data.has("item_name") or not item_data.has("item_id"):
		print("错误: 生成的 JSON 缺少必要字段")
		return
	
	var new_item: ItemProfile = ItemProfile.new()
	new_item.item_id = item_data.get("item_id", "")
	new_item.item_name = item_data.get("item_name", "")
	new_item.description = item_data.get("description", "")
	new_item.usage = item_data.get("usage", "")
	new_item.effect = item_data.get("effect", "")
	
	var rarity_str: String = item_data.get("rarity", "COMMON")
	match rarity_str.to_upper():
		"COMMON":
			new_item.rarity = ItemProfile.ItemRarity.COMMON
		"UNCOMMON":
			new_item.rarity = ItemProfile.ItemRarity.UNCOMMON
		"RARE":
			new_item.rarity = ItemProfile.ItemRarity.RARE
		"EPIC":
			new_item.rarity = ItemProfile.ItemRarity.EPIC
		"LEGENDARY":
			new_item.rarity = ItemProfile.ItemRarity.LEGENDARY
		_:
			new_item.rarity = ItemProfile.ItemRarity.COMMON
	
	var type_str: String = item_data.get("item_type", "GENERAL")
	match type_str.to_upper():
		"GENERAL":
			new_item.item_type = ItemProfile.ItemType.GENERAL
		"WEAPON":
			new_item.item_type = ItemProfile.ItemType.WEAPON
		"ARMOR":
			new_item.item_type = ItemProfile.ItemType.ARMOR
		"CONSUMABLE":
			new_item.item_type = ItemProfile.ItemType.CONSUMABLE
		"MATERIAL":
			new_item.item_type = ItemProfile.ItemType.MATERIAL
		"QUEST":
			new_item.item_type = ItemProfile.ItemType.QUEST
		"KEY":
			new_item.item_type = ItemProfile.ItemType.KEY
		_:
			new_item.item_type = ItemProfile.ItemType.GENERAL
	
	new_item.value = item_data.get("value", 0)
	new_item.weight = item_data.get("weight", 1.0)
	
	var properties_dict: Dictionary = item_data.get("properties", {})
	for key: String in properties_dict:
		new_item.set_property(key, properties_dict[key])
	
	var tags_array: Array = item_data.get("custom_tags", [])
	new_item.custom_tags.clear()
	for tag in tags_array:
		new_item.custom_tags.append(tag)
	
	new_item._post_validate()
	
	if new_item.is_valid() and item_profile_manager:
		item_profile_manager.register_item_profile(new_item)
		_refresh_item_list()
		_save_items_to_file()
		print("成功添加 AI 生成的物品: %s" % new_item.item_name)
	else:
		print("错误: AI 生成的物品无效")


func _on_item_generation_error(error: String) -> void:
	print("物品生成错误: %s" % error)
	_is_generating = false
