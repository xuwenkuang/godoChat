extends Node
## 模型管理器 - 负责管理 LLM 模型的加载、缓存和生命周期
##
## 功能说明：
## - 管理 NobodyWhoModel 节点的生命周期
## - 提供模型加载、卸载、查询接口
## - 支持模型缓存，避免重复加载
## - 支持异步加载和预加载
## - 提供 GPU 加速配置选项（macOS Metal 支持）
## - 发送模型加载状态信号
##
## 使用场景：
## - 游戏中的 AI 对话系统
## - 动态文本生成
## - NPC 行为决策
##
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

## 模型缓存条目类
class ModelCacheEntry:
	var model_id: String
	var model_node: NobodyWhoModel
	var model_path: String
	var reference_count: int
	var last_used: float
	var is_preloaded: bool
	var load_time: float
	var memory_usage: int
	var priority: int

	func _init(p_model_id: String, p_model_node: NobodyWhoModel, p_model_path: String, p_priority: int = 0) -> void:
		model_id = p_model_id
		model_node = p_model_node
		model_path = p_model_path
		reference_count = 0
		last_used = Time.get_unix_time_from_system()
		is_preloaded = false
		load_time = 0.0
		memory_usage = 0
		priority = p_priority

## 模型加载状态枚举
enum LoadStatus {
	NOT_LOADED,
	LOADING,
	LOADED,
	UNLOADING,
	ERROR
}

## GPU 加速后端枚举
enum GPUBackend {
	CPU_ONLY,
	METAL,
	CUDA,
	ROCM,
	VULKAN
}

## Signals - 模型加载事件信号
signal model_loading_started(model_id: String)
signal model_loading_completed(model_id: String, model_node: NobodyWhoModel)
signal model_loading_failed(model_id: String, error: String)
signal model_unloading_started(model_id: String)
signal model_unloading_completed(model_id: String)
signal model_cache_cleared()
signal preloading_completed(model_id: String)
signal performance_stats_updated(stats: Dictionary)
signal memory_warning_triggered(current_usage: int, threshold: int)

## Configuration - 配置参数
@export_category("Configuration")
@export var max_cache_size: int = 5
@export var cache_timeout: float = 300.0
@export var enable_gpu_acceleration: bool = true
@export var gpu_backend: GPUBackend = GPUBackend.CPU_ONLY
@export var default_max_tokens: int = 2048
@export var default_temperature: float = 0.7
@export var default_top_p: float = 0.9
@export var default_top_k: int = 40
@export var enable_auto_cleanup: bool = true
@export var cleanup_interval: float = 60.0
@export var enable_background_loading: bool = true
@export var max_background_threads: int = 2
@export var enable_lru_cache: bool = true
@export var enable_memory_monitoring: bool = true
@export var memory_warning_threshold: int = 1073741824
@export var default_model_id: String = "default"
@export var default_model_path: String = ""

enum ModelType {
	LOCAL,
	REMOTE_OPENAI,
	REMOTE_CLAUDE,
	REMOTE_KIMI,
	REMOTE_CUSTOM
}

var model_settings: Dictionary = {}

## State - 内部状态
var _model_cache: Dictionary = {}
var _loading_tasks: Dictionary = {}
var _preload_queue: Array = []
var _cleanup_timer: Timer = null
var _background_threads: Array[Thread] = []
var _active_thread_count: int = 0
var _lru_order: Array = []
var _performance_stats: Dictionary = {}
var _memory_usage_history: Array[Dictionary] = []

## Singleton references
@onready var LogWrapper: Node = get_node("/root/LogWrapper")


func _ready() -> void:
	LogWrapper.info(self, "ModelManager initialized")
	
	if enable_auto_cleanup:
		_setup_cleanup_timer()
	
	_detect_gpu_backend()
	_load_model_settings()
	_load_default_model()


func _load_model_settings() -> void:
	var config_file: ConfigFile = ConfigFile.new()
	var config_path: String = "user://model_settings.cfg"
	
	var load_result: Error = config_file.load(config_path)
	if load_result == OK:
		model_settings = {
			"model_type": config_file.get_value("model", "type", ModelType.REMOTE_OPENAI),
			"api_url": config_file.get_value("model", "api_url", ""),
			"api_key": config_file.get_value("model", "api_key", ""),
			"model_name": config_file.get_value("model", "model_name", ""),
			"temperature": config_file.get_value("model", "temperature", 0.7),
			"max_tokens": config_file.get_value("model", "max_tokens", 1000)
		}
		LogWrapper.info(self, "Model settings loaded from config")
	else:
		model_settings = _get_default_settings()
		LogWrapper.debug(self, "Using default model settings")


func _get_default_settings() -> Dictionary:
	return {
		"model_type": ModelType.REMOTE_OPENAI,
		"api_url": "https://api.openai.com/v1/chat/completions",
		"api_key": "",
		"model_name": "gpt-3.5-turbo",
		"temperature": 0.7,
		"max_tokens": 1000
	}


func _load_default_model() -> void:
	if default_model_id == "" or default_model_path == "":
		LogWrapper.debug(self, "No default model configured")
		return
	
	if not is_model_loaded(default_model_id):
		LogWrapper.info(self, "Loading default model: ", default_model_id)
		load_model(default_model_id, default_model_path)


func _setup_cleanup_timer() -> void:
	_cleanup_timer = Timer.new()
	_cleanup_timer.wait_time = cleanup_interval
	_cleanup_timer.autostart = true
	_cleanup_timer.timeout.connect(_on_cleanup_timeout)
	add_child(_cleanup_timer)
	LogWrapper.debug(self, "Auto cleanup timer started with interval: %s seconds" % cleanup_interval)


func _detect_gpu_backend() -> void:
	var os_name: String = OS.get_name()
	
	if enable_gpu_acceleration:
		if os_name == "macOS":
			gpu_backend = GPUBackend.METAL
			LogWrapper.info(self, "Detected macOS, using Metal backend for GPU acceleration")
		elif os_name == "Windows":
			gpu_backend = GPUBackend.CUDA
			LogWrapper.info(self, "Detected Windows, using CUDA backend for GPU acceleration")
		elif os_name == "Linux":
			gpu_backend = GPUBackend.ROCM
			LogWrapper.info(self, "Detected Linux, using ROCm backend for GPU acceleration")
		else:
			gpu_backend = GPUBackend.CPU_ONLY
			LogWrapper.warn(self, "Unsupported OS for GPU acceleration, using CPU only")
	else:
		gpu_backend = GPUBackend.CPU_ONLY
		LogWrapper.info(self, "GPU acceleration disabled, using CPU only")


func _on_cleanup_timeout() -> void:
	cleanup_unused_models()


## 加载模型（同步）
func load_model(model_id: String, model_path: String) -> NobodyWhoModel:
	var cache_entry: ModelCacheEntry
	
	if _model_cache.has(model_id):
		cache_entry = _model_cache[model_id]
		cache_entry.reference_count += 1
		cache_entry.last_used = Time.get_unix_time_from_system()
		LogWrapper.debug(self, "Model loaded from cache: %s (ref count: %d)" % [model_id, cache_entry.reference_count])
		return cache_entry.model_node
	
	LogWrapper.info(self, "Loading model: %s from path: %s" % [model_id, model_path])
	model_loading_started.emit(model_id)
	
	var model_node: NobodyWhoModel = NobodyWhoModel.new()
	model_node.name = "Model_" + model_id
	add_child(model_node)
	
	model_node.load_model(model_path)
	model_node.set_generation_parameters(default_max_tokens, default_temperature, default_top_p, default_top_k)
	
	cache_entry = ModelCacheEntry.new(model_id, model_node, model_path)
	cache_entry.reference_count = 1
	_model_cache[model_id] = cache_entry
	
	model_loading_completed.emit(model_id, model_node)
	LogWrapper.info(self, "Model loaded successfully: ", model_id)
	
	return model_node


## 加载模型（异步）
func load_model_async(model_id: String, model_path: String) -> void:
	var cache_entry: ModelCacheEntry
	
	if _loading_tasks.has(model_id):
		LogWrapper.warn(self, "Model already loading: ", model_id)
		return
	
	if _model_cache.has(model_id):
		cache_entry = _model_cache[model_id]
		cache_entry.reference_count += 1
		cache_entry.last_used = Time.get_unix_time_from_system()
		model_loading_completed.emit(model_id, cache_entry.model_node)
		LogWrapper.debug(self, "Model loaded from cache (async): %s" % model_id)
		return
	
	LogWrapper.info(self, "Starting async model load: %s from path: %s" % [model_id, model_path])
	model_loading_started.emit(model_id)
	
	_loading_tasks[model_id] = true
	
	await get_tree().process_frame
	
	var model_node: NobodyWhoModel = NobodyWhoModel.new()
	model_node.name = "Model_" + model_id
	add_child(model_node)
	
	model_node.load_model(model_path)
	model_node.set_generation_parameters(default_max_tokens, default_temperature, default_top_p, default_top_k)
	
	cache_entry = ModelCacheEntry.new(model_id, model_node, model_path)
	cache_entry.reference_count = 1
	_model_cache[model_id] = cache_entry
	
	_loading_tasks.erase(model_id)
	
	model_loading_completed.emit(model_id, model_node)
	LogWrapper.info(self, "Model loaded successfully (async): ", model_id)


## 预加载模型
func preload_model(model_id: String, model_path: String) -> void:
	if _model_cache.has(model_id):
		LogWrapper.debug(self, "Model already cached: ", model_id)
		return
	
	_preload_queue.append({"model_id": model_id, "model_path": model_path})
	LogWrapper.info(self, "Model added to preload queue: ", model_id)
	
	_process_preload_queue()


func _process_preload_queue() -> void:
	while not _preload_queue.is_empty():
		var preload_data: Dictionary = _preload_queue.pop_front()
		var model_id: String = preload_data["model_id"]
		var model_path: String = preload_data["model_path"]
		
		LogWrapper.info(self, "Preloading model: ", model_id)
		model_loading_started.emit(model_id)
		
		var model_node: NobodyWhoModel = NobodyWhoModel.new()
		model_node.name = "Model_" + model_id
		add_child(model_node)
		
		model_node.load_model(model_path)
		model_node.set_generation_parameters(default_max_tokens, default_temperature, default_top_p, default_top_k)
		
		var cache_entry: ModelCacheEntry = ModelCacheEntry.new(model_id, model_node, model_path)
		cache_entry.reference_count = 0
		cache_entry.is_preloaded = true
		_model_cache[model_id] = cache_entry
		
		preloading_completed.emit(model_id)
		LogWrapper.info(self, "Model preloaded successfully: ", model_id)


## 卸载模型
func unload_model(model_id: String) -> bool:
	if not _model_cache.has(model_id):
		LogWrapper.warn(self, "Model not found in cache: ", model_id)
		return false
	
	var cache_entry: ModelCacheEntry = _model_cache[model_id]
	
	if cache_entry.reference_count > 0:
		cache_entry.reference_count -= 1
		LogWrapper.debug(self, "Model reference decreased: %s (ref count: %d)" % [model_id, cache_entry.reference_count])
		
		if cache_entry.reference_count > 0:
			return true
	
	LogWrapper.info(self, "Unloading model: ", model_id)
	model_unloading_started.emit(model_id)
	
	cache_entry.model_node.queue_free()
	_model_cache.erase(model_id)
	
	model_unloading_completed.emit(model_id)
	LogWrapper.info(self, "Model unloaded successfully: ", model_id)
	
	return true


## 强制卸载模型（忽略引用计数）
func force_unload_model(model_id: String) -> bool:
	if not _model_cache.has(model_id):
		LogWrapper.warn(self, "Model not found in cache: ", model_id)
		return false
	
	LogWrapper.info(self, "Force unloading model: ", model_id)
	model_unloading_started.emit(model_id)
	
	var cache_entry: ModelCacheEntry = _model_cache[model_id]
	cache_entry.model_node.queue_free()
	_model_cache.erase(model_id)
	
	model_unloading_completed.emit(model_id)
	LogWrapper.info(self, "Model force unloaded successfully: ", model_id)
	
	return true


## 获取模型
func get_model(model_id: String) -> NobodyWhoModel:
	if not _model_cache.has(model_id):
		return null
	
	var cache_entry: ModelCacheEntry = _model_cache[model_id]
	cache_entry.reference_count += 1
	cache_entry.last_used = Time.get_unix_time_from_system()
	
	return cache_entry.model_node


## 检查模型是否已加载
func is_model_loaded(model_id: String) -> bool:
	return _model_cache.has(model_id)


## 获取模型加载状态
func get_model_status(model_id: String) -> LoadStatus:
	if _loading_tasks.has(model_id):
		return LoadStatus.LOADING
	
	if _model_cache.has(model_id):
		return LoadStatus.LOADED
	
	return LoadStatus.NOT_LOADED


## 获取模型信息
func get_model_info(model_id: String) -> Dictionary:
	if not _model_cache.has(model_id):
		return {}
	
	var cache_entry: ModelCacheEntry = _model_cache[model_id]
	return {
		"model_id": cache_entry.model_id,
		"model_path": cache_entry.model_path,
		"reference_count": cache_entry.reference_count,
		"last_used": cache_entry.last_used,
		"is_preloaded": cache_entry.is_preloaded,
		"is_loaded": true
	}


## 获取所有已加载的模型
func get_loaded_models() -> Array:
	return _model_cache.keys()


## 获取默认模型
func get_default_model() -> NobodyWhoModel:
	if default_model_id == "":
		LogWrapper.warn(self, "No default model ID configured")
		return null
	
	return get_model(default_model_id)


## 获取模型设置
func get_model_settings() -> Dictionary:
	return model_settings.duplicate()


## 设置模型配置
func set_model_settings(settings: Dictionary) -> void:
	model_settings = settings.duplicate()
	LogWrapper.info(self, "Model settings updated")
	
	var config_file: ConfigFile = ConfigFile.new()
	var config_path: String = "user://model_settings.cfg"
	
	config_file.set_value("model", "type", settings.get("model_type", ModelType.REMOTE_OPENAI))
	config_file.set_value("model", "api_url", settings.get("api_url", ""))
	config_file.set_value("model", "api_key", settings.get("api_key", ""))
	config_file.set_value("model", "model_name", settings.get("model_name", ""))
	config_file.set_value("model", "temperature", settings.get("temperature", 0.7))
	config_file.set_value("model", "max_tokens", settings.get("max_tokens", 1000))
	
	var save_result: Error = config_file.save(config_path)
	if save_result != OK:
		LogWrapper.error(self, "Failed to save model settings: ", save_result)
	else:
		LogWrapper.info(self, "Model settings saved to config")


## 创建远程模型
func create_remote_model(settings: Dictionary) -> NobodyWhoModel:
	var model_node: NobodyWhoModel = NobodyWhoModel.new()
	model_node.name = "RemoteModel_" + str(get_instance_id())
	
	var api_url: String = settings.get("api_url", "")
	var api_key: String = settings.get("api_key", "")
	var model_name: String = settings.get("model_name", "")
	var temperature: float = settings.get("temperature", 0.7)
	var max_tokens: int = settings.get("max_tokens", 1000)
	
	model_node.set_generation_parameters(max_tokens, temperature, default_top_p, default_top_k)
	model_node.set_remote_config(api_url, api_key, model_name)
	
	LogWrapper.info(self, "Created remote model: ", model_name)
	return model_node


## 获取缓存大小
func get_cache_size() -> int:
	return _model_cache.size()


## 清理未使用的模型
func cleanup_unused_models() -> void:
	var current_time: float = Time.get_unix_time_from_system()
	var models_to_remove: Array = []
	
	for model_id: String in _model_cache:
		var cache_entry: ModelCacheEntry = _model_cache[model_id]
		
		if cache_entry.reference_count == 0 and (current_time - cache_entry.last_used) > cache_timeout:
			models_to_remove.append(model_id)
	
	for model_id: String in models_to_remove:
		force_unload_model(model_id)
	
	if not models_to_remove.is_empty():
		LogWrapper.info(self, "Cleaned up ", models_to_remove.size(), " unused models")
	else:
		LogWrapper.debug(self, "No unused models to clean up")


## 清空模型缓存
func clear_cache() -> void:
	var model_ids: Array = _model_cache.keys()
	
	for model_id: String in model_ids:
		force_unload_model(model_id)
	
	model_cache_cleared.emit()
	LogWrapper.info(self, "Model cache cleared")


## 设置生成参数
func set_generation_parameters(model_id: String, max_tokens: int = 2048, temperature: float = 0.7, top_p: float = 0.9, top_k: int = 40) -> bool:
	if not _model_cache.has(model_id):
		LogWrapper.warn(self, "Model not found: ", model_id)
		return false
	
	var cache_entry: ModelCacheEntry = _model_cache[model_id]
	cache_entry.model_node.set_generation_parameters(max_tokens, temperature, top_p, top_k)
	
	LogWrapper.debug(self, "Generation parameters updated for model: ", model_id)
	return true


## 获取 GPU 加速配置
func get_gpu_config() -> Dictionary:
	return {
		"enabled": enable_gpu_acceleration,
		"backend": gpu_backend,
		"backend_name": _get_backend_name(gpu_backend)
	}


func _get_backend_name(backend: GPUBackend) -> String:
	match backend:
		GPUBackend.CPU_ONLY:
			return "CPU Only"
		GPUBackend.METAL:
			return "Metal (macOS)"
		GPUBackend.CUDA:
			return "CUDA (NVIDIA)"
		GPUBackend.ROCM:
			return "ROCm (AMD)"
		GPUBackend.VULKAN:
			return "Vulkan"
		_:
			return "Unknown"


## 设置 GPU 加速后端
func set_gpu_backend(backend: GPUBackend) -> void:
	gpu_backend = backend
	LogWrapper.info(self, "GPU backend set to: ", _get_backend_name(backend))


## 启用/禁用 GPU 加速
func set_gpu_acceleration(enabled: bool) -> void:
	enable_gpu_acceleration = enabled
	
	if enabled:
		_detect_gpu_backend()
		LogWrapper.info(self, "GPU acceleration enabled")
	else:
		gpu_backend = GPUBackend.CPU_ONLY
		LogWrapper.info(self, "GPU acceleration disabled")


## 获取管理器统计信息
func get_statistics() -> Dictionary:
	var total_refs: int = 0
	var preloaded_count: int = 0
	var total_load_time: float = 0.0
	var total_memory: int = 0
	
	for cache_entry: ModelCacheEntry in _model_cache.values():
		total_refs += cache_entry.reference_count
		if cache_entry.is_preloaded:
			preloaded_count += 1
		total_load_time += cache_entry.load_time
		total_memory += cache_entry.memory_usage
	
	return {
		"cache_size": _model_cache.size(),
		"max_cache_size": max_cache_size,
		"total_references": total_refs,
		"preloaded_models": preloaded_count,
		"loading_tasks": _loading_tasks.size(),
		"preload_queue_size": _preload_queue.size(),
		"gpu_enabled": enable_gpu_acceleration,
		"gpu_backend": _get_backend_name(gpu_backend),
		"cache_timeout": cache_timeout,
		"total_load_time": total_load_time,
		"total_memory_usage": total_memory,
		"active_threads": _active_thread_count,
		"lru_enabled": enable_lru_cache
	}


## 增强的预加载机制 - 带优先级的预加载
func preload_model_with_priority(model_id: String, model_path: String, priority: int = 0) -> void:
	if _model_cache.has(model_id):
		LogWrapper.debug(self, "Model already cached: ", model_id)
		return
	
	_preload_queue.append({
		"model_id": model_id,
		"model_path": model_path,
		"priority": priority
	})
	
	_sort_preload_queue()
	LogWrapper.info(self, "Model added to preload queue with priority %d: %s" % [priority, model_id])
	
	_process_preload_queue()


## 批量预加载模型
func batch_preload_models(models: Array[Dictionary]) -> void:
	for model_data: Dictionary in models:
		var model_id: String = model_data.get("model_id", "")
		var model_path: String = model_data.get("model_path", "")
		var priority: int = model_data.get("priority", 0)
		
		if model_id != "" and model_path != "":
			preload_model_with_priority(model_id, model_path, priority)
	
	LogWrapper.info(self, "Batch preload started: ", models.size(), " models")


## 按优先级排序预加载队列
func _sort_preload_queue() -> void:
	_preload_queue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["priority"] > b["priority"])


## 后台线程加载模型
func load_model_in_background(model_id: String, model_path: String, priority: int = 0) -> void:
	if not enable_background_loading:
		load_model_async(model_id, model_path)
		return
	
	if _active_thread_count >= max_background_threads:
		LogWrapper.warn(self, "Maximum background threads reached, using async load instead")
		load_model_async(model_id, model_path)
		return
	
	if _loading_tasks.has(model_id):
		LogWrapper.warn(self, "Model already loading: ", model_id)
		return
	
	if _model_cache.has(model_id):
		var cache_entry: ModelCacheEntry = _model_cache[model_id]
		cache_entry.reference_count += 1
		cache_entry.last_used = Time.get_unix_time_from_system()
		model_loading_completed.emit(model_id, cache_entry.model_node)
		LogWrapper.debug(self, "Model loaded from cache (background): ", model_id)
		return
	
	LogWrapper.info(self, "Starting background model load: ", model_id)
	model_loading_started.emit(model_id)
	
	var thread: Thread = Thread.new()
	_background_threads.append(thread)
	_active_thread_count += 1
	
	var load_data: Dictionary = {
		"model_id": model_id,
		"model_path": model_path,
		"priority": priority,
		"start_time": Time.get_ticks_usec()
	}
	
	thread.start(_background_load_thread.bind(load_data))
	LogWrapper.debug(self, "Background thread started for model: ", model_id)


## 后台加载线程函数
func _background_load_thread(load_data: Dictionary) -> void:
	var model_id: String = load_data["model_id"]
	var model_path: String = load_data["model_path"]
	var priority: int = load_data["priority"]
	var start_time: float = load_data["start_time"]
	
	var model_node: NobodyWhoModel = NobodyWhoModel.new()
	model_node.name = "Model_" + model_id
	
	model_node.load_model(model_path)
	model_node.set_generation_parameters(default_max_tokens, default_temperature, default_top_p, default_top_k)
	
	var load_time: float = (Time.get_ticks_usec() - start_time) / 1000000.0
	
	call_deferred("_on_background_load_completed", model_id, model_node, model_path, priority, load_time)


## 后台加载完成回调
func _on_background_load_completed(model_id: String, model_node: NobodyWhoModel, model_path: String, priority: int, load_time: float) -> void:
	if _model_cache.has(model_id):
		LogWrapper.warn(self, "Model already in cache: ", model_id)
		model_node.queue_free()
		return
	
	var cache_entry: ModelCacheEntry = ModelCacheEntry.new(model_id, model_node, model_path, priority)
	cache_entry.reference_count = 1
	cache_entry.load_time = load_time
	cache_entry.memory_usage = _estimate_memory_usage(model_path)
	_model_cache[model_id] = cache_entry
	
	if enable_lru_cache:
		_update_lru_order(model_id)
	
	_update_performance_stats(model_id, load_time, cache_entry.memory_usage)
	
	model_loading_completed.emit(model_id, model_node)
	LogWrapper.info(self, "Model loaded successfully in background: %s (time: %fs)" % [model_id, load_time])
	
	_active_thread_count -= 1


## 估计模型内存使用
func _estimate_memory_usage(model_path: String) -> int:
	var file: FileAccess = FileAccess.open(model_path, FileAccess.READ)
	if not file:
		return 0
	
	var file_size: int = file.get_length()
	file.close()
	
	return file_size * 3


## 更新LRU缓存顺序
func _update_lru_order(model_id: String) -> void:
	if model_id in _lru_order:
		_lru_order.erase(model_id)
	
	_lru_order.append(model_id)


## LRU缓存清理
func cleanup_lru_cache() -> void:
	if not enable_lru_cache:
		return
	
	while _model_cache.size() >= max_cache_size and not _lru_order.is_empty():
		var oldest_model_id: String = _lru_order.pop_front()
		
		if _model_cache.has(oldest_model_id):
			var cache_entry: ModelCacheEntry = _model_cache[oldest_model_id]
			
			if cache_entry.reference_count == 0:
				force_unload_model(oldest_model_id)
				LogWrapper.info(self, "LRU cache evicted model: ", oldest_model_id)
			else:
				_lru_order.append(oldest_model_id)


## 更新性能统计
func _update_performance_stats(model_id: String, load_time: float, memory_usage: int) -> void:
	if not _performance_stats.has(model_id):
		_performance_stats[model_id] = {
			"load_count": 0,
			"total_load_time": 0.0,
			"avg_load_time": 0.0,
			"min_load_time": INF,
			"max_load_time": 0.0,
			"total_memory": 0,
			"avg_memory": 0
		}
	
	var stats: Dictionary = _performance_stats[model_id]
	stats["load_count"] += 1
	stats["total_load_time"] += load_time
	stats["avg_load_time"] = stats["total_load_time"] / stats["load_count"]
	stats["min_load_time"] = min(stats["min_load_time"], load_time)
	stats["max_load_time"] = max(stats["max_load_time"], load_time)
	stats["total_memory"] += memory_usage
	stats["avg_memory"] = stats["total_memory"] / stats["load_count"]
	
	_record_memory_usage()
	
	performance_stats_updated.emit(_performance_stats)


## 记录内存使用历史
func _record_memory_usage() -> void:
	if not enable_memory_monitoring:
		return
	
	var total_memory: int = 0
	for cache_entry: ModelCacheEntry in _model_cache.values():
		total_memory += cache_entry.memory_usage
	
	var record: Dictionary = {
		"timestamp": Time.get_unix_time_from_system(),
		"total_memory": total_memory,
		"cache_size": _model_cache.size()
	}
	
	_memory_usage_history.append(record)
	
	if _memory_usage_history.size() > 100:
		_memory_usage_history.pop_front()
	
	if total_memory > memory_warning_threshold:
		memory_warning_triggered.emit(total_memory, memory_warning_threshold)
		LogWrapper.warn(self, "Memory usage warning: %d bytes (threshold: %d)" % [total_memory, memory_warning_threshold])


## 获取性能统计
func get_performance_stats(model_id: String = "") -> Dictionary:
	if model_id != "":
		return _performance_stats.get(model_id, {})
	
	return _performance_stats.duplicate()


## 获取内存使用历史
func get_memory_history() -> Array[Dictionary]:
	return _memory_usage_history.duplicate()


## 获取当前内存使用
func get_current_memory_usage() -> int:
	var total_memory: int = 0
	for cache_entry: ModelCacheEntry in _model_cache.values():
		total_memory += cache_entry.memory_usage
	return total_memory


## 获取性能优化建议
func get_performance_recommendations() -> Array[String]:
	var recommendations: Array[String] = []
	var stats: Dictionary = get_statistics()
	
	if stats["cache_size"] >= stats["max_cache_size"] * 0.8:
		recommendations.append("考虑增加 max_cache_size 以减少模型加载频率")
	
	if stats["preload_queue_size"] > 5:
		recommendations.append("预加载队列较长，考虑分批预加载或增加后台线程数")
	
	if stats["active_threads"] >= max_background_threads:
		recommendations.append("后台线程已满载，考虑增加 max_background_threads")
	
	var current_memory: int = get_current_memory_usage()
	if current_memory > memory_warning_threshold * 0.7:
		recommendations.append("内存使用接近阈值，考虑启用更激进的清理策略")
	
	for model_id: String in _performance_stats:
		var model_stats: Dictionary = _performance_stats[model_id]
		if model_stats["avg_load_time"] > 5.0:
			recommendations.append("模型 " + model_id + " 平均加载时间较长，考虑预加载或优化模型大小")
	
	if recommendations.is_empty():
		recommendations.append("当前性能表现良好，无需调整")
	
	return recommendations


## 按需卸载模型
func unload_model_on_demand(model_id: String) -> bool:
	if not _model_cache.has(model_id):
		LogWrapper.warn(self, "Model not found: ", model_id)
		return false
	
	var cache_entry: ModelCacheEntry = _model_cache[model_id]
	
	if cache_entry.reference_count > 0:
		LogWrapper.warn(self, "Model still in use: %s (ref count: %d)" % [model_id, cache_entry.reference_count])
		return false
	
	LogWrapper.info(self, "Unloading model on demand: ", model_id)
	
	if model_id in _lru_order:
		_lru_order.erase(model_id)
	
	return force_unload_model(model_id)


## 设置缓存大小限制
func set_cache_size_limit(limit: int) -> void:
	max_cache_size = limit
	LogWrapper.info(self, "Cache size limit set to: ", limit)
	
	if enable_lru_cache:
		cleanup_lru_cache()


## 设置内存警告阈值
func set_memory_warning_threshold(threshold: int) -> void:
	memory_warning_threshold = threshold
	LogWrapper.info(self, "Memory warning threshold set to: %s bytes" % threshold)


## 获取详细性能报告
func get_detailed_performance_report() -> Dictionary:
	var report: Dictionary = {
		"timestamp": Time.get_unix_time_from_system(),
		"statistics": get_statistics(),
		"current_memory": get_current_memory_usage(),
		"memory_history": get_memory_history(),
		"performance_stats": get_performance_stats(),
		"recommendations": get_performance_recommendations(),
		"gpu_config": get_gpu_config()
	}
	
	return report


## 导出性能报告到文件
func export_performance_report(file_path: String = "") -> void:
	if file_path == "":
		file_path = "user://model_manager_performance_report_" + str(Time.get_unix_time_from_system()) + ".json"
	
	var report: Dictionary = get_detailed_performance_report()
	var json_string: String = JSON.stringify(report, "\t")
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		LogWrapper.info(self, "Performance report exported to: ", file_path)
	else:
		LogWrapper.error(self, "Failed to export performance report to: ", file_path)


## 清理所有后台线程
func cleanup_background_threads() -> void:
	for thread: Thread in _background_threads:
		if thread.is_alive():
			thread.wait_to_finish()
	
	_background_threads.clear()
	_active_thread_count = 0
	LogWrapper.info(self, "All background threads cleaned up")


## 重置性能统计
func reset_performance_stats() -> void:
	_performance_stats.clear()
	_memory_usage_history.clear()
	LogWrapper.info(self, "Performance stats reset")


## 退出时清理
func _exit_tree() -> void:
	cleanup_background_threads()
	clear_cache()
