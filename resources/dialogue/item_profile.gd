class_name ItemProfile
extends Resource

@export_group("Basic Information")
@export var item_id: String = ""
@export var item_name: String = "物品"
@export var item_texture: Texture2D = null
@export var is_enabled: bool = true

@export_group("Item Properties")
@export var properties: Dictionary = {}
@export var rarity: ItemRarity = ItemRarity.COMMON
@export var item_type: ItemType = ItemType.GENERAL
@export var stack_size: int = 99
@export var is_consumable: bool = false
@export var is_quest_item: bool = false

@export_group("Usage Information")
@export var description: String = ""
@export var usage: String = ""
@export var effect: String = ""
@export var cooldown: float = 0.0

@export_group("Localization")
@export var localized_names: Dictionary = {}
@export var localized_descriptions: Dictionary = {}
@export var localized_usages: Dictionary = {}

@export_group("Advanced Settings")
@export var custom_tags: Array[String] = []
@export var required_level: int = 0
@export var value: int = 0
@export var weight: float = 1.0

enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

enum ItemType {
	GENERAL,
	WEAPON,
	ARMOR,
	CONSUMABLE,
	MATERIAL,
	QUEST,
	KEY
}

var _is_valid: bool = false

func _validate_profile() -> void:
	_is_valid = item_id != "" and item_name != ""
	if not _is_valid:
		push_warning("ItemProfile: Invalid profile - item_id and item_name are required")

func _post_validate() -> void:
	_validate_profile()

func is_valid() -> bool:
	return _is_valid

func get_localized_name(locale: String = "") -> String:
	if locale.is_empty():
		return item_name
	
	if localized_names.has(locale):
		return localized_names[locale]
	
	return item_name

func get_localized_description(locale: String = "") -> String:
	if locale.is_empty():
		return description
	
	if localized_descriptions.has(locale):
		return localized_descriptions[locale]
	
	return description

func get_localized_usage(locale: String = "") -> String:
	if locale.is_empty():
		return usage
	
	if localized_usages.has(locale):
		return localized_usages[locale]
	
	return usage

func get_property(key: String) -> Variant:
	if properties.has(key):
		return properties[key]
	return null

func set_property(key: String, property_value: Variant) -> void:
	properties[key] = property_value

func remove_property(key: String) -> void:
	properties.erase(key)

func has_property(key: String) -> bool:
	return properties.has(key)

func get_all_properties() -> Dictionary:
	return properties.duplicate()

func get_rarity_name() -> String:
	match rarity:
		ItemRarity.COMMON:
			return "普通"
		ItemRarity.UNCOMMON:
			return "优秀"
		ItemRarity.RARE:
			return "稀有"
		ItemRarity.EPIC:
			return "史诗"
		ItemRarity.LEGENDARY:
			return "传说"
		_:
			return "普通"

func get_rarity_color() -> Color:
	match rarity:
		ItemRarity.COMMON:
			return Color.WHITE
		ItemRarity.UNCOMMON:
			return Color.GREEN
		ItemRarity.RARE:
			return Color.BLUE
		ItemRarity.EPIC:
			return Color.PURPLE
		ItemRarity.LEGENDARY:
			return Color.GOLD
		_:
			return Color.WHITE

func get_type_name() -> String:
	match item_type:
		ItemType.GENERAL:
			return "通用"
		ItemType.WEAPON:
			return "武器"
		ItemType.ARMOR:
			return "护甲"
		ItemType.CONSUMABLE:
			return "消耗品"
		ItemType.MATERIAL:
			return "材料"
		ItemType.QUEST:
			return "任务物品"
		ItemType.KEY:
			return "钥匙"
		_:
			return "通用"

func export_to_dict() -> Dictionary:
	var data: Dictionary = {
		"item_id": item_id,
		"item_name": item_name,
		"is_enabled": is_enabled,
		"properties": properties,
		"rarity": rarity,
		"item_type": item_type,
		"stack_size": stack_size,
		"is_consumable": is_consumable,
		"is_quest_item": is_quest_item,
		"description": description,
		"usage": usage,
		"effect": effect,
		"cooldown": cooldown,
		"localized_names": localized_names,
		"localized_descriptions": localized_descriptions,
		"localized_usages": localized_usages,
		"custom_tags": custom_tags,
		"required_level": required_level,
		"value": value,
		"weight": weight
	}
	return data

func import_from_dict(data: Dictionary) -> void:
	if data.has("item_id"):
		item_id = data["item_id"]
	if data.has("item_name"):
		item_name = data["item_name"]
	if data.has("is_enabled"):
		is_enabled = data["is_enabled"]
	if data.has("properties"):
		properties = data["properties"]
	if data.has("rarity"):
		rarity = data["rarity"]
	if data.has("item_type"):
		item_type = data["item_type"]
	if data.has("stack_size"):
		stack_size = data["stack_size"]
	if data.has("is_consumable"):
		is_consumable = data["is_consumable"]
	if data.has("is_quest_item"):
		is_quest_item = data["is_quest_item"]
	if data.has("description"):
		description = data["description"]
	if data.has("usage"):
		usage = data["usage"]
	if data.has("effect"):
		effect = data["effect"]
	if data.has("cooldown"):
		cooldown = data["cooldown"]
	if data.has("localized_names"):
		localized_names = data["localized_names"]
	if data.has("localized_descriptions"):
		localized_descriptions = data["localized_descriptions"]
	if data.has("localized_usages"):
		localized_usages = data["localized_usages"]
	if data.has("custom_tags"):
		custom_tags = data["custom_tags"]
	if data.has("required_level"):
		required_level = data["required_level"]
	if data.has("value"):
		value = data["value"]
	if data.has("weight"):
		weight = data["weight"]
	
	_validate_profile()

func export_to_json_file(file_path: String) -> Error:
	var data: Dictionary = export_to_dict()
	var json_string: String = JSON.stringify(data, "\t")
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return ERR_FILE_CANT_OPEN
	
	file.store_string(json_string)
	file.close()
	return OK

func import_from_json_file(file_path: String) -> Error:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return ERR_FILE_CANT_OPEN
	
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)
	if parse_result != OK:
		return parse_result
	
	import_from_dict(json.data)
	return OK

func clone() -> ItemProfile:
	var new_profile: ItemProfile = ItemProfile.new()
	new_profile.import_from_dict(export_to_dict())
	return new_profile

func get_summary() -> String:
	var summary_parts: Array[String] = []
	summary_parts.append("物品: %s" % item_name)
	summary_parts.append("稀有度: %s" % get_rarity_name())
	summary_parts.append("类型: %s" % get_type_name())
	if not description.is_empty():
		summary_parts.append("描述: %s" % description)
	if not usage.is_empty():
		summary_parts.append("用途: %s" % usage)
	if value > 0:
		summary_parts.append("价值: %d" % value)
	summary_parts.append("启用: %s" % ("是" if is_enabled else "否"))
	
	return "\n".join(summary_parts)

func _to_string() -> String:
	return "ItemProfile(%s)" % item_id

func _get_property_list() -> Array:
	var properties_list: Array = []
	
	var rarity_property: Dictionary = {
		"name": "rarity",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Common,Uncommon,Rare,Epic,Legendary"
	}
	
	var type_property: Dictionary = {
		"name": "item_type",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "General,Weapon,Armor,Consumable,Material,Quest,Key"
	}
	
	properties_list.append(rarity_property)
	properties_list.append(type_property)
	
	return properties_list

func _validate_property(property: Dictionary) -> void:
	if property.name == "stack_size":
		if stack_size < 1 or stack_size > 9999:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "cooldown":
		if cooldown < 0.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "required_level":
		if required_level < 0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "value":
		if value < 0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "weight":
		if weight < 0.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
