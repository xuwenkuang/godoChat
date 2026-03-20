class_name ButtonAudio
extends Node
## 按钮音频组件 - 为按钮添加音效
## 
## 功能说明：
## - 监听目标[BaseButton]的信号（焦点、点击、释放）
## - 在按钮交互时播放相应的音效
## - 支持[OptionButton]的选项信号
## 
## 使用方式：
## - 附加到父节点，会自动查找父节点或后代中的[BaseButton]
## - 递归查找可以为内部子按钮提供音效（如[ConfirmationDialog]的按钮）
## - 使用[NodeUtils.find_descendant]进行递归查找
## 
## 音效类型：
## - focus: 获得焦点时的音效
## - down: 按下时的音效
## - up: 释放时的音效
## 
## 智能过滤：
## - skip_focus_on_nothing_pressed: 没有按键时跳过焦点音效
## - skip_down_after_focus: 焦点和按下同时触发时跳过按下音效
## - skip_up_for_option_button: OptionButton同时触发up和down时跳过up
## - last_interaction_timeout: 防止多个信号同时触发
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

enum Interaction { NULL, FOCUS, DOWN, UP }

## Sets target as parent if target is not already set.
## If parent is not instance of [BaseButton], searches for a descendant instead (recursive search).
## NOTE: While searching for target, ignores nodes that already have a [ButtonAudio] attached.
@export var target: BaseButton

@export_category("Sounds")
@export var focus: AudioEnum.Sfx = AudioEnum.Sfx.SELECT
@export var down: AudioEnum.Sfx = AudioEnum.Sfx.SELECT
@export var up: AudioEnum.Sfx = AudioEnum.Sfx.CLICK

@export_category("Interaction Options")
## Consider focus is grabbed by a script instead by an interaction.
@export var skip_focus_on_nothing_pressed: bool = true
## Consider focus and down sfx are triggered at the same time.
@export var skip_down_after_focus: bool = true
## Consider [OptionButton] emits button_up signal at the same frame as the button_down signal.
@export var skip_up_for_option_button: bool = true
## Consider multiple signals trigger interactions at the same time.
@export var last_interaction_timeout: float = 0.1:
	set(value):
		last_interaction_timeout = value
		last_interaction_timer.wait_time = value

var _last_interaction: Interaction = Interaction.NULL

@onready var last_interaction_timer: Timer = %LastInteractionTimer


func _ready() -> void:
	# determine target node to apply to
	if target == null:
		target = NodeUtils.find_descendant(get_parent(), _is_valid_target, true)
	if target == null:
		LogWrapper.warn(self, "Target not found for parent: ", get_parent().name)
		return

	# sets flag so other [ButtonAudio] nodes do not apply multiple times to the same node
	target.add_theme_constant_override("button_audio_attached", 1)

	_connect_signals()


func _is_valid_target(node: Node) -> bool:
	if not "get_theme_constant" in node:
		return false  # ignore "non-themed" nodes (internal nodes not related to [Control] nodes)

	var is_instance_of_base_button: bool = is_instance_of(node, BaseButton)
	var is_aready_a_target: bool = node.get_theme_constant("button_audio_attached") == 1

	return is_instance_of_base_button and not is_aready_a_target


func _connect_signals() -> void:
	last_interaction_timer.timeout.connect(_on_clear_last_interaction)
	target.visibility_changed.connect(_on_clear_last_interaction)

	target.focus_entered.connect(_on_target_focus_entered)
	target.button_down.connect(_on_target_button_down)
	target.button_up.connect(_on_target_button_up)

	if is_instance_of(target, OptionButton):
		(target as OptionButton).get_popup().id_focused.connect(_on_target_option_focus_entered)
		(target as OptionButton).get_popup().id_pressed.connect(_on_target_option_button_up)


func _on_clear_last_interaction() -> void:
	_last_interaction = Interaction.NULL


func _on_target_focus_entered() -> void:
	if skip_focus_on_nothing_pressed and not Input.is_anything_pressed():
		return
	if _is_set(focus):
		AudioManagerWrapper.play_sfx(focus)
	_new_interaction(Interaction.FOCUS)

	LogWrapper.debug(self, "Button sfx focus: %s" % EnumUtils.to_name(focus, AudioEnum.Sfx))


func _on_target_button_down() -> void:
	if skip_down_after_focus and _last_interaction == Interaction.FOCUS:
		return
	if _is_set(down):
		AudioManagerWrapper.play_sfx(down)
	_new_interaction(Interaction.DOWN)

	LogWrapper.debug(self, "Button sfx down: %s" % EnumUtils.to_name(down, AudioEnum.Sfx))


func _on_target_button_up(internal: bool = false) -> void:
	if not internal and skip_up_for_option_button and is_instance_of(target, OptionButton):
		return
	if _is_set(up):
		AudioManagerWrapper.play_sfx(up)
	_new_interaction(Interaction.UP)

	LogWrapper.debug(self, "Button sfx up: %s" % EnumUtils.to_name(up, AudioEnum.Sfx))


func _on_target_option_focus_entered(_id: int) -> void:
	_on_target_focus_entered()


func _on_target_option_button_up(_id: int) -> void:
	_on_target_button_up(true)


func _new_interaction(interaction: Interaction) -> void:
	if last_interaction_timeout > 0.0:
		last_interaction_timer.start()
	_last_interaction = interaction


func _is_set(event: AudioEnum.Sfx) -> bool:
	return target != null and event != AudioEnum.Sfx.NULL
