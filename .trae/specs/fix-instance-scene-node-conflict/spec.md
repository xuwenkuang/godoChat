# 修复实例化场景节点引用冲突 Spec

## Why
当 `AnimalCharacterList` 场景被实例化到 `AnimalChatroomScene` 中时，父场景中的实例节点设置了 `unique_name_in_owner = true`，这改变了节点所有者关系，导致 `AnimalCharacterList` 脚本无法通过 `%CharacterListContainer` 找到子节点。

## What Changes
- 在 `animal_chatroom_scene.tscn` 中移除 `AnimalCharacterList` 实例节点的 `unique_name_in_owner = true` 属性
- 确保 `AnimalCharacterList` 场景内部的节点引用能够正常工作

## Impact
- Affected specs: fix-character-list-node-references
- Affected code: `scenes/scene/animal_chatroom_scene/animal_chatroom_scene.tscn`

## ADDED Requirements
### Requirement: 实例节点唯一性配置
当场景被实例化到父场景中时，如果该场景内部使用了 `%` 语法引用子节点，则父场景中的实例节点不应设置 `unique_name_in_owner = true`，以避免节点所有者关系冲突。

#### Scenario: 成功避免节点引用冲突
- **WHEN** 移除父场景中实例节点的 `unique_name_in_owner = true` 属性
- **THEN** 子场景内部的 `%` 语法引用能够正常工作，不再报错 "Node not found"

## MODIFIED Requirements
无

## REMOVED Requirements
无
