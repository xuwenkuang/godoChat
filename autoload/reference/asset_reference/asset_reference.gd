extends Node
## 资源预加载器 - 显式预加载常用资源
## 
## 功能说明：
## - 显式预加载常用资源以实现快速访问
## - 使用preload关键字在编译时加载资源
## - 避免运行时加载延迟
## 
## 资源类型：
## - Music: 背景音乐资源
## - SFX: 音效资源
## 
## 使用方式：
## - 直接通过常量访问预加载的资源
## - 示例：AssetReference.CLICK_4
## 
## 设计优势：
## - 编译时加载，无运行时开销
## - 类型安全，编译时检查
## - 适合频繁使用的小型资源
## 
## 注意事项：
## - 不适合大型资源（会增加内存占用）
## - 只预加载真正需要的资源
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

# Music
const MENU_DOODLE_2_LOOP: AudioStream = preload(
	"res://assets/audio/music/menu_doodle_2_loop/ogg/menu_doodle_2_loop.ogg"
)

# SFX
const CLICK_4: AudioStream = preload("res://assets/audio/sfx/kenny_ui/ogg/click4.ogg")
const CLICK_5: AudioStream = preload("res://assets/audio/sfx/kenny_ui/ogg/click5.ogg")
const MOUSECLICK_1: AudioStream = preload("res://assets/audio/sfx/kenny_ui/ogg/mouseclick1.ogg")
const MOUSERELEASE_1: AudioStream = preload("res://assets/audio/sfx/kenny_ui/ogg/mouserelease1.ogg")
