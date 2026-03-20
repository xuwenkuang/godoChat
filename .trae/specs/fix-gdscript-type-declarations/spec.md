# 修复GDScript类型声明警告 Spec

## Why
在 dialogue_manager.gd 和 model_manager.gd 文件中存在多个GDScript类型声明警告，包括变量缺少静态类型、函数缺少返回类型、参数缺少类型声明等问题，这些警告会影响代码的类型安全性和可读性。

## What Changes
- 在 dialogue_manager.gd 中为 LogWrapper 变量和 for 循环迭代变量添加静态类型
- 在 model_manager.gd 中为 _init() 函数添加返回类型
- 在 model_manager.gd 中为 LogWrapper 变量添加静态类型
- 在 model_manager.gd 中修复 cache_entry 变量声明位置问题
- 在 model_manager.gd 中为 sort_custom 函数的参数添加类型声明

## Impact
- Affected specs: 无
- Affected code: autoload/dialogue_manager/dialogue_manager.gd, autoload/model_manager/model_manager.gd

## ADDED Requirements
### Requirement: GDScript类型声明完整性
所有GDScript文件中的变量、函数参数和函数返回值都应该有明确的静态类型声明，以确保类型安全和代码可读性。

#### Scenario: 成功添加类型声明
- **WHEN** 为缺少类型的变量、参数和函数添加静态类型声明
- **THEN** GDScript类型检查警告消失，代码具有更好的类型安全性

## MODIFIED Requirements
无

## REMOVED Requirements
无
