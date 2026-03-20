class_name ModelSettingsDialog
extends ConfirmationDialog

signal settings_saved(settings: Dictionary)

enum ModelType {
	LOCAL,
	REMOTE_OPENAI,
	REMOTE_CLAUDE,
	REMOTE_KIMI,
	REMOTE_CUSTOM
}

var model_type_option_button: OptionButton
var api_url_line_edit: LineEdit
var api_key_line_edit: LineEdit
var model_name_line_edit: LineEdit
var model_name_hint_label: Label
var temperature_spin_box: SpinBox
var max_tokens_spin_box: SpinBox

var current_settings: Dictionary = {}


func _ready() -> void:
	_get_node_references()
	_connect_signals()
	_populate_model_types()
	_load_current_settings()


func _get_node_references() -> void:
	model_type_option_button = $SettingsVBoxContainer/ModelTypeOptionButton
	api_url_line_edit = $SettingsVBoxContainer/ApiUrlLineEdit
	api_key_line_edit = $SettingsVBoxContainer/ApiKeyLineEdit
	model_name_line_edit = $SettingsVBoxContainer/ModelNameLineEdit
	temperature_spin_box = $SettingsVBoxContainer/TemperatureSpinBox
	max_tokens_spin_box = $SettingsVBoxContainer/MaxTokensSpinBox
	model_name_hint_label = $SettingsVBoxContainer/ModelNameHintLabel


func _connect_signals() -> void:
	confirmed.connect(_on_confirmed)
	canceled.connect(_on_canceled)
	close_requested.connect(_on_canceled)
	
	if model_type_option_button:
		model_type_option_button.item_selected.connect(_on_model_type_selected)


func _populate_model_types() -> void:
	if not model_type_option_button:
		return
	
	model_type_option_button.clear()
	model_type_option_button.add_item("本地模型", ModelType.LOCAL)
	model_type_option_button.add_item("OpenAI API", ModelType.REMOTE_OPENAI)
	model_type_option_button.add_item("Claude API", ModelType.REMOTE_CLAUDE)
	model_type_option_button.add_item("Kimi API", ModelType.REMOTE_KIMI)
	model_type_option_button.add_item("自定义 API", ModelType.REMOTE_CUSTOM)
	model_type_option_button.selected = 0


func _load_current_settings() -> void:
	var model_manager: Node = get_node("/root/ModelManager")
	if not model_manager:
		LogWrapper.warn(self, "ModelManager not found")
		return
	
	current_settings = model_manager.get_model_settings() if model_manager.has_method("get_model_settings") else {}
	
	if current_settings.is_empty():
		current_settings = _get_default_settings()
	
	_apply_settings_to_ui(current_settings)


func _get_default_settings() -> Dictionary:
	return {
		"model_type": ModelType.REMOTE_OPENAI,
		"api_url": "https://api.openai.com/v1/chat/completions",
		"api_key": "",
		"model_name": "gpt-3.5-turbo",
		"temperature": 0.7,
		"max_tokens": 1000
	}


func _apply_settings_to_ui(settings: Dictionary) -> void:
	if not model_type_option_button:
		return
	
	var model_type: int = settings.get("model_type", ModelType.REMOTE_OPENAI)
	model_type_option_button.selected = model_type
	
	_on_model_type_selected(model_type)
	
	if api_url_line_edit:
		api_url_line_edit.text = settings.get("api_url", "")
	
	if api_key_line_edit:
		api_key_line_edit.text = settings.get("api_key", "")
	
	if model_name_line_edit:
		model_name_line_edit.text = settings.get("model_name", "")
	
	if temperature_spin_box:
		temperature_spin_box.value = settings.get("temperature", 0.7)
	
	if max_tokens_spin_box:
		max_tokens_spin_box.value = settings.get("max_tokens", 1000)


func _on_model_type_selected(index: int) -> void:
	var model_type: int = model_type_option_button.get_item_id(index)
	
	match model_type:
		ModelType.LOCAL:
			_disable_remote_fields()
			_update_model_hint("")
		ModelType.REMOTE_OPENAI:
			_enable_remote_fields()
			if api_url_line_edit:
				api_url_line_edit.text = "https://api.openai.com/v1/chat/completions"
			if model_name_line_edit:
				model_name_line_edit.text = "gpt-3.5-turbo"
			_update_model_hint("可用模型: gpt-3.5-turbo, gpt-4, gpt-4-turbo")
		ModelType.REMOTE_CLAUDE:
			_enable_remote_fields()
			if api_url_line_edit:
				api_url_line_edit.text = "https://api.anthropic.com/v1/messages"
			if model_name_line_edit:
				model_name_line_edit.text = "claude-3-sonnet-20240229"
			_update_model_hint("可用模型: claude-3-sonnet-20240229, claude-3-opus-20240229")
		ModelType.REMOTE_KIMI:
			_enable_remote_fields()
			if api_url_line_edit:
				api_url_line_edit.text = "https://api.moonshot.cn/v1/chat/completions"
			if model_name_line_edit:
				model_name_line_edit.text = "moonshot-v1-8k"
			_update_model_hint("可用模型: moonshot-v1-8k, moonshot-v1-32k, moonshot-v1-128k")
		ModelType.REMOTE_CUSTOM:
			_enable_remote_fields()
			_update_model_hint("")


func _disable_remote_fields() -> void:
	if api_url_line_edit:
		api_url_line_edit.editable = false
		api_url_line_edit.modulate = Color(0.5, 0.5, 0.5, 1.0)
	
	if api_key_line_edit:
		api_key_line_edit.editable = false
		api_key_line_edit.modulate = Color(0.5, 0.5, 0.5, 1.0)
	
	if model_name_line_edit:
		model_name_line_edit.editable = false
		model_name_line_edit.modulate = Color(0.5, 0.5, 0.5, 1.0)


func _enable_remote_fields() -> void:
	if api_url_line_edit:
		api_url_line_edit.editable = true
		api_url_line_edit.modulate = Color.WHITE
	
	if api_key_line_edit:
		api_key_line_edit.editable = true
		api_key_line_edit.modulate = Color.WHITE
	
	if model_name_line_edit:
		model_name_line_edit.editable = true
		model_name_line_edit.modulate = Color.WHITE


func _update_model_hint(hint_text: String) -> void:
	if model_name_hint_label:
		model_name_hint_label.text = hint_text
		model_name_hint_label.visible = not hint_text.is_empty()


func _on_confirmed() -> void:
	var settings: Dictionary = _get_settings_from_ui()
	
	if _validate_settings(settings):
		_save_settings(settings)
		settings_saved.emit(settings)
		LogWrapper.info(self, "Model settings saved")
	else:
		LogWrapper.warn(self, "Invalid settings, not saved")


func _on_canceled() -> void:
	LogWrapper.debug(self, "Settings dialog canceled")


func _get_settings_from_ui() -> Dictionary:
	var model_type: int = model_type_option_button.selected if model_type_option_button else ModelType.REMOTE_OPENAI
	
	return {
		"model_type": model_type,
		"api_url": api_url_line_edit.text if api_url_line_edit else "",
		"api_key": api_key_line_edit.text if api_key_line_edit else "",
		"model_name": model_name_line_edit.text if model_name_line_edit else "",
		"temperature": temperature_spin_box.value if temperature_spin_box else 0.7,
		"max_tokens": int(max_tokens_spin_box.value) if max_tokens_spin_box else 1000
	}


func _validate_settings(settings: Dictionary) -> bool:
	var model_type: int = settings.get("model_type", ModelType.REMOTE_OPENAI)
	
	if model_type == ModelType.LOCAL:
		return true
	
	var api_url: String = settings.get("api_url", "")
	var api_key: String = settings.get("api_key", "")
	var model_name: String = settings.get("model_name", "")
	
	if api_url.is_empty():
		LogWrapper.warn(self, "API URL is required for remote models")
		return false
	
	if api_key.is_empty():
		LogWrapper.warn(self, "API Key is required for remote models")
		return false
	
	if model_name.is_empty():
		LogWrapper.warn(self, "Model name is required")
		return false
	
	return true


func _save_settings(settings: Dictionary) -> void:
	var model_manager: Node = get_node("/root/ModelManager")
	if not model_manager:
		LogWrapper.warn(self, "ModelManager not found")
		return
	
	if model_manager.has_method("set_model_settings"):
		model_manager.set_model_settings(settings)
	else:
		LogWrapper.warn(self, "ModelManager does not have set_model_settings method")
		_save_to_config_file(settings)


func _save_to_config_file(settings: Dictionary) -> void:
	var config_file: ConfigFile = ConfigFile.new()
	var config_path: String = "user://model_settings.cfg"
	
	var load_result: Error = config_file.load(config_path)
	if load_result != OK and load_result != ERR_FILE_NOT_FOUND:
		LogWrapper.error(self, "Failed to load config file: ", load_result)
		return
	
	config_file.set_value("model", "type", settings.get("model_type", ModelType.REMOTE_OPENAI))
	config_file.set_value("model", "api_url", settings.get("api_url", ""))
	config_file.set_value("model", "api_key", settings.get("api_key", ""))
	config_file.set_value("model", "model_name", settings.get("model_name", ""))
	config_file.set_value("model", "temperature", settings.get("temperature", 0.7))
	config_file.set_value("model", "max_tokens", settings.get("max_tokens", 1000))
	
	var save_result: Error = config_file.save(config_path)
	if save_result != OK:
		LogWrapper.error(self, "Failed to save config file: ", save_result)
	else:
		LogWrapper.info(self, "Settings saved to config file")
