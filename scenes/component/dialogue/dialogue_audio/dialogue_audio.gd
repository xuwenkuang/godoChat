class_name DialogueAudio
extends Node

# 对话音频管理器 - 管理对话相关的音效和音乐
# 
# 功能说明：
# - 播放对话打字音效
# - 播放对话开始/结束音效
# - 播放选项选择音效
# - 支持背景音乐切换（对话时切换到对话音乐）
# - 对话结束后恢复原来的背景音乐
# - 与 SoundManager 和 MusicManager 集成
# - 支持音量调节和音效配置
# 
# 使用方式：
# - 附加到 DialogueBox 或其他对话相关节点
# - 通过信号连接自动播放音效
# - 可配置各种音效和音乐参数
# 
# Original File MIT License Copyright (c) 2024 TinyTakinTeller

signal dialogue_audio_started()
signal dialogue_audio_ended()

@export_category("Sound Effects")
@export var typing_sound: AudioEnum.Sfx = AudioEnum.Sfx.SELECT
@export var dialogue_start_sound: AudioEnum.Sfx = AudioEnum.Sfx.SELECT
@export var dialogue_end_sound: AudioEnum.Sfx = AudioEnum.Sfx.CLICK
@export var choice_select_sound: AudioEnum.Sfx = AudioEnum.Sfx.SELECT_2

@export_category("Music")
@export var dialogue_music: AudioEnum.Music = AudioEnum.Music.MENU_DODDLE
@export var enable_music_switch: bool = true
@export var music_crossfade_time: float = 1.0
@export var restore_music_on_end: bool = true

@export_category("Volume Settings")
@export_range(0.0, 1.0, 0.05) var typing_volume: float = 0.5
@export_range(0.0, 1.0, 0.05) var dialogue_start_volume: float = 0.7
@export_range(0.0, 1.0, 0.05) var dialogue_end_volume: float = 0.7
@export_range(0.0, 1.0, 0.05) var choice_select_volume: float = 0.8

@export_category("Typing Settings")
@export var play_typing_sound: bool = true
@export var typing_interval: float = 0.05
@export var typing_pitch_variation: float = 0.1

var _previous_music: AudioEnum.Music = AudioEnum.Music.NULL
var _is_dialogue_active: bool = false
var _typing_timer: Timer
var _dialogue_box: DialogueBox
var _dialogue_manager: DialogueManager

func _ready() -> void:
	_setup_typing_timer()
	_find_dialogue_components()
	_connect_signals()


func _setup_typing_timer() -> void:
	_typing_timer = Timer.new()
	_typing_timer.wait_time = typing_interval
	_typing_timer.timeout.connect(_on_typing_timer_timeout)
	add_child(_typing_timer)


func _find_dialogue_components() -> void:
	var parent = get_parent()
	
	if parent is DialogueBox:
		_dialogue_box = parent
	else:
		_dialogue_box = parent.find_child("DialogueBox", true, false)
	
	if not _dialogue_box:
		LogWrapper.warn(self, "DialogueBox not found")
		return
	
	_dialogue_manager = DialogueManager


func _connect_signals() -> void:
	if not _dialogue_box:
		return
	
	_dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	_dialogue_box.choice_selected.connect(_on_choice_selected)
	
	if _dialogue_manager:
		_dialogue_manager.dialogue_started.connect(_on_dialogue_manager_started)
		_dialogue_manager.dialogue_ended.connect(_on_dialogue_manager_ended)


func play_dialogue_start_sound() -> void:
	if dialogue_start_sound != AudioEnum.Sfx.NULL:
		AudioManagerWrapper.play_sfx(dialogue_start_sound)
	
	LogWrapper.debug(self, "Dialogue start sound played")


func play_dialogue_end_sound() -> void:
	if dialogue_end_sound != AudioEnum.Sfx.NULL:
		AudioManagerWrapper.play_sfx(dialogue_end_sound)
	
	LogWrapper.debug(self, "Dialogue end sound played")


func play_typing_sound() -> void:
	if not play_typing_sound or typing_sound == AudioEnum.Sfx.NULL:
		return
	
	AudioManagerWrapper.play_sfx(typing_sound)
	
	LogWrapper.debug(self, "Typing sound played")


func play_choice_select_sound() -> void:
	if choice_select_sound != AudioEnum.Sfx.NULL:
		AudioManagerWrapper.play_sfx(choice_select_sound)
	
	LogWrapper.debug(self, "Choice select sound played")


func start_dialogue_music() -> void:
	if not enable_music_switch or dialogue_music == AudioEnum.Music.NULL:
		return
	
	_previous_music = _get_current_music()
	
	if _previous_music != dialogue_music:
		AudioManagerWrapper.play_music(dialogue_music, music_crossfade_time, true)
		LogWrapper.debug(self, "Dialogue music started: %s" % EnumUtils.to_name(dialogue_music, AudioEnum.Music))


func end_dialogue_music() -> void:
	if not enable_music_switch or not restore_music_on_end:
		return
	
	if _previous_music != AudioEnum.Music.NULL and _previous_music != dialogue_music:
		AudioManagerWrapper.play_music(_previous_music, music_crossfade_time, true)
		LogWrapper.debug(self, "Previous music restored: %s" % EnumUtils.to_name(_previous_music, AudioEnum.Music))


func start_dialogue_audio() -> void:
	if _is_dialogue_active:
		return
	
	_is_dialogue_active = true
	play_dialogue_start_sound()
	start_dialogue_music()
	dialogue_audio_started.emit()
	
	LogWrapper.debug(self, "Dialogue audio started")


func end_dialogue_audio() -> void:
	if not _is_dialogue_active:
		return
	
	_is_dialogue_active = false
	_typing_timer.stop()
	play_dialogue_end_sound()
	end_dialogue_music()
	dialogue_audio_ended.emit()
	
	LogWrapper.debug(self, "Dialogue audio ended")


func start_typing_sounds() -> void:
	if not play_typing_sound or not _is_dialogue_active:
		return
	
	_typing_timer.start()


func stop_typing_sounds() -> void:
	_typing_timer.stop()


func _get_current_music() -> AudioEnum.Music:
	if not MusicManager.is_playing():
		return AudioEnum.Music.NULL
	
	for music in AudioEnum.Music.values():
		if music == AudioEnum.Music.NULL:
			continue
		var music_name = EnumUtils.to_name(music, AudioEnum.Music)
		if MusicManager.is_playing(AudioManagerWrapper.audio_banks.MUSIC_BANK, music_name):
			return music
	
	return AudioEnum.Music.NULL


func _on_dialogue_manager_started(session_id: String, npc_id: String, npc_name: String) -> void:
	start_dialogue_audio()


func _on_dialogue_manager_ended(session_id: String, npc_id: String) -> void:
	end_dialogue_audio()


func _on_dialogue_finished() -> void:
	end_dialogue_audio()


func _on_choice_selected(choice_index: int) -> void:
	play_choice_select_sound()


func _on_typing_timer_timeout() -> void:
	if _dialogue_box and _dialogue_box.is_typing():
		play_typing_sound()


func set_typing_volume(volume: float) -> void:
	typing_volume = clamp(volume, 0.0, 1.0)


func set_dialogue_start_volume(volume: float) -> void:
	dialogue_start_volume = clamp(volume, 0.0, 1.0)


func set_dialogue_end_volume(volume: float) -> void:
	dialogue_end_volume = clamp(volume, 0.0, 1.0)


func set_choice_select_volume(volume: float) -> void:
	choice_select_volume = clamp(volume, 0.0, 1.0)


func set_music_crossfade_time(time: float) -> void:
	music_crossfade_time = max(0.0, time)


func is_dialogue_audio_active() -> bool:
	return _is_dialogue_active


func get_current_music() -> AudioEnum.Music:
	return _get_current_music()


func get_previous_music() -> AudioEnum.Music:
	return _previous_music


func _exit_tree() -> void:
	if _typing_timer:
		_typing_timer.queue_free()
	
	if _dialogue_box:
		_dialogue_box.dialogue_finished.disconnect(_on_dialogue_finished)
		_dialogue_box.choice_selected.disconnect(_on_choice_selected)
	
	if _dialogue_manager:
		_dialogue_manager.dialogue_started.disconnect(_on_dialogue_manager_started)
		_dialogue_manager.dialogue_ended.disconnect(_on_dialogue_manager_ended)
