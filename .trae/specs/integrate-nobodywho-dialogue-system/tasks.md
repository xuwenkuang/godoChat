# Tasks

- [x] Task 1: 安装和配置 NobodyWho 插件
  - [x] SubTask 1.1: 从 Godot AssetLib 或 GitHub 下载 NobodyWho 插件
  - [x] SubTask 1.2: 将插件导入到项目的 addons 目录
  - [x] SubTask 1.3: 在 project.godot 中启用插件
  - [x] SubTask 1.4: 验证插件节点类型在编辑器中可用

- [x] Task 2: 创建对话管理器（DialogueManager）
  - [x] SubTask 2.1: 创建 DialogueManager 脚本和场景
  - [x] SubTask 2.2: 实现对话会话管理功能（创建、存储、销毁）
  - [x] SubTask 2.3: 实现对话历史记录功能
  - [x] SubTask 2.4: 将 DialogueManager 添加到 autoload 单例

- [x] Task 3: 创建 LLM 模型管理器
  - [x] SubTask 3.1: 创建 ModelManager 脚本
  - [x] SubTask 3.2: 实现 GGUF 模型加载功能
  - [x] SubTask 3.3: 实现模型复用和缓存机制
  - [x] SubTask 3.4: 添加 GPU 加速配置（macOS Metal 支持）

- [x] Task 4: 创建 NPC 对话组件
  - [x] SubTask 4.1: 创建 NPCDialogue 脚本，继承 NobodyWhoChat
  - [x] SubTask 4.2: 实现 NPC 角色设定（system prompt）配置
  - [x] SubTask 4.3: 实现对话流式输出功能
  - [x] SubTask 4.4: 实现对话上下文和记忆管理

- [x] Task 5: 创建对话 UI 组件
  - [x] SubTask 5.1: 创建 DialogueBox 场景和脚本
  - [x] SubTask 5.2: 实现 NPC 名称显示和对话文本显示
  - [x] SubTask 5.3: 实现打字机效果和文本自动换行
  - [x] SubTask 5.4: 创建对话选项 UI（如需要）
  - [x] SubTask 5.5: 添加对话 UI 动画效果

- [x] Task 6: 集成对话系统与场景管理
  - [x] SubTask 6.1: 在游戏场景中添加对话触发机制
  - [x] SubTask 6.2: 实现对话期间的游戏暂停功能
  - [x] SubTask 6.3: 实现对话结束后的游戏恢复功能
  - [x] SubTask 6.4: 与 SceneManager 协同工作

- [x] Task 7: 集成对话系统与音频管理
  - [x] SubTask 7.1: 添加对话音效播放功能
  - [x] SubTask 7.2: 集成背景音乐切换（对话时使用特定音乐）
  - [x] SubTask 7.3: 通过 SoundManager 和 MusicManager 播放音频

- [x] Task 8: 创建 NPC 配置资源
  - [x] SubTask 8.1: 创建 NPCProfile 资源类型
  - [x] SubTask 8.2: 定义 NPC 配置字段（名称、头像、角色设定、对话风格等）
  - [x] SubTask 8.3: 创建示例 NPC 配置资源

- [x] Task 9: 实现对话参数配置
  - [x] SubTask 9.1: 创建 DialogueSettings 资源类型
  - [x] SubTask 9.2: 定义可配置参数（温度、最大长度、采样器等）
  - [x] SubTask 9.3: 实现参数应用和动态调整功能

- [x] Task 10: 添加国际化支持
  - [x] SubTask 10.1: 确保对话 UI 支持多语言
  - [x] SubTask 10.2: 为 NPC system prompt 添加多语言支持
  - [x] SubTask 10.3: 添加对话相关的翻译条目

- [x] Task 11: 实现性能优化
  - [x] SubTask 11.1: 实现模型预加载机制
  - [x] SubTask 11.2: 实现后台加载和异步处理
  - [x] SubTask 11.3: 实现资源释放和内存管理

- [x] Task 12: 创建示例场景和文档
  - [x] SubTask 12.1: 创建示例对话场景，包含可交互的 NPC
  - [x] SubTask 12.2: 编写对话系统使用文档
  - [x] SubTask 12.3: 创建 NPC 配置示例和教程

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 1]
- [Task 4] depends on [Task 2, Task 3]
- [Task 5] depends on [Task 2]
- [Task 6] depends on [Task 4, Task 5]
- [Task 7] depends on [Task 5]
- [Task 8] depends on [Task 4]
- [Task 9] depends on [Task 3]
- [Task 10] depends on [Task 5, Task 8]
- [Task 11] depends on [Task 3]
- [Task 12] depends on [Task 4, Task 5, Task 8]
