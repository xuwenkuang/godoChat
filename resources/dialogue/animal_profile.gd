class_name AnimalProfile
extends Resource

@export var inventory: Dictionary = {}

func add_item(item: String, quantity: int = 1) -> bool:
	if item.is_empty():
		return false
	if quantity <= 0:
		return false
	
	if inventory.has(item):
		inventory[item] += quantity
	else:
		inventory[item] = quantity
	return true

func remove_item(item: String, quantity: int = 1) -> bool:
	if not inventory.has(item):
		return false
	
	if quantity <= 0:
		return false
	
	if quantity >= inventory[item]:
		inventory.erase(item)
	else:
		inventory[item] -= quantity
	return true

func has_item(item: String) -> bool:
	return inventory.has(item) and inventory[item] > 0

func get_item_quantity(item: String) -> int:
	if inventory.has(item):
		return inventory[item]
	return 0

func get_inventory() -> Dictionary:
	return inventory.duplicate()

func get_inventory_size() -> int:
	return inventory.size()

func get_total_items() -> int:
	var total: int = 0
	for item: int in inventory.values():
		total += item
	return total

func clear_inventory() -> void:
	inventory.clear()

func get_inventory_as_string() -> String:
	if inventory.is_empty():
		return "空"
	
	var items: Array[String] = []
	for item: String in inventory:
		var quantity: int = inventory[item]
		if quantity > 1:
			items.append("%s x%d" % [item, quantity])
		else:
			items.append(item)
	
	return ", ".join(items)
