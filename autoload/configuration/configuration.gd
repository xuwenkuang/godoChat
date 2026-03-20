extends Node
## 配置管理器 - 管理游戏运行时配置
## 
## 功能说明：
## - 管理在[ConfigurationEnum]中定义的所有配置项
## - [ConfigurationController]是可以在项目运行时更改的配置（如音量、分辨率等）
## - [ConfigurationNode]是在项目启动前设置的配置（如游戏标题、作者等）
## 
## 架构设计：
## - [ConfigurationControllerLoader]将[ConfigurationEnum]映射到具体的[ConfigurationController]
## - 配置通过INI文件持久化存储
## - 配置更改会自动保存到文件系统
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

const GAME_TITLE: String = "GAME_TITLE"
const GAME_AUTHOR: String = "TinyTakinTeller"

@export var loader: ConfigurationControllerLoader


func _ready() -> void:
	ConfigStorageAppLog.app_opened()

	LogWrapper.debug(self, "AUTOLOAD READY.")


func reset_options(config_group: ConfigurationEnum.Group) -> void:
	var cfgs: Array[ConfigurationController] = loader.get_configuration_controllers(config_group)
	for cfg: ConfigurationController in cfgs:
		cfg.reset_config_value()


func get_theme() -> Theme:
	return %ThemeListCfg.get_config_value()


func get_number_format() -> NumberUtils.NumberFormat:
	return %NumberFormatListCfg.get_config_value()


func get_game_mode_content_scene() -> PackedScene:
	return %GameModeListCfg.get_config_resource()
