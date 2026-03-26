class_name ItemTooltip
extends Control

@export_category("UI References")
@onready var item_texture_rect: TextureRect = %ItemTextureRect
@onready var item_name_label: Label = %ItemNameLabel
@onready var rarity_label: Label = %RarityLabel
@onready var type_label: Label = %TypeLabel
@onready var description_label: Label = %DescriptionLabel
@onready var usage_label: Label = %UsageLabel
@onready var effect_label: Label = %EffectLabel
@onready var value_label: Label = %ValueLabel
@onready var weight_label: Label = %WeightLabel
@onready var properties_container: VBoxContainer = %PropertiesContainer
@onready var tags_container: HBoxContainer = %TagsContainer
@onready var background_panel: Panel = %BackgroundPanel

var _current_item_profile: ItemProfile = null
var _target_control: Control = null
var _offset: Vector2 = Vector2(10, 10)

func _ready() -> void:
	visible = false
	mouse_filter = MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)

func show_tooltip(item_profile: ItemProfile, target_control: Control) -> void:
	_current_item_profile = item_profile
	_target_control = target_control
	
	if not item_profile:
		hide()
		return
	
	_update_tooltip_content()
	_update_position()
	visible = true

func hide_tooltip() -> void:
	visible = false
	_current_item_profile = null
	_target_control = null

func update_position() -> void:
	if _target_control:
		_update_position()

func _update_tooltip_content() -> void:
	if not _current_item_profile:
		return
	
	if item_texture_rect:
		item_texture_rect.texture = _current_item_profile.item_texture
	
	if item_name_label:
		item_name_label.text = _current_item_profile.item_name
		item_name_label.modulate = _current_item_profile.get_rarity_color()
	
	if rarity_label:
		rarity_label.text = _current_item_profile.get_rarity_name()
		rarity_label.modulate = _current_item_profile.get_rarity_color()
	
	if type_label:
		type_label.text = _current_item_profile.get_type_name()
	
	if description_label:
		var desc: String = _current_item_profile.description
		if desc.is_empty():
			description_label.visible = false
		else:
			description_label.visible = true
			description_label.text = desc
	
	if usage_label:
		var usage: String = _current_item_profile.usage
		if usage.is_empty():
			usage_label.visible = false
		else:
			usage_label.visible = true
			usage_label.text = "用途: " + usage
	
	if effect_label:
		var effect: String = _current_item_profile.effect
		if effect.is_empty():
			effect_label.visible = false
		else:
			effect_label.visible = true
			effect_label.text = "效果: " + effect
	
	if value_label:
		if _current_item_profile.value > 0:
			value_label.visible = true
			value_label.text = "价值: %d" % _current_item_profile.value
		else:
			value_label.visible = false
	
	if weight_label:
		if _current_item_profile.weight > 0:
			weight_label.visible = true
			weight_label.text = "重量: %.1f" % _current_item_profile.weight
		else:
			weight_label.visible = false
	
	if properties_container:
		_update_properties()
	
	if tags_container:
		_update_tags()

func _update_properties() -> void:
	if not properties_container:
		return
	
	for child in properties_container.get_children():
		child.queue_free()
	
	var properties: Dictionary = _current_item_profile.get_all_properties()
	
	if properties.is_empty():
		properties_container.visible = false
		return
	
	properties_container.visible = true
	
	for key: String in properties:
		var value: Variant = properties[key]
		var property_label: Label = Label.new()
		property_label.text = "%s: %s" % [key, str(value)]
		property_label.add_theme_font_size_override("font_size", 12)
		property_label.modulate = Color(0.7, 0.7, 0.7, 1)
		properties_container.add_child(property_label)

func _update_tags() -> void:
	if not tags_container:
		return
	
	for child in tags_container.get_children():
		child.queue_free()
	
	var tags: Array[String] = _current_item_profile.custom_tags
	
	if tags.is_empty():
		tags_container.visible = false
		return
	
	tags_container.visible = true
	
	for tag: String in tags:
		var tag_label: Label = Label.new()
		tag_label.text = tag
		tag_label.add_theme_font_size_override("font_size", 10)
		tag_label.modulate = Color(0.6, 0.8, 1.0, 1)
		tags_container.add_child(tag_label)

func _update_position() -> void:
	if not _target_control:
		return
	
	var global_pos: Vector2 = _target_control.get_global_position()
	var target_size: Vector2 = _target_control.get_size()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	var tooltip_pos: Vector2 = global_pos + target_size + _offset
	
	if tooltip_pos.x + size.x > viewport_size.x:
		tooltip_pos.x = global_pos.x - size.x - _offset.x
	
	if tooltip_pos.y + size.y > viewport_size.y:
		tooltip_pos.y = viewport_size.y - size.y - _offset.y
	
	global_position = tooltip_pos

func _process(_delta: float) -> void:
	if visible and _target_control:
		_update_position()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_tooltip()
