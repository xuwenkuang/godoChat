# This alternative to [ParticleEmitter] has a better performance (higher FPS) if used per particle.
# Spawning "a node with tween" is more efficient than "a whole particle emitter for each particle".
class_name ParticleTween
extends Node
## 粒子补间组件 - 使用补间动画模拟粒子效果
## 
## 功能说明：
## - 使用Tween动画模拟粒子发射器
## - 目标节点必须具有position和modulate属性
## - 性能优于为每个粒子创建完整的粒子发射器
## 
## 使用场景：
## - [LabelParticleTween]设置为PCK场景，在[SpawnerBuffer]中的[GameButton]中使用
## - 需要大量粒子效果但性能要求高的情况
## 
## 配置选项：
## - target: 目标节点（必须有position和modulate属性）
## - duration: 动画持续时间
## - direction: 发射方向（角度）
## - direction_spread: 方向扩散范围
## - speed: 发射速度
## - speed_spread: 速度扩散范围
## - gravity: 重力加速度
## - horizontal_damping: 水平阻尼（防止粒子扩散太远）
## 
## 性能优势：
## - 每个粒子使用"带补间的节点"比"整个粒子发射器"更高效
## - 适合需要大量粒子效果的场景
## 
## 信号：
## - finished: 动画完成
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

signal finished

@export_group("Tween Options")
@export var target: Node

@export_group("Particle Options")
@export var duration: float = 3.0
@export var direction: float = 90
@export var direction_spread: float = 90
@export var speed: float = 275.0
@export var speed_spread: float = 50
@export var gravity: float = 200.0
## Helps prevent particles from spreading too far apart from origin.
@export_range(0, 1) var horizontal_damping: float = 0.4


func start() -> void:
	if target == null:
		return

	var tween: Tween = create_tween()
	var start_position: Vector2 = target.position
	var random_angle: float = randf_range(-direction_spread, direction_spread) / 2 + direction
	var random_speed: float = randf_range(-speed_spread, speed_spread) + speed
	var velocity: Vector2 = Vector2(
		random_speed * cos(deg_to_rad(random_angle)), -random_speed * sin(deg_to_rad(random_angle))
	)

	tween.tween_method(_update_arc_position.bind(start_position, velocity), 0.0, 1.0, duration)
	tween.parallel().tween_property(target, "modulate:a", 0.0, duration)
	tween.connect("finished", _on_tween_finished)


func _update_arc_position(progress: float, start_pos: Vector2, velocity: Vector2) -> void:
	var time: float = progress * duration
	var base_x: float = start_pos.x + velocity.x * time
	var base_y: float = start_pos.y + (velocity.y * time) + (0.5 * gravity * time * time)

	var center_attraction_strength: float = horizontal_damping * progress
	var final_x: float = lerp(base_x, start_pos.x, center_attraction_strength)

	target.position = Vector2(final_x, base_y)


func _on_tween_finished() -> void:
	finished.emit()
