class_name CharacterInfoPanel
extends Control

@export_category("UI References")
@onready var avatar_texture_rect: TextureRect = %AvatarTextureRect
@onready var name_label: Label = %NameLabel
@onready var identity_label: Label = %IdentityLabel
@onready var personality_label: Label = %PersonalityLabel
@onready var background_story_label: RichTextLabel = %BackgroundStoryLabel
@onready var speaking_style_label: RichTextLabel = %SpeakingStyleLabel

var _current_profile: NPCProfile = null

func _ready() -> void:
	_connect_signals()
	_setup_initial_state()


func _connect_signals() -> void:
	if not Engine.is_editor_hint():
		SignalBus.language_changed.connect(_on_language_changed)


func _setup_initial_state() -> void:
	clear_info()


func set_character_profile(profile: NPCProfile) -> void:
	_current_profile = profile
	
	if not profile or not profile.is_valid():
		clear_info()
		return
	
	_update_ui()


func clear_info() -> void:
	_current_profile = null
	
	if avatar_texture_rect:
		avatar_texture_rect.texture = null
	
	if name_label:
		name_label.text = ""
	
	if identity_label:
		identity_label.text = ""
	
	if personality_label:
		personality_label.text = ""
	
	if background_story_label:
		background_story_label.text = ""
	
	if speaking_style_label:
		speaking_style_label.text = ""


func _update_ui() -> void:
	if not _current_profile:
		return
	
	if avatar_texture_rect and _current_profile.avatar_texture:
		avatar_texture_rect.texture = _current_profile.avatar_texture
	
	if name_label:
		name_label.text = _current_profile.display_name
	
	if identity_label:
		var identity_text: String = _current_profile.identity
		if not identity_text.is_empty():
			identity_label.text = "身份: " + identity_text
		else:
			identity_label.text = ""
	
	if personality_label:
		var personality_text: String = _current_profile.personality
		if not personality_text.is_empty():
			personality_label.text = "性格: " + personality_text
		else:
			personality_label.text = ""
	
	if background_story_label:
		var background_text: String = _current_profile.background_story
		if not background_text.is_empty():
			background_story_label.text = "[b]背景故事:[/b]\n" + background_text
		else:
			background_story_label.text = ""
	
	if speaking_style_label:
		var style_text: String = _current_profile.speaking_style
		if not style_text.is_empty():
			speaking_style_label.text = "[b]说话风格:[/b]\n" + style_text
		else:
			speaking_style_label.text = ""


func get_current_profile() -> NPCProfile:
	return _current_profile


func _on_language_changed(_locale: String) -> void:
	_update_ui()


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		if SignalBus.language_changed.is_connected(_on_language_changed):
			SignalBus.language_changed.disconnect(_on_language_changed)
