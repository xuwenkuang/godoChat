# Tasks

- [x] Task 1: 创建动物聊天室主场景
  - [x] SubTask 1.1: 创建 AnimalChatroomScene 场景和脚本
  - [x] SubTask 1.2: 实现场景切换逻辑（从主菜单进入聊天室）
  - [x] SubTask 1.3: 创建开始界面 UI（标题、开始按钮）
  - [x] SubTask 1.4: 创建聊天室界面 UI（角色列表、对话区域、输入框）
  - [x] SubTask 1.5: 添加返回按钮和场景切换逻辑

- [x] Task 2: 创建动物 NPC 配置资源
  - [x] SubTask 2.1: 为大象（elephant）创建 NPCProfile 资源
  - [x] SubTask 2.2: 为长颈鹿（giraffe）创建 NPCProfile 资源
  - [x] SubTask 2.3: 为河马（hippo）创建 NPCProfile 资源
  - [x] SubTask 2.4: 为猴子（monkey）创建 NPCProfile 资源
  - [x] SubTask 2.5: 为熊猫（panda）创建 NPCProfile 资源
  - [x] SubTask 2.6: 为鹦鹉（parrot）创建 NPCProfile 资源
  - [x] SubTask 2.7: 为企鹅（penguin）创建 NPCProfile 资源
  - [x] SubTask 2.8: 为猪（pig）创建 NPCProfile 资源
  - [x] SubTask 2.9: 为兔子（rabbit）创建 NPCProfile 资源
  - [x] SubTask 2.10: 为蛇（snake）创建 NPCProfile 资源
  - [x] SubTask 2.11: 为每个动物配置头像资源路径
  - [x] SubTask 2.12: 为每个动物配置独特的角色设定和说话风格

- [x] Task 3: 实现聊天室 UI 组件
  - [x] SubTask 3.1: 创建 AnimalCharacterList 组件（显示动物角色列表）
  - [x] SubTask 3.2: 创建 CharacterItem 组件（单个动物角色项）
  - [x] SubTask 3.3: 创建 DialogueHistoryPanel 组件（显示对话历史）
  - [x] SubTask 3.4: 创建 MessageBubble 组件（单个消息气泡）
  - [x] SubTask 3.5: 创建 MessageInputBox 组件（消息输入框）

- [x] Task 4: 实现角色选择和切换功能
  - [x] SubTask 4.1: 实现角色点击选择逻辑
  - [x] SubTask 4.2: 实现角色选中状态视觉反馈
  - [x] SubTask 4.3: 实现角色切换时的对话历史更新
  - [x] SubTask 4.4: 实现角色信息显示面板

- [x] Task 5: 集成对话系统
  - [x] SubTask 5.1: 在聊天室场景中创建 NPCDialogue 节点
  - [x] SubTask 5.2: 实现与 DialogueManager 的集成
  - [x] SubTask 5.3: 实现消息发送和接收逻辑
  - [x] SubTask 5.4: 实现对话历史记录和显示
  - [x] SubTask 5.5: 实现流式消息显示效果

- [x] Task 6: 实现多角色并发对话
  - [x] SubTask 6.1: 为每个动物创建独立的 NPCDialogue 实例
  - [x] SubTask 6.2: 实现每个角色的独立对话上下文管理
  - [x] SubTask 6.3: 实现角色切换时的对话状态保持
  - [x] SubTask 6.4: 实现多角色对话历史的独立存储

- [ ] Task 7: 添加音效和动画
  - [ ] SubTask 7.1: 添加消息发送音效
  - [ ] SubTask 7.2: 添加消息接收音效
  - [ ] SubTask 7.3: 添加 UI 元素过渡动画
  - [ ] SubTask 7.4: 添加消息淡入动画
  - [ ] SubTask 7.5: 添加角色选中动画

- [x] Task 8: 创建动物头像资源引用
  - [x] SubTask 8.1: 为每个动物配置头像资源路径
  - [x] SubTask 8.2: 创建头像资源预览
  - [x] SubTask 8.3: 实现头像加载和显示逻辑

- [x] Task 9: 实现场景管理和清理
  - [x] SubTask 9.1: 实现场景进入时的初始化逻辑
  - [x] SubTask 9.2: 实现场景退出时的清理逻辑
  - [x] SubTask 9.3: 实现对话会话的自动结束
  - [x] SubTask 9.4: 实现资源的释放和清理

- [ ] Task 10: 测试和优化
  - [ ] SubTask 10.1: 测试场景切换功能
  - [ ] SubTask 10.2: 测试角色选择和切换功能
  - [ ] SubTask 10.3: 测试对话发送和接收功能
  - [ ] SubTask 10.4: 测试多角色并发对话
  - [ ] SubTask 10.5: 测试音效和动画效果
  - [ ] SubTask 10.6: 优化性能和用户体验

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 1]
- [Task 4] depends on [Task 3]
- [Task 5] depends on [Task 2, Task 3]
- [Task 6] depends on [Task 5]
- [Task 7] depends on [Task 3, Task 5]
- [Task 8] depends on [Task 2]
- [Task 9] depends on [Task 5, Task 6]
- [Task 10] depends on [Task 4, Task 5, Task 6, Task 7, Task 8, Task 9]
