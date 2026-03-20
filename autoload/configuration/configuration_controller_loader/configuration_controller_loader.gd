class_name ConfigurationControllerLoader
extends Node
## 配置控制器加载器 - 管理配置控制器的映射和加载
## 
## 功能说明：
## - 提供getter方法，将枚举值映射到配置控制器
## - 加载[configuration_controllers_root]下的所有子节点
## - 子节点名称后缀必须匹配：ListCfg、SliderCfg、ToggleCfg、TreeCfg
## - 子节点名称前缀必须匹配[ConfigurationEnum]枚举（可带或不带下划线）
## 
## 映射规则：
## - ListCfg -> ListConfigurationController
## - SliderCfg -> SliderConfigurationController
## - ToggleCfg -> ToggleConfigurationController
## - TreeCfg -> TreeConfigurationController
## 
## 主要方法：
## - get_configuration_controllers(): 获取指定组的所有配置控制器
## - get_list_configuration_controller(): 获取列表配置控制器
## - get_slider_configuration_controller(): 获取滑块配置控制器
## - get_toggle_configuration_controller(): 获取开关配置控制器
## - get_tree_configuration_controller(): 获取树形配置控制器
## 
## 设计优势：
## - 自动映射，无需手动注册
## - 类型安全的配置访问
## - 支持按分组管理配置
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@export var configuration_controllers_root: Node

var _config_group_map: Dictionary = {}

var _list_cfg_map: Dictionary = {}
var _slider_cfg_map: Dictionary = {}
var _toggle_cfg_map: Dictionary = {}
var _tree_cfg_map: Dictionary = {}


func _ready() -> void:
	_init_cfg_maps()


func get_configuration_controllers(
	config_group: ConfigurationEnum.Group
) -> Array[ConfigurationController]:
	return _config_group_map[config_group]


func get_list_configuration_controller(
	list_cfg: ConfigurationEnum.ListCfg
) -> ListConfigurationController:
	return _list_cfg_map[list_cfg]


func get_slider_configuration_controller(
	cfg: ConfigurationEnum.SliderCfg
) -> SliderConfigurationController:
	return _slider_cfg_map[cfg]


func get_toggle_configuration_controller(
	toggle_cfg: ConfigurationEnum.ToggleCfg
) -> ToggleConfigurationController:
	return _toggle_cfg_map[toggle_cfg]


func get_tree_configuration_controller(
	tree_cfg: ConfigurationEnum.TreeCfg
) -> TreeConfigurationController:
	return _tree_cfg_map[tree_cfg]


func _init_cfg_maps() -> void:
	NodeUtils.apply_function_to_all_children(configuration_controllers_root, _init_cfg_map_on_child)


func _init_cfg_map_on_child(node: Node) -> void:
	if is_instance_of(node, TreeConfigurationController):
		_init_cfg_map_entry(node, ConfigurationEnum.TreeCfg, "TreeCfg", _tree_cfg_map)
	elif is_instance_of(node, ToggleConfigurationController):
		_init_cfg_map_entry(node, ConfigurationEnum.ToggleCfg, "ToggleCfg", _toggle_cfg_map)
	elif is_instance_of(node, SliderConfigurationController):
		_init_cfg_map_entry(node, ConfigurationEnum.SliderCfg, "SliderCfg", _slider_cfg_map)
	elif is_instance_of(node, ListConfigurationController):
		_init_cfg_map_entry(node, ConfigurationEnum.ListCfg, "ListCfg", _list_cfg_map)
	else:
		LogWrapper.debug(self, "Skipped loading configuration controller '%s'." % node.name)


func _init_cfg_map_entry(
	node: ConfigurationController, enum_class: Variant, suffix: String, map: Dictionary
) -> void:
	var node_name: String = node.name.split(suffix)[0]
	var enum_value: int = EnumUtils.from_name(node_name, enum_class)
	map[enum_value] = node

	var config_group: ConfigurationEnum.Group = node.config_group
	if _config_group_map.has(config_group):
		_config_group_map[config_group].append(node)
	else:
		var array: Array[ConfigurationController] = []
		array.append(node)
		_config_group_map[config_group] = array
