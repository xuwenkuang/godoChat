class_name DialogueBox
extends Control

signal dialogue_finished()
signal choice_selected(choice_index: int)
signal skip_requested()

@export_category("Dialogue Settings")
@export var typing_speed: float = 0.03
@export var auto_continue_delay: float = 2.0
@export var enable_typing_effect: bool = true
@export var enable_auto_continue: bool = false
@export var skip_on_key_press: bool = true

@export_category("Animation Settings")
@export var fade_in_duration: float = 0.3
@export var fade_out_duration: float = 0.3
@export var slide_in_duration: float = 0.4
@export var slide_offset: float = 50.0

@export_category("UI References")
@onready var npc_name_label: Label = %NpcNameLabel
@onready var dialogue_text_label: RichTextLabel = %DialogueTextLabel
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var continue_prompt: Label = %ContinuePrompt
@onready var background_panel: Panel = %BackgroundPanel

const DIALOGUE_CONTINUE_PROMPT: String = "DIALOGUE_CONTINUE_PROMPT"
const DIALOGUE_DEFAULT_CHOICE: String = "DIALOGUE_DEFAULT_CHOICE"

var _current_text: String = ""
var _typing_timer: Timer
var _auto_continue_timer: Timer
var _is_typing: bool = false
var _is_skipped: bool = false
var _current_choices: Array[Dictionary] = []
var _dialogue_manager: DialogueManager
var _current_session_id: String = ""
var _tween: Tween
var _current_npc_name: String = ""
var _current_dialogue_text: String = ""

func _ready() -> void:
	_setup_timers()
	_connect_signals()
	_setup_initial_state()
	
	_dialogue_manager = DialogueManager
	if _dialogue_manager:
		_connect_to_dialogue_manager()
	
	if not Engine.is_editor_hint():
		SignalBus.language_changed.connect(_on_language_changed)


func _setup_timers() -> void:
	_typing_timer = Timer.new()
	_typing_timer.wait_time = typing_speed
	_typing_timer.timeout.connect(_on_typing_timer_timeout)
	add_child(_typing_timer)
	
	_auto_continue_timer = Timer.new()
	_auto_continue_timer.wait_time = auto_continue_delay
	_auto_continue_timer.timeout.connect(_on_auto_continue_timer_timeout)
	_auto_continue_timer.one_shot = true
	add_child(_auto_continue_timer)


func _connect_signals() -> void:
	gui_input.connect(_on_gui_input)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)


func _setup_initial_state() -> void:
	visible = false
	modulate = Color.TRANSPARENT
	if continue_prompt:
		continue_prompt.visible = false
	if choices_container:
		choices_container.visible = false


func _connect_to_dialogue_manager() -> void:
	if not _dialogue_manager:
		return
	
	_dialogue_manager.dialogue_started.connect(_on_dialogue_started)
	_dialogue_manager.dialogue_updated.connect(_on_dialogue_updated)
	_dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	_dialogue_manager.dialogue_choice_selected.connect(_on_dialogue_choice_selected)


func show_dialogue(npc_name: String, text: String, choices: Array[Dictionary] = []) -> void:
	_current_session_id = ""
	_current_choices = choices
	_current_npc_name = npc_name
	_current_dialogue_text = text
	
	if npc_name_label:
		npc_name_label.text = TranslationServerWrapper.translate(npc_name)
	
	_current_text = TranslationServerWrapper.translate(text)
	_is_skipped = false
	
	if enable_typing_effect:
		_start_typing_effect()
	else:
		_show_full_text()
	
	_show_dialogue_box()
	_handle_choices()


func show_dialogue_with_session(session_id: String, npc_name: String, text: String, choices: Array[Dictionary] = []) -> void:
	_current_session_id = session_id
	_current_choices = choices
	_current_npc_name = npc_name
	_current_dialogue_text = text
	
	if npc_name_label:
		npc_name_label.text = TranslationServerWrapper.translate(npc_name)
	
	_current_text = TranslationServerWrapper.translate(text)
	_is_skipped = false
	
	if enable_typing_effect:
		_start_typing_effect()
	else:
		_show_full_text()
	
	_show_dialogue_box()
	_handle_choices()


func hide_dialogue() -> void:
	_hide_dialogue_box()
	if _typing_timer:
		_typing_timer.stop()
	if _auto_continue_timer:
		_auto_continue_timer.stop()
	_is_typing = false


func skip_typing() -> void:
	if not _is_typing:
		return
	
	_is_skipped = true
	if _typing_timer:
		_typing_timer.stop()
	
	_show_full_text()
	_on_typing_complete()


func _start_typing_effect() -> void:
	_is_typing = true
	if dialogue_text_label:
		dialogue_text_label.text = ""
		_typing_timer.start()


func _show_full_text() -> void:
	if dialogue_text_label:
		dialogue_text_label.text = _current_text


func _on_typing_timer_timeout() -> void:
	if not dialogue_text_label:
		_on_typing_complete()
		return
	
	var current_length: int = dialogue_text_label.text.length()
	var target_length: int = _current_text.length()
	
	if current_length < target_length:
		var char_to_add: String = _current_text[current_length]
		dialogue_text_label.text += char_to_add
		
		if _is_skipped:
			dialogue_text_label.text = _current_text
			_on_typing_complete()
		else:
			_typing_timer.start()
	else:
		_on_typing_complete()


func _on_typing_complete() -> void:
	_is_typing = false
	
	if continue_prompt:
		continue_prompt.visible = _current_choices.is_empty()
	
	if enable_auto_continue and _current_choices.is_empty():
		_auto_continue_timer.start()
	
	skip_requested.emit()


func _on_auto_continue_timer_timeout() -> void:
	dialogue_finished.emit()


func _handle_choices() -> void:
	if not choices_container:
		return
	
	_clear_choices()
	
	if _current_choices.is_empty():
		choices_container.visible = false
		return
	
	choices_container.visible = true
	
	for i: int in range(_current_choices.size()):
		var choice_data: Dictionary = _current_choices[i]
		var choice_button: Button = _create_choice_button(choice_data, i)
		choices_container.add_child(choice_button)


func _create_choice_button(choice_data: Dictionary, index: int) -> Button:
	var button: Button = Button.new()
	var choice_text: String = choice_data.get("text", "")
	if choice_text.is_empty():
		choice_text = TranslationServerWrapper.translate(DIALOGUE_DEFAULT_CHOICE) % (index + 1)
	else:
		choice_text = TranslationServerWrapper.translate(choice_text)
	
	button.text = choice_text
	button.pressed.connect(_on_choice_button_pressed.bind(index))
	
	var node_theme: Theme = ThemeUtils.get_inherited_theme(self)
	if node_theme:
		button.theme = node_theme
	
	button.custom_minimum_size = Vector2(0, 40)
	
	return button


func _clear_choices() -> void:
	if not choices_container:
		return
	
	for child: Node in choices_container.get_children():
		child.queue_free()


func _on_choice_button_pressed(choice_index: int) -> void:
	if _dialogue_manager and _current_session_id != "":
		_dialogue_manager.select_choice(_current_session_id, choice_index)
	
	choice_selected.emit(choice_index)


func _show_dialogue_box() -> void:
	visible = true
	
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_parallel(true)
	
	_tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)
	
	if background_panel:
		var original_position: Vector2 = background_panel.position
		background_panel.position.y += slide_offset
		_tween.tween_property(background_panel, "position", original_position, slide_in_duration)
	
	_tween.play()


func _hide_dialogue_box() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_parallel(true)
	
	_tween.tween_property(self, "modulate:a", 0.0, fade_out_duration)
	
	if background_panel:
		var target_position: Vector2 = background_panel.position
		target_position.y += slide_offset
		_tween.tween_property(background_panel, "position", target_position, fade_out_duration)
	
	_tween.tween_callback(_on_hide_animation_complete).set_delay(fade_out_duration)
	_tween.play()


func _on_hide_animation_complete() -> void:
	visible = false
	dialogue_finished.emit()


func _on_gui_input(event: InputEvent) -> void:
	if not skip_on_key_press:
		return
	
	if event is InputEventKey and event.pressed:
		if _is_typing:
			skip_typing()
		elif _current_choices.is_empty():
			dialogue_finished.emit()
	
	if event is InputEventMouseButton and event.pressed:
		if _is_typing:
			skip_typing()
		elif _current_choices.is_empty():
			dialogue_finished.emit()


func _on_focus_entered() -> void:
	pass


func _on_focus_exited() -> void:
	pass


func _on_dialogue_started(session_id: String, npc_id: String, npc_name: String) -> void:
	pass


func _on_dialogue_updated(session_id: String, node_id: String) -> void:
	pass


func _on_dialogue_ended(session_id: String, npc_id: String) -> void:
	if session_id == _current_session_id:
		hide_dialogue()


func _on_dialogue_choice_selected(session_id: String, choice_index: int) -> void:
	if session_id == _current_session_id:
		_clear_choices()


func set_typing_speed(speed: float) -> void:
	typing_speed = speed
	if _typing_timer:
		_typing_timer.wait_time = speed


func set_auto_continue_delay(delay: float) -> void:
	auto_continue_delay = delay
	if _auto_continue_timer:
		_auto_continue_timer.wait_time = delay


func is_typing() -> bool:
	return _is_typing


func get_current_text() -> String:
	return _current_text


func get_current_choices() -> Array[Dictionary]:
	return _current_choices.duplicate()


func _on_language_changed(locale: String) -> void:
	_update_dialogue_ui()


func _update_dialogue_ui() -> void:
	if not visible:
		return
	
	_update_npc_name()
	_update_dialogue_text()
	_update_choices()
	_update_continue_prompt()


func _update_npc_name() -> void:
	if not npc_name_label or _current_npc_name.is_empty():
		return
	
	npc_name_label.text = TranslationServerWrapper.translate(_current_npc_name)


func _update_dialogue_text() -> void:
	if not dialogue_text_label or _current_dialogue_text.is_empty():
		return
	
	var translated_text: String = TranslationServerWrapper.translate(_current_dialogue_text)
	
	if _is_typing:
		_current_text = translated_text
		if dialogue_text_label.text.length() < _current_text.length():
			dialogue_text_label.text = _current_text
			_on_typing_complete()
	else:
		_current_text = translated_text
		dialogue_text_label.text = _current_text


func _update_choices() -> void:
	if not choices_container or _current_choices.is_empty():
		return
	
	_handle_choices()


func _update_continue_prompt() -> void:
	if not continue_prompt:
		return
	
	continue_prompt.text = TranslationServerWrapper.translate(DIALOGUE_CONTINUE_PROMPT)


func _exit_tree() -> void:
	if _typing_timer:
		_typing_timer.queue_free()
	if _auto_continue_timer:
		_auto_continue_timer.queue_free()
	
	if _dialogue_manager:
		_dialogue_manager.dialogue_started.disconnect(_on_dialogue_started)
		_dialogue_manager.dialogue_updated.disconnect(_on_dialogue_updated)
		_dialogue_manager.dialogue_ended.disconnect(_on_dialogue_ended)
		_dialogue_manager.dialogue_choice_selected.disconnect(_on_dialogue_choice_selected)
	
	if not Engine.is_editor_hint():
		if SignalBus.language_changed.is_connected(_on_language_changed):
			SignalBus.language_changed.disconnect(_on_language_changed)
