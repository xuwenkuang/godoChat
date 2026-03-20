# 修复GDScript代码警告和错误 Spec

## Why
在多个GDScript文件中存在各种代码警告和错误，包括变量遮蔽、未使用参数、缺少返回类型声明以及场景实例化时的父路径问题，这些问题会影响代码质量和运行时稳定性。

## What Changes
- 在 model_manager.gd 中修复 cache_entry 变量声明位置问题
- 在 model_manager.gd 中为匿名函数添加返回类型
- 在 character_item.gd 中修复参数 name 遮蔽基类属性问题
- 在 character_info_panel.gd 中修复未使用的参数 locale
- 在 npc_dialogue.gd 中修复参数遮蔽和未使用参数问题
- 在 message_bubble.gd 中修复参数 name 遮蔽基类属性问题
- 在 message_bubble.gd 中修复未使用的参数 locale
- 修复 animal_character_list.tscn 中的场景实例化父路径问题

## Impact
- Affected specs: fix-gdscript-type-declarations
- Affected code: autoload/model_manager/model_manager.gd, scenes/component/chatroom/character_item/character_item.gd, scenes/component/chatroom/character_info_panel/character_info_panel.gd, scenes/node/dialogue/npc_dialogue/npc_dialogue.gd, scenes/component/chatroom/message_bubble/message_bubble.gd, scenes/component/chatroom/animal_character_list/animal_character_list.tscn

## ADDED Requirements
### Requirement: GDScript代码质量
所有GDScript文件应该避免变量遮蔽、未使用参数、缺少返回类型等问题，确保代码质量和类型安全。

#### Scenario: 成功修复代码警告
- **WHEN** 修复变量遮蔽、未使用参数、缺少返回类型等问题
- **THEN** GDScript警告和错误消失，代码质量提升

## MODIFIED Requirements
无

## REMOVED Requirements
无
