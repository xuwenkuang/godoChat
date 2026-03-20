### 📁 项目整体架构

这是一个基于 **Godot 4.3** 的SLG（策略类）游戏模板项目，采用了模块化设计，包含以下主要模块：

---

### 🔄 Autoload 自动加载模块

#### 1. **Data** ([data.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/data/data.gd))
- **功能**：数据管理器，负责游戏存档系统的核心功能
- **特点**：
  - 自动保存和加载游戏数据
  - 支持元数据和游戏数据分离
  - JSON格式存储，支持加密
  - 自动保存机制（可配置间隔）

#### 2. **SignalBus** ([signal_bus.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/signal_bus/signal_bus.gd))
- **功能**：全局信号总线，用于跨场景、跨层级的事件通信
- **用途**：语言切换、游戏状态变化、UI更新等全局事件

#### 3. **Configuration** ([configuration.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/configuration/configuration.gd))
- **功能**：配置管理器，管理游戏运行时配置
- **特点**：通过INI文件持久化，支持运行时修改

#### 4. **Overlay** ([overlay.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/overlay/overlay.gd))
- **功能**：全局覆盖层容器
- **用途**：显示FPS计数器等全局UI元素

#### 5. **SceneManagerWrapper** ([scene_manager_wrapper.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/wrapper/scene_manager_wrapper/scene_manager_wrapper.gd))
- **功能**：场景管理器包装器
- **特点**：使用枚举标识场景，类型安全，统一管理场景切换

#### 6. **AudioManagerWrapper** ([audio_manager_wrapper.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/wrapper/audio_manager_wrapper/audio_manager_wrapper.gd))
- **功能**：音频管理器包装器
- **特点**：封装Resonate插件，支持音乐和音效管理

#### 7. **LogWrapper** ([log_wrapper.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/wrapper/log_wrapper/log_wrapper.gd))
- **功能**：日志包装器
- **特点**：支持日志分组、级别控制、模块化日志管理

#### 8. **ResourceReference** ([resource_reference.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/reference/resource_reference/resource_reference.gd))
- **功能**：资源引用管理器
- **特点**：自动预加载.tres资源，字典存储快速访问

#### 9. **AssetReference** ([asset_reference.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/reference/asset_reference/asset_reference.gd))
- **功能**：资源预加载器
- **特点**：编译时预加载常用资源，无运行时开销

#### 10. **TranslationServerWrapper** ([translation_server_wrapper.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/wrapper/translation_server_wrapper/translation_server_wrapper.gd))
- **功能**：翻译服务器包装器
- **特点**：支持多语言分隔符、编辑器预览、修复Godot翻译问题

---

### 🎬 Scenes 场景模块

#### 1. **MainMenu** ([main_menu.gd](file:///Users/mac/project/godot/slg-takin-game-template/scenes/scene/menu_scene/main_menu/main_menu.gd))
- **功能**：主菜单场景
- **特点**：显示游戏信息、提供导航入口、支持多语言

#### 2. **GameScene** ([game_scene.gd](file:///Users/mac/project/godot/slg-takin-game-template/scenes/scene/game_scene/game_scene.gd))
- **功能**：游戏场景容器
- **特点**：管理游戏暂停/继续、提供游戏内选项、支持返回主菜单

#### 3. **BootSplashScene** ([boot_splash_scene.gd](file:///Users/mac/project/godot/slg-takin-game-template/scenes/scene/boot_splash_scene/boot_splash_scene.gd))
- **功能**：启动画面场景
- **特点**：显示Logo、自动切换场景

---

### 🧩 Components 组件模块

#### 1. **ButtonAudio** ([button_audio.gd](file:///Users/mac/project/godot/slg-takin-game-template/scenes/component/audio/button_audio/button_audio.gd))
- **功能**：按钮音频组件
- **特点**：自动为按钮添加音效，智能过滤重复触发

#### 2. **ParticleEmitter** ([particle_emitter.gd](file:///Users/mac/project/godot/slg-takin-game-template/scenes/component/emitter/particle_emitter/particle_emitter.gd))
- **功能**：粒子发射器组件
- **特点**：将任意场景转换为粒子效果，支持自定义材质

#### 3. **ParticleTween** ([particle_tween.gd](file:///Users/mac/project/godot/slg-takin-game-template/scenes/component/tween/particle_tween/particle_tween.gd))
- **功能**：粒子补间组件
- **特点**：使用Tween模拟粒子，性能优于完整粒子发射器

---

### 🛠️ Scripts 工具脚本模块

#### 1. **MathUtils** ([math_utils.gd](file:///Users/mac/project/godot/slg-takin-game-template/scripts/util/math_utils.gd))
- **功能**：数学工具类
- **特点**：提供对数、幂运算、进制转换等数学函数

#### 2. **StringUtils** ([string_utils.gd](file:///Users/mac/project/godot/slg-takin-game-template/scripts/util/string_utils.gd))
- **功能**：字符串工具类
- **特点**：字符串验证、清理、转换等常用操作

#### 3. **NodeUtils** ([node_utils.gd](file:///Users/mac/project/godot/slg-takin-game-template/scripts/util/node_utils.gd))
- **功能**：节点工具类
- **特点**：节点查找、添加、删除、遍历等操作

#### 4. **LinkedMap** ([linked_map.gd](file:///Users/mac/project/godot/slg-takin-game-template/scripts/object/linked_map/linked_map.gd))
- **功能**：有序映射数据结构
- **特点**：保持插入顺序的字典，支持按值排序

---

### 📋 配置管理模块

#### 1. **ConfigurationControllerLoader** ([configuration_controller_loader.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/configuration/configuration_controller_loader/configuration_controller_loader.gd))
- **功能**：配置控制器加载器
- **特点**：自动映射枚举到配置控制器，类型安全

#### 2. **ConfigurationController** ([_configuration_controller.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/configuration/configuration_controller/_configuration_controller/_configuration_controller.gd))
- **功能**：配置控制器基类
- **特点**：管理单个配置项的保存、加载和应用

---

### 💾 存档数据模块

#### 1. **GameSaveData** ([game_save_data.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/data/save_data/game_save_data/game_save_data.gd))
- **功能**：游戏数据存档
- **特点**：存储实际游戏进度，支持自动保存

#### 2. **MetaSaveData** ([meta_save_data.gd](file:///Users/mac/project/godot/slg-takin-game-template/autoload/data/save_data/meta_save_data/meta_save_data.gd))
- **功能**：元数据存档
- **特点**：存储存档文件信息（文件名、游戏时长等）

---

### ✨ 项目特点

1. **模块化设计**：各模块职责清晰，易于维护和扩展
2. **类型安全**：大量使用枚举替代字符串，减少错误
3. **自动化管理**：自动加载、自动保存、自动映射
4. **性能优化**：资源预加载、补间动画替代粒子系统
5. **国际化支持**：完整的多语言支持系统
6. **配置灵活**：支持运行时修改配置，INI文件持久化
7. **日志完善**：分组日志系统，便于调试

所有核心模块都已添加详细的中文注释，包括功能说明、使用方式、设计特点等，方便后续开发和维护。