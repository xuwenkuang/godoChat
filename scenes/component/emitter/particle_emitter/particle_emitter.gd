# Easy to customize with [ParticleProcessMaterial].
# Note that a [GPUParticles2D] using a [SubViewport] can be performance expensive.
# To avoid performance cost, use one emitter for multiple particles instead of spawning emitters.
class_name ParticleEmitter
extends GPUParticles2D
## 粒子发射器组件 - 将任意场景转换为粒子效果
## 
## 功能说明：
## - 使用子视口（SubViewport）将任意场景转换为粒子
## - 发射包含[particle]节点的子视口
## - 通过[particle_process_material_id]配置粒子材质
## 
## 使用方式：
## - 继承此类并设置override导出变量：[sub_viewport]、[particle]
## - 使用[start]和[stop]方法控制粒子发射
## - 可通过[ParticleProcessMaterial]自定义粒子效果
## 
## 性能注意：
## - 使用SubViewport的GPUParticles2D可能有性能开销
## - 为避免性能问题，使用一个发射器发射多个粒子，而不是生成多个发射器
## 
## 配置选项：
## - particle_process_material_id: 粒子材质ID
## - particle_modulate: 粒子颜色调制
## - stop_on_not_visible: 不可见时停止发射
## - ready_one_shot: 单次发射
## - ready_emitting: 就绪时开始发射
## - ready_amount: 发射数量
## 
## 信号：
## - particle_started: 粒子开始发射
## - particle_stopped: 粒子停止发射
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

signal particle_started
signal particle_stopped

@export_group("Options")
@export var particle_process_material_id: String = "":
	set(value):
		particle_process_material_id = value
		_set_particle()
@export var particle_modulate: Color = Color.WHITE:
	set(value):
		particle_modulate = value
		_set_modulate()
@export var stop_on_not_visible: bool = true

@export_group("On Ready")
@export var ready_one_shot: bool = true
@export var ready_emitting: bool = false
@export var ready_amount: int = 1

@export_group("Override")
@export var sub_viewport: SubViewport
@export var particle: Node

var is_finished: bool = true


# workaround for flickering particles
# - https://github.com/godotengine/godot/issues/65390
func _notification(what: int) -> void:
	if NOTIFICATION_PAUSED == what:
		self.interpolate = false
	elif NOTIFICATION_UNPAUSED == what:
		self.interpolate = true


func _process(_delta: float) -> void:
	if stop_on_not_visible and !is_visible_in_tree():
		stop()


func _ready() -> void:
	particle.theme = Configuration.get_theme()

	initialize()


func initialize() -> void:
	if sub_viewport == null or particle == null:
		LogWrapper.error(self, "SubViewport and Particle are mandatory, but are not set.")
		return

	self.one_shot = ready_one_shot
	self.emitting = ready_emitting
	self.amount = ready_amount

	self.finished.connect(_on_finished)


func start() -> void:
	_on_started()
	is_finished = false
	particle.visible = true
	self.emitting = true
	self.restart()


func stop() -> void:
	self.emitting = false
	particle.visible = false


func _set_particle() -> void:
	var particle_process_material: ParticleProcessMaterial = (
		ResourceReference.get_particle_process_material(particle_process_material_id)
	)
	if particle_process_material != null:
		self.process_material = particle_process_material


func _set_modulate() -> void:
	particle.modulate = particle_modulate


func _on_started() -> void:
	particle_started.emit()


func _on_finished() -> void:
	is_finished = true
	particle_stopped.emit()
