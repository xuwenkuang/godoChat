class_name CharacterItem
extends Control

signal item_clicked(npc_id: String)

@export_category("Character Settings")
@export var npc_id: String = ""
@export var npc_name: String = ""
@export var avatar_texture: Texture2D
@export var is_selected: bool = false

@export_category("UI References")
@onready var avatar_texture_rect: TextureRect = %AvatarTextureRect
@onready var name_label: Label = %NameLabel
@onready var selection_indicator: Panel = %SelectionIndicator
@onready var background_panel: Panel = %BackgroundPanel

const SELECTED_COLOR: Color = Color(0.3, 0.6, 1.0, 0.3)
const HOVER_COLOR: Color = Color(0.8, 0.8, 0.8, 0.2)
const NORMAL_COLOR: Color = Color.TRANSPARENT
const SELECTED_HIGHLIGHT_COLOR: Color = Color(0.3, 0.6, 1.0, 0.6)

var _is_hovered: bool = false
var _tween: Tween
var _was_selected: bool = false

func _ready() -> void:
	_connect_signals()
	_setup_initial_state()
	_update_ui()
	
	if not Engine.is_editor_hint():
		SignalBus.language_changed.connect(_on_language_changed)


func _connect_signals() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _setup_initial_state() -> void:
	_update_selection_visuals()


func set_character_data(id: String, p_name: String, avatar: Texture2D) -> void:
	npc_id = id
	npc_name = p_name
	avatar_texture = avatar
	_update_ui()


func set_selected(selected: bool) -> void:
	if is_selected == selected:
		return
	
	_was_selected = is_selected
	is_selected = selected
	_update_selection_visuals()
	_play_selection_animation()


func toggle_selected() -> void:
	set_selected(!is_selected)


func _update_ui() -> void:
	if avatar_texture_rect and avatar_texture:
		avatar_texture_rect.texture = avatar_texture
	
	if name_label and not npc_name.is_empty():
		name_label.text = TranslationServerWrapper.translate(npc_name)


func _update_selection_visuals() -> void:
	if not selection_indicator:
		return
	
	if is_selected:
		selection_indicator.modulate = SELECTED_COLOR
		selection_indicator.visible = true
	else:
		selection_indicator.modulate = HOVER_COLOR if _is_hovered else NORMAL_COLOR
		selection_indicator.visible = _is_hovered


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		item_clicked.emit(npc_id)
		_play_click_animation()


func _on_mouse_entered() -> void:
	_is_hovered = true
	_update_selection_visuals()
	_play_hover_animation()


func _on_mouse_exited() -> void:
	_is_hovered = false
	_update_selection_visuals()


func _play_click_animation() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.05)
	_tween.play()


func _play_hover_animation() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	_tween.play()


func _play_selection_animation() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_parallel(true)
	
	if is_selected:
		_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15)
		_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_delay(0.15)
		
		if selection_indicator:
			_tween.tween_property(selection_indicator, "modulate", SELECTED_HIGHLIGHT_COLOR, 0.15)
			_tween.tween_property(selection_indicator, "modulate", SELECTED_COLOR, 0.15).set_delay(0.15)
	else:
		_tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
		_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1)
	
	_tween.play()


func _on_language_changed(_locale: String) -> void:
	_update_ui()


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		if SignalBus.language_changed.is_connected(_on_language_changed):
			SignalBus.language_changed.disconnect(_on_language_changed)
