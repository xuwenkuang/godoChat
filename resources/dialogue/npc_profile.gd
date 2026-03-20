class_name NPCProfile
extends Resource
## NPC 配置资源 - 定义 NPC 的基本信息、角色设定和对话配置
##
## 功能说明：
## - 存储 NPC 的基本信息（ID、名称、头像等）
## - 配置 NPC 的角色设定（身份、性格、背景故事、说话风格）
## - 设置对话配置（对话风格、记忆配置、参数配置）
## - 支持多语言配置
## - 支持资源导出和导入
## - 提供默认值和验证
##
## 使用场景：
## - 在编辑器中创建和编辑 NPC 配置
## - 通过代码加载和使用 NPC 配置
## - 导出配置到文件或从文件导入
##
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@export_group("Basic Information")
@export var npc_id: String = ""
@export var display_name: String = "NPC"
@export var avatar_texture: Texture2D = null
@export var is_enabled: bool = true

@export_group("Character Settings")
@export var identity: String = ""
@export var personality: String = ""
@export var background_story: String = ""
@export var speaking_style: String = ""

@export_group("Dialogue Configuration")
@export var dialogue_style: DialogueStyle = DialogueStyle.FRIENDLY
@export var enable_streaming: bool = true
@export var streaming_speed: float = 0.05
@export var max_memory_entries: int = 50
@export var enable_context_memory: bool = true
@export var temperature: float = 0.7
@export var max_tokens: int = 1000

@export_group("Localization")
@export var localized_names: Dictionary = {}
@export var localized_identity: Dictionary = {}
@export var localized_personality: Dictionary = {}
@export var localized_background: Dictionary = {}
@export var localized_speaking_style: Dictionary = {}

@export_group("Advanced Settings")
@export var custom_keywords: Array[String] = []
@export var forbidden_words: Array[String] = []
@export var response_templates: Array[String] = []
@export var initial_greeting: String = ""

enum DialogueStyle {
	FRIENDLY,
	FORMAL,
	CASUAL,
	MYSTERIOUS,
	HUMOROUS,
	SERIOUS,
	AGGRESSIVE,
	GENTLE
}

var _is_valid: bool = false

func _validate_profile() -> void:
	_is_valid = npc_id != "" and display_name != ""
	if not _is_valid:
		push_warning("NPCProfile: Invalid profile - npc_id and display_name are required")

func _post_validate() -> void:
	call_deferred("_validate_profile")


func is_valid() -> bool:
	return _is_valid


func get_localized_name(locale: String = "") -> String:
	if locale.is_empty():
		return display_name
	
	if localized_names.has(locale):
		return localized_names[locale]
	
	return display_name


func get_localized_identity(locale: String = "") -> String:
	if locale.is_empty():
		return identity
	
	if localized_identity.has(locale):
		return localized_identity[locale]
	
	return identity


func get_localized_personality(locale: String = "") -> String:
	if locale.is_empty():
		return personality
	
	if localized_personality.has(locale):
		return localized_personality[locale]
	
	return personality


func get_localized_background(locale: String = "") -> String:
	if locale.is_empty():
		return background_story
	
	if localized_background.has(locale):
		return localized_background[locale]
	
	return background_story


func get_localized_speaking_style(locale: String = "") -> String:
	if locale.is_empty():
		return speaking_style
	
	if localized_speaking_style.has(locale):
		return localized_speaking_style[locale]
	
	return speaking_style


func get_personality_dict() -> Dictionary:
	return {
		"name": display_name,
		"role": identity,
		"personality": personality,
		"background": background_story,
		"speaking_style": speaking_style
	}


func get_localized_personality_dict(locale: String = "") -> Dictionary:
	return {
		"name": get_localized_name(locale),
		"role": get_localized_identity(locale),
		"personality": get_localized_personality(locale),
		"background": get_localized_background(locale),
		"speaking_style": get_localized_speaking_style(locale)
	}


func get_dialogue_config() -> Dictionary:
	return {
		"enable_streaming": enable_streaming,
		"streaming_speed": streaming_speed,
		"max_memory_entries": max_memory_entries,
		"enable_context_memory": enable_context_memory,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"dialogue_style": dialogue_style
	}


func export_to_dict() -> Dictionary:
	var data: Dictionary = {
		"npc_id": npc_id,
		"display_name": display_name,
		"is_enabled": is_enabled,
		"identity": identity,
		"personality": personality,
		"background_story": background_story,
		"speaking_style": speaking_style,
		"dialogue_style": dialogue_style,
		"enable_streaming": enable_streaming,
		"streaming_speed": streaming_speed,
		"max_memory_entries": max_memory_entries,
		"enable_context_memory": enable_context_memory,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"localized_names": localized_names,
		"localized_identity": localized_identity,
		"localized_personality": localized_personality,
		"localized_background": localized_background,
		"localized_speaking_style": localized_speaking_style,
		"custom_keywords": custom_keywords,
		"forbidden_words": forbidden_words,
		"response_templates": response_templates,
		"initial_greeting": initial_greeting
	}
	return data


func import_from_dict(data: Dictionary) -> void:
	if data.has("npc_id"):
		npc_id = data["npc_id"]
	if data.has("display_name"):
		display_name = data["display_name"]
	if data.has("is_enabled"):
		is_enabled = data["is_enabled"]
	if data.has("identity"):
		identity = data["identity"]
	if data.has("personality"):
		personality = data["personality"]
	if data.has("background_story"):
		background_story = data["background_story"]
	if data.has("speaking_style"):
		speaking_style = data["speaking_style"]
	if data.has("dialogue_style"):
		dialogue_style = data["dialogue_style"]
	if data.has("enable_streaming"):
		enable_streaming = data["enable_streaming"]
	if data.has("streaming_speed"):
		streaming_speed = data["streaming_speed"]
	if data.has("max_memory_entries"):
		max_memory_entries = data["max_memory_entries"]
	if data.has("enable_context_memory"):
		enable_context_memory = data["enable_context_memory"]
	if data.has("temperature"):
		temperature = data["temperature"]
	if data.has("max_tokens"):
		max_tokens = data["max_tokens"]
	if data.has("localized_names"):
		localized_names = data["localized_names"]
	if data.has("localized_identity"):
		localized_identity = data["localized_identity"]
	if data.has("localized_personality"):
		localized_personality = data["localized_personality"]
	if data.has("localized_background"):
		localized_background = data["localized_background"]
	if data.has("localized_speaking_style"):
		localized_speaking_style = data["localized_speaking_style"]
	if data.has("custom_keywords"):
		custom_keywords = data["custom_keywords"]
	if data.has("forbidden_words"):
		forbidden_words = data["forbidden_words"]
	if data.has("response_templates"):
		response_templates = data["response_templates"]
	if data.has("initial_greeting"):
		initial_greeting = data["initial_greeting"]
	
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


func clone() -> NPCProfile:
	var new_profile: NPCProfile = NPCProfile.new()
	new_profile.import_from_dict(export_to_dict())
	return new_profile


func get_dialogue_style_name() -> String:
	match dialogue_style:
		DialogueStyle.FRIENDLY:
			return "friendly"
		DialogueStyle.FORMAL:
			return "formal"
		DialogueStyle.CASUAL:
			return "casual"
		DialogueStyle.MYSTERIOUS:
			return "mysterious"
		DialogueStyle.HUMOROUS:
			return "humorous"
		DialogueStyle.SERIOUS:
			return "serious"
		DialogueStyle.AGGRESSIVE:
			return "aggressive"
		DialogueStyle.GENTLE:
			return "gentle"
		_:
			return "friendly"


func set_dialogue_style_by_name(style_name: String) -> void:
	match style_name.to_lower():
		"friendly":
			dialogue_style = DialogueStyle.FRIENDLY
		"formal":
			dialogue_style = DialogueStyle.FORMAL
		"casual":
			dialogue_style = DialogueStyle.CASUAL
		"mysterious":
			dialogue_style = DialogueStyle.MYSTERIOUS
		"humorous":
			dialogue_style = DialogueStyle.HUMOROUS
		"serious":
			dialogue_style = DialogueStyle.SERIOUS
		"aggressive":
			dialogue_style = DialogueStyle.AGGRESSIVE
		"gentle":
			dialogue_style = DialogueStyle.GENTLE
		_:
			dialogue_style = DialogueStyle.FRIENDLY


func get_summary() -> String:
	var summary_parts: Array[String] = []
	summary_parts.append("NPC: %s" % display_name)
	if not identity.is_empty():
		summary_parts.append("身份: %s" % identity)
	if not personality.is_empty():
		summary_parts.append("性格: %s" % personality)
	summary_parts.append("对话风格: %s" % get_dialogue_style_name())
	summary_parts.append("启用: %s" % ("是" if is_enabled else "否"))
	
	return "\n".join(summary_parts)


func _to_string() -> String:
	return "NPCProfile(%s)" % npc_id


func _get_property_list() -> Array:
	var properties: Array = []
	
	var dialogue_style_property: Dictionary = {
		"name": "dialogue_style",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Friendly,Formal,Casual,Mysterious,Humorous,Serious,Aggressive,Gentle"
	}
	
	properties.append(dialogue_style_property)
	
	return properties


func _validate_property(property: Dictionary) -> void:
	if property.name == "temperature":
		if temperature < 0.0 or temperature > 2.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "max_tokens":
		if max_tokens < 1 or max_tokens > 4096:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "streaming_speed":
		if streaming_speed < 0.01 or streaming_speed > 1.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "max_memory_entries":
		if max_memory_entries < 1 or max_memory_entries > 1000:
			property.usage = PROPERTY_USAGE_NO_EDITOR
