class_name AnimalChatroomScene
extends Control

signal chatroom_started
signal chatroom_ended

@export_category("Scene Configuration")
@export var scene_name: String = "Animal Chatroom Scene"

@export_category("UI References")
@export var npc_dialogues_container: Node

var start_screen: Control
var title_label: Label
var start_button: MenuButtonClass

var DialogueManager: DialogueManager
var message_send_audio: AudioStreamPlayer
var message_receive_audio: AudioStreamPlayer

var _animal_profiles: Dictionary = {}
var _is_initialized: bool = false

func _ready() -> void:
	LogWrapper.debug(self, "DEBUG: _ready() called")
	
	start_screen = $StartScreen
	title_label = $StartScreen/StartScreenCenterContainer/StartScreenVBoxContainer/TitleLabel
	start_button = $StartScreen/StartScreenCenterContainer/StartScreenVBoxContainer/StartButton
	
	DialogueManager = get_node("/root/DialogueManager")
	message_send_audio = $MessageSendAudio
	message_receive_audio = $MessageReceiveAudio
	
	LogWrapper.debug(self, "DEBUG: Connecting signals")
	_connect_signals()
	
	_refresh_labels()
	
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
	
	if start_button:
		start_button.confirmed.connect(_on_start_button_pressed)


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


func _refresh_labels() -> void:
	if title_label:
		title_label.text = TranslationServerWrapper.translate("ANIMAL_CHATROOM_TITLE")


func _on_start_button_pressed() -> void:
	LogWrapper.debug(self, "Start button pressed")
	SceneManagerWrapper.change_scene(SceneManagerEnum.Scene.ANIMAL_CHATROOM_SCENE_CHAT, "fade_1s")


func _on_language_changed(_locale: String) -> void:
	_refresh_labels()


func _cleanup_before_scene_change() -> void:
	_disconnect_all_signals()
	_reset_scene_state()
	
	LogWrapper.debug(self, "Cleanup before scene change completed")


func _disconnect_all_signals() -> void:
	if SignalBus.language_changed.is_connected(_on_language_changed):
		SignalBus.language_changed.disconnect(_on_language_changed)
	
	if start_button and start_button.confirmed.is_connected(_on_start_button_pressed):
		start_button.confirmed.disconnect(_on_start_button_pressed)
	
	LogWrapper.debug(self, "All signals disconnected")


func _reset_scene_state() -> void:
	_is_initialized = false
	
	LogWrapper.debug(self, "Scene state reset")


func get_animal_profiles() -> Dictionary:
	return _animal_profiles.duplicate()
