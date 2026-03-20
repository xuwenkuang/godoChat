# 修复动物聊天室场景黑屏问题 Spec

## Why
动物聊天室场景进入后黑屏，原因是场景文件存在多个资源引用错误和配置问题。

## What Changes
- 修复 tscn 文件中缺失的音频资源引用
- 修复 ChatroomScreen 默认可见性设置
- 添加缺失的 NPCDialoguesContainer 节点
- 确保 StartScreen 默认可见

## Impact
- Affected specs: create-animal-chatroom-demo
- Affected code: animal_chatroom_scene.tscn

## ADDED Requirements
### Requirement: 场景资源正确加载
场景文件 SHALL 正确引用所有外部资源，避免加载失败。

#### Scenario: 音频资源加载
- **WHEN** 场景加载时
- **THEN** 音频资源应正确引用并加载

#### Scenario: 场景初始显示
- **WHEN** 用户进入动物聊天室场景
- **THEN** 应显示 StartScreen 开始界面而非黑屏

## MODIFIED Requirements
### Requirement: 场景文件结构
场景文件 SHALL 包含完整的节点结构和正确的资源引用。

## REMOVED Requirements
无
