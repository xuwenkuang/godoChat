---
alwaysApply: true
---
# 项目规则

## 集成插件

### 开发工具
- **format_on_save** - 保存时自动格式化代码
- **gdLinter** - GDScript代码静态检查和规范检查
- **script-ide** - 脚本编辑器增强功能
- **resources_spreadsheet_view** - 资源电子表格视图编辑器

### 功能插件
- **logger** - 统一日志系统，支持多级别日志输出
- **nobodywho** - AI对话系统，集成自然语言处理模型
- **resonate** - 音频管理系统，包含音乐和音效管理器
- **scene_manager** - 场景管理器，支持场景切换和导航

## 项目目录结构

### 核心目录
- **addons/** - 插件目录，存放所有第三方和自定义插件
- **autoload/** - 自动加载单例，全局管理器（Log、Data、DialogueManager等）
- **scenes/** - 场景文件，按功能模块划分
- **scripts/** - 脚本文件，通用脚本和工具类
- **resources/** - 资源文件，对话配置、主题、音频总线等
- **assets/** - 游戏资源，音频、字体、国际化文件等

### 功能模块
- **scenes/scene/** - 游戏场景
  - boot_splash_scene/ - 启动画面
  - menu_scene/ - 主菜单和设置菜单
  - game_scene/ - 游戏主场景
  - animal_chatroom_scene/ - 动物聊天室
  - item_config_scene/ - 物品配置场景
- **autoload/wrapper/** - 插件包装器，统一插件接口
- **resources/dialogue/** - 对话系统配置，NPC和动物角色配置

### 辅助目录
- **artifacts/** - 示例项目，如3D第一人称控制器
- **examples/** - 示例代码和配置
- **snippets/** - 代码片段和模板
- **shaders/** - 自定义着色器




