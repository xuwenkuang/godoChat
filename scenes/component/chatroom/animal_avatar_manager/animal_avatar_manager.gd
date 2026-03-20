extends Node
## 动物头像管理器 - 负责管理所有动物头像资源的加载和缓存
##
## 功能说明：
## - 管理所有动物头像资源的加载和缓存
## - 支持同步和异步加载
## - 提供编辑器预览功能
## - 实现头像资源的快速查看
##
## 使用场景：
## - 聊天室中的动物角色头像显示
## - 角色选择界面
## - 对话历史面板
##
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

## 头像缓存条目类
class AvatarCacheEntry:
	var animal_id: String
	var texture: Texture2D
	var resource_path: String
	var reference_count: int
	var last_used: float
	var load_time: float

	func _init(p_animal_id: String, p_texture: Texture2D, p_resource_path: String):
		animal_id = p_animal_id
		texture = p_texture
		resource_path = p_resource_path
		reference_count = 0
		last_used = Time.get_unix_time_from_system()
		load_time = 0.0

## 头像加载状态枚举
enum LoadStatus {
	NOT_LOADED,
	LOADING,
	LOADED,
	ERROR
}

## Signals - 头像加载事件信号
signal avatar_loading_started(animal_id: String)
signal avatar_loading_completed(animal_id: String, texture: Texture2D)
signal avatar_loading_failed(animal_id: String, error: String)
signal avatar_cache_cleared()
signal all_avatars_preloaded()

## Configuration - 配置参数
@export_category("Configuration")
@export var enable_caching: bool = true
@export var cache_timeout: float = 600.0
@export var enable_async_loading: bool = true
@export var preload_on_ready: bool = false
@export var avatar_base_path: String = "res://assets/image/game/animal/png/round/"

## Editor Preview - 编辑器预览
@export_category("Editor Preview")
@export var preview_animal_id: String = "elephant"
@export_group("Supported Animals")
@export var supported_animals: Array[String] = [
	"elephant",
	"giraffe",
	"hippo",
	"monkey",
	"panda",
	"parrot",
	"penguin",
	"pig",
	"rabbit",
	"snake"
]

## State - 内部状态
var _avatar_cache: Dictionary = {}
var _loading_tasks: Dictionary = {}
var _preload_queue: Array = []

## Singleton references
@onready var LogWrapper = get_node("/root/LogWrapper")


func _ready() -> void:
	LogWrapper.info(self, "AnimalAvatarManager initialized")
	
	if preload_on_ready:
		preload_all_avatars()


func _get_property_list() -> Array:
	var properties: Array = []
	
	properties.append({
		"name": "Editor Preview",
		"type": TYPE_NIL,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_CATEGORY
	})
	
	properties.append({
		"name": "preview_animal_id",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(supported_animals),
		"usage": PROPERTY_USAGE_EDITOR
	})
	
	return properties


## 获取头像（同步）
func get_avatar(animal_id: String) -> Texture2D:
	if not _is_valid_animal_id(animal_id):
		LogWrapper.warn(self, "Invalid animal ID: ", animal_id)
		return _get_default_avatar()
	
	if enable_caching and _avatar_cache.has(animal_id):
		var cache_entry: AvatarCacheEntry = _avatar_cache[animal_id]
		cache_entry.reference_count += 1
		cache_entry.last_used = Time.get_unix_time_from_system()
		LogWrapper.debug(self, "Avatar loaded from cache: %s (ref count: %d)" % [animal_id, cache_entry.reference_count])
		return cache_entry.texture
	
	LogWrapper.info(self, "Loading avatar: ", animal_id)
	avatar_loading_started.emit(animal_id)
	
	var resource_path: String = avatar_base_path + animal_id + ".png"
	var texture: Texture2D = load(resource_path)
	
	if not texture:
		LogWrapper.error(self, "Failed to load avatar: %s from path: %s" % [animal_id, resource_path])
		avatar_loading_failed.emit(animal_id, "Resource not found: " + resource_path)
		return _get_default_avatar()
	
	if enable_caching:
		var cache_entry: AvatarCacheEntry = AvatarCacheEntry.new(animal_id, texture, resource_path)
		cache_entry.reference_count = 1
		_avatar_cache[animal_id] = cache_entry
	
	avatar_loading_completed.emit(animal_id, texture)
	LogWrapper.info(self, "Avatar loaded successfully: ", animal_id)
	
	return texture


## 获取头像（异步）
func get_avatar_async(animal_id: String) -> void:
	if not _is_valid_animal_id(animal_id):
		LogWrapper.warn(self, "Invalid animal ID: ", animal_id)
		avatar_loading_failed.emit(animal_id, "Invalid animal ID")
		return
	
	if _loading_tasks.has(animal_id):
		LogWrapper.warn(self, "Avatar already loading: ", animal_id)
		return
	
	if enable_caching and _avatar_cache.has(animal_id):
		var cache_entry: AvatarCacheEntry = _avatar_cache[animal_id]
		cache_entry.reference_count += 1
		cache_entry.last_used = Time.get_unix_time_from_system()
		avatar_loading_completed.emit(animal_id, cache_entry.texture)
		LogWrapper.debug(self, "Avatar loaded from cache (async): ", animal_id)
		return
	
	if not enable_async_loading:
		get_avatar(animal_id)
		return
	
	LogWrapper.info(self, "Starting async avatar load: ", animal_id)
	avatar_loading_started.emit(animal_id)
	
	_loading_tasks[animal_id] = true
	
	await get_tree().process_frame
	
	var resource_path: String = avatar_base_path + animal_id + ".png"
	var texture: Texture2D = load(resource_path)
	
	_loading_tasks.erase(animal_id)
	
	if not texture:
		LogWrapper.error(self, "Failed to load avatar (async): %s from path: %s" % [animal_id, resource_path])
		avatar_loading_failed.emit(animal_id, "Resource not found: " + resource_path)
		return
	
	if enable_caching:
		var cache_entry: AvatarCacheEntry = AvatarCacheEntry.new(animal_id, texture, resource_path)
		cache_entry.reference_count = 1
		_avatar_cache[animal_id] = cache_entry
	
	avatar_loading_completed.emit(animal_id, texture)
	LogWrapper.info(self, "Avatar loaded successfully (async): ", animal_id)


## 预加载头像
func preload_avatar(animal_id: String) -> void:
	if not _is_valid_animal_id(animal_id):
		LogWrapper.warn(self, "Invalid animal ID for preload: ", animal_id)
		return
	
	if enable_caching and _avatar_cache.has(animal_id):
		LogWrapper.debug(self, "Avatar already cached: ", animal_id)
		return
	
	_preload_queue.append(animal_id)
	LogWrapper.info(self, "Avatar added to preload queue: ", animal_id)
	
	_process_preload_queue()


## 预加载所有头像
func preload_all_avatars() -> void:
	for animal_id: String in supported_animals:
		preload_avatar(animal_id)
	
	LogWrapper.info(self, "All avatars added to preload queue")


## 处理预加载队列
func _process_preload_queue() -> void:
	while not _preload_queue.is_empty():
		var animal_id: String = _preload_queue.pop_front()
		
		LogWrapper.info(self, "Preloading avatar: ", animal_id)
		avatar_loading_started.emit(animal_id)
		
		var resource_path: String = avatar_base_path + animal_id + ".png"
		var texture: Texture2D = load(resource_path)
		
		if not texture:
			LogWrapper.error(self, "Failed to preload avatar: %s from path: %s" % [animal_id, resource_path])
			avatar_loading_failed.emit(animal_id, "Resource not found: " + resource_path)
			continue
		
		if enable_caching:
			var cache_entry: AvatarCacheEntry = AvatarCacheEntry.new(animal_id, texture, resource_path)
			cache_entry.reference_count = 0
			_avatar_cache[animal_id] = cache_entry
		
		LogWrapper.info(self, "Avatar preloaded successfully: ", animal_id)
	
	all_avatars_preloaded.emit()


## 释放头像引用
func release_avatar(animal_id: String) -> bool:
	if not enable_caching:
		return false
	
	if not _avatar_cache.has(animal_id):
		LogWrapper.warn(self, "Avatar not found in cache: ", animal_id)
		return false
	
	var cache_entry: AvatarCacheEntry = _avatar_cache[animal_id]
	
	if cache_entry.reference_count > 0:
		cache_entry.reference_count -= 1
		LogWrapper.debug(self, "Avatar reference decreased: %s (ref count: %d)" % [animal_id, cache_entry.reference_count])
		return true
	
	return false


## 检查头像是否已加载
func is_avatar_loaded(animal_id: String) -> bool:
	if not enable_caching:
		return false
	
	return _avatar_cache.has(animal_id)


## 获取头像加载状态
func get_avatar_status(animal_id: String) -> LoadStatus:
	if _loading_tasks.has(animal_id):
		return LoadStatus.LOADING
	
	if enable_caching and _avatar_cache.has(animal_id):
		return LoadStatus.LOADED
	
	return LoadStatus.NOT_LOADED


## 获取头像信息
func get_avatar_info(animal_id: String) -> Dictionary:
	if not enable_caching:
		return {}
	
	if not _avatar_cache.has(animal_id):
		return {}
	
	var cache_entry: AvatarCacheEntry = _avatar_cache[animal_id]
	return {
		"animal_id": cache_entry.animal_id,
		"resource_path": cache_entry.resource_path,
		"reference_count": cache_entry.reference_count,
		"last_used": cache_entry.last_used,
		"is_loaded": true
	}


## 获取所有已加载的头像
func get_loaded_avatars() -> Array:
	if not enable_caching:
		return []
	
	return _avatar_cache.keys()


## 获取缓存大小
func get_cache_size() -> int:
	if not enable_caching:
		return 0
	
	return _avatar_cache.size()


## 清理未使用的头像
func cleanup_unused_avatars() -> void:
	if not enable_caching:
		return
	
	var current_time: float = Time.get_unix_time_from_system()
	var avatars_to_remove: Array = []
	
	for animal_id: String in _avatar_cache:
		var cache_entry: AvatarCacheEntry = _avatar_cache[animal_id]
		
		if cache_entry.reference_count == 0 and (current_time - cache_entry.last_used) > cache_timeout:
			avatars_to_remove.append(animal_id)
	
	for animal_id: String in avatars_to_remove:
		_avatar_cache.erase(animal_id)
	
	if not avatars_to_remove.is_empty():
		LogWrapper.info(self, "Cleaned up ", avatars_to_remove.size(), " unused avatars")
	else:
		LogWrapper.debug(self, "No unused avatars to clean up")


## 清空头像缓存
func clear_cache() -> void:
	if not enable_caching:
		return
	
	_avatar_cache.clear()
	avatar_cache_cleared.emit()
	LogWrapper.info(self, "Avatar cache cleared")


## 获取默认头像
func _get_default_avatar() -> Texture2D:
	var default_path: String = avatar_base_path + "elephant.png"
	var default_texture: Texture2D = load(default_path)
	
	if default_texture:
		return default_texture
	
	return null


## 验证动物ID是否有效
func _is_valid_animal_id(animal_id: String) -> bool:
	return animal_id in supported_animals


## 获取支持的头像列表
func get_supported_animals() -> Array[String]:
	return supported_animals.duplicate()


## 获取头像资源路径
func get_avatar_resource_path(animal_id: String) -> String:
	if not _is_valid_animal_id(animal_id):
		return ""
	
	return avatar_base_path + animal_id + ".png"


## 获取编辑器预览头像
func _get_preview_avatar() -> Texture2D:
	if Engine.is_editor_hint():
		return get_avatar(preview_animal_id)
	return null


## 批量获取头像
func get_avatars_batch(animal_ids: Array[String]) -> Dictionary:
	var result: Dictionary = {}
	
	for animal_id: String in animal_ids:
		result[animal_id] = get_avatar(animal_id)
	
	return result


## 批量异步获取头像
func get_avatars_batch_async(animal_ids: Array[String]) -> void:
	for animal_id: String in animal_ids:
		get_avatar_async(animal_id)


## 获取头像统计信息
func get_statistics() -> Dictionary:
	var total_refs: int = 0
	
	if enable_caching:
		for cache_entry: AvatarCacheEntry in _avatar_cache.values():
			total_refs += cache_entry.reference_count
	
	return {
		"cache_enabled": enable_caching,
		"cache_size": _avatar_cache.size(),
		"total_references": total_refs,
		"loading_tasks": _loading_tasks.size(),
		"preload_queue_size": _preload_queue.size(),
		"supported_animals": supported_animals.size(),
		"cache_timeout": cache_timeout
	}


## 设置头像基础路径
func set_avatar_base_path(path: String) -> void:
	avatar_base_path = path
	LogWrapper.info(self, "Avatar base path set to: ", path)


## 启用/禁用缓存
func set_caching_enabled(enabled: bool) -> void:
	enable_caching = enabled
	
	if not enabled:
		clear_cache()
	
	LogWrapper.info(self, "Caching ", "enabled" if enabled else "disabled")


## 设置缓存超时时间
func set_cache_timeout(timeout: float) -> void:
	cache_timeout = timeout
	LogWrapper.info(self, "Cache timeout set to: %s seconds" % timeout)


## 获取头像使用统计
func get_avatar_usage_stats() -> Dictionary:
	if not enable_caching:
		return {}
	
	var stats: Dictionary = {}
	
	for animal_id: String in _avatar_cache:
		var cache_entry: AvatarCacheEntry = _avatar_cache[animal_id]
		stats[animal_id] = {
			"reference_count": cache_entry.reference_count,
			"last_used": cache_entry.last_used,
			"load_time": cache_entry.load_time
		}
	
	return stats


## 检查头像资源是否存在
func check_avatar_resource_exists(animal_id: String) -> bool:
	if not _is_valid_animal_id(animal_id):
		return false
	
	var resource_path: String = avatar_base_path + animal_id + ".png"
	return FileAccess.file_exists(resource_path)


## 获取缺失的头像资源列表
func get_missing_avatars() -> Array[String]:
	var missing: Array[String] = []
	
	for animal_id: String in supported_animals:
		if not check_avatar_resource_exists(animal_id):
			missing.append(animal_id)
	
	return missing


## 退出时清理
func _exit_tree() -> void:
	if enable_caching:
		clear_cache()
	
	_preload_queue.clear()
	_loading_tasks.clear()
