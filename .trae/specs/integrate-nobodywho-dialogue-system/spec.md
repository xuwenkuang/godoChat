# 集成 NobodyWho 对话系统规范

## Why
当前项目缺少对话系统，无法实现 NPC 与玩家的互动对话。NobodyWho 插件提供了本地 LLM 运行能力，可以为每个 NPC 创建独特的对话体验，支持动态生成对话内容，提升游戏的叙事深度和玩家沉浸感。

## What Changes
- 安装并配置 NobodyWho 插件到项目
- 创建对话系统基础架构（对话管理器、对话 UI 组件）
- 实现 NPC 对话功能，支持多角色独立对话
- 集成 LLM 模型加载和管理
- 实现对话历史记录和上下文管理
- 添加对话系统与现有游戏系统的集成（场景管理、音频管理等）

## Impact
- 受影响的功能：新增对话系统功能
- 受影响的代码：addons/ 目录（新增 nobodywho 插件）、scenes/ 目录（新增对话相关场景）、autoload/ 目录（新增对话管理器）
- 受影响的资源：新增 LLM 模型文件、对话配置资源

## ADDED Requirements
### Requirement: 插件安装与配置
系统 SHALL 正确安装并配置 NobodyWho 插件，使其能够在 Godot 4.6 项目中运行。

#### Scenario: 插件安装成功
- **WHEN** 开发者通过 AssetLib 或手动导入 NobodyWho 插件
- **THEN** 插件应出现在项目插件列表中，并可以正常启用
- **THEN** 插件节点类型（NobodyWhoModel、NobodyWhoChat）应在编辑器中可用

### Requirement: LLM 模型管理
系统 SHALL 提供统一的 LLM 模型加载和管理机制。

#### Scenario: 模型加载成功
- **WHEN** 系统加载 GGUF 格式的 LLM 模型文件
- **THEN** 模型应成功加载并可用于对话生成
- **THEN** 系统应支持 GPU 加速（macOS 使用 Metal）

#### Scenario: 模型复用
- **WHEN** 多个 NPC 需要使用同一个 LLM 模型
- **THEN** 系统应复用同一个 NobodyWhoModel 节点，避免重复加载模型

### Requirement: 对话管理器
系统 SHALL 提供全局对话管理器，负责管理所有对话会话和 NPC 交互。

#### Scenario: 创建对话会话
- **WHEN** 玩家与 NPC 交互时
- **THEN** 对话管理器应创建新的对话会话
- **THEN** 会话应包含 NPC 身份、对话历史、上下文信息

#### Scenario: 对话历史管理
- **WHEN** 对话进行中
- **THEN** 系统应记录完整的对话历史
- **THEN** 历史记录应可用于后续对话的上下文参考

### Requirement: NPC 对话系统
系统 SHALL 为每个 NPC 提供独立的对话能力。

#### Scenario: NPC 独立对话
- **WHEN** 玩家与不同 NPC 交互
- **THEN** 每个 NPC 应有独立的对话上下文和记忆
- **THEN** NPC 应根据其角色设定（system prompt）生成符合性格的对话

#### Scenario: 对话流式输出
- **WHEN** NPC 生成对话内容
- **THEN** 对话应逐字流式输出，提供更好的用户体验
- **THEN** 流式输出应支持中断和继续

### Requirement: 对话 UI 组件
系统 SHALL 提供可复用的对话 UI 组件，用于显示对话内容。

#### Scenario: 对话框显示
- **WHEN** 对话开始时
- **THEN** 应显示对话 UI，包含 NPC 名称、对话文本、对话选项（如适用）
- **THEN** UI 应支持打字机效果和文本自动换行

#### Scenario: 对话选项处理
- **WHEN** NPC 提供对话选项
- **THEN** 玩家应能够选择选项
- **THEN** 选择应触发相应的对话响应

### Requirement: 与现有系统集成
系统 SHALL 与项目的现有系统（场景管理、音频管理、国际化等）无缝集成。

#### Scenario: 场景集成
- **WHEN** 对话在游戏场景中触发
- **THEN** 对话系统应与场景管理器协同工作
- **THEN** 对话期间应正确处理游戏暂停和恢复

#### Scenario: 音频集成
- **WHEN** 对话进行时
- **THEN** 应支持播放对话音效和背景音乐
- **THEN** 音频应通过现有的音频管理器播放

#### Scenario: 国际化支持
- **WHEN** 游戏切换语言
- **THEN** 对话系统应支持多语言
- **THEN** NPC 的 system prompt 应考虑语言设置

### Requirement: 性能优化
系统 SHALL 优化性能，确保对话系统不会影响游戏运行流畅度。

#### Scenario: 模型预加载
- **WHEN** 游戏启动或进入新场景
- **THEN** 系统应预加载必要的 LLM 模型
- **THEN** 预加载应在后台进行，不阻塞主线程

#### Scenario: 内存管理
- **WHEN** 对话会话结束或场景切换
- **THEN** 系统应释放不再需要的对话资源
- **THEN** 模型节点应在适当的时候卸载

### Requirement: 配置管理
系统 SHALL 提供对话系统的配置管理功能。

#### Scenario: 对话参数配置
- **WHEN** 开发者需要调整对话生成参数
- **THEN** 系统应支持配置温度、最大长度、采样器等参数
- **THEN** 配置应可以通过资源文件或代码设置

#### Scenario: NPC 角色配置
- **WHEN** 创建新的 NPC
- **THEN** 应能够配置 NPC 的角色设定、对话风格、记忆等信息
- **THEN** 配置应支持资源化，便于复用和管理

## MODIFIED Requirements
无现有需求需要修改。

## REMOVED Requirements
无现有需求需要移除。
