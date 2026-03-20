# TODO: Does not wrap all methods. Wrap other methods from [SceneManager] if and when needed.
extends Node
## 场景管理器包装器 - 封装SceneManager插件
## 
## 功能说明：
## - 封装SceneManager插件，提供更便捷的场景切换接口
## - 使用[SceneManagerEnum]枚举来跟踪可用场景
## - 使用[SceneManagerOptions]资源替代插件的[SceneManager.Options]对象
## 
## 设计优势：
## - 类型安全：使用枚举而非字符串来标识场景
## - 统一管理：场景切换选项集中管理
## - 易于扩展：可添加更多场景切换相关功能
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller


func _ready() -> void:
	LogWrapper.debug(self, "AUTOLOAD READY.")


func change_scene(scene: SceneManagerEnum.Scene, scene_manager_options_id: String) -> void:
	var scene_id: String = SceneManagerEnum.scene_name(scene)
	LogWrapper.debug(self, "Change scene: ", scene_id)

	var scene_manager_options: SceneManagerOptions = ResourceReference.get_scene_manager_options(
		scene_manager_options_id
	)
	SceneManager.change_scene(
		scene_id,
		scene_manager_options.create_fade_out_options(),
		scene_manager_options.create_fade_in_options(),
		scene_manager_options.create_general_options()
	)


func change_scene_to_loaded_scene(scene_manager_options_id: String) -> void:
	LogWrapper.debug(self, "Change to loaded scene. ")

	var scene_manager_options: SceneManagerOptions = ResourceReference.get_scene_manager_options(
		scene_manager_options_id
	)
	SceneManager.change_scene_to_loaded_scene(
		scene_manager_options.create_fade_out_options(),
		scene_manager_options.create_fade_in_options(),
		scene_manager_options.create_general_options()
	)


func change_scene_to_existing_scene_in_scene_tree(scene_manager_options_id: String) -> void:
	LogWrapper.debug(self, "Change to loaded scene. ")

	var scene_manager_options: SceneManagerOptions = ResourceReference.get_scene_manager_options(
		scene_manager_options_id
	)
	SceneManager.change_scene_to_existing_scene_in_scene_tree(
		scene_manager_options.create_fade_out_options(),
		scene_manager_options.create_fade_in_options(),
		scene_manager_options.create_general_options()
	)
