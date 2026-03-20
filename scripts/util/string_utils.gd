class_name StringUtils
## 字符串工具类 - 提供常用的字符串处理函数
## 
## 功能说明：
## - 提供静态字符串工具函数
## - 包含字符串验证、清理、转换等常用操作
## - 支持字符集过滤和长度限制
## 
## 主要函数：
## - is_set()/is_empty(): 字符串非空/空检查
## - equals_ignore_case(): 忽略大小写的字符串比较
## - join(): 字符数组连接
## - add_padding(): 添加前后填充
## - trim_end(): 从末尾截断字符串
## - trim_unallowed(): 移除不允许的字符
## - sanitize_text(): 清理文本（过滤字符集+限制长度）
## - sanitize_newline(): 清理换行符
## - charset_map(): 创建字符集映射字典
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller


static func is_set(string: String) -> bool:
	return string != null and not string.is_empty()


static func is_empty(string: String) -> bool:
	return string == null or string.is_empty()


static func equals_ignore_case(a: String, b: String) -> bool:
	return a.to_lower() == b.to_lower()


static func join(char_array: Array[String]) -> String:
	var output: String = ""
	for c: String in char_array:
		output += c
	return output


## Adds suffix and prefix as padding to given text.
static func add_padding(text: String, n: int, padding: String = " ") -> String:
	for i: int in range(n):
		text = padding + text + padding
	return text


## Shorten text from end to fit given max_length.
static func trim_end(text: String, max_length: int) -> String:
	return text.substr(0, min(text.length(), max_length))


## Remove chars from text that are not in allowed charset.
static func trim_unallowed(text: String, allowed_charset: String) -> String:
	var output: String = ""
	for c in text:
		if allowed_charset.contains(c):
			output += c
	return output


## Remove chars from text that are not in allowed and then shorten it down to max_length. [br]
## Default allowed charset is ASCII, while default max_length is unlimited.
static func sanitize_text(
	text: String,
	allowed_charset: String = CharsetConsts.ASCII,
	max_length: int = -1,
	default_empty: String = ""
) -> String:
	text = StringUtils.trim_unallowed(text, allowed_charset)
	if max_length > -1:
		text = StringUtils.trim_end(text, max_length)
	if text.length() == 0:
		text = default_empty
	return text


static func sanitize_newline(text: String) -> String:
	text = text.replace("\n", "")
	text = text.replace("\r\n", "")
	text = text.replace("\n\r", "")
	return text


static func charset_map(charset_keys: String, charset_values: String) -> Dictionary:
	var map: Dictionary = {}
	for i: int in range(charset_keys.length()):
		map[charset_keys[i]] = charset_values[i]
	return map

## Generate a random UUID string
static func generate_uuid() -> String:
	var uuid: String = ""
	for i in range(32):
		if i == 8 or i == 12 or i == 16 or i == 20:
			uuid += "-"
		else:
			uuid += "%x" % randi() % 16
	return uuid
