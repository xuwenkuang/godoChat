@tool
extends Node
## 翻译服务器包装器 - 扩展TranslationServer功能
## 
## 功能说明：
## - 扩展[TranslationServer]以提供额外功能
## - 支持[LOCALE_LIST_SEPARATOR]处理本地化字符串连接
## - 支持在@tool脚本中使用translate（编辑器中返回key）
## - 修复：https://github.com/godotengine/godot/issues/46271
## 
## 主要功能：
## - translate(): 翻译文本，支持多语言分隔符
## - 支持编辑器中的翻译预览
## - 自动处理本地化字符串的连接
## 
## 设计特点：
## - 使用|作为多语言分隔符
## - 编辑器模式下使用默认语言（en）
## - 找不到翻译时返回原文
## 
## 使用示例：
## - TranslationServerWrapper.translate("Hello|你好")
## - 会根据当前语言返回相应的翻译
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

const LOCALE_LIST_SEPARATOR: String = "|"

const DEFAULT_EDITOR_LOCALE: String = "en"


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	LogWrapper.debug(self, "AUTOLOAD READY.")


func translate(text: String) -> String:
	if not text.contains(LOCALE_LIST_SEPARATOR):
		return _translate(text)

	var texts: String = ""
	for subtext: String in text.split(LOCALE_LIST_SEPARATOR):
		texts += _translate(subtext)
	return texts


func _translate(text: String) -> String:
	var localized_text: String
	if Engine.is_editor_hint():
		var translation: Translation = TranslationServer.get_translation_object(
			DEFAULT_EDITOR_LOCALE
		)
		localized_text = translation.get_message(text)
	else:
		localized_text = tr(text)

	if localized_text == "":
		return text
	return localized_text
