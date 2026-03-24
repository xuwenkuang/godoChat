class_name AnimalChatroomSceneChat
extends Control

signal chatroom_started
signal chatroom_ended

@export_category("Scene Configuration")
@export var scene_name: String = "Animal Chatroom Scene Chat"

@export_category("UI References")
@export var npc_dialogues_container: Node

var animal_character_list: AnimalCharacterList
var character_info_panel: CharacterInfoPanel
var animal_inventory_panel: AnimalInventoryPanel
var message_input_box: MessageInputBox
var settings_button: MenuButtonClass
var back_button: MenuButtonClass
var chat_window_scroll_container: ScrollContainer
var chat_window_vbox_container: VBoxContainer

var DialogueManager: DialogueManager
var message_send_audio: AudioStreamPlayer
var message_receive_audio: AudioStreamPlayer
var model_settings_dialog: ModelSettingsDialog
var model_not_configured_dialog: AcceptDialog

var _is_chatroom_active: bool = false
var _animal_profiles: Dictionary = {}
var _current_selected_npc_id: String = ""
var _npc_dialogues: Dictionary = {}
var _active_dialogue_sessions: Dictionary = {}
var _is_initialized: bool = false
var _chat_history: Dictionary = {}

func _ready() -> void:
	LogWrapper.debug(self, "DEBUG: _ready() called")
	
	LogWrapper.debug(self, "DEBUG: Getting animal_character_list node reference")
	animal_character_list = $ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/AnimalCharacterListPanel/AnimalCharacterList
	LogWrapper.debug(self, "DEBUG: animal_character_list node: %s" % str(animal_character_list != null))
	
	character_info_panel = $ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomContentHBoxContainer/CharacterInfoPanelPanel/CharacterInfoPanel
	message_input_box = $ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomTopHBoxContainer/PaddingMarginContainer/MessageInputHBoxContainer/MessageInputBox
	back_button = $ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomTopHBoxContainer/BackButton
	settings_button = $ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomTopHBoxContainer/SettingsButton
	
	chat_window_scroll_container = $ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomContentHBoxContainer/ChatWindowPanel/ChatWindowMarginContainer/ChatWindowScrollContainer
	chat_window_vbox_container = $ChatroomScreenMarginContainer/ChatroomScreenHBoxContainer/ChatroomMainVBoxContainer/ChatroomContentHBoxContainer/ChatWindowPanel/ChatWindowMarginContainer/ChatWindowScrollContainer/ChatWindowVBoxContainer
	
	DialogueManager = get_node("/root/DialogueManager")
	message_send_audio = $MessageSendAudio
	message_receive_audio = $MessageReceiveAudio
	
	LogWrapper.debug(self, "DEBUG: Connecting signals")
	_connect_signals()
	
	LogWrapper.debug(self, "DEBUG: Calling _setup_animal_character_list")
	_setup_animal_character_list()
	
	show_chatroom_screen()
	
	LogWrapper.debug(self, "Scene ready: %s" % scene_name)


func _enter_tree() -> void:
	if not _is_initialized:
		_load_animal_profiles()
		_preload_animal_avatars()
		LogWrapper.info(self, "Scene initialized on enter_tree")


func _exit_tree() -> void:
	_cleanup_before_scene_change()
	LogWrapper.debug(self, "Scene exit_tree cleanup completed")


func _connect_signals() -> void:
	SignalBus.language_changed.connect(_on_language_changed)
	
	if message_input_box:
		message_input_box.message_sent.connect(_on_message_sent)
	
	if back_button:
		back_button.confirmed.connect(_on_back_button_pressed)
	
	if settings_button:
		settings_button.confirmed.connect(_on_settings_button_pressed)
	
	if animal_character_list:
		animal_character_list.character_selected.connect(_on_character_selected)
	
	if character_info_panel:
		character_info_panel.avatar_clicked.connect(_on_avatar_clicked)


func _load_animal_profiles() -> void:
	_animal_profiles.clear()
	
	LogWrapper.debug(self, "DEBUG: Starting to load animal profiles")
	
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
	
	LogWrapper.debug(self, "DEBUG: Found %s profile files to load" % profile_files.size())
	
	for profile_file: String in profile_files:
		LogWrapper.debug(self, "DEBUG: Loading profile file: %s" % profile_file)
		var profile_script: GDScript = load(profile_file) as GDScript
		if profile_script:
			LogWrapper.debug(self, "DEBUG: Profile script loaded successfully: %s" % profile_file)
			var profile: NPCProfile = profile_script.create_profile()
			if profile:
				LogWrapper.debug(self, "DEBUG: Profile created: %s, valid: %s" % [profile.npc_id, profile.is_valid()])
				if profile.is_valid():
					_animal_profiles[profile.npc_id] = profile
					LogWrapper.debug(self, "DEBUG: Profile added to _animal_profiles: %s" % profile.npc_id)
				else:
					LogWrapper.warning(self, "DEBUG: Profile is not valid: ", profile.npc_id)
			else:
				LogWrapper.warning(self, "DEBUG: Failed to create profile from: ", profile_file)
		else:
			LogWrapper.error(self, "DEBUG: Failed to load profile script: %s" % profile_file)
	
	LogWrapper.debug(self, "DEBUG: Loaded %s animal profiles successfully" % _animal_profiles.size())


func _preload_animal_avatars() -> void:
	LogWrapper.debug(self, "Avatar preloading skipped - avatars loaded via NPCProfile")


func _setup_animal_character_list() -> void:
	LogWrapper.debug(self, "DEBUG: Starting _setup_animal_character_list")
	
	if not animal_character_list:
		LogWrapper.error(self, "DEBUG: animal_character_list is null, cannot setup character list")
		return
	
	LogWrapper.debug(self, "DEBUG: animal_character_list found, clearing list")
	animal_character_list.clear_list()
	
	if _animal_profiles.is_empty():
		LogWrapper.debug(self, "DEBUG: _animal_profiles is empty, loading profiles")
		_load_animal_profiles()
	else:
		LogWrapper.debug(self, "DEBUG: _animal_profiles has %s profiles" % _animal_profiles.size())
	
	LogWrapper.debug(self, "DEBUG: Starting to add characters to list")
	var added_count: int = 0
	for npc_id: String in _animal_profiles.keys():
		var profile: NPCProfile = _animal_profiles[npc_id]
		if profile and profile.is_valid():
			LogWrapper.debug(self, "DEBUG: Adding character: %s, name: %s" % [npc_id, profile.display_name])
			animal_character_list.add_character(
				profile.npc_id,
				profile.display_name,
				profile.avatar_texture
			)
			added_count += 1
		else:
			LogWrapper.warning(self, "DEBUG: Skipping invalid profile: ", npc_id)
	
	LogWrapper.debug(self, "DEBUG: Added %s characters to list" % added_count)
	
	if _animal_profiles.size() > 0:
		var first_npc_id: String = _animal_profiles.keys()[0]
		LogWrapper.debug(self, "DEBUG: Selecting first character: %s" % first_npc_id)
		animal_character_list.select_character(first_npc_id)
	
	LogWrapper.debug(self, "DEBUG: Setup animal character list with %s characters" % _animal_profiles.size())


func _initialize_npc_dialogues() -> void:
	if _is_initialized:
		return
	
	_npc_dialogues.clear()
	
	for npc_id: String in _animal_profiles.keys():
		var profile: NPCProfile = _animal_profiles[npc_id]
		if profile and profile.is_valid():
			var npc_dialogue: NPCDialogue = _create_npc_dialogue(profile)
			if npc_dialogue:
				_npc_dialogues[npc_id] = npc_dialogue
				LogWrapper.debug(self, "Created NPCDialogue for: %s" % npc_id)
	
	_is_initialized = true
	LogWrapper.info(self, "Initialized %s NPCDialogue instances" % _npc_dialogues.size())


func _create_npc_dialogue(profile: NPCProfile) -> NPCDialogue:
	if not profile:
		return null
	
	var npc_dialogue: NPCDialogue = NPCDialogue.new()
	npc_dialogue.npc_id = profile.npc_id
	npc_dialogue.npc_name = profile.display_name
	npc_dialogue.npc_profile = profile
	
	var current_locale: String = TranslationServer.get_locale()
	var localized_personality: Dictionary = profile.get_localized_personality_dict(current_locale)
	npc_dialogue.set_npc_personality(localized_personality)
	
	var dialogue_config: Dictionary = profile.get_dialogue_config()
	npc_dialogue.enable_streaming = dialogue_config.get("enable_streaming", true)
	npc_dialogue.streaming_speed = dialogue_config.get("streaming_speed", 0.05)
	npc_dialogue.max_memory_entries = dialogue_config.get("max_memory_entries", 50)
	npc_dialogue.enable_context_memory = dialogue_config.get("enable_context_memory", true)
	
	if npc_dialogues_container:
		npc_dialogues_container.add_child(npc_dialogue)
	else:
		add_child(npc_dialogue)
	
	_connect_npc_dialogue_signals(npc_dialogue)
	
	return npc_dialogue


func _connect_npc_dialogue_signals(npc_dialogue: NPCDialogue) -> void:
	if not npc_dialogue:
		return
	
	if not npc_dialogue.dialogue_started.is_connected(_on_npc_dialogue_started):
		npc_dialogue.dialogue_started.connect(_on_npc_dialogue_started)
	
	if not npc_dialogue.dialogue_ended.is_connected(_on_npc_dialogue_ended):
		npc_dialogue.dialogue_ended.connect(_on_npc_dialogue_ended)
	
	if not npc_dialogue.message_streaming.is_connected(_on_message_streaming):
		npc_dialogue.message_streaming.connect(_on_message_streaming)


func _on_npc_dialogue_started(npc_id: String, npc_name: String) -> void:
	_active_dialogue_sessions[npc_id] = true
	LogWrapper.info(self, "NPC dialogue started: %s" % npc_name)


func _on_npc_dialogue_ended(npc_id: String) -> void:
	if _active_dialogue_sessions.has(npc_id):
		_active_dialogue_sessions.erase(npc_id)
	
	LogWrapper.info(self, "NPC dialogue ended: %s" % npc_id)


func _on_message_streaming(_content: String, _is_complete: bool) -> void:
	pass


func show_chatroom_screen() -> void:
	_initialize_npc_dialogues()
	_start_all_npc_dialogues()
	
	_is_chatroom_active = true
	chatroom_started.emit()
	
	LogWrapper.info(self, "Chatroom started")


func _start_all_npc_dialogues() -> void:
	for npc_id: String in _npc_dialogues.keys():
		var npc_dialogue: NPCDialogue = _npc_dialogues[npc_id]
		if npc_dialogue:
			npc_dialogue.start_npc_dialogue()
			LogWrapper.debug(self, "Started dialogue for: %s" % npc_id)


func _on_settings_button_pressed() -> void:
	LogWrapper.debug(self, "Settings button pressed")
	
	if not model_settings_dialog:
		_create_model_settings_dialog()
	
	if model_settings_dialog:
		model_settings_dialog.popup_centered()


func _create_model_settings_dialog() -> void:
	var settings_dialog_scene: PackedScene = load("res://scenes/component/chatroom/model_settings_dialog/model_settings_dialog.tscn")
	if not settings_dialog_scene:
		LogWrapper.error(self, "Failed to load model settings dialog scene")
		return
	
	model_settings_dialog = settings_dialog_scene.instantiate()
	if not model_settings_dialog:
		LogWrapper.error(self, "Failed to instantiate model settings dialog")
		return
	
	add_child(model_settings_dialog)
	model_settings_dialog.settings_saved.connect(_on_model_settings_saved)
	LogWrapper.debug(self, "Model settings dialog created")


func _on_model_settings_saved(settings: Dictionary) -> void:
	LogWrapper.info(self, "Model settings saved: %s" % str(settings))
	
	for npc_id: String in _npc_dialogues.keys():
		var npc_dialogue: NPCDialogue = _npc_dialogues[npc_id]
		if npc_dialogue and npc_dialogue.is_active:
			npc_dialogue.reload_model()
			LogWrapper.debug(self, "Model updated for NPC: %s" % npc_id)


func _show_model_not_configured_dialog() -> void:
	if not model_not_configured_dialog:
		_create_model_not_configured_dialog()
	
	if model_not_configured_dialog:
		model_not_configured_dialog.popup_centered()


func _create_model_not_configured_dialog() -> void:
	model_not_configured_dialog = AcceptDialog.new()
	model_not_configured_dialog.title = "模型未配置"
	model_not_configured_dialog.dialog_text = "您还没有配置 AI 模型。要使用聊天功能，请先配置模型设置。\n\n点击下方按钮打开设置。"
	model_not_configured_dialog.ok_button_text = "打开设置"
	model_not_configured_dialog.cancel_button_text = "取消"
	
	add_child(model_not_configured_dialog)
	
	model_not_configured_dialog.confirmed.connect(_on_open_settings_from_dialog)
	model_not_configured_dialog.canceled.connect(_on_cancel_model_dialog)
	
	LogWrapper.debug(self, "Model not configured dialog created")


func _on_open_settings_from_dialog() -> void:
	LogWrapper.debug(self, "Opening settings from model not configured dialog")
	_on_settings_button_pressed()


func _on_cancel_model_dialog() -> void:
	LogWrapper.debug(self, "Model not configured dialog canceled")


func _cleanup_dialogs() -> void:
	if model_settings_dialog and model_settings_dialog.get_parent():
		model_settings_dialog.queue_free()
		model_settings_dialog = null
	
	if model_not_configured_dialog and model_not_configured_dialog.get_parent():
		model_not_configured_dialog.queue_free()
		model_not_configured_dialog = null
	
	LogWrapper.debug(self, "Dialogs cleaned up")


func _on_message_sent(message: String) -> void:
	if message.is_empty():
		return
	
	await _send_message(message)


func _send_message(message: String) -> void:
	if _current_selected_npc_id.is_empty():
		LogWrapper.warning(self, "No character selected")
		return
	
	var npc_dialogue: NPCDialogue = _npc_dialogues.get(_current_selected_npc_id)
	if not npc_dialogue:
		LogWrapper.warning(self, "No NPCDialogue found for: ", _current_selected_npc_id)
		return
	
	if not npc_dialogue.model:
		_show_model_not_configured_dialog()
		return
	
	var formatted_message: String = "我: " + message
	_add_to_dialogue(formatted_message)
	
	_play_message_send_sound()
	
	await get_tree().create_timer(0.5).timeout
	
	await _send_to_npc_dialogue(npc_dialogue, message)
	
	LogWrapper.debug(self, "Message sent: %s" % message)


func _send_to_npc_dialogue(npc_dialogue: NPCDialogue, message: String) -> void:
	if not npc_dialogue:
		return
	
	if not npc_dialogue.is_active:
		npc_dialogue.start_npc_dialogue()
	
	var response: String = await npc_dialogue.send_npc_message(message)
	
	if not response.is_empty():
		_play_message_receive_sound()
		var profile: NPCProfile = _animal_profiles.get(_current_selected_npc_id)
		var display_name: String = profile.display_name if profile else "NPC"
		var formatted_response: String = display_name + ": " + response
		_add_to_dialogue(formatted_response)
	else:
		LogWrapper.warning(self, "Empty response from NPCDialogue")


func _add_to_dialogue(message: String) -> void:
	_save_chat_history(message)
	await _create_message_bubble(message)


func _create_message_bubble(message: String) -> void:
	
	LogWrapper.debug(self, "========== Creating Message Label ==========")
	LogWrapper.debug(self, "Original message: %s" % message)
	
	var is_player: bool = message.begins_with("我:")
	var sender_name: String = ""
	var content: String = message
	var avatar: Texture2D = null
	
	LogWrapper.debug(self, "is_player: %s" % is_player)
	
	if is_player:
		sender_name = "我"
		content = message.replace("我: ", "")
		LogWrapper.debug(self, "Player message - sender_name: %s, content: %s" % [sender_name, content])
	else:
		var colon_pos: int = message.find(": ")
		if colon_pos > 0:
			sender_name = message.substr(0, colon_pos)
			content = message.substr(colon_pos + 2)
		else:
			sender_name = ""
			content = message
		
		var profile: NPCProfile = _animal_profiles.get(_current_selected_npc_id)
		if profile:
			sender_name = profile.display_name
			avatar = profile.avatar_texture
		
		LogWrapper.debug(self, "NPC message - sender_name: %s, content: %s, avatar: %s" % [sender_name, content, avatar != null])
	
	LogWrapper.debug(self, "Final parameters - is_player: %s, sender_name: %s, content: %s" % [is_player, sender_name, content])
	LogWrapper.debug(self, "===========================================")
	
	var message_label: Label = Label.new()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(0, 0)
	message_label.size_flags_horizontal = Control.SIZE_FILL
	message_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	if is_player:
		message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		message_label.text = "[我] " + content
	else:
		message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		message_label.text = "[" + sender_name + "] " + content
	
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	
	LogWrapper.debug(self, "========== Message Label Display Debug ==========")
	LogWrapper.debug(self, "About to add message label to chat window")
	LogWrapper.debug(self, "Message label created successfully")
	LogWrapper.debug(self, "Message text: %s" % message_label.text)
	LogWrapper.debug(self, "Is player message: %s" % is_player)
	
	if chat_window_vbox_container:
		LogWrapper.debug(self, "chat_window_vbox_container is valid, adding child...")
		chat_window_vbox_container.add_child(message_label)
		LogWrapper.debug(self, "Message label added to chat window successfully")
		
		await get_tree().process_frame
		LogWrapper.debug(self, "Process frame completed")
		
		if chat_window_scroll_container:
			chat_window_scroll_container.scroll_vertical = int(chat_window_scroll_container.get_v_scroll_bar().max_value)
			LogWrapper.debug(self, "Chat window scrolled to bottom")
		else:
			LogWrapper.warning(self, "chat_window_scroll_container is null, cannot scroll")
	else:
		LogWrapper.error(self, "chat_window_vbox_container is null, cannot add message label")
		message_label.queue_free()
	
	LogWrapper.debug(self, "==================================================")


func _on_character_selected(npc_id: String) -> void:
	if _current_selected_npc_id == npc_id:
		return
	
	_current_selected_npc_id = npc_id
	
	_log_character_debug_info(npc_id)
	_update_character_info_panel()
	_clear_chat_window()
	_load_chat_history(npc_id)
	
	LogWrapper.debug(self, "Character selected: %s" % npc_id)


func _on_avatar_clicked(npc_id: String) -> void:
	LogWrapper.debug(self, "Avatar clicked for NPC: %s" % npc_id)
	_show_animal_inventory_panel(npc_id)


func _show_animal_inventory_panel(npc_id: String) -> void:
	if animal_inventory_panel:
		LogWrapper.warning(self, "Inventory panel already open")
		return
	
	var profile: NPCProfile = _animal_profiles.get(npc_id)
	if not profile:
		LogWrapper.warning(self, "No profile found for NPC: %s" % npc_id)
		return
	
	var inventory_panel_scene: PackedScene = load("res://scenes/component/chatroom/animal_inventory_panel/animal_inventory_panel.tscn")
	if not inventory_panel_scene:
		LogWrapper.error(self, "Failed to load inventory panel scene")
		return
	
	animal_inventory_panel = inventory_panel_scene.instantiate()
	if not animal_inventory_panel:
		LogWrapper.error(self, "Failed to instantiate inventory panel")
		return
	
	add_child(animal_inventory_panel)
	animal_inventory_panel.close_requested.connect(_on_inventory_panel_close_requested)
	
	var animal_profile: AnimalProfile = _get_animal_profile(npc_id)
	if animal_profile:
		animal_inventory_panel.set_animal_profile(animal_profile, profile)
	
	LogWrapper.debug(self, "Inventory panel opened for: %s" % npc_id)


func _on_inventory_panel_close_requested() -> void:
	if animal_inventory_panel:
		animal_inventory_panel.queue_free()
		animal_inventory_panel = null
	
	LogWrapper.debug(self, "Inventory panel closed")


func _get_animal_profile(npc_id: String) -> AnimalProfile:
	var profile_script_path: String = ""
	
	match npc_id:
		"elephant":
			profile_script_path = "res://resources/dialogue/animal_profiles/elephant_profile.gd"
		"panda":
			profile_script_path = "res://resources/dialogue/animal_profiles/panda_profile.gd"
		"giraffe":
			profile_script_path = "res://resources/dialogue/animal_profiles/giraffe_profile.gd"
		"hippo":
			profile_script_path = "res://resources/dialogue/animal_profiles/hippo_profile.gd"
		"monkey":
			profile_script_path = "res://resources/dialogue/animal_profiles/monkey_profile.gd"
		"parrot":
			profile_script_path = "res://resources/dialogue/animal_profiles/parrot_profile.gd"
		"penguin":
			profile_script_path = "res://resources/dialogue/animal_profiles/penguin_profile.gd"
		"pig":
			profile_script_path = "res://resources/dialogue/animal_profiles/pig_profile.gd"
		"rabbit":
			profile_script_path = "res://resources/dialogue/animal_profiles/rabbit_profile.gd"
		"snake":
			profile_script_path = "res://resources/dialogue/animal_profiles/snake_profile.gd"
	
	if profile_script_path.is_empty():
		return null
	
	var profile_script: GDScript = load(profile_script_path) as GDScript
	if not profile_script:
		return null
	
	if profile_script.has_method("create_animal_profile"):
		return profile_script.create_animal_profile()
	
	return null


func _update_character_info_panel() -> void:
	if not character_info_panel:
		return
	
	var profile: NPCProfile = _animal_profiles.get(_current_selected_npc_id)
	if profile:
		character_info_panel.set_character_profile(profile)
	else:
		character_info_panel.clear_info()


func _log_character_debug_info(npc_id: String) -> void:
	var profile: NPCProfile = _animal_profiles.get(npc_id)
	if not profile:
		LogWrapper.warning(self, "No profile found for NPC ID: ", npc_id)
		return
	
	LogWrapper.debug(self, "========== Character Debug Info =========")
	LogWrapper.debug(self, "NPC ID: %s" % profile.npc_id)
	LogWrapper.debug(self, "Display Name: %s" % profile.display_name)
	LogWrapper.debug(self, "===========================================")


func _on_back_button_pressed() -> void:
	LogWrapper.debug(self, "Back button pressed")
	
	_is_chatroom_active = false
	chatroom_ended.emit()
	
	_cleanup_before_scene_change()
	SceneManagerWrapper.change_scene(SceneManagerEnum.Scene.ANIMAL_CHATROOM_SCENE, "fade_1s")


func _cleanup_before_scene_change() -> void:
	_end_all_dialogue_sessions()
	_release_avatar_resources()
	_disconnect_all_signals()
	_reset_scene_state()
	_cleanup_dialogs()
	
	LogWrapper.debug(self, "Cleanup before scene change completed")


func _play_message_send_sound() -> void:
	if message_send_audio and message_send_audio.stream:
		message_send_audio.play()


func _play_message_receive_sound() -> void:
	if message_receive_audio and message_receive_audio.stream:
		message_receive_audio.play()


func _on_language_changed(_locale: String) -> void:
	pass


func _end_all_dialogue_sessions() -> void:
	for npc_id: String in _npc_dialogues.keys():
		var npc_dialogue: NPCDialogue = _npc_dialogues[npc_id]
		if npc_dialogue and npc_dialogue.is_active:
			npc_dialogue.end_npc_dialogue()
			LogWrapper.debug(self, "Ended dialogue for: %s" % npc_id)
	
	_active_dialogue_sessions.clear()
	
	if DialogueManager:
		DialogueManager.end_all_dialogues()
	
	LogWrapper.info(self, "All dialogue sessions ended")


func _release_avatar_resources() -> void:
	LogWrapper.debug(self, "Avatar resources release skipped - managed by NPCProfile")


func _disconnect_all_signals() -> void:
	if SignalBus.language_changed.is_connected(_on_language_changed):
		SignalBus.language_changed.disconnect(_on_language_changed)
	
	if message_input_box and message_input_box.message_sent.is_connected(_on_message_sent):
		message_input_box.message_sent.disconnect(_on_message_sent)
	
	if back_button and back_button.confirmed.is_connected(_on_back_button_pressed):
		back_button.confirmed.disconnect(_on_back_button_pressed)
	
	if animal_character_list and animal_character_list.character_selected.is_connected(_on_character_selected):
		animal_character_list.character_selected.disconnect(_on_character_selected)
	
	if character_info_panel and character_info_panel.avatar_clicked.is_connected(_on_avatar_clicked):
		character_info_panel.avatar_clicked.disconnect(_on_avatar_clicked)
	
	if animal_inventory_panel and animal_inventory_panel.close_requested.is_connected(_on_inventory_panel_close_requested):
		animal_inventory_panel.close_requested.disconnect(_on_inventory_panel_close_requested)
	
	for npc_id: String in _npc_dialogues.keys():
		var npc_dialogue: NPCDialogue = _npc_dialogues[npc_id]
		if npc_dialogue:
			if npc_dialogue.dialogue_started.is_connected(_on_npc_dialogue_started):
				npc_dialogue.dialogue_started.disconnect(_on_npc_dialogue_started)
			
			if npc_dialogue.dialogue_ended.is_connected(_on_npc_dialogue_ended):
				npc_dialogue.dialogue_ended.disconnect(_on_npc_dialogue_ended)
			
			if npc_dialogue.message_streaming.is_connected(_on_message_streaming):
				npc_dialogue.message_streaming.disconnect(_on_message_streaming)
	
	LogWrapper.debug(self, "All signals disconnected")


func _reset_scene_state() -> void:
	_is_chatroom_active = false
	_current_selected_npc_id = ""
	_is_initialized = false
	_chat_history.clear()
	
	if message_input_box:
		message_input_box.clear_text()
	
	if character_info_panel:
		character_info_panel.clear_info()
	
	if animal_character_list:
		animal_character_list.clear_list()
	
	if chat_window_vbox_container:
		for child in chat_window_vbox_container.get_children():
			child.queue_free()
	
	LogWrapper.debug(self, "Scene state reset")


func _cleanup() -> void:
	_end_all_dialogue_sessions()
	_cleanup_npc_dialogues()
	
	_is_chatroom_active = false
	_is_initialized = false
	
	if message_input_box:
		message_input_box.text = ""
	
	LogWrapper.debug(self, "Scene cleanup completed")


func _cleanup_npc_dialogues() -> void:
	for npc_id: String in _npc_dialogues.keys():
		var npc_dialogue: NPCDialogue = _npc_dialogues[npc_id]
		if npc_dialogue:
			if npc_dialogue.dialogue_started.is_connected(_on_npc_dialogue_started):
				npc_dialogue.dialogue_started.disconnect(_on_npc_dialogue_started)
			
			if npc_dialogue.dialogue_ended.is_connected(_on_npc_dialogue_ended):
				npc_dialogue.dialogue_ended.disconnect(_on_npc_dialogue_ended)
			
			if npc_dialogue.message_streaming.is_connected(_on_message_streaming):
				npc_dialogue.message_streaming.disconnect(_on_message_streaming)
			
			npc_dialogue.clear_memory()
			
			if npc_dialogue.get_parent():
				npc_dialogue.get_parent().remove_child(npc_dialogue)
				npc_dialogue.queue_free()
	
	_npc_dialogues.clear()
	LogWrapper.debug(self, "Cleaned up all NPCDialogue instances")


func get_animal_profiles() -> Dictionary:
	return _animal_profiles.duplicate()


func get_current_selected_npc_id() -> String:
	return _current_selected_npc_id


func is_chatroom_active() -> bool:
	return _is_chatroom_active


func get_npc_dialogue(npc_id: String) -> NPCDialogue:
	return _npc_dialogues.get(npc_id)


func get_all_npc_dialogues() -> Dictionary:
	return _npc_dialogues.duplicate()


func get_npc_memory_entries(npc_id: String) -> Array[Dictionary]:
	var npc_dialogue: NPCDialogue = _npc_dialogues.get(npc_id)
	if npc_dialogue:
		return npc_dialogue.get_memory_entries()
	return []


func get_npc_context_keywords(npc_id: String) -> Array[String]:
	var npc_dialogue: NPCDialogue = _npc_dialogues.get(npc_id)
	if npc_dialogue:
		return npc_dialogue.get_context_keywords()
	return []


func clear_npc_memory(npc_id: String) -> void:
	var npc_dialogue: NPCDialogue = _npc_dialogues.get(npc_id)
	if npc_dialogue:
		npc_dialogue.clear_memory()
		LogWrapper.debug(self, "Cleared memory for: %s" % npc_id)


func search_npc_memory(npc_id: String, keyword: String) -> Array[Dictionary]:
	var npc_dialogue: NPCDialogue = _npc_dialogues.get(npc_id)
	if npc_dialogue:
		return npc_dialogue.search_memory(keyword)
	return []


func get_npc_info(npc_id: String) -> Dictionary:
	var npc_dialogue: NPCDialogue = _npc_dialogues.get(npc_id)
	if npc_dialogue:
		return npc_dialogue.get_npc_info()
	return {}


func get_all_npc_info() -> Dictionary:
	var all_info: Dictionary = {}
	for npc_id: String in _npc_dialogues.keys():
		var npc_dialogue: NPCDialogue = _npc_dialogues[npc_id]
		if npc_dialogue:
			all_info[npc_id] = npc_dialogue.get_npc_info()
	return all_info


func get_active_dialogue_sessions() -> Dictionary:
	return _active_dialogue_sessions.duplicate()


func get_scene_statistics() -> Dictionary:
	return {
		"is_active": _is_chatroom_active,
		"is_initialized": _is_initialized,
		"npc_count": _npc_dialogues.size(),
		"active_dialogues": _active_dialogue_sessions.size(),
		"current_npc_id": _current_selected_npc_id
	}


func _save_chat_history(message: String) -> void:
	if _current_selected_npc_id.is_empty():
		return
	
	if not _chat_history.has(_current_selected_npc_id):
		_chat_history[_current_selected_npc_id] = []
	
	_chat_history[_current_selected_npc_id].append(message)
	LogWrapper.debug(self, "Saved chat history for %s, total messages: %d" % [_current_selected_npc_id, _chat_history[_current_selected_npc_id].size()])


func _clear_chat_window() -> void:
	if not chat_window_vbox_container:
		return
	
	for child in chat_window_vbox_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	LogWrapper.debug(self, "Chat window cleared")


func _load_chat_history(npc_id: String) -> void:
	if not _chat_history.has(npc_id):
		LogWrapper.debug(self, "No chat history found for %s" % npc_id)
		return
	
	var messages: Array = _chat_history[npc_id]
	LogWrapper.debug(self, "Loading %d messages for %s" % [messages.size(), npc_id])
	
	for message: String in messages:
		await _create_message_bubble(message)
	
	LogWrapper.debug(self, "Chat history loaded for %s" % npc_id)


func get_chat_history(npc_id: String) -> Array:
	if not _chat_history.has(npc_id):
		return []
	return _chat_history[npc_id].duplicate()


func get_all_chat_history() -> Dictionary:
	return _chat_history.duplicate()


func clear_chat_history(npc_id: String) -> void:
	if _chat_history.has(npc_id):
		_chat_history.erase(npc_id)
		LogWrapper.debug(self, "Cleared chat history for %s" % npc_id)


func clear_all_chat_history() -> void:
	_chat_history.clear()
	LogWrapper.debug(self, "Cleared all chat history")


func get_chat_history_count(npc_id: String) -> int:
	if not _chat_history.has(npc_id):
		return 0
	return _chat_history[npc_id].size()
