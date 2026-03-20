extends Node
## 资源引用管理器 - 预加载和管理游戏资源
## 
## 功能说明：
## - 自动预加载资源以实现快速访问
## - 扫描PRELOAD_PATH目录下的所有.tres资源文件
## - 使用字典存储资源引用，通过名称快速访问
## 
## 使用方式：
## - 示例：[ResourceReference.get_resource(resource_id, SceneManagerOptions)]
## - 资源键格式：类型-资源ID（避免不同类型资源的名称冲突）
## 
## 资源加载：
## - 自动扫描res://resources/preload/目录
## - 支持所有.tres格式的资源文件
## - 资源键由类型和资源ID组成
## 
## 主要方法：
## - get_particle_process_material(): 获取粒子材质
## - get_scene_manager_options(): 获取场景管理选项
## - get_resource(): 通用资源获取方法
## 
## 设计优势：
## - 集中管理资源引用
## - 避免重复加载
## - 类型安全的资源访问
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

const NAME: String = "Reference"

const PRELOAD_PATH = PathConsts.RESOURCES + "preload/"
const RESOURCE_EXTENSION = ".tres"

var _resource_references_map: Dictionary = {}


func _ready() -> void:
	var paths: Array[String] = FileSystemUtils.get_paths(PRELOAD_PATH, RESOURCE_EXTENSION)
	_resource_references_map = _load_resources(paths)

	LogWrapper.debug(self, "AUTOLOAD READY.")


func get_particle_process_material(particle_id: String) -> ParticleProcessMaterial:
	return get_resource(particle_id, "ParticleProcessMaterial")


func get_scene_manager_options(resource_id: String) -> SceneManagerOptions:
	return get_resource(resource_id, SceneManagerOptions)


func get_resource(resource_id: String, type: Variant) -> Resource:
	var key: String = _get_key(resource_id, type)
	if _resource_references_map.has(key):
		return _resource_references_map[key]
	return null


static func _load_resources(paths: Array[String]) -> Dictionary:
	var resource_references: Dictionary = {}
	for path: String in paths:
		var resource: Resource = load(path) as Resource
		if resource != null:
			var resource_id: String = FileSystemUtils.get_file_name(path)
			var key: String = _get_key(resource_id, _get_type(resource))
			if resource_references.has(key):
				LogWrapper.warn(NAME, "Duplicate resource reference key: ", key)
				continue
			resource_references[key] = resource
			LogWrapper.debug(NAME, "Success to load resource reference key: ", key)
		else:
			LogWrapper.warn(NAME, "Failed to load resource reference at: ", path)
	return resource_references


static func _get_type(resource: Resource) -> Variant:
	return resource.get_script() if resource.get_script() != null else resource


static func _get_key(resource_id: String, type: Variant) -> String:
	if type == null:
		return resource_id
	if type is String or type is StringName:
		return type + "-" + resource_id
	if "get_global_name" in type:
		return type.get_global_name() + "-" + resource_id
	return type.get_class() + "-" + resource_id
