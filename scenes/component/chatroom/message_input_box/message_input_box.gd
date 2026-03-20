class_name MessageInputBox
extends Control

signal message_sent(message: String)

@export_category("Input Settings")
@export var max_length: int = 500
@export var placeholder_text: String = "Type your message..."
@export var send_on_enter: bool = true
@export var clear_after_send: bool = true

@export_category("UI References")
@onready var text_edit: TextEdit = %TextEdit
@onready var send_button: Button = %SendButton
@onready var character_count_label: Label = %CharacterCountLabel

const PLACEHOLDER_KEY: String = "CHATROOM_INPUT_PLACEHOLDER"
const SEND_BUTTON_TEXT: String = "CHATROOM_SEND_BUTTON"

var _is_sending: bool = false

func _ready() -> void:
	_connect_signals()
	_setup_initial_state()
	_update_ui()
	
	if not Engine.is_editor_hint():
		SignalBus.language_changed.connect(_on_language_changed)


func _connect_signals() -> void:
	if send_button:
		send_button.pressed.connect(_on_send_button_pressed)
	
	if text_edit:
		text_edit.text_changed.connect(_on_text_changed)
		text_edit.gui_input.connect(_on_text_edit_gui_input)


func _setup_initial_state() -> void:
	if text_edit:
		text_edit.placeholder_text = TranslationServerWrapper.translate(placeholder_text)
		text_edit.wrap_mode = TextEdit.LineWrappingMode.LINE_WRAPPING_BOUNDARY
	
	if send_button:
		send_button.text = TranslationServerWrapper.translate(SEND_BUTTON_TEXT)
	
	_update_send_button_state()
	_update_character_count()


func _update_ui() -> void:
	if text_edit:
		text_edit.placeholder_text = TranslationServerWrapper.translate(PLACEHOLDER_KEY)
	
	if send_button:
		send_button.text = TranslationServerWrapper.translate(SEND_BUTTON_TEXT)


func send_message() -> void:
	if _is_sending:
		return
	
	var message: String = text_edit.text.strip_edges() if text_edit else ""
	
	if message.is_empty():
		LogWrapper.warning(name, "Cannot send empty message")
		return
	
	if message.length() > max_length:
		LogWrapper.warning(name, "Message exceeds maximum length of %d" % max_length)
		return
	
	_is_sending = true
	_update_send_button_state()
	
	message_sent.emit(message)
	
	LogWrapper.debug(name, "Message sent: %s" % message)
	
	if clear_after_send and text_edit:
		text_edit.text = ""
		_on_text_changed()
	
	_is_sending = false
	_update_send_button_state()


func set_placeholder(text: String) -> void:
	placeholder_text = text
	if text_edit:
		text_edit.placeholder_text = TranslationServerWrapper.translate(text)


func set_max_length(length: int) -> void:
	max_length = length
	_update_character_count()


func get_current_text() -> String:
	return text_edit.text if text_edit else ""


func set_text(text: String) -> void:
	if text_edit:
		text_edit.text = text
		_on_text_changed()


func clear_text() -> void:
	set_text("")


func focus_input() -> void:
	if text_edit:
		text_edit.grab_focus()


func _update_send_button_state() -> void:
	if not send_button:
		return
	
	var can_send: bool = not _is_sending and not get_current_text().is_empty()
	send_button.disabled = not can_send


func _update_character_count() -> void:
	if not character_count_label:
		return
	
	var current_length: int = get_current_text().length()
	character_count_label.text = "%d/%d" % [current_length, max_length]
	
	if current_length > max_length:
		character_count_label.modulate = Color.RED
	else:
		character_count_label.modulate = Color.WHITE


func _on_send_button_pressed() -> void:
	send_message()


func _on_text_changed() -> void:
	_update_send_button_state()
	_update_character_count()


func _on_text_edit_gui_input(event: InputEvent) -> void:
	if not send_on_enter:
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			if event.shift_pressed:
				accept_event()
			else:
				accept_event()
				send_message()


func _on_language_changed(_locale: String) -> void:
	_update_ui()


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		if SignalBus.language_changed.is_connected(_on_language_changed):
			SignalBus.language_changed.disconnect(_on_language_changed)
