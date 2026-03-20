class_name ConfigurationController
extends Node
## 配置控制器基类 - 管理单个配置项的保存、加载和应用
## 
## 功能说明：
## - 配置控制器的基类，负责配置的持久化和应用
## - 使用[ConfigStorage]对象通过INI文件保存和加载配置
## - 支持配置更改信号通知
## 
## 核心方法：
## - get_default_value(): 获取默认值（首次使用时）
## - get_config_value(): 获取当前应用的配置值
## - get_saved_config_value(): 获取已保存的配置值
## - load_config_value(): 加载并应用保存的配置值
## - update_config_value(): 应用并保存新的配置值
## - apply_config_value(): 应用配置值到游戏
## - save_config_value(): 保存配置值到文件
## - reset_config_value(): 重置为默认值
## 
## 配置流程：
## 1. 首次启动：使用默认值
## 2. 后续启动：从INI文件加载保存的值
## 3. 运行时更改：应用并保存新值
## 
## 平台支持：
## - 通过is_disabled()方法支持平台特定的配置禁用
## 
## 信号：
## - configuration_applied: 配置应用时发出
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

## Can emit this if nodes need to react to configuration changes
signal configuration_applied

@export_group("ConfigStorage")
@export var config_group: ConfigurationEnum.Group
@export var config_id: String


# load and apply the saved configuration value at startup
func _ready() -> void:
	load_config_value()


func get_config_group_id() -> String:
	return EnumUtils.to_name(config_group, ConfigurationEnum.Group)


func get_config_id() -> String:
	return config_id


# some platforms do not support some configurations
func is_disabled() -> bool:
	return false


# get default value (used first time, if configuration was never saved and there is nothing to load)
func get_default_value() -> Variant:
	push_error("Not Implemented")
	return null


# get applied (current) configuration value
func get_config_value() -> Variant:
	push_error("Not Implemented")
	return null


# use when [get_config_value] is an ID for some other resource (to avoid saving entire resource)
func get_config_resource() -> Variant:
	push_error("Not Implemented")
	return null


# get saved configuration value
func get_saved_config_value() -> Variant:
	return ConfigStorage.get_config(get_config_group_id(), get_config_id(), get_default_value())


# load and apply the saved configuration value
func load_config_value() -> void:
	var value: Variant = get_saved_config_value()
	apply_config_value(value)


# apply and save a new configuration value
func update_config_value(value: Variant) -> void:
	apply_config_value(value)
	save_config_value(value)


# save a new configuration value
func save_config_value(value: Variant) -> void:
	ConfigStorage.set_config(get_config_group_id(), get_config_id(), value)


# apply the given configuration value
func apply_config_value(_value: Variant) -> void:
	push_error("Not Implemented")


# apply and save the default configuration value
func reset_config_value() -> void:
	update_config_value(get_default_value())
