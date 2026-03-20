extends Control
## 全局覆盖层容器 - 显示全局UI元素
## 
## 功能说明：
## - 作为全局UI元素的容器节点
## - 当前包含FPS计数器显示
## - 可以扩展添加其他全局UI元素（如通知、提示等）
## 
## 设计特点：
## - 使用Control节点作为基础，支持布局管理
## - FPS计数器可通过配置开关显示/隐藏
## - 在_process中实时更新FPS显示
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@onready var fps_counter_margin_container: MarginContainer = %FPSCounterMarginContainer
@onready var fps_counter_label: Label = %FPSCounterLabel


func _ready() -> void:
	fps_counter_toggle(false)


func _process(_delta: float) -> void:
	if fps_counter_margin_container.visible:
		var fps: int = int(Engine.get_frames_per_second())
		fps_counter_label.text = "%d FPS" % [fps]


func is_enabled() -> bool:
	return fps_counter_margin_container.visible


func fps_counter_toggle(enabled: bool) -> void:
	fps_counter_margin_container.visible = enabled
