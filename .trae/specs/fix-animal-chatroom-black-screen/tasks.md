# Tasks

- [x] Task 1: 修复场景文件资源引用错误
  - [x] SubTask 1.1: 添加缺失的音频资源外部引用 (click1.ogg, switch1.ogg)
  - [x] SubTask 1.2: 修复音频节点引用正确的 ExtResource ID

- [x] Task 2: 修复场景初始显示状态
  - [x] SubTask 2.1: 设置 StartScreen 默认可见 (visible = true)
  - [x] SubTask 2.2: 设置 ChatroomScreen 默认隐藏 (visible = false)

- [x] Task 3: 添加缺失的节点
  - [x] SubTask 3.1: 添加 NPCDialoguesContainer 节点用于存放 NPCDialogue 实例

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 1]
