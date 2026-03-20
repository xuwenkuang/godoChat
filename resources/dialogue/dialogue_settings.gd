class_name DialogueSettings
extends Resource
## 对话参数配置资源 - 定义 LLM 生成和对话行为的所有参数
##
## 功能说明：
## - 配置 LLM 生成参数（温度、采样、最大长度等）
## - 配置采样器策略和重复惩罚
## - 配置流式输出行为
## - 配置记忆和上下文窗口
## - 支持参数验证和范围检查
## - 支持参数导出和导入
## - 提供默认值和预设配置
##
## 使用场景：
## - 在编辑器中创建和编辑对话参数配置
## - 通过代码加载和使用对话参数
## - 为不同 NPC 或场景使用不同的参数配置
## - 导出配置到文件或从文件导入
##
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@export_group("LLM Generation Parameters")
@export var temperature: float = 0.7
@export var top_p: float = 0.9
@export var top_k: int = 40
@export var max_tokens: int = 1000
@export var min_tokens: int = 10
@export var frequency_penalty: float = 0.0
@export var presence_penalty: float = 0.0
@export var repetition_penalty: float = 1.0

@export_group("Sampler Configuration")
@export var sampling_strategy: SamplingStrategy = SamplingStrategy.TOP_P
@export var enable_nucleus_sampling: bool = true
@export var enable_top_k_sampling: bool = false
@export var enable_beam_search: bool = false
@export var beam_width: int = 4
@export var beam_diversity: float = 0.5

@export_group("Streaming Configuration")
@export var enable_streaming: bool = true
@export var streaming_speed: float = 0.05
@export var streaming_delay: float = 0.0
@export var chunk_size: int = 10
@export var enable_realtime_display: bool = true

@export_group("Memory Configuration")
@export var max_memory_entries: int = 50
@export var enable_context_memory: bool = true
@export var context_window_size: int = 4096
@export var memory_retention_time: float = 3600.0
@export var enable_memory_compression: bool = false
@export var memory_compression_ratio: float = 0.7

@export_group("Advanced Settings")
@export var stop_sequences: Array[String] = []
@export var seed: int = -1
@export var enable_deterministic_output: bool = false
@export var custom_parameters: Dictionary = {}

enum SamplingStrategy {
	TOP_P,
	TOP_K,
	BEAM_SEARCH,
	MIXED
}

var _is_valid: bool = false
var _validation_errors: Array[String] = []


func _init() -> void:
	_validate_settings()


func _validate_settings() -> void:
	_validation_errors.clear()
	_is_valid = true
	
	if temperature < 0.0 or temperature > 2.0:
		_validation_errors.append("Temperature must be between 0.0 and 2.0")
		_is_valid = false
	
	if top_p < 0.0 or top_p > 1.0:
		_validation_errors.append("Top-p must be between 0.0 and 1.0")
		_is_valid = false
	
	if top_k < 1 or top_k > 100:
		_validation_errors.append("Top-k must be between 1 and 100")
		_is_valid = false
	
	if max_tokens < 1 or max_tokens > 8192:
		_validation_errors.append("Max tokens must be between 1 and 8192")
		_is_valid = false
	
	if min_tokens < 0 or min_tokens >= max_tokens:
		_validation_errors.append("Min tokens must be between 0 and max_tokens")
		_is_valid = false
	
	if frequency_penalty < -2.0 or frequency_penalty > 2.0:
		_validation_errors.append("Frequency penalty must be between -2.0 and 2.0")
		_is_valid = false
	
	if presence_penalty < -2.0 or presence_penalty > 2.0:
		_validation_errors.append("Presence penalty must be between -2.0 and 2.0")
		_is_valid = false
	
	if repetition_penalty < 1.0 or repetition_penalty > 2.0:
		_validation_errors.append("Repetition penalty must be between 1.0 and 2.0")
		_is_valid = false
	
	if streaming_speed < 0.01 or streaming_speed > 1.0:
		_validation_errors.append("Streaming speed must be between 0.01 and 1.0")
		_is_valid = false
	
	if streaming_delay < 0.0 or streaming_delay > 10.0:
		_validation_errors.append("Streaming delay must be between 0.0 and 10.0")
		_is_valid = false
	
	if chunk_size < 1 or chunk_size > 100:
		_validation_errors.append("Chunk size must be between 1 and 100")
		_is_valid = false
	
	if max_memory_entries < 1 or max_memory_entries > 1000:
		_validation_errors.append("Max memory entries must be between 1 and 1000")
		_is_valid = false
	
	if context_window_size < 512 or context_window_size > 32768:
		_validation_errors.append("Context window size must be between 512 and 32768")
		_is_valid = false
	
	if memory_retention_time < 60.0 or memory_retention_time > 86400.0:
		_validation_errors.append("Memory retention time must be between 60.0 and 86400.0")
		_is_valid = false
	
	if memory_compression_ratio < 0.1 or memory_compression_ratio > 1.0:
		_validation_errors.append("Memory compression ratio must be between 0.1 and 1.0")
		_is_valid = false
	
	if beam_width < 1 or beam_width > 10:
		_validation_errors.append("Beam width must be between 1 and 10")
		_is_valid = false
	
	if beam_diversity < 0.0 or beam_diversity > 1.0:
		_validation_errors.append("Beam diversity must be between 0.0 and 1.0")
		_is_valid = false


func is_valid() -> bool:
	return _is_valid


func get_validation_errors() -> Array[String]:
	return _validation_errors


func apply_to_model(model: Node) -> void:
	if model.has_method("set_generation_parameters"):
		model.set_generation_parameters(max_tokens, temperature, top_p, top_k)
	
	if model.has_method("set_frequency_penalty"):
		model.set_frequency_penalty(frequency_penalty)
	
	if model.has_method("set_presence_penalty"):
		model.set_presence_penalty(presence_penalty)
	
	if model.has_method("set_repetition_penalty"):
		model.set_repetition_penalty(repetition_penalty)
	
	if model.has_method("set_sampling_strategy"):
		model.set_sampling_strategy(sampling_strategy)
	
	if model.has_method("set_beam_search"):
		model.set_beam_search(beam_width, beam_diversity)


func update_parameter(param_name: String, value: Variant) -> bool:
	match param_name:
		"temperature":
			if value is float and value >= 0.0 and value <= 2.0:
				temperature = value
				return true
		"top_p":
			if value is float and value >= 0.0 and value <= 1.0:
				top_p = value
				return true
		"top_k":
			if value is int and value >= 1 and value <= 100:
				top_k = value
				return true
		"max_tokens":
			if value is int and value >= 1 and value <= 8192:
				max_tokens = value
				return true
		"min_tokens":
			if value is int and value >= 0 and value < max_tokens:
				min_tokens = value
				return true
		"frequency_penalty":
			if value is float and value >= -2.0 and value <= 2.0:
				frequency_penalty = value
				return true
		"presence_penalty":
			if value is float and value >= -2.0 and value <= 2.0:
				presence_penalty = value
				return true
		"repetition_penalty":
			if value is float and value >= 1.0 and value <= 2.0:
				repetition_penalty = value
				return true
		"streaming_speed":
			if value is float and value >= 0.01 and value <= 1.0:
				streaming_speed = value
				return true
		"streaming_delay":
			if value is float and value >= 0.0 and value <= 10.0:
				streaming_delay = value
				return true
		"chunk_size":
			if value is int and value >= 1 and value <= 100:
				chunk_size = value
				return true
		"max_memory_entries":
			if value is int and value >= 1 and value <= 1000:
				max_memory_entries = value
				return true
		"context_window_size":
			if value is int and value >= 512 and value <= 32768:
				context_window_size = value
				return true
		"memory_retention_time":
			if value is float and value >= 60.0 and value <= 86400.0:
				memory_retention_time = value
				return true
		"memory_compression_ratio":
			if value is float and value >= 0.1 and value <= 1.0:
				memory_compression_ratio = value
				return true
		"beam_width":
			if value is int and value >= 1 and value <= 10:
				beam_width = value
				return true
		"beam_diversity":
			if value is float and value >= 0.0 and value <= 1.0:
				beam_diversity = value
				return true
		"enable_streaming":
			if value is bool:
				set(param_name, value)
				return true
		"enable_context_memory":
			if value is bool:
				set(param_name, value)
				return true
		"enable_memory_compression":
			if value is bool:
				set(param_name, value)
				return true
		"enable_nucleus_sampling":
			if value is bool:
				set(param_name, value)
				return true
		"enable_top_k_sampling":
			if value is bool:
				set(param_name, value)
				return true
		"enable_beam_search":
			if value is bool:
				set(param_name, value)
				return true
		"enable_realtime_display":
			if value is bool:
				set(param_name, value)
				return true
		"enable_deterministic_output":
			if value is bool:
				set(param_name, value)
				return true
		"sampling_strategy":
			if value is int and value >= 0 and value < SamplingStrategy.size():
				sampling_strategy = value
				return true
		"seed":
			if value is int:
				seed = value
				return true
	
	return false


func get_parameter(param_name: String) -> Variant:
	if has_method("get"):
		return call("get", param_name)
	return null


func export_to_dict() -> Dictionary:
	var data: Dictionary = {
		"temperature": temperature,
		"top_p": top_p,
		"top_k": top_k,
		"max_tokens": max_tokens,
		"min_tokens": min_tokens,
		"frequency_penalty": frequency_penalty,
		"presence_penalty": presence_penalty,
		"repetition_penalty": repetition_penalty,
		"sampling_strategy": sampling_strategy,
		"enable_nucleus_sampling": enable_nucleus_sampling,
		"enable_top_k_sampling": enable_top_k_sampling,
		"enable_beam_search": enable_beam_search,
		"beam_width": beam_width,
		"beam_diversity": beam_diversity,
		"enable_streaming": enable_streaming,
		"streaming_speed": streaming_speed,
		"streaming_delay": streaming_delay,
		"chunk_size": chunk_size,
		"enable_realtime_display": enable_realtime_display,
		"max_memory_entries": max_memory_entries,
		"enable_context_memory": enable_context_memory,
		"context_window_size": context_window_size,
		"memory_retention_time": memory_retention_time,
		"enable_memory_compression": enable_memory_compression,
		"memory_compression_ratio": memory_compression_ratio,
		"stop_sequences": stop_sequences,
		"seed": seed,
		"enable_deterministic_output": enable_deterministic_output,
		"custom_parameters": custom_parameters
	}
	return data


func import_from_dict(data: Dictionary) -> void:
	if data.has("temperature"):
		temperature = data["temperature"]
	if data.has("top_p"):
		top_p = data["top_p"]
	if data.has("top_k"):
		top_k = data["top_k"]
	if data.has("max_tokens"):
		max_tokens = data["max_tokens"]
	if data.has("min_tokens"):
		min_tokens = data["min_tokens"]
	if data.has("frequency_penalty"):
		frequency_penalty = data["frequency_penalty"]
	if data.has("presence_penalty"):
		presence_penalty = data["presence_penalty"]
	if data.has("repetition_penalty"):
		repetition_penalty = data["repetition_penalty"]
	if data.has("sampling_strategy"):
		sampling_strategy = data["sampling_strategy"]
	if data.has("enable_nucleus_sampling"):
		enable_nucleus_sampling = data["enable_nucleus_sampling"]
	if data.has("enable_top_k_sampling"):
		enable_top_k_sampling = data["enable_top_k_sampling"]
	if data.has("enable_beam_search"):
		enable_beam_search = data["enable_beam_search"]
	if data.has("beam_width"):
		beam_width = data["beam_width"]
	if data.has("beam_diversity"):
		beam_diversity = data["beam_diversity"]
	if data.has("enable_streaming"):
		enable_streaming = data["enable_streaming"]
	if data.has("streaming_speed"):
		streaming_speed = data["streaming_speed"]
	if data.has("streaming_delay"):
		streaming_delay = data["streaming_delay"]
	if data.has("chunk_size"):
		chunk_size = data["chunk_size"]
	if data.has("enable_realtime_display"):
		enable_realtime_display = data["enable_realtime_display"]
	if data.has("max_memory_entries"):
		max_memory_entries = data["max_memory_entries"]
	if data.has("enable_context_memory"):
		enable_context_memory = data["enable_context_memory"]
	if data.has("context_window_size"):
		context_window_size = data["context_window_size"]
	if data.has("memory_retention_time"):
		memory_retention_time = data["memory_retention_time"]
	if data.has("enable_memory_compression"):
		enable_memory_compression = data["enable_memory_compression"]
	if data.has("memory_compression_ratio"):
		memory_compression_ratio = data["memory_compression_ratio"]
	if data.has("stop_sequences"):
		stop_sequences = data["stop_sequences"]
	if data.has("seed"):
		seed = data["seed"]
	if data.has("enable_deterministic_output"):
		enable_deterministic_output = data["enable_deterministic_output"]
	if data.has("custom_parameters"):
		custom_parameters = data["custom_parameters"]
	
	_validate_settings()


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


func clone() -> DialogueSettings:
	var new_settings: DialogueSettings = DialogueSettings.new()
	new_settings.import_from_dict(export_to_dict())
	return new_settings


static func create_default() -> DialogueSettings:
	return DialogueSettings.new()


static func create_creative() -> DialogueSettings:
	var settings: DialogueSettings = DialogueSettings.new()
	settings.temperature = 1.0
	settings.top_p = 0.95
	settings.top_k = 50
	settings.frequency_penalty = 0.3
	settings.presence_penalty = 0.3
	return settings


static func create_balanced() -> DialogueSettings:
	var settings: DialogueSettings = DialogueSettings.new()
	settings.temperature = 0.7
	settings.top_p = 0.9
	settings.top_k = 40
	settings.frequency_penalty = 0.0
	settings.presence_penalty = 0.0
	return settings


static func create_precise() -> DialogueSettings:
	var settings: DialogueSettings = DialogueSettings.new()
	settings.temperature = 0.3
	settings.top_p = 0.8
	settings.top_k = 20
	settings.frequency_penalty = -0.2
	settings.presence_penalty = -0.2
	return settings


static func create_fast() -> DialogueSettings:
	var settings: DialogueSettings = DialogueSettings.new()
	settings.temperature = 0.5
	settings.top_p = 0.85
	settings.top_k = 30
	settings.max_tokens = 500
	settings.streaming_speed = 0.03
	settings.chunk_size = 20
	return settings


static func create_detailed() -> DialogueSettings:
	var settings: DialogueSettings = DialogueSettings.new()
	settings.temperature = 0.8
	settings.top_p = 0.92
	settings.top_k = 45
	settings.max_tokens = 2000
	settings.min_tokens = 50
	settings.streaming_speed = 0.08
	return settings


func get_preset_name() -> String:
	if temperature == 1.0 and top_p == 0.95 and top_k == 50:
		return "creative"
	elif temperature == 0.3 and top_p == 0.8 and top_k == 20:
		return "precise"
	elif temperature == 0.5 and top_p == 0.85 and top_k == 30 and max_tokens == 500:
		return "fast"
	elif temperature == 0.8 and top_p == 0.92 and top_k == 45 and max_tokens == 2000:
		return "detailed"
	elif temperature == 0.7 and top_p == 0.9 and top_k == 40:
		return "balanced"
	else:
		return "custom"


func apply_preset(preset_name: String) -> void:
	match preset_name.to_lower():
		"creative":
			apply_preset_data(DialogueSettings.create_creative())
		"balanced":
			apply_preset_data(DialogueSettings.create_balanced())
		"precise":
			apply_preset_data(DialogueSettings.create_precise())
		"fast":
			apply_preset_data(DialogueSettings.create_fast())
		"detailed":
			apply_preset_data(DialogueSettings.create_detailed())


func apply_preset_data(preset: DialogueSettings) -> void:
	temperature = preset.temperature
	top_p = preset.top_p
	top_k = preset.top_k
	max_tokens = preset.max_tokens
	min_tokens = preset.min_tokens
	frequency_penalty = preset.frequency_penalty
	presence_penalty = preset.presence_penalty
	repetition_penalty = preset.repetition_penalty
	sampling_strategy = preset.sampling_strategy
	enable_nucleus_sampling = preset.enable_nucleus_sampling
	enable_top_k_sampling = preset.enable_top_k_sampling
	enable_beam_search = preset.enable_beam_search
	beam_width = preset.beam_width
	beam_diversity = preset.beam_diversity
	enable_streaming = preset.enable_streaming
	streaming_speed = preset.streaming_speed
	streaming_delay = preset.streaming_delay
	chunk_size = preset.chunk_size
	enable_realtime_display = preset.enable_realtime_display
	max_memory_entries = preset.max_memory_entries
	enable_context_memory = preset.enable_context_memory
	context_window_size = preset.context_window_size
	memory_retention_time = preset.memory_retention_time
	enable_memory_compression = preset.enable_memory_compression
	memory_compression_ratio = preset.memory_compression_ratio


func get_summary() -> String:
	var summary_parts: Array[String] = []
	summary_parts.append("预设: %s" % get_preset_name())
	summary_parts.append("温度: %.2f" % temperature)
	summary_parts.append("Top-p: %.2f" % top_p)
	summary_parts.append("Top-k: %d" % top_k)
	summary_parts.append("最大令牌: %d" % max_tokens)
	summary_parts.append("流式输出: %s" % ("启用" if enable_streaming else "禁用"))
	summary_parts.append("记忆条目: %d" % max_memory_entries)
	
	return "\n".join(summary_parts)


func _to_string() -> String:
	return "DialogueSettings(%s)" % get_preset_name()


func _get_property_list() -> Array:
	var properties: Array = []
	
	var sampling_strategy_property: Dictionary = {
		"name": "sampling_strategy",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Top-p,Top-k,Beam Search,Mixed"
	}
	
	properties.append(sampling_strategy_property)
	
	return properties


func _validate_property(property: Dictionary) -> void:
	if property.name == "temperature":
		if temperature < 0.0 or temperature > 2.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "top_p":
		if top_p < 0.0 or top_p > 1.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "top_k":
		if top_k < 1 or top_k > 100:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "max_tokens":
		if max_tokens < 1 or max_tokens > 8192:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "min_tokens":
		if min_tokens < 0 or min_tokens >= max_tokens:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "frequency_penalty":
		if frequency_penalty < -2.0 or frequency_penalty > 2.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "presence_penalty":
		if presence_penalty < -2.0 or presence_penalty > 2.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "repetition_penalty":
		if repetition_penalty < 1.0 or repetition_penalty > 2.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "streaming_speed":
		if streaming_speed < 0.01 or streaming_speed > 1.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "streaming_delay":
		if streaming_delay < 0.0 or streaming_delay > 10.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "chunk_size":
		if chunk_size < 1 or chunk_size > 100:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "max_memory_entries":
		if max_memory_entries < 1 or max_memory_entries > 1000:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "context_window_size":
		if context_window_size < 512 or context_window_size > 32768:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "memory_retention_time":
		if memory_retention_time < 60.0 or memory_retention_time > 86400.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "memory_compression_ratio":
		if memory_compression_ratio < 0.1 or memory_compression_ratio > 1.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "beam_width":
		if beam_width < 1 or beam_width > 10:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "beam_diversity":
		if beam_diversity < 0.0 or beam_diversity > 1.0:
			property.usage = PROPERTY_USAGE_NO_EDITOR