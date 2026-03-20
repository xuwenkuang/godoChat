class_name GameSaveData
extends SaveData
## 游戏数据存档 - 存储实际的游戏进度数据
## 
## 功能说明：
## - 存储玩家的游戏进度、金币、属性等核心数据
## - 继承自[SaveData]基类，自动处理保存和加载
## - 使用setter触发信号，通知数据变化
## 
## 数据示例：
## - coins: 玩家金币数量
## - max_clicks_per_second: 最大每秒点击次数
## 
## 设计特点：
## - 数据变化时自动发出信号
## - 支持自动保存机制
## - 可根据游戏需求扩展更多数据字段
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

signal coins_set(value: int)
signal max_clicks_per_second_set(value: int)

var coins: int:
	set(value):
		coins = value
		coins_set.emit(value)

var max_clicks_per_second: int:
	set(value):
		max_clicks_per_second = value
		max_clicks_per_second_set.emit(value)


func clear(_index: int = -1) -> void:
	coins = 0
	max_clicks_per_second = 0
