class_name WeightedTable

var _items: Array = []
var _total_weight: int = 0

# Add an item with a weight
func add_item(item, weight: int) -> void:
	_items.append({ "item": item, "weight": weight})
	_total_weight += weight

# Return an item width
func get_width(item) -> int:
	for entry in _items:
		if entry["item"] == item:
			return entry["width"]
	return 0

# Change the weight of an existing item
func change_weight(item, new_weight: int) -> bool:
	for entry in _items:
		if entry["item"] == item:
			_total_weight -= entry["weight"]
			_total_weight += new_weight
			entry["weight"] = new_weight
			return true
	return false

# Get a random item based on weights
func get_random():
	if _items.is_empty():
		return null
	
	var rand_val := randi() % _total_weight
	var cumulative_weight := 0
	
	for entry in _items:
		cumulative_weight += entry["weight"]
		if rand_val < cumulative_weight:
			return entry["item"]
	
	return null

# NEW: Reset the entire table (clear all items & weights)
func reset() -> void:
	_items.clear()  # Remove all entries
	_total_weight = 0  # Reset weight counter
