extends Node
## 全局信号总线 - 用于全局事件通信
## 
## 功能说明：
## - 提供全局信号系统，用于跨场景、跨层级的事件通信
## - 子节点到父节点的通信应使用普通信号，其他情况使用全局信号
## - 避免在信号中传递大量数据，应使用引用或ID
## 
## 使用场景：
## - 语言切换通知
## - 游戏状态变化通知
## - UI更新通知
## - 跨模块数据同步
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

# Configuration - 配置相关信号
signal language_changed(locale: String)
signal number_format_changed(number_format: NumberUtils.NumberFormat)

# Game - 游戏相关信号
signal clicks_per_second_updated(cps: int)
