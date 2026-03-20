# 修复动物头像显示问题 Spec

## Why
动物聊天室界面中无法正确显示动物头像，原因是 CharacterItem 组件的节点使用了 `unique_name_in_owner = true`，导致 `%` 相对路径引用失败。

## What Changes
- 修复 CharacterItem 场景文件中的节点引用问题
- 移除不必要的 `unique_name_in_owner = true` 属性
- 确保 avatar_texture 正确显示

## Impact
- Affected specs: create-animal-chatroom-demo
- Affected code: character_item.tscn, character_item.gd

## ADDED Requirements
### Requirement: 动物头像正确显示
系统 SHALL 在聊天室界面中正确显示所有动物头像。

#### Scenario: 角色列表显示
- **WHEN** 用户进入聊天室界面
- **THEN** 应显示所有动物角色及其头像

## MODIFIED Requirements
### Requirement: CharacterItem 组件
CharacterItem 组件 SHALL 正确引用所有子节点。

## REMOVED Requirements
无
