# NobodyWho 插件安装说明

## 概述

本项目已安装 NobodyWho 插件的基础架构和占位符。该插件为 Godot 项目提供大语言模型（LLM）集成功能。

## 当前状态

**重要提示：** 当前安装的是插件的占位符版本，仅提供基础架构和接口定义。实际的 LLM 功能需要下载完整的 NobodyWho 插件。

## 插件结构

```
addons/nobodywho/
├── plugin.cfg              # 插件配置文件
├── plugin.gd               # 插件主文件
├── nobodywho_model.gd      # NobodyWhoModel 节点类
└── nobodywho_chat.gd       # NobodyWhoChat 节点类
```

## 已创建的组件

### 1. NobodyWhoModel
用于管理 LLM 模型的节点类，提供以下功能：
- 模型加载和卸载
- 文本生成（同步和异步）
- 生成参数配置（temperature、top_p、top_k 等）
- 模型信息查询

**主要信号：**
- `model_loaded` - 模型加载完成
- `model_unloaded` - 模型卸载完成
- `generation_started` - 生成开始
- `generation_finished` - 生成完成
- `generation_error` - 生成错误

### 2. NobodyWhoChat
用于管理对话会话的节点类，提供以下功能：
- 对话会话管理
- 消息发送和接收
- 对话历史记录
- 系统提示词设置
- 历史记录长度控制

**主要信号：**
- `message_received` - 接收到消息
- `chat_started` - 对话开始
- `chat_ended` - 对话结束
- `error_occurred` - 发生错误

## 使用方法

### 基本用法示例

```gdscript
# 创建模型节点
var model = NobodyWhoModel.new()
add_child(model)

# 创建聊天节点
var chat = NobodyWhoChat.new()
add_child(chat)

# 设置模型
chat.set_model(model)

# 设置系统提示词
chat.set_system_prompt("你是一个友好的游戏助手。")

# 开始对话
chat.start_chat()

# 发送消息
var response = chat.send_message("你好！")
print(response)
```

### 监听信号

```gdscript
# 监听消息接收
chat.message_received.connect(func(role, content):
    print(role, ": ", content)
)

# 监听生成完成
model.generation_finished.connect(func(result):
    print("生成结果: ", result)
)
```

## 获取完整插件

要使用实际的 LLM 功能，请从以下渠道获取完整的 NobodyWho 插件：

1. **官方 GitHub 仓库**（如果可用）
2. **Godot Asset Library**（如果已发布）
3. **社区发布渠道**

### 安装完整插件

1. 下载完整的 NobodyWho 插件
2. 替换 `addons/nobodywho/` 目录中的文件
3. 在 Godot 编辑器中重新加载项目
4. 插件将自动启用并提供完整的 LLM 功能

## 配置参数

### NobodyWhoModel 参数
- `max_tokens`: 最大生成令牌数（默认：2048）
- `temperature`: 温度参数，控制随机性（默认：0.7）
- `top_p`: 核采样参数（默认：0.9）
- `top_k`: Top-K 采样参数（默认：40）

### NobodyWhoChat 参数
- `system_prompt`: 系统提示词
- `max_history_length`: 最大历史记录长度（默认：10）

## 注意事项

1. **占位符限制**：当前版本不提供实际的 LLM 功能，所有生成操作都会返回占位符文本
2. **性能考虑**：完整的 LLM 插件可能需要较多的计算资源
3. **API 密钥**：某些 LLM 服务可能需要 API 密钥，请在完整插件中配置
4. **网络连接**：使用在线 LLM 服务需要稳定的网络连接

## 故障排除

### 插件未启用
- 检查 `project.godot` 文件中的 `[editor_plugins]` 部分
- 确保 `res://addons/nobodywho/plugin.cfg` 在 `enabled` 数组中

### 找不到节点类
- 确保 Godot 编辑器已重新加载项目
- 检查脚本文件是否正确创建

### 生成功能不工作
- 这是预期的行为，因为当前是占位符版本
- 请下载并安装完整的 NobodyWho 插件

## 支持

如需帮助或报告问题，请：
- 查看 NobodyWho 插件的官方文档
- 在相关社区论坛寻求帮助
- 检查项目的 issue 跟踪器

## 版本信息

- 当前版本：1.0.0（占位符）
- Godot 版本要求：4.0+
- 最后更新：2026-03-17

## 许可证

请参考完整 NobodyWho 插件的许可证信息。