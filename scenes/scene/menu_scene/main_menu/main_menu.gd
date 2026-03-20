class_name MainMenu
extends Control
## 主菜单场景 - 游戏启动后的第一个界面
## 
## 功能说明：
## - 显示游戏标题、作者和版本信息
## - 提供游戏主要入口按钮（开始游戏、选项、制作人员、退出）
## - 支持多语言显示
## - Web平台自动隐藏退出按钮
## 
## UI元素：
## - 标题标签：显示游戏标题（支持本地化）
## - 作者标签：显示游戏作者
## - 版本标签：显示游戏版本号
## - 导航按钮：进入不同功能模块
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

const VERSION_PREFIX: String = "v"

@onready var title_label: Label = %TitleLabel
@onready var author_label: Label = %AuthorLabel
@onready var version_label: Label = %VersionLabel

@onready var animal_chatroom_button: MenuButtonClass = %AnimalChatroomButton
@onready var options_menu_button: MenuButtonClass = %OptionsMenuButton
@onready var credits_menu_button: MenuButtonClass = %CreditsMenuButton
@onready var quit_menu_button: MenuButtonClass = %QuitMenuButton


func _ready() -> void:
	_connect_signals()
	_refresh_labels()

	if OS.has_feature("web"):
		quit_menu_button.visible = false

	LogWrapper.debug(self, "Scene ready.")


func _refresh_labels() -> void:
	title_label.text = TranslationServerWrapper.translate(Configuration.GAME_TITLE)
	author_label.text = Configuration.GAME_AUTHOR
	version_label.text = VERSION_PREFIX + ProjectSettings.get_setting("application/config/version")


func _connect_signals() -> void:
	SignalBus.language_changed.connect(_on_language_changed)

	animal_chatroom_button.confirmed.connect(_on_animal_chatroom_button)
	quit_menu_button.confirmed.connect(_on_quit_button)


func _on_language_changed(_locale: String) -> void:
	_refresh_labels()


func _on_animal_chatroom_button() -> void:
	SceneManagerWrapper.change_scene(SceneManagerEnum.Scene.ANIMAL_CHATROOM_SCENE, "fade_1s")


func _on_quit_button() -> void:
	get_tree().quit()
