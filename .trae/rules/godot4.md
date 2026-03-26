---
alwaysApply: true
---
## Godot版本
本项目使用 **Godot 4.6** 引擎开发。
## 项目特色

本项目是一个基于Godot 4.6引擎开发的游戏，集成了：
- AI驱动的对话系统（NobodyWho）
- 完整的音频管理系统（Resonate）
- 灵活的场景管理器
- 国际化支持（多语言）
- 自动保存系统
- 配置管理系统
- 物品管理系统
- NPC管理系统
- 商店管理系统（待实施）
- 家园系统（待实施）：npc可自建自己的房子
- 剧情管理系统（待实施）
- 地图管理系统（待实施）
- 肉鸽类战斗系统（待实施）
- 剧情战斗使用战旗系统（代实施）

## 开发规范

### 代码规范
- 使用gdLinter进行代码检查，确保代码质量
- 使用format_on_save自动格式化代码
- 遵循Godot 4.6的GDScript语法规范

### 资源管理
- 使用resources_spreadsheet_view编辑资源数据
- 音频资源通过resonate插件管理
- 对话配置使用NPCProfile和AnimalProfile资源类

### 场景管理
- 使用SceneManager单例管理场景切换
- 通过SceneManagerWrapper统一场景管理接口
- 支持场景预加载和缓存


