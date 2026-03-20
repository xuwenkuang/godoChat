# 修复角色列表节点引用问题 Spec

## Why
在 `AnimalCharacterList` 脚本中，使用 `@onready var scroll_container: ScrollContainer = %ScrollContainer` 和 `@onready var character_list_container: VBoxContainer = %CharacterListContainer` 时，Godot 无法找到这些节点，因为场景文件中的节点没有被设置为唯一节点（unique_name_in_owner）。

## What Changes
- 在 `animal_character_list.tscn` 场景文件中为 `ScrollContainer` 和 `CharacterListContainer` 节点添加 `unique_name_in_owner = true` 属性
- 确保 `@onready` 变量能够正确引用这些节点

## Impact
- Affected specs: 无
- Affected code: `scenes/component/chatroom/animal_character_list/animal_character_list.tscn`

## ADDED Requirements
### Requirement: 节点唯一性配置
场景文件中的 `ScrollContainer` 和 `CharacterListContainer` 节点必须配置为唯一节点，以便脚本能够通过 `%` 语法正确引用。

#### Scenario: 成功配置节点唯一性
- **WHEN** 在场景文件中为 `ScrollContainer` 和 `CharacterListContainer` 节点添加 `unique_name_in_owner = true` 属性
- **THEN** 脚本中的 `@onready var scroll_container: ScrollContainer = %ScrollContainer` 和 `@onready var character_list_container: VBoxContainer = %CharacterListContainer` 能够正确引用节点，不再报错

## MODIFIED Requirements
无

## REMOVED Requirements
无
