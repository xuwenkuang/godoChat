class_name ItemProfileManager
extends Node

signal item_profile_loaded(item_id: String, profile: ItemProfile)
signal item_profile_failed(item_id: String)

var _item_profiles: Dictionary = {}

func _ready() -> void:
	_load_default_profiles()

func _load_default_profiles() -> void:
	pass

func register_item_profile(profile: ItemProfile) -> void:
	if not profile or not profile.is_valid():
		push_warning("ItemProfileManager: Cannot register invalid profile")
		return
	
	var item_id: String = profile.item_id
	_item_profiles[item_id] = profile
	item_profile_loaded.emit(item_id, profile)

func unregister_item_profile(item_id: String) -> void:
	if _item_profiles.has(item_id):
		_item_profiles.erase(item_id)

func get_item_profile(item_id: String) -> ItemProfile:
	if _item_profiles.has(item_id):
		return _item_profiles[item_id]
	return null

func has_item_profile(item_id: String) -> bool:
	return _item_profiles.has(item_id)

func get_all_item_ids() -> Array[String]:
	var ids: Array[String] = []
	for item_id: String in _item_profiles:
		ids.append(item_id)
	return ids

func get_item_count() -> int:
	return _item_profiles.size()

func clear_all_profiles() -> void:
	_item_profiles.clear()

func load_profile_from_dict(data: Dictionary) -> bool:
	var profile: ItemProfile = ItemProfile.new()
	profile.import_from_dict(data)
	
	if profile.is_valid():
		register_item_profile(profile)
		return true
	else:
		push_warning("ItemProfileManager: Failed to load profile from dict")
		return false

func load_profiles_from_dict_array(data_array: Array) -> int:
	var loaded_count: int = 0
	for data: Dictionary in data_array:
		if load_profile_from_dict(data):
			loaded_count += 1
	return loaded_count

func load_profile_from_json_file(file_path: String) -> bool:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("ItemProfileManager: Cannot open file: %s" % file_path)
		return false
	
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)
	if parse_result != OK:
		push_error("ItemProfileManager: Failed to parse JSON from file: %s" % file_path)
		return false
	
	if json.data is Dictionary:
		return load_profile_from_dict(json.data)
	elif json.data is Array:
		var loaded_count: int = load_profiles_from_dict_array(json.data)
		return loaded_count > 0
	else:
		push_error("ItemProfileManager: Invalid JSON format in file: %s" % file_path)
		return false

func save_profile_to_json_file(item_id: String, file_path: String) -> bool:
	var profile: ItemProfile = get_item_profile(item_id)
	if not profile:
		push_error("ItemProfileManager: Profile not found: %s" % item_id)
		return false
	
	var error: Error = profile.export_to_json_file(file_path)
	if error != OK:
		push_error("ItemProfileManager: Failed to save profile to file: %s" % file_path)
		return false
	
	return true

func save_all_profiles_to_json_file(file_path: String) -> bool:
	var data_array: Array = []
	for item_id: String in _item_profiles:
		var profile: ItemProfile = _item_profiles[item_id]
		data_array.append(profile.export_to_dict())
	
	var json_string: String = JSON.stringify(data_array, "\t")
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("ItemProfileManager: Cannot open file for writing: %s" % file_path)
		return false
	
	file.store_string(json_string)
	file.close()
	return true

func search_profiles_by_name(search_term: String) -> Array[ItemProfile]:
	var results: Array[ItemProfile] = []
	var search_name: String = search_term.to_lower()
	
	for item_id: String in _item_profiles:
		var profile: ItemProfile = _item_profiles[item_id]
		if profile.item_name.to_lower().contains(search_name):
			results.append(profile)
	
	return results

func search_profiles_by_type(item_type: ItemProfile.ItemType) -> Array[ItemProfile]:
	var results: Array[ItemProfile] = []
	
	for item_id: String in _item_profiles:
		var profile: ItemProfile = _item_profiles[item_id]
		if profile.item_type == item_type:
			results.append(profile)
	
	return results

func search_profiles_by_rarity(rarity: ItemProfile.ItemRarity) -> Array[ItemProfile]:
	var results: Array[ItemProfile] = []
	
	for item_id: String in _item_profiles:
		var profile: ItemProfile = _item_profiles[item_id]
		if profile.rarity == rarity:
			results.append(profile)
	
	return results

func search_profiles_by_tag(tag: String) -> Array[ItemProfile]:
	var results: Array[ItemProfile] = []
	
	for item_id: String in _item_profiles:
		var profile: ItemProfile = _item_profiles[item_id]
		if tag in profile.custom_tags:
			results.append(profile)
	
	return results

func get_items_by_value_range(min_value: int, max_value: int) -> Array[ItemProfile]:
	var results: Array[ItemProfile] = []
	
	for item_id: String in _item_profiles:
		var profile: ItemProfile = _item_profiles[item_id]
		if profile.value >= min_value and profile.value <= max_value:
			results.append(profile)
	
	return results

func clone_profile(item_id: String) -> ItemProfile:
	var profile: ItemProfile = get_item_profile(item_id)
	if profile:
		return profile.clone()
	return null
