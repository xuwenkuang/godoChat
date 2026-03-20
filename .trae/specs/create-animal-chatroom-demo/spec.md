# 动物聊天室 Demo 规范

## Why
为了展示 NobodyWho 对话系统的实际应用效果，创建一个直观的动物聊天室 demo，让用户能够体验与多个 AI 动物角色进行实时对话的乐趣。这个 demo 将作为项目的示例场景，展示如何利用现有的对话系统快速构建多角色互动场景。

## What Changes
- 创建动物聊天室主场景，包含开始界面和聊天室界面
- 为每种动物创建独立的 NPC 配置资源（NPCProfile），包含角色设定和头像
- 实现聊天室 UI，显示多个动物角色和对话历史
- 实现角色选择和切换功能
- 集成现有的对话系统（DialogueManager、ModelManager、NPCDialogue）
- 添加动物头像资源的引用和显示
- 实现多角色并发对话功能
- 添加音效和动画效果

## Impact
- 受影响的功能：新增动物聊天室 demo 场景
- 受影响的代码：scenes/ 目录（新增聊天室相关场景）、resources/ 目录（新增 NPC 配置资源）
- 受影响的资源：使用现有的动物头像资源

## ADDED Requirements
### Requirement: 动物聊天室主场景
系统 SHALL 提供动物聊天室主场景，包含开始界面和聊天室界面。

#### Scenario: 进入聊天室
- **WHEN** 玩家点击"开始游戏"按钮
- **THEN** 应从主菜单场景切换到聊天室场景
- **THEN** 应加载所有动物 NPC 配置
- **THEN** 应预加载 LLM 模型（如果需要）

#### Scenario: 返回主菜单
- **WHEN** 玩家点击"返回"按钮
- **THEN** 应从聊天室场景切换回主菜单场景
- **THEN** 应结束所有活跃的对话会话

### Requirement: 动物 NPC 配置
系统 SHALL 为每种动物创建独立的 NPC 配置资源。

#### Scenario: 加载动物配置
- **WHEN** 聊天室场景初始化
- **THEN** 应加载所有动物的 NPCProfile 资源
- **THEN** 每个动物应有独特的角色设定（system prompt）
- **THEN** 每个动物应有对应的头像图片

#### Scenario: 动物角色设定
- **WHEN** 创建动物 NPC 配置
- **THEN** 每个动物应有符合其特征的性格设定
- **THEN** 每个动物应有独特的说话风格
- **THEN** 每个动物应有背景故事

### Requirement: 聊天室 UI
系统 SHALL 提供聊天室用户界面，显示动物角色和对话内容。

#### Scenario: 显示动物角色列表
- **WHEN** 聊天室场景加载完成
- **THEN** 应显示所有可用的动物角色
- **THEN** 每个角色应显示头像和名称
- **THEN** 玩家应能够点击选择角色

#### Scenario: 显示对话历史
- **WHEN** 与动物进行对话
- **THEN** 应显示完整的对话历史
- **THEN** 应区分玩家消息和动物回复
- **THEN** 应显示消息发送者名称和头像

#### Scenario: 发送消息
- **WHEN** 玩家在输入框中输入消息并发送
- **THEN** 消息应发送给当前选中的动物
- **THEN** 动物的回复应流式显示
- **THEN** 对话历史应自动滚动到最新消息

### Requirement: 角色选择和切换
系统 SHALL 允许玩家选择和切换不同的动物角色进行对话。

#### Scenario: 选择角色
- **WHEN** 玩家点击某个动物角色
- **THEN** 该角色应被标记为当前选中状态
- **THEN** 应显示该角色的详细信息和对话历史
- **THEN** 后续消息应发送给该角色

#### Scenario: 切换角色
- **WHEN** 玩家点击另一个动物角色
- **THEN** 当前选中状态应切换到新角色
- **THEN** 应显示新角色的对话历史
- **THEN** 后续消息应发送给新角色

### Requirement: 多角色并发对话
系统 SHALL 支持与多个动物角色同时进行对话。

#### Scenario: 多角色对话
- **WHEN** 玩家与多个动物角色进行对话
- **THEN** 每个角色应保持独立的对话上下文
- **THEN** 每个角色应有独立的对话历史
- **THEN** 角色之间不应相互影响

### Requirement: 音效和动画
系统 SHALL 为聊天室添加音效和动画效果。

#### Scenario: 消息发送音效
- **WHEN** 玩家发送消息
- **THEN** 应播放消息发送音效

#### Scenario: 消息接收音效
- **WHEN** 动物回复消息
- **THEN** 应播放消息接收音效

#### Scenario: UI 动画
- **WHEN** UI 元素显示或隐藏
- **THEN** 应有平滑的过渡动画
- **WHEN** 消息显示
- **THEN** 应有淡入动画

### Requirement: 动物头像资源
系统 SHALL 使用现有的动物头像资源。

#### Scenario: 加载头像资源
- **WHEN** 创建动物 NPC 配置
- **THEN** 应从 assets/image/game/animal/png/round/ 加载对应的头像
- **THEN** 头像应正确显示在 UI 中

## MODIFIED Requirements
无现有需求需要修改。

## REMOVED Requirements
无现有需求需要移除。
