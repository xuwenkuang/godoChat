# 动物角色列表间距优化 Spec

## Why
当前动物角色列表中，动物与动物之间的间距太小（8px），导致视觉效果拥挤，动物展示效果挤在一起，影响用户体验和界面美观性。

## What Changes
- 将CharacterListContainer的separation从8px增加到10px
- 确保所有动物角色之间有足够的视觉间隔

## Impact
- Affected specs: UI布局优化
- Affected code: animal_character_list.tscn

## ADDED Requirements
### Requirement: 动物角色间距优化
系统应提供足够的动物角色间距，确保视觉清晰。

#### Scenario: 成功案例
- **WHEN** 用户查看动物角色列表
- **THEN** 每个动物角色之间应有10px的间距，视觉效果清晰舒适

## MODIFIED Requirements
### Requirement: 现有间距配置
修改CharacterListContainer的theme_override_constants/separation属性值。
