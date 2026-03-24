extends Node

func _ready() -> void:
	test_inventory_system()

func test_inventory_system() -> void:
	print("=== 测试背包系统 ===")
	
	var elephant: ElephantProfile = ElephantProfile.new()
	
	print("\n1. 测试添加物品（带数量）")
	var result: bool = elephant.add_item("香蕉", 3)
	print("添加3个香蕉: %s" % result)
	result = elephant.add_item("苹果", 2)
	print("添加2个苹果: %s" % result)
	result = elephant.add_item("香蕉", 2)
	print("再添加2个香蕉（应该累加）: %s" % result)
	
	print("\n2. 测试检查物品和数量")
	print("是否有香蕉: %s" % elephant.has_item("香蕉"))
	print("香蕉数量: %d" % elephant.get_item_quantity("香蕉"))
	print("是否有橘子: %s" % elephant.has_item("橘子"))
	print("橘子数量: %d" % elephant.get_item_quantity("橘子"))
	
	print("\n3. 测试获取背包内容")
	print("背包内容: %s" % elephant.get_inventory_as_string())
	print("背包种类数: %d" % elephant.get_inventory_size())
	print("背包总物品数: %d" % elephant.get_total_items())
	
	print("\n4. 测试移除物品（带数量）")
	result = elephant.remove_item("苹果", 1)
	print("移除1个苹果: %s" % result)
	print("剩余苹果数量: %d" % elephant.get_item_quantity("苹果"))
	
	result = elephant.remove_item("苹果", 5)
	print("移除5个苹果（应该全部移除）: %s" % result)
	print("背包中是否还有苹果: %s" % elephant.has_item("苹果"))
	
	print("\n5. 移除后的背包内容")
	print("背包内容: %s" % elephant.get_inventory_as_string())
	print("背包种类数: %d" % elephant.get_inventory_size())
	print("背包总物品数: %d" % elephant.get_total_items())
	
	print("\n6. 测试清空背包")
	elephant.add_item("葡萄", 2)
	elephant.add_item("西瓜", 1)
	print("添加葡萄和西瓜后，背包内容: %s" % elephant.get_inventory_as_string())
	elephant.clear_inventory()
	print("清空背包后，背包内容: %s" % elephant.get_inventory_as_string())
	
	print("\n7. 测试边界情况")
	print("添加空物品: %s" % elephant.add_item("", 1))
	print("添加负数数量: %s" % elephant.add_item("苹果", -1))
	print("移除不存在的物品: %s" % elephant.remove_item("橘子", 1))
	print("移除0个物品: %s" % elephant.remove_item("香蕉", 0))
	
	print("\n=== 测试完成 ===")
