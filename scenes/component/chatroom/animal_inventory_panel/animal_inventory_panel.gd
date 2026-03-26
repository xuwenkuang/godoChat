class_name AnimalInventoryPanel
extends Control

signal close_requested()

@export_category("UI References")
@onready var avatar_texture_rect: TextureRect = %AvatarTextureRect
@onready var name_label: Label = %NameLabel
@onready var inventory_label: Label = %InventoryLabel
@onready var inventory_container: VBoxContainer = %InventoryContainer
@onready var close_button: Button = %CloseButton
@onready var background_panel: Panel = %BackgroundPanel

@export_category("Item Profile")
@export var item_profile_manager: ItemProfileManager = null
@export var tooltip_scene: PackedScene = null

var _current_animal_profile: AnimalProfile = null
var _current_npc_profile: NPCProfile = null
var _item_tooltip: ItemTooltip = null

func _ready() -> void:
	_connect_signals()
	_setup_initial_state()
	_setup_tooltip()


func _connect_signals() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	
	if background_panel:
		background_panel.gui_input.connect(_on_background_gui_input)


func _setup_initial_state() -> void:
	clear_inventory()


func _setup_tooltip() -> void:
	if tooltip_scene:
		_item_tooltip = tooltip_scene.instantiate()
		add_child(_item_tooltip)
		_item_tooltip.mouse_filter = MOUSE_FILTER_IGNORE


func set_animal_profile(animal_profile: AnimalProfile, npc_profile: NPCProfile = null) -> void:
	_current_animal_profile = animal_profile
	_current_npc_profile = npc_profile
	
	if not animal_profile:
		clear_inventory()
		return
	
	_update_ui()


func clear_inventory() -> void:
	_current_animal_profile = null
	
	if avatar_texture_rect:
		avatar_texture_rect.texture = null
	
	if name_label:
		name_label.text = ""
	
	if inventory_label:
		inventory_label.text = ""
	
	if inventory_container:
		for child in inventory_container.get_children():
			child.queue_free()


func _update_ui() -> void:
	if not _current_animal_profile:
		return
	
	if avatar_texture_rect and _current_npc_profile and _current_npc_profile.avatar_texture:
		avatar_texture_rect.texture = _current_npc_profile.avatar_texture
	
	if name_label:
		var display_name: String = ""
		if _current_npc_profile:
			display_name = _current_npc_profile.display_name
		elif _current_animal_profile:
			display_name = _current_animal_profile.display_name if _current_animal_profile.has_method("get") else ""
		name_label.text = display_name + " 的背包"
	
	if inventory_label:
		var inventory_str: String = _current_animal_profile.get_inventory_as_string()
		if inventory_str == "空":
			inventory_label.text = "背包是空的"
		else:
			inventory_label.text = "背包内容: " + inventory_str
	
	if inventory_container:
		_update_inventory_items()


func _update_inventory_items() -> void:
	if not _current_animal_profile:
		return
	
	for child in inventory_container.get_children():
		child.queue_free()
	
	var inventory: Dictionary = _current_animal_profile.get_inventory()
	
	if inventory.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "背包是空的"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 16)
		empty_label.modulate = Color(0.6, 0.6, 0.6, 1)
		inventory_container.add_child(empty_label)
	else:
		for item: String in inventory:
			var quantity: int = inventory[item]
			var item_panel: Panel = _create_item_panel(item, quantity)
			inventory_container.add_child(item_panel)


func _create_item_panel(item_name: String, quantity: int) -> Panel:
	var panel: Panel = Panel.new()
	panel.custom_minimum_size = Vector2(0, 50)
	
	var margin_container: MarginContainer = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 12)
	margin_container.add_theme_constant_override("margin_right", 12)
	margin_container.add_theme_constant_override("margin_top", 8)
	margin_container.add_theme_constant_override("margin_bottom", 8)
	
	var hbox: HBoxContainer = HBoxContainer.new()
	
	var item_label: Label = Label.new()
	item_label.text = item_name
	item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_label.add_theme_font_size_override("font_size", 14)
	
	var quantity_label: Label = Label.new()
	quantity_label.text = "x%d" % quantity
	quantity_label.add_theme_font_size_override("font_size", 14)
	quantity_label.modulate = Color(0.4, 0.8, 0.4, 1)
	
	hbox.add_child(item_label)
	hbox.add_child(quantity_label)
	margin_container.add_child(hbox)
	panel.add_child(margin_container)
	
	var item_panel_script: RefCounted = ItemPanelHandler.new(item_name, panel, self)
	panel.set_meta("handler", item_panel_script)
	
	return panel


func _on_item_panel_clicked(item_name: String, panel: Panel) -> void:
	print("=== 物品点击事件 ===")
	print("物品名称: %s" % item_name)
	
	if not item_profile_manager:
		print("错误: item_profile_manager 未设置")
		return
	
	if _item_tooltip and _item_tooltip.visible:
		print("隐藏物品提示框")
		_item_tooltip.hide_tooltip()
	else:
		var item_profile: ItemProfile = item_profile_manager.get_item_profile(item_name)
		if item_profile and _item_tooltip:
			print("物品ID: %s" % item_profile.item_id)
			print("物品名称: %s" % item_profile.item_name)
			print("稀有度: %s" % item_profile.get_rarity_name())
			print("类型: %s" % item_profile.get_type_name())
			print("描述: %s" % item_profile.description)
			print("用途: %s" % item_profile.usage)
			print("效果: %s" % item_profile.effect)
			print("价值: %d" % item_profile.value)
			print("重量: %.1f" % item_profile.weight)
			print("属性: %s" % item_profile.get_all_properties())
			print("标签: %s" % item_profile.custom_tags)
			print("显示物品提示框")
			_item_tooltip.show_tooltip(item_profile, panel)
		else:
			print("警告: 未找到物品 '%s' 的配置信息" % item_name)


class ItemPanelHandler extends RefCounted:
	var _item_name: String
	var _panel: Panel
	var _parent: AnimalInventoryPanel
	
	func _init(item_name: String, panel: Panel, parent: AnimalInventoryPanel) -> void:
		_item_name = item_name
		_panel = panel
		_parent = parent
		_panel.gui_input.connect(_on_gui_input)
	
	func _on_gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_parent._on_item_panel_clicked(_item_name, _panel)
	
	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			if _panel and _panel.gui_input.is_connected(_on_gui_input):
				_panel.gui_input.disconnect(_on_gui_input)


func _on_close_button_pressed() -> void:
	close_requested.emit()


func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_requested.emit()


func _exit_tree() -> void:
	if close_button and close_button.pressed.is_connected(_on_close_button_pressed):
		close_button.pressed.disconnect(_on_close_button_pressed)
	
	if background_panel and background_panel.gui_input.is_connected(_on_background_gui_input):
		background_panel.gui_input.disconnect(_on_background_gui_input)
	
	if _item_tooltip:
		_item_tooltip.queue_free()
