@tool
extends Control
## 启动画面场景 - 游戏启动时的过渡场景
## 
## 功能说明：
## - 显示游戏启动画面（Logo、加载界面等）
## - 使用项目设置中的启动画面配置
## - 自动切换到下一个场景
## 
## 配置来源：
## - 背景颜色：ProjectSettings.get("application/boot_splash/bg_color")
## - 启动图片：ProjectSettings.get("application/boot_splash/image")
## 
## 设计特点：
## - 在编辑器中不自动切换场景（@tool模式）
## - 使用SceneManagerWrapper进行场景切换
## - 支持自定义过渡效果
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@export_group("Next Scene")
@export var scene: SceneManagerEnum.Scene = SceneManagerEnum.Scene.MENU_SCENE
@export var scene_manager_options_id: String = "fade_boot"

var _boot_splash_color: Color = ProjectSettings.get("application/boot_splash/bg_color")
var _boot_splash_image_path: String = ProjectSettings.get("application/boot_splash/image")
var _boot_splash_texture: Texture = load(_boot_splash_image_path)

@onready var boot_splash_color_rect: ColorRect = %BootSplashColorRect
@onready var boot_splash_texture_rect: TextureRect = %BootSplashTextureRect


func _ready() -> void:
	_set_boot_splash()

	if Engine.is_editor_hint():
		return

	SceneManagerWrapper.change_scene(scene, scene_manager_options_id)


func _set_boot_splash() -> void:
	boot_splash_color_rect.color = _boot_splash_color
	boot_splash_texture_rect.texture = _boot_splash_texture
