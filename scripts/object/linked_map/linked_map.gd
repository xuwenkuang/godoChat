class_name LinkedMap
extends Object
## 有序映射数据结构 - 保持插入顺序的字典
## 
## 功能说明：
## - 实现一个有序映射（Ordered Map）
## - 保持键的插入顺序
## - 支持按值对键进行排序
## - 结合了数组的有序性和字典的快速查找
## 
## 数据结构：
## - keys: 保存键的有序数组
## - key_value_map: 保存键值对的字典
## 
## 主要方法：
## - get_value()/get_value_at(): 通过键或索引获取值
## - get_key_at()/get_key_by_value(): 获取键
## - add(): 添加键值对（保持插入顺序）
## - remove(): 删除键值对
## - sort_by_values(): 按值排序键
## - get_keys()/get_values(): 获取所有键或值
## - find_key_by_value(): 通过值查找键
## 
## 使用场景：
## - 需要保持顺序的配置项
## - 需要按值排序的映射
## - 需要同时支持索引和键访问的数据
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

var keys: Array[String] = []
var key_value_map: Dictionary = {}


func get_value(key: String) -> Variant:
	return key_value_map[key]


func get_value_at(index: int) -> Variant:
	return get_value(get_key_at(index))


func get_key_at(index: int) -> Variant:
	return keys[index]


func get_key_by_value(value: Variant) -> String:
	var index: int = find_key_index_by_value(value)
	return keys[index]


func add(key: String, value: Variant) -> void:
	if not key_value_map.has(key):
		keys.append(key)
	key_value_map[key] = value


func remove(key: String) -> void:
	if key_value_map.has(key):
		keys.erase(key)
		key_value_map.erase(key)


func sort_by_values() -> void:
	keys.sort_custom(func(a: Variant, b: Variant) -> bool: return a < b)


func get_keys() -> Array[String]:
	return keys


func get_values() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in keys:
		result.append(key_value_map[key])
	return result


## return "" if not found
func find_key_by_value(value: Variant) -> String:
	for key: String in keys:
		if key_value_map.get(key, null) == value:
			return key
	return ""


## return -1 if not found
func find_key_index_by_value(value: Variant) -> int:
	return keys.find(find_key_by_value(value))
