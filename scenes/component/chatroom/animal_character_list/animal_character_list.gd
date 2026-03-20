class_name AnimalCharacterList
extends Control

signal character_selected(npc_id: String)

@export_category("List Settings")
@export var character_item_scene: PackedScene
@export var scroll_speed: float = 0.2

@export_category("UI References")
@onready var scroll_container: ScrollContainer
@onready var character_list_container: VBoxContainer

const DEFAULT_AVATAR: Texture2D = null
var _character_items: Dictionary = {}
var _selected_npc_id: String = ""
var _tween: Tween

func _ready() -> void:
	scroll_container = find_child("ScrollContainer", true, false)
	character_list_container = find_child("CharacterListContainer", true, false)
	_connect_signals()
	_setup_initial_state()


func _connect_signals() -> void:
	pass


func _setup_initial_state() -> void:
	if character_item_scene and character_item_scene.can_instantiate():
		pass


func add_character(npc_id: String, npc_name: String, avatar_texture: Texture2D = DEFAULT_AVATAR) -> void:
	LogWrapper.debug(name, "DEBUG: add_character called - npc_id: %s, npc_name: %s" % [npc_id, npc_name])
	
	if _character_items.has(npc_id):
		LogWrapper.warning(name, "Character with ID %s already exists in the list" % npc_id)
		return
	
	LogWrapper.debug(name, "DEBUG: character_item_scene exists: ", character_item_scene != null)
	var character_item: CharacterItem = character_item_scene.instantiate() if character_item_scene else null
	if not character_item:
		LogWrapper.error(name, "Failed to instantiate character item scene")
		return
	
	LogWrapper.debug(name, "DEBUG: Character item instantiated successfully")
	character_item.set_character_data(npc_id, npc_name, avatar_texture)
	character_item.item_clicked.connect(_on_character_item_clicked)
	
	LogWrapper.debug(name, "DEBUG: character_list_container exists: ", character_list_container != null)
	if character_list_container:
		character_list_container.add_child(character_item)
		_character_items[npc_id] = character_item
		
		LogWrapper.debug(name, "Added character %s to the list" % npc_id)
	else:
		LogWrapper.error(name, "DEBUG: character_list_container is null, cannot add character")


func remove_character(npc_id: String) -> void:
	if not _character_items.has(npc_id):
		LogWrapper.warning(name, "Character with ID %s not found in the list" % npc_id)
		return
	
	var character_item: CharacterItem = _character_items[npc_id]
	character_item.queue_free()
	_character_items.erase(npc_id)
	
	if _selected_npc_id == npc_id:
		_selected_npc_id = ""
	
	LogWrapper.debug(name, "Removed character %s from the list" % npc_id)


func select_character(npc_id: String) -> void:
	LogWrapper.debug(name, "DEBUG: select_character called - npc_id: ", npc_id)
	
	if not _character_items.has(npc_id):
		LogWrapper.warning(name, "Character with ID %s not found in the list" % npc_id)
		LogWrapper.debug(name, "DEBUG: _character_items keys: ", _character_items.keys())
		return
	
	LogWrapper.debug(name, "DEBUG: Deselecting current character: ", _selected_npc_id)
	_deselect_current_character()
	
	var character_item: CharacterItem = _character_items[npc_id]
	character_item.set_selected(true)
	_selected_npc_id = npc_id
	
	LogWrapper.debug(name, "DEBUG: Emitting character_selected signal for: ", npc_id)
	character_selected.emit(npc_id)
	
	LogWrapper.debug(name, "Selected character %s" % npc_id)


func _deselect_current_character() -> void:
	if not _selected_npc_id.is_empty() and _character_items.has(_selected_npc_id):
		var character_item: CharacterItem = _character_items[_selected_npc_id]
		character_item.set_selected(false)


func get_selected_character_id() -> String:
	return _selected_npc_id


func get_character_count() -> int:
	return _character_items.size()


func clear_list() -> void:
	for npc_id: String in _character_items.keys():
		var character_item: CharacterItem = _character_items[npc_id]
		character_item.queue_free()
	
	_character_items.clear()
	_selected_npc_id = ""
	
	LogWrapper.debug(name, "Cleared all characters from the list")


func scroll_to_character(npc_id: String) -> void:
	if not _character_items.has(npc_id):
		return
	
	var character_item: CharacterItem = _character_items[npc_id]
	
	if scroll_container:
		var target_y: float = character_item.global_position.y - scroll_container.global_position.y
		_scroll_to_position(target_y)


func _scroll_to_position(y_position: float) -> void:
	if not scroll_container:
		return
	
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(scroll_container, "scroll_vertical", y_position, scroll_speed)
	_tween.play()


func _on_character_item_clicked(npc_id: String) -> void:
	select_character(npc_id)


func _exit_tree() -> void:
	clear_list()
