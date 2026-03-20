# TODO: Does not wrap all methods. Wrap other methods from [Log] if and when needed.
# NOTE: Stack trace is debug only: https://github.com/godotengine/godot-proposals/issues/105
extends Node
## 日志包装器 - 扩展Logger插件功能
## 
## 功能说明：
## - 扩展logger [Log]插件，支持日志分组配置
## - 通过[LoggerWrapperConfiguration]配置日志级别
## - 支持按模块和层级控制日志输出
## 
## 日志级别：
## - DEBUG: 调试信息（可通过配置禁用）
## - INFO: 一般信息
## - WARN: 警告信息
## - ERROR: 错误信息
## 
## 日志分组：
## - 支持点分隔的日志分组（如"Module.SubModule"）
## - 支持继承的日志级别设置
## - 可为不同模块设置不同的日志级别
## 
## 设计特点：
## - 源名称自动提取（支持对象和字符串）
## - 日志消息自动添加前缀
## - 支持禁用所有调试日志
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

const LOG_SOURCE_SEPARATOR: String = "."
const LOG_LEVEL_DISABLED: int = 9
const LOG_LEVEL_NONE: int = -1

var default_log_group: Log.LogLevel
var log_groups: Dictionary
var disable_debug_logs: bool = false


func debug(src: Variant, msg: String, values: Variant = null, src_suffix: String = "") -> void:
	if disable_debug_logs:
		return
	var src_name: String = _src_name(src)
	var source: String = _extract_log_group(src_name, src_suffix)
	var message: String = _prefix_message(msg, source)
	if _is_log_group_active(Log.LogLevel.DEBUG, source):
		Log.debug(message, values)


func info(src: Variant, msg: String, values: Variant = null, src_suffix: String = "") -> void:
	var src_name: String = _src_name(src)
	var source: String = _extract_log_group(src_name, src_suffix)
	var message: String = _prefix_message(msg, source)
	if _is_log_group_active(Log.LogLevel.INFO, source):
		Log.info(message, values)


func warn(src: Variant, msg: String, values: Variant = null, src_suffix: String = "") -> void:
	var src_name: String = _src_name(src)
	var source: String = _extract_log_group(src_name, src_suffix)
	var message: String = _prefix_message(msg, source)
	if _is_log_group_active(Log.LogLevel.WARN, source):
		Log.warn(message, values)


func warning(src: Variant, msg: String, values: Variant = null, src_suffix: String = "") -> void:
	warn(src, msg, values, src_suffix)


func error(src: Variant, msg: String, values: Variant = null, src_suffix: String = "") -> void:
	var src_name: String = _src_name(src)
	var source: String = _extract_log_group(src_name, src_suffix)
	var message: String = _prefix_message(msg, source)
	if _is_log_group_active(Log.LogLevel.ERROR, source):
		Log.error(message, values)


func _src_name(src: Variant) -> String:
	return src if src is String or src is StringName else src.name


func _extract_log_group(source_name: String, source: String) -> String:
	if source != "":
		return source_name + LOG_SOURCE_SEPARATOR + source
	return source_name


func _prefix_message(message: String, source_name: String) -> String:
	return "[%s] %s" % [source_name, message]


func _is_log_group_active(source_log_level: Log.LogLevel, source: String) -> bool:
	var key: String = source
	var value: int = log_groups.get(key, LOG_LEVEL_NONE)
	while value == LOG_LEVEL_NONE:
		if not key.contains(LOG_SOURCE_SEPARATOR):
			break
		key = key.split(LOG_SOURCE_SEPARATOR, 2)[0]
		value = log_groups.get(key, LOG_LEVEL_NONE)

	if value == LOG_LEVEL_DISABLED:
		return false

	var group_log_level: Log.LogLevel = (
		(value as Log.LogLevel) if value != LOG_LEVEL_NONE else default_log_group
	)

	return source_log_level >= group_log_level
