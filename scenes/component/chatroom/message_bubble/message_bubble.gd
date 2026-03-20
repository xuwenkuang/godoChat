class_name MessageBubble
extends Control

@export_category("Message Settings")
@export var sender_name: String = ""
@export var sender_avatar: Texture2D
@export var content: String = ""
@export var is_player: bool = false

@export_category("UI References")
@onready var avatar_texture_rect: TextureRect = %AvatarTextureRect
@onready var sender_name_label: Label = %SenderNameLabel
@onready var background_panel: Panel = %BackgroundPanel
@onready var message_container: HBoxContainer = %MessageContainer
@onready var content_label: RichTextLabel = %ContentLabel

const PLAYER_BUBBLE_COLOR: Color = Color(0.0, 0.5, 0.0, 0.8)
const NPC_BUBBLE_COLOR: Color = Color(0.0, 0.6, 0.0, 0.9)
const PLAYER_TEXT_COLOR: Color = Color.WHITE
const NPC_TEXT_COLOR: Color = Color.WHITE
const FADE_IN_DURATION: float = 0.3
const SLIDE_IN_DURATION: float = 0.3
const SLIDE_OFFSET: float = 20.0
const TYPEWRITER_SPEED: float = 0.05

var _tween: Tween
var _typewriter_tween: Tween
var _is_typing: bool = false
var _text_shown: bool = false

func _ready() -> void:
	_setup_initial_state()
	_get_node_references()
	_update_ui()
	
	if not Engine.is_editor_hint():
		SignalBus.language_changed.connect(_on_language_changed)


func _get_node_references() -> void:
	avatar_texture_rect = %AvatarTextureRect
	sender_name_label = %SenderNameLabel
	background_panel = %BackgroundPanel
	message_container = %MessageContainer
	
	LogWrapper.debug(self, "Node references obtained: avatar=%s, sender=%s, content=%s, bg=%s, container=%s" % [
		avatar_texture_rect != null,
		sender_name_label != null,
		content_label != null,
		background_panel != null,
		message_container != null
	])


func _setup_initial_state() -> void:
	modulate = Color.TRANSPARENT


func set_message_data(p_name: String, avatar: Texture2D, message: String, player: bool) -> void:
	LogWrapper.debug(self, "========== set_message_data called ==========")
	LogWrapper.debug(self, "p_name: %s" % p_name)
	LogWrapper.debug(self, "avatar: %s" % (avatar != null))
	LogWrapper.debug(self, "message: %s" % message)
	LogWrapper.debug(self, "player: %s" % player)
	
	sender_name = p_name
	sender_avatar = avatar
	content = message
	is_player = player
	_update_ui()
	
	LogWrapper.debug(self, "===========================================")


func _update_ui() -> void:
	_update_avatar()
	_update_sender_name()
	_update_content()
	_update_bubble_style()
	_update_layout()


func _update_avatar() -> void:
	if not avatar_texture_rect:
		return
	
	if sender_avatar:
		avatar_texture_rect.texture = sender_avatar
		avatar_texture_rect.visible = true
	else:
		avatar_texture_rect.visible = false


func _update_sender_name() -> void:
	if not sender_name_label:
		return
	
	if not sender_name.is_empty():
		sender_name_label.text = TranslationServerWrapper.translate(sender_name)
		sender_name_label.visible = true
	else:
		sender_name_label.visible = false


func _update_content() -> void:
	if not content_label:
		LogWrapper.warning(self, "content_label is null!")
		return
	
	if not content.is_empty():
		content_label.text = ""
		content_label.visible = true
		content_label.queue_redraw()
	else:
		content_label.visible = false


func start_typewriter_effect() -> void:
	if not content_label or content.is_empty():
		LogWrapper.warning(self, "Cannot start typewriter: content_label=%s, content_empty=%s" % [content_label != null, content.is_empty()])
		return
	
	content_label.visible = true
	content_label.text = ""
	content_label.queue_redraw()
	
	if _typewriter_tween:
		_typewriter_tween.kill()
	
	_is_typing = true
	var full_text: String = TranslationServerWrapper.translate(content)
	var current_text: String = ""
	var char_count: int = full_text.length()
	
	_typewriter_tween = create_tween()
	_typewriter_tween.set_parallel(false)
	
	for i in range(char_count + 1):
		current_text = full_text.substr(0, i)
		_typewriter_tween.tween_callback(_update_text_content.bind(current_text))
		_typewriter_tween.tween_interval(TYPEWRITER_SPEED)
	
	_typewriter_tween.tween_callback(_on_typewriter_complete)
	_typewriter_tween.play()


func show_text_immediately() -> void:
	if not content_label or content.is_empty():
		return
	
	if _typewriter_tween:
		_typewriter_tween.kill()
	
	content_label.text = TranslationServerWrapper.translate(content)
	_is_typing = false
	_text_shown = true


func _update_text_content(text: String) -> void:
	if content_label:
		content_label.text = text
		content_label.queue_redraw()


func _on_typewriter_complete() -> void:
	_is_typing = false


func _wait_for_typewriter_complete() -> void:
	while _is_typing:
		await get_tree().process_frame


func _update_bubble_style() -> void:
	if not background_panel:
		return
	
	var bubble_color: Color = PLAYER_BUBBLE_COLOR if is_player else NPC_BUBBLE_COLOR
	background_panel.modulate = bubble_color
	
	if content_label:
		var text_color: Color = PLAYER_TEXT_COLOR if is_player else NPC_TEXT_COLOR
		content_label.add_theme_color_override("default_color", text_color)
		LogWrapper.debug(self, "Bubble style updated, text_color: %s" % text_color)


func _update_layout() -> void:
	if not message_container:
		return
	
	if is_player:
		message_container.alignment = BoxContainer.ALIGNMENT_END
	else:
		message_container.alignment = BoxContainer.ALIGNMENT_BEGIN


func show_message() -> void:
	visible = true
	LogWrapper.debug(self, "show_message called, is_player: %s, content: %s" % [is_player, content])
	_play_show_animation()
	if not _text_shown and not _is_typing:
		start_typewriter_effect()
		await _wait_for_typewriter_complete()


func hide_message() -> void:
	_play_hide_animation()


func _play_show_animation() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_parallel(true)
	
	_tween.tween_property(self, "modulate:a", 1.0, FADE_IN_DURATION)
	
	var original_position: Vector2 = position
	if is_player:
		position.x += SLIDE_OFFSET
		_tween.tween_property(self, "position:x", original_position.x, SLIDE_IN_DURATION)
	else:
		position.x -= SLIDE_OFFSET
		_tween.tween_property(self, "position:x", original_position.x, SLIDE_IN_DURATION)
	
	_tween.play()


func _play_hide_animation() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, FADE_IN_DURATION)
	_tween.tween_callback(_on_hide_animation_complete).set_delay(FADE_IN_DURATION)
	_tween.play()


func _on_hide_animation_complete() -> void:
	visible = false


func _on_language_changed(_locale: String) -> void:
	_update_ui()


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		if SignalBus.language_changed.is_connected(_on_language_changed):
			SignalBus.language_changed.disconnect(_on_language_changed)
