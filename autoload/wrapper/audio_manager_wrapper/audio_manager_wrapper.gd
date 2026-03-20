# TODO: Does not wrap all methods. Wrap other methods from [MusicManager] [SoundManager] if needed.
extends Node
## 音频管理器包装器 - 封装Resonate音频管理插件
## 
## 功能说明：
## - 封装Resonate插件的[MusicManager]和[SoundManager]自动加载节点
## - 在[AudioBanks]中初始化音频音轨
## - 使用[AudioEnum]枚举替代字符串名称来标识音频
## - 扩展[play_music]方法，添加[unique]标志以跟踪已播放的音乐
## 
## 设计优势：
## - 类型安全：使用枚举而非字符串标识音频
## - 防止重复：unique标志避免循环音乐重复播放
## - 集中管理：音频资源在AudioBanks中统一配置
## 
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

# tracks already playing music (useful to avoid replaying looped music)
var _already_playing: Dictionary = {}

@onready var audio_banks: AudioBanks = %AudioBanks


func _ready() -> void:
	LogWrapper.debug(self, "AUTOLOAD READY.")


func play_music(music: AudioEnum.Music, crossfade: float = 0.0, unique: float = true) -> void:
	var music_name: String = EnumUtils.to_name(music, AudioEnum.Music)

	# skip playing music if [unqiue] flag is true
	if unique:
		if _already_playing.get(music_name, false):
			return
		_already_playing[music_name] = true

	MusicManager.play(audio_banks.MUSIC_BANK, music_name, crossfade)


func play_sfx(sfx: AudioEnum.Sfx) -> void:
	SoundManager.play(audio_banks.SOUND_BANK, EnumUtils.to_name(sfx, AudioEnum.Sfx))
