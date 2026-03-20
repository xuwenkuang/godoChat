class_name NPCDialogue
extends NobodyWhoChat

signal dialogue_started(npc_id: String, npc_name: String)
signal dialogue_ended(npc_id: String)
signal message_streaming(content: String, is_complete: bool)
signal dialogue_interrupted(npc_id: String)
signal dialogue_resumed(npc_id: String)
signal npc_personality_changed(npc_id: String, personality: Dictionary)

@export_category("NPC Configuration")
@export var npc_id: String = ""
@export var npc_name: String = "NPC"
@export var npc_profile: NPCProfile = null
@export var npc_personality: Dictionary = {
	"name": "",
	"role": "",
	"personality": "",
	"background": "",
	"speaking_style": ""
}

@export_category("Dialogue Settings")
@export var enable_streaming: bool = true
@export var streaming_speed: float = 0.05
@export var max_memory_entries: int = 50
@export var enable_context_memory: bool = true

@export_category("Integration")
@export var auto_register_with_manager: bool = true

var _dialogue_manager: DialogueManager
var _model_manager: ModelManager
var _streaming_timer: Timer
var _current_stream_content: String = ""
var _is_streaming: bool = false
var _is_interrupted: bool = false
var _memory_entries: Array[Dictionary] = []
var _context_keywords: Array[String] = []

func _ready() -> void:
	super._ready()
	
	_setup_streaming_timer()
	_load_npc_profile()
	_connect_to_dialogue_manager()
	_setup_model()
	_build_system_prompt()
	
	LogWrapper.debug(self, "NPCDialogue initialized for: %s" % npc_name)
	
	if not Engine.is_editor_hint():
		SignalBus.language_changed.connect(_on_language_changed)


func _setup_streaming_timer() -> void:
	_streaming_timer = Timer.new()
	_streaming_timer.wait_time = streaming_speed
	_streaming_timer.one_shot = false
	_streaming_timer.timeout.connect(_on_streaming_timeout)
	add_child(_streaming_timer)


func _connect_to_dialogue_manager() -> void:
	if not auto_register_with_manager:
		return
	
	_dialogue_manager = DialogueManager
	if _dialogue_manager:
		_dialogue_manager.dialogue_started.connect(_on_manager_dialogue_started)
		_dialogue_manager.dialogue_ended.connect(_on_manager_dialogue_ended)


func _setup_model() -> void:
	_model_manager = ModelManager
	if not _model_manager:
		LogWrapper.error(self, "ModelManager not found")
		return
	
	var model_settings: Dictionary = _model_manager.get_model_settings() if _model_manager.has_method("get_model_settings") else {}
	
	if model_settings.is_empty():
		LogWrapper.debug(self, "No model settings available, using defaults")
		model_settings = _get_default_model_settings()
	
	var model_type: int = model_settings.get("model_type", 0)
	var model_node: NobodyWhoModel = null
	
	match model_type:
		0:
			model_node = _model_manager.get_default_model()
			if not model_node:
				LogWrapper.debug(self, "No default local model available, will use placeholder")
		_:
			if _model_manager.has_method("create_remote_model"):
				model_node = _model_manager.create_remote_model(model_settings)
				add_child(model_node)
			else:
				LogWrapper.error(self, "ModelManager does not support remote models")
	
	if not model_node:
		LogWrapper.debug(self, "No model configured for NPC: %s, using placeholder" % npc_name)
		return
	
	set_model(model_node)
	LogWrapper.debug(self, "Model set for NPC: %s (type: %s)" % [npc_name, model_type])


func _get_default_model_settings() -> Dictionary:
	return {
		"model_type": 1,
		"api_url": "https://api.openai.com/v1/chat/completions",
		"api_key": "",
		"model_name": "gpt-3.5-turbo",
		"temperature": 0.7,
		"max_tokens": 1000
	}


func reload_model() -> void:
	if model:
		model.queue_free()
		model = null
	
	_setup_model()
	LogWrapper.debug(self, "Model reloaded for NPC: %s" % npc_name)


func _load_npc_profile() -> void:
	if not npc_profile:
		return
	
	npc_id = npc_profile.npc_id
	npc_name = npc_profile.display_name
	
	var current_locale: String = TranslationServer.get_locale()
	var localized_personality: Dictionary = npc_profile.get_localized_personality_dict(current_locale)
	
	if localized_personality.name != "":
		npc_personality.name = localized_personality.name
	if localized_personality.role != "":
		npc_personality.role = localized_personality.role
	if localized_personality.personality != "":
		npc_personality.personality = localized_personality.personality
	if localized_personality.background != "":
		npc_personality.background = localized_personality.background
	if localized_personality.speaking_style != "":
		npc_personality.speaking_style = localized_personality.speaking_style


func _build_system_prompt() -> void:
	var prompt_parts: Array[String] = []
	
	if npc_personality.name != "":
		prompt_parts.append("你的名字是: " + npc_personality.name)
	
	if npc_personality.role != "":
		prompt_parts.append("你的身份是: " + npc_personality.role)
	
	if npc_personality.personality != "":
		prompt_parts.append("你的性格特点: " + npc_personality.personality)
	
	if npc_personality.background != "":
		prompt_parts.append("你的背景故事: " + npc_personality.background)
	
	if npc_personality.speaking_style != "":
		prompt_parts.append("你的说话风格: " + npc_personality.speaking_style)
	
	if prompt_parts.is_empty():
		prompt_parts.append("你是一个友好的游戏角色。")
	
	prompt_parts.append("请以角色的身份与玩家进行自然的对话。")
	
	set_system_prompt("\n".join(prompt_parts))


func set_npc_personality(personality: Dictionary) -> void:
	npc_personality = personality
	_build_system_prompt()
	npc_personality_changed.emit(npc_id, personality)
	LogWrapper.debug(self, "NPC personality updated for: %s" % npc_name)


func start_npc_dialogue() -> String:
	if npc_id == "":
		npc_id = "npc_" + str(get_instance_id())
	
	_is_interrupted = false
	_is_streaming = false
	_current_stream_content = ""
	
	start_chat()
	
	if _dialogue_manager:
		var session_id: String = _dialogue_manager.start_dialogue(npc_id, npc_name, {})
		dialogue_started.emit(npc_id, npc_name)
		return session_id
	
	dialogue_started.emit(npc_id, npc_name)
	return ""


func end_npc_dialogue() -> void:
	_is_interrupted = false
	_is_streaming = false
	
	if _streaming_timer and _streaming_timer.is_stopped() == false:
		_streaming_timer.stop()
	
	end_chat()
	
	if _dialogue_manager:
		var session: DialogueManager.DialogueSession = _dialogue_manager.get_npc_session(npc_id)
		if session:
			_dialogue_manager.end_dialogue(session.session_id)
	
	dialogue_ended.emit(npc_id)
	LogWrapper.debug(self, "NPC dialogue ended for: %s" % npc_name)


func send_npc_message(user_message: String) -> String:
	if not is_active:
		LogWrapper.warn(self, "Cannot send message - dialogue not active")
		return ""
	
	if _is_interrupted:
		LogWrapper.warn(self, "Cannot send message - dialogue interrupted")
		return ""
	
	_add_to_memory("user", user_message)
	
	if enable_streaming:
		return await _send_message_with_streaming(user_message)
	else:
		return await send_message(user_message)


func _send_message_with_streaming(user_message: String) -> String:
	if _is_streaming:
		LogWrapper.warn(self, "Already streaming, cannot send new message")
		return ""
	
	var full_response: String = await send_message(user_message)
	
	if full_response == "":
		return ""
	
	_is_streaming = true
	_current_stream_content = ""
	_streaming_timer.start()
	
	return full_response


func _on_streaming_timeout() -> void:
	if _current_stream_content.is_empty():
		var full_response: String = conversation_history.back().content if not conversation_history.is_empty() else ""
		if full_response != "":
			_stream_text(full_response)
		else:
			_stop_streaming()
		return
	
	_stop_streaming()


func _stream_text(text: String) -> void:
	var chars_per_tick: int = max(1, int(text.length() * streaming_speed / 0.1))
	
	if _current_stream_content.length() + chars_per_tick >= text.length():
		_current_stream_content = text
		message_streaming.emit(_current_stream_content, true)
		_add_to_memory("assistant", _current_stream_content)
		_stop_streaming()
	else:
		_current_stream_content = text.substr(0, _current_stream_content.length() + chars_per_tick)
		message_streaming.emit(_current_stream_content, false)


func _stop_streaming() -> void:
	_is_streaming = false
	if _streaming_timer:
		_streaming_timer.stop()


func interrupt_dialogue() -> void:
	if not is_active:
		return
	
	_is_interrupted = true
	_is_streaming = false
	
	if _streaming_timer and _streaming_timer.is_stopped() == false:
		_streaming_timer.stop()
	
	dialogue_interrupted.emit(npc_id)
	LogWrapper.debug(self, "NPC dialogue interrupted for: %s" % npc_name)


func resume_dialogue() -> void:
	if not is_active or not _is_interrupted:
		return
	
	_is_interrupted = false
	dialogue_resumed.emit(npc_id)
	LogWrapper.debug(self, "NPC dialogue resumed for: %s" % npc_name)


func _add_to_memory(role: String, content: String) -> void:
	if not enable_context_memory:
		return
	
	var memory_entry: Dictionary = {
		"role": role,
		"content": content,
		"timestamp": Time.get_unix_time_from_system(),
		"context_keywords": _extract_keywords(content)
	}
	
	_memory_entries.append(memory_entry)
	
	if _memory_entries.size() > max_memory_entries:
		_memory_entries.pop_front()
	
	_update_context_keywords()


func _extract_keywords(text: String) -> Array[String]:
	var keywords: Array[String] = []
	var words: PackedStringArray = text.to_lower().split(" ", false)
	
	for word in words:
		if word.length() > 3:
			keywords.append(word)
	
	return keywords


func _update_context_keywords() -> void:
	_context_keywords.clear()
	
	for entry: Dictionary in _memory_entries:
		var keywords: Array[String] = entry.get("context_keywords", [])
		for keyword: String in keywords:
			if not _context_keywords.has(keyword):
				_context_keywords.append(keyword)


func get_memory_entries() -> Array[Dictionary]:
	return _memory_entries.duplicate()


func get_context_keywords() -> Array[String]:
	return _context_keywords.duplicate()


func search_memory(keyword: String) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	
	for entry: Dictionary in _memory_entries:
		var content: String = entry.get("content", "").to_lower()
		if keyword.to_lower() in content:
			results.append(entry)
	
	return results


func clear_memory() -> void:
	_memory_entries.clear()
	_context_keywords.clear()
	LogWrapper.debug(self, "Memory cleared for: %s" % npc_name)


func get_npc_info() -> Dictionary:
	return {
		"npc_id": npc_id,
		"npc_name": npc_name,
		"personality": npc_personality,
		"is_active": is_active,
		"is_streaming": _is_streaming,
		"is_interrupted": _is_interrupted,
		"memory_count": _memory_entries.size(),
		"system_prompt": system_prompt
	}


func _on_manager_dialogue_started(session_id: String, p_npc_id: String, _p_npc_name: String) -> void:
	if p_npc_id == self.npc_id:
		LogWrapper.debug(self, "Dialogue started via manager: %s" % session_id)


func _on_manager_dialogue_ended(session_id: String, p_npc_id: String) -> void:
	if p_npc_id == self.npc_id:
		LogWrapper.debug(self, "Dialogue ended via manager: %s" % session_id)
		end_npc_dialogue()


func _on_language_changed(locale: String) -> void:
	_load_npc_profile()
	_build_system_prompt()
	LogWrapper.debug(self, "Language changed to: %s for NPC: %s" % [locale, npc_name])


func _exit_tree() -> void:
	if _streaming_timer:
		_streaming_timer.queue_free()
	
	if _dialogue_manager:
		_dialogue_manager.dialogue_started.disconnect(_on_manager_dialogue_started)
		_dialogue_manager.dialogue_ended.disconnect(_on_manager_dialogue_ended)
	
	if not Engine.is_editor_hint():
		if SignalBus.language_changed.is_connected(_on_language_changed):
			SignalBus.language_changed.disconnect(_on_language_changed)
