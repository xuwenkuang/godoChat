extends Node
## 对话管理器 - 负责管理游戏中的对话系统
##
## 功能说明：
## - 管理所有活跃的对话会话
## - 维护对话历史记录
## - 提供对话事件的信号系统
## - 支持多 NPC 并发对话
##
## 使用场景：
## - NPC 对话交互
## - 剧情对话系统
## - 多角色对话管理
##
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

## 对话会话类 - 表示一个活跃的对话会话
class DialogueSession:
	var session_id: String
	var npc_id: String
	var npc_name: String
	var dialogue_data: Dictionary
	var current_node: String
	var is_active: bool = true
	var started_at: float
	var last_updated: float

	func _init(p_session_id: String, p_npc_id: String, p_npc_name: String, p_dialogue_data: Dictionary) -> void:
		session_id = p_session_id
		npc_id = p_npc_id
		npc_name = p_npc_name
		dialogue_data = p_dialogue_data
		current_node = "start"
		started_at = Time.get_unix_time_from_system()
		last_updated = started_at

## 对话历史记录类
class DialogueHistory:
	var history_id: String
	var npc_id: String
	var npc_name: String
	var dialogue_content: String
	var timestamp: float
	var player_choices: Array
	var keywords: Array[String]
	var compressed: bool = false

	func _init(p_npc_id: String, p_npc_name: String, p_content: String, p_choices: Array = []) -> void:
		history_id = StringUtils.generate_uuid()
		npc_id = p_npc_id
		npc_name = p_npc_name
		dialogue_content = p_content
		timestamp = Time.get_unix_time_from_system()
		player_choices = p_choices
		keywords = _extract_keywords(p_content)

	func _extract_keywords(text: String) -> Array[String]:
		var extracted_keywords: Array[String] = []
		var words: PackedStringArray = text.to_lower().split(" ", false)
		
		for word in words:
			if word.length() > 3:
				extracted_keywords.append(word)
		
		return extracted_keywords

## Signals - 对话事件信号
signal dialogue_started(session_id: String, npc_id: String, npc_name: String)
signal dialogue_ended(session_id: String, npc_id: String)
signal dialogue_updated(session_id: String, node_id: String)
signal dialogue_choice_selected(session_id: String, choice_index: int)
signal dialogue_history_added(history: DialogueHistory)
signal all_dialogues_ended()
signal history_compressed(compression_ratio: float)
signal history_search_completed(results: Array[DialogueHistory], query: String)

## Configuration - 配置参数
@export_category("Configuration")
@export var max_history_size: int = 100
@export var max_active_sessions: int = 10
@export var auto_save_history: bool = true
@export var enable_history_compression: bool = true
@export var compression_threshold: int = 50
@export var enable_keyword_index: bool = true
@export var enable_fast_search: bool = true
@export var history_retention_days: int = 30
@export var save_interval: float = 60.0
@export var enable_batch_save: bool = true

## State - 内部状态
var _active_sessions: Dictionary = {}
var _dialogue_history: Array[DialogueHistory] = []
var _session_counter: int = 0
var _keyword_index: Dictionary = {}
var _history_by_npc: Dictionary = {}
var _pending_saves: Array[DialogueHistory] = []
var _save_timer: Timer = null
var _history_stats: Dictionary = {}

## Singleton references
@onready var LogWrapper: Node = get_node("/root/LogWrapper")


func _ready() -> void:
	LogWrapper.debug(self, "DialogueManager initialized")
	
	if enable_batch_save and auto_save_history:
		_setup_save_timer()


## 开始一个新的对话会话
func start_dialogue(npc_id: String, npc_name: String, dialogue_data: Dictionary) -> String:
	if _active_sessions.size() >= max_active_sessions:
		LogWrapper.warn(self, "Maximum active sessions reached: ", max_active_sessions)
		return ""

	var session_id: String = "dialogue_%d" % _session_counter
	_session_counter += 1

	var session: DialogueSession = DialogueSession.new(session_id, npc_id, npc_name, dialogue_data)
	_active_sessions[session_id] = session

	dialogue_started.emit(session_id, npc_id, npc_name)
	LogWrapper.debug(self, "Dialogue started: %s with NPC: %s" % [session_id, npc_name])

	return session_id


## 结束指定的对话会话
func end_dialogue(session_id: String) -> bool:
	if not _active_sessions.has(session_id):
		LogWrapper.warn(self, "Session not found: ", session_id)
		return false

	var session: DialogueSession = _active_sessions[session_id]
	session.is_active = false
	_active_sessions.erase(session_id)

	dialogue_ended.emit(session_id, session.npc_id)
	LogWrapper.debug(self, "Dialogue ended: ", session_id)

	if _active_sessions.is_empty():
		all_dialogues_ended.emit()

	return true


## 结束所有活跃的对话会话
func end_all_dialogues() -> void:
	var session_ids: Array = _active_sessions.keys()
	for session_id: String in session_ids:
		end_dialogue(session_id)


## 获取指定的对话会话
func get_session(session_id: String) -> DialogueSession:
	return _active_sessions.get(session_id)


## 获取所有活跃的对话会话
func get_active_sessions() -> Array[DialogueSession]:
	return _active_sessions.values()


## 获取指定 NPC 的活跃对话会话
func get_npc_session(npc_id: String) -> DialogueSession:
	for session: DialogueSession in _active_sessions.values():
		if session.npc_id == npc_id and session.is_active:
			return session
	return null


## 检查指定 NPC 是否有活跃对话
func has_active_dialogue(npc_id: String) -> bool:
	return get_npc_session(npc_id) != null


## 更新对话节点
func update_dialogue_node(session_id: String, node_id: String) -> bool:
	var session: DialogueSession = get_session(session_id)
	if session == null:
		LogWrapper.warn(self, "Session not found: ", session_id)
		return false

	session.current_node = node_id
	session.last_updated = Time.get_unix_time_from_system()

	dialogue_updated.emit(session_id, node_id)
	return true


## 选择对话选项
func select_choice(session_id: String, choice_index: int) -> bool:
	var session: DialogueSession = get_session(session_id)
	if session == null:
		LogWrapper.warn(self, "Session not found: ", session_id)
		return false

	dialogue_choice_selected.emit(session_id, choice_index)
	return true


## 添加对话历史记录
func add_dialogue_history(npc_id: String, npc_name: String, content: String, choices: Array = []) -> void:
	var history: DialogueHistory = DialogueHistory.new(npc_id, npc_name, content, choices)
	_dialogue_history.append(history)
	
	if enable_keyword_index:
		_update_keyword_index(history)
	
	_update_npc_history_index(history)
	_update_history_stats(history)
	
	if _dialogue_history.size() > max_history_size:
		_dialogue_history.pop_front()
		_cleanup_keyword_index()
	
	if enable_history_compression and _dialogue_history.size() > compression_threshold:
		_compress_history()
	
	dialogue_history_added.emit(history)
	
	if auto_save_history:
		if enable_batch_save:
			_pending_saves.append(history)
		else:
			_save_history()


## 获取对话历史记录
func get_dialogue_history() -> Array[DialogueHistory]:
	return _dialogue_history

## 获取活跃对话会话数量
func get_active_session_count() -> int:
	return _active_sessions.size()


## 获取对话历史记录数量
func get_history_count() -> int:
	return _dialogue_history.size()


## 检查是否有任何活跃的对话
func has_active_dialogues() -> bool:
	return not _active_sessions.is_empty()


## 保存对话历史记录到文件
func _save_history() -> void:
	var history_data: Array = []
	for history: DialogueHistory in _dialogue_history:
		var data: Dictionary = {
			"history_id": history.history_id,
			"npc_id": history.npc_id,
			"npc_name": history.npc_name,
			"dialogue_content": history.dialogue_content,
			"timestamp": history.timestamp,
			"player_choices": history.player_choices
		}
		history_data.append(data)

	var save_path: String = "user://dialogue_history.json"
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(history_data))
		file.close()
		LogWrapper.debug(self, "Dialogue history saved to: ", save_path)
	else:
		LogWrapper.warn(self, "Failed to save dialogue history")


## 从文件加载对话历史记录
func load_history() -> void:
	var save_path: String = "user://dialogue_history.json"
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var content: String = file.get_as_text()
		file.close()

		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(content)
		if parse_result == Error.OK:
			var history_data: Array = json.data
			_dialogue_history.clear()

			for data: Dictionary in history_data:
				var history: DialogueHistory = DialogueHistory.new(
					data.get("npc_id", ""),
					data.get("npc_name", ""),
					data.get("dialogue_content", ""),
					data.get("player_choices", [])
				)
				history.history_id = data.get("history_id", "")
				history.timestamp = data.get("timestamp", 0.0)
				_dialogue_history.append(history)

			LogWrapper.debug(self, "Dialogue history loaded: %s entries" % _dialogue_history.size())
		else:
			LogWrapper.warn(self, "Failed to parse dialogue history JSON")
	else:
		LogWrapper.debug(self, "No dialogue history file found")


## 设置批量保存定时器
func _setup_save_timer() -> void:
	_save_timer = Timer.new()
	_save_timer.wait_time = save_interval
	_save_timer.autostart = true
	_save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(_save_timer)
	LogWrapper.debug(self, "Batch save timer started with interval: %s seconds" % save_interval)


## 批量保存定时器回调
func _on_save_timer_timeout() -> void:
	if not _pending_saves.is_empty():
		var save_count: int = _pending_saves.size()
		_save_history()
		_pending_saves.clear()
		LogWrapper.debug(self, "Batch saved %s history entries" % save_count)


## 更新关键词索引
func _update_keyword_index(history: DialogueHistory) -> void:
	for keyword: String in history.keywords:
		if not _keyword_index.has(keyword):
			_keyword_index[keyword] = []
		
		if not history.history_id in _keyword_index[keyword]:
			_keyword_index[keyword].append(history.history_id)


## 清理关键词索引
func _cleanup_keyword_index() -> void:
	var current_ids: Dictionary = {}
	for history: DialogueHistory in _dialogue_history:
		current_ids[history.history_id] = true
	
	for keyword: String in _keyword_index:
		var filtered_ids: Array = []
		for history_id: String in _keyword_index[keyword]:
			if current_ids.has(history_id):
				filtered_ids.append(history_id)
		_keyword_index[keyword] = filtered_ids


## 更新NPC历史索引
func _update_npc_history_index(history: DialogueHistory) -> void:
	if not _history_by_npc.has(history.npc_id):
		_history_by_npc[history.npc_id] = []
	
	_history_by_npc[history.npc_id].append(history.history_id)


## 更新历史统计
func _update_history_stats(history: DialogueHistory) -> void:
	if not _history_stats.has(history.npc_id):
		_history_stats[history.npc_id] = {
			"count": 0,
			"total_length": 0,
			"avg_length": 0.0,
			"last_interaction": 0.0
		}
	
	var stats: Dictionary = _history_stats[history.npc_id]
	stats["count"] += 1
	stats["total_length"] += history.dialogue_content.length()
	stats["avg_length"] = stats["total_length"] / stats["count"]
	stats["last_interaction"] = history.timestamp


## 压缩历史记录
func _compress_history() -> void:
	var original_size: int = _dialogue_history.size()
	var compressed_count: int = 0
	
	for i in range(_dialogue_history.size()):
		var history: DialogueHistory = _dialogue_history[i]
		if not history.compressed and history.dialogue_content.length() > 200:
			history.dialogue_content = history.dialogue_content.substr(0, 100) + "... [compressed]"
			history.compressed = true
			compressed_count += 1
	
	if compressed_count > 0:
		var compression_ratio: float = float(compressed_count) / float(original_size)
		history_compressed.emit(compression_ratio)
		LogWrapper.info(self, "Compressed %d history entries (ratio: %f)" % [compressed_count, compression_ratio])


## 获取指定 NPC 的对话历史记录（优化版）
func get_npc_history(npc_id: String) -> Array[DialogueHistory]:
	if _history_by_npc.has(npc_id):
		var history_ids: Array = _history_by_npc[npc_id]
		var npc_history: Array[DialogueHistory] = []
		
		for history_id: String in history_ids:
			for history: DialogueHistory in _dialogue_history:
				if history.history_id == history_id:
					npc_history.append(history)
					break
		
		return npc_history
	
	return []


## 搜索对话历史记录（快速搜索）
func search_history(query: String, npc_id: String = "") -> Array[DialogueHistory]:
	var results: Array[DialogueHistory] = []
	var lower_query: String = query.to_lower()
	
	if enable_fast_search and enable_keyword_index:
		var query_words: PackedStringArray = lower_query.split(" ", false)
		var matched_ids: Dictionary = {}
		
		for word: String in query_words:
			if word.length() > 3 and _keyword_index.has(word):
				for history_id: String in _keyword_index[word]:
					matched_ids[history_id] = true
		
		for history_id: String in matched_ids:
			for history: DialogueHistory in _dialogue_history:
				if history.history_id == history_id:
					if npc_id == "" or history.npc_id == npc_id:
						results.append(history)
					break
	else:
		for history: DialogueHistory in _dialogue_history:
			if npc_id == "" or history.npc_id == npc_id:
				if lower_query in history.dialogue_content.to_lower():
					results.append(history)
	
	history_search_completed.emit(results, query)
	return results


## 获取指定时间范围内的历史记录
func get_history_by_time_range(start_time: float, end_time: float) -> Array[DialogueHistory]:
	var results: Array[DialogueHistory] = []
	
	for history: DialogueHistory in _dialogue_history:
		if history.timestamp >= start_time and history.timestamp <= end_time:
			results.append(history)
	
	return results


## 获取最近的历史记录
func get_recent_history(count: int = 10, npc_id: String = "") -> Array[DialogueHistory]:
	var results: Array[DialogueHistory] = []
	var start_index: int = max(0, _dialogue_history.size() - count)
	
	for i in range(start_index, _dialogue_history.size()):
		var history: DialogueHistory = _dialogue_history[i]
		if npc_id == "" or history.npc_id == npc_id:
			results.append(history)
	
	return results


## 清理过期历史记录
func cleanup_expired_history() -> void:
	var current_time: float = Time.get_unix_time_from_system()
	var cutoff_time: float = current_time - (history_retention_days * 86400)
	var original_size: int = _dialogue_history.size()
	
	var filtered_history: Array[DialogueHistory] = []
	for history: DialogueHistory in _dialogue_history:
		if history.timestamp >= cutoff_time:
			filtered_history.append(history)
	
	_dialogue_history = filtered_history
	
	if _dialogue_history.size() < original_size:
		_cleanup_keyword_index()
		_rebuild_npc_index()
		LogWrapper.info(self, "Cleaned up ", original_size - _dialogue_history.size(), " expired history entries")


## 重建NPC索引
func _rebuild_npc_index() -> void:
	_history_by_npc.clear()
	
	for history: DialogueHistory in _dialogue_history:
		_update_npc_history_index(history)


## 获取历史统计信息
func get_history_stats(npc_id: String = "") -> Dictionary:
	if npc_id != "":
		return _history_stats.get(npc_id, {})
	
	return _history_stats.duplicate()


## 获取历史记录统计
func get_history_statistics() -> Dictionary:
	var npc_counts: Dictionary = {}
	var total_length: int = 0
	var compressed_count: int = 0
	
	for history: DialogueHistory in _dialogue_history:
		if not npc_counts.has(history.npc_id):
			npc_counts[history.npc_id] = 0
		npc_counts[history.npc_id] += 1
		total_length += history.dialogue_content.length()
		if history.compressed:
			compressed_count += 1
	
	return {
		"total_entries": _dialogue_history.size(),
		"npc_counts": npc_counts,
		"total_length": total_length,
		"avg_length": float(total_length) / max(1, _dialogue_history.size()),
		"compressed_entries": compressed_count,
		"compression_ratio": float(compressed_count) / max(1, _dialogue_history.size()),
		"keyword_index_size": _keyword_index.size(),
		"npc_index_size": _history_by_npc.size()
	}


## 导出历史记录
func export_history(file_path: String = "") -> void:
	if file_path == "":
		file_path = "user://dialogue_history_export_" + str(Time.get_unix_time_from_system()) + ".json"
	
	var history_data: Array = []
	for history: DialogueHistory in _dialogue_history:
		var data: Dictionary = {
			"history_id": history.history_id,
			"npc_id": history.npc_id,
			"npc_name": history.npc_name,
			"dialogue_content": history.dialogue_content,
			"timestamp": history.timestamp,
			"player_choices": history.player_choices,
			"keywords": history.keywords,
			"compressed": history.compressed
		}
		history_data.append(data)
	
	var export_data: Dictionary = {
		"export_time": Time.get_unix_time_from_system(),
		"statistics": get_history_statistics(),
		"history": history_data
	}
	
	var json_string: String = JSON.stringify(export_data, "\t")
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		LogWrapper.info(self, "Dialogue history exported to: ", file_path)
	else:
		LogWrapper.error(self, "Failed to export dialogue history to: ", file_path)


## 清空对话历史记录
func clear_dialogue_history() -> void:
	_dialogue_history.clear()
	_keyword_index.clear()
	_history_by_npc.clear()
	_pending_saves.clear()
	_history_stats.clear()
	LogWrapper.debug(self, "Dialogue history cleared")


## 退出时清理
func _exit_tree() -> void:
	if _save_timer:
		_save_timer.queue_free()
	
	if not _pending_saves.is_empty():
		_save_history()
		_pending_saves.clear()
