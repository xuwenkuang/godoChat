class_name AnimalProfileExample
extends Node

func _ready() -> void:
	print("=== 小动物背包系统示例 ===\n")
	
	var elephant: ElephantProfile = ElephantProfile.new()
	var panda: PandaProfile = PandaProfile.new()
	var rabbit: RabbitProfile = RabbitProfile.new()
	
	print("1. 大象的背包")
	elephant.add_item("香蕉", 3)
	elephant.add_item("苹果", 2)
	elephant.add_item("水壶", 1)
	print("   背包内容: %s" % elephant.get_inventory_as_string())
	print("   背包种类数: %d" % elephant.get_inventory_size())
	print("   背包总物品数: %d\n" % elephant.get_total_items())
	
	print("2. 熊猫的背包")
	panda.add_item("竹子", 5)
	panda.add_item("竹子", 3)
	print("   背包内容: %s" % panda.get_inventory_as_string())
	print("   竹子数量: %d" % panda.get_item_quantity("竹子"))
	print("   背包种类数: %d\n" % panda.get_inventory_size())
	
	print("3. 兔子的背包")
	rabbit.add_item("胡萝卜", 2)
	rabbit.add_item("青菜", 1)
	print("   背包内容: %s" % rabbit.get_inventory_as_string())
	print("   背包总物品数: %d\n" % rabbit.get_total_items())
	
	print("4. 检查大象是否有苹果")
	print("   结果: %s" % elephant.has_item("苹果"))
	print("   苹果数量: %d\n" % elephant.get_item_quantity("苹果"))
	
	print("5. 移除大象的1个香蕉")
	if elephant.remove_item("香蕉", 1):
		print("   移除成功")
		print("   新的背包内容: %s" % elephant.get_inventory_as_string())
		print("   剩余香蕉数量: %d\n" % elephant.get_item_quantity("香蕉"))
	else:
		print("   移除失败\n")
	
	print("6. 移除大象的所有苹果")
	if elephant.remove_item("苹果", 10):
		print("   移除成功")
		print("   新的背包内容: %s\n" % elephant.get_inventory_as_string())
	else:
		print("   移除失败\n")
	
	print("7. 移除大象的所有水壶")
	if elephant.remove_item("水壶", 1):
		print("   移除成功")
		print("   新的背包内容: %s\n" % elephant.get_inventory_as_string())
	else:
		print("   移除失败\n")
	
	print("=== 示例完成 ===")
