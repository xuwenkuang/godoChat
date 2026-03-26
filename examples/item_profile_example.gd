class_name ItemProfileExample
extends Node

func _ready() -> void:
	print("=== 物品信息管理系统示例 ===\n")
	
	_create_and_register_sample_items()
	_test_item_profile_manager()
	_test_item_tooltip_system()
	
	print("\n=== 示例完成 ===")

func _create_and_register_sample_items() -> void:
	print("1. 创建并注册示例物品")
	
	var manager: ItemProfileManager = ItemProfileManager.new()
	add_child(manager)
	
	var banana: ItemProfile = ItemProfile.new()
	banana.item_id = "banana"
	banana.item_name = "香蕉"
	banana.description = "一种美味的热带水果，富含钾元素"
	banana.usage = "食用可恢复体力"
	banana.rarity = ItemProfile.ItemRarity.COMMON
	banana.item_type = ItemProfile.ItemType.CONSUMABLE
	banana.value = 5
	banana.weight = 0.2
	banana.is_consumable = true
	banana.properties = {"恢复体力": 20, "饱食度": 10}
	banana.custom_tags = ["水果", "食物"]
	manager.register_item_profile(banana)
	print("   ✓ 注册物品: 香蕉")
	
	var apple: ItemProfile = ItemProfile.new()
	apple.item_id = "apple"
	apple.item_name = "苹果"
	apple.description = "红彤彤的苹果，清脆可口"
	apple.usage = "食用可恢复少量体力"
	apple.rarity = ItemProfile.ItemRarity.COMMON
	apple.item_type = ItemProfile.ItemType.CONSUMABLE
	apple.value = 3
	apple.weight = 0.15
	apple.is_consumable = true
	apple.properties = {"恢复体力": 15, "饱食度": 8}
	apple.custom_tags = ["水果", "食物"]
	manager.register_item_profile(apple)
	print("   ✓ 注册物品: 苹果")
	
	var water_bottle: ItemProfile = ItemProfile.new()
	water_bottle.item_id = "water_bottle"
	water_bottle.item_name = "水壶"
	water_bottle.description = "一个便携的水壶，可以储存饮用水"
	water_bottle.usage = "在旅途中提供水源"
	water_bottle.rarity = ItemProfile.ItemRarity.UNCOMMON
	water_bottle.item_type = ItemProfile.ItemType.GENERAL
	water_bottle.value = 20
	water_bottle.weight = 0.5
	water_bottle.properties = {"容量": 500, "耐久度": 100}
	water_bottle.custom_tags = ["容器", "生存"]
	manager.register_item_profile(water_bottle)
	print("   ✓ 注册物品: 水壶")
	
	var magic_sword: ItemProfile = ItemProfile.new()
	magic_sword.item_id = "magic_sword"
	magic_sword.item_name = "魔法剑"
	magic_sword.description = "一把散发着神秘光芒的剑，蕴含强大的魔法力量"
	magic_sword.usage = "攻击敌人，造成魔法伤害"
	magic_sword.effect = "造成 50-80 点魔法伤害"
	magic_sword.rarity = ItemProfile.ItemRarity.LEGENDARY
	magic_sword.item_type = ItemProfile.ItemType.WEAPON
	magic_sword.value = 1000
	magic_sword.weight = 3.5
	magic_sword.required_level = 10
	magic_sword.properties = {"攻击力": 60, "魔法攻击": 40, "攻击速度": 1.2}
	magic_sword.custom_tags = ["武器", "魔法", "传说"]
	manager.register_item_profile(magic_sword)
	print("   ✓ 注册物品: 魔法剑")
	
	var quest_key: ItemProfile = ItemProfile.new()
	quest_key.item_id = "quest_key"
	quest_key.item_name = "古老钥匙"
	quest_key.description = "一把生锈的古老钥匙，上面刻着神秘的符文"
	quest_key.usage = "用于开启神秘的宝箱"
	quest_key.rarity = ItemProfile.ItemRarity.RARE
	quest_key.item_type = ItemProfile.ItemType.KEY
	quest_key.value = 0
	quest_key.weight = 0.1
	quest_key.is_quest_item = true
	quest_key.custom_tags = ["任务物品", "钥匙"]
	manager.register_item_profile(quest_key)
	print("   ✓ 注册物品: 古老钥匙")
	
	print("   总共注册了 %d 个物品\n" % manager.get_item_count())
	
	manager.queue_free()

func _test_item_profile_manager() -> void:
	print("2. 测试物品管理器功能")
	
	var manager: ItemProfileManager = ItemProfileManager.new()
	add_child(manager)
	
	var banana: ItemProfile = ItemProfile.new()
	banana.item_id = "banana"
	banana.item_name = "香蕉"
	banana.rarity = ItemProfile.ItemRarity.COMMON
	banana.item_type = ItemProfile.ItemType.CONSUMABLE
	banana.custom_tags = ["水果", "食物"]
	manager.register_item_profile(banana)
	
	var apple: ItemProfile = ItemProfile.new()
	apple.item_id = "apple"
	apple.item_name = "苹果"
	apple.rarity = ItemProfile.ItemRarity.COMMON
	apple.item_type = ItemProfile.ItemType.CONSUMABLE
	apple.custom_tags = ["水果", "食物"]
	manager.register_item_profile(apple)
	
	var sword: ItemProfile = ItemProfile.new()
	sword.item_id = "sword"
	sword.item_name = "剑"
	sword.rarity = ItemProfile.ItemRarity.RARE
	sword.item_type = ItemProfile.ItemType.WEAPON
	sword.custom_tags = ["武器"]
	manager.register_item_profile(sword)
	
	print("   查询物品 'banana': %s" % manager.has_item_profile("banana"))
	print("   查询物品 'orange': %s" % manager.has_item_profile("orange"))
	
	var banana_profile: ItemProfile = manager.get_item_profile("banana")
	if banana_profile:
		print("   香蕉的稀有度: %s" % banana_profile.get_rarity_name())
		print("   香蕉的类型: %s" % banana_profile.get_type_name())
	
	print("   按类型搜索(消耗品):")
	var consumables: Array[ItemProfile] = manager.search_profiles_by_type(ItemProfile.ItemType.CONSUMABLE)
	for item: ItemProfile in consumables:
		print("     - %s (%s)" % [item.item_name, item.get_rarity_name()])
	
	print("   按标签搜索(水果):")
	var fruits: Array[ItemProfile] = manager.search_profiles_by_tag("水果")
	for item: ItemProfile in fruits:
		print("     - %s" % item.item_name)
	
	print("   按稀有度搜索(稀有):")
	var rare_items: Array[ItemProfile] = manager.search_profiles_by_rarity(ItemProfile.ItemRarity.RARE)
	for item: ItemProfile in rare_items:
		print("     - %s" % item.item_name)
	
	print("   所有物品ID: %s\n" % manager.get_all_item_ids())
	
	manager.queue_free()

func _test_item_tooltip_system() -> void:
	print("3. 测试物品提示框系统")
	
	var item: ItemProfile = ItemProfile.new()
	item.item_id = "test_item"
	item.item_name = "测试物品"
	item.description = "这是一个用于测试的物品"
	item.usage = "测试用途"
	item.effect = "测试效果"
	item.rarity = ItemProfile.ItemRarity.EPIC
	item.item_type = ItemProfile.ItemType.GENERAL
	item.value = 100
	item.weight = 1.0
	item.properties = {"属性1": "值1", "属性2": "值2"}
	item.custom_tags = ["测试", "示例"]
	
	print("   物品名称: %s" % item.item_name)
	print("   物品ID: %s" % item.item_id)
	print("   稀有度: %s" % item.get_rarity_name())
	print("   类型: %s" % item.get_type_name())
	print("   描述: %s" % item.description)
	print("   用途: %s" % item.usage)
	print("   效果: %s" % item.effect)
	print("   价值: %d" % item.value)
	print("   重量: %.1f" % item.weight)
	print("   属性: %s" % item.get_all_properties())
	print("   标签: %s" % item.custom_tags)
	
	print("\n   物品摘要:")
	print(item.get_summary())
	
	print("\n   导出为字典:")
	var data: Dictionary = item.export_to_dict()
	print("   导出的键: %s" % data.keys())
	
	print("\n   克隆物品:")
	var cloned_item: ItemProfile = item.clone()
	print("   克隆物品ID: %s" % cloned_item.item_id)
	print("   克隆物品名称: %s" % cloned_item.item_name)
	
	print("\n   验证物品有效性: %s" % item.is_valid())
