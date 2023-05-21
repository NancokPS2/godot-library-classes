extends Resource
class_name Inventory

signal item_store_status(message:String)
#signal item_stored_success
#signal item_stored_failure
signal item_stored_bool(success:bool)
signal contents_changed

const AUTO_SORT_SLOT:int = -1
enum ObjectFilters {TOOL, COMPONENT}


#@export var validClasses:Array[String]
@export var contents:Dictionary
@export var invSize:int = 1
@export var maxItemSize:int = 3

func _init(_invSize:int=1) -> void:
	invSize = _invSize
	
#	item_stored_failure.connect(emit_signal.bind("item_stored_bool",false))
#	item_stored_success.connect(emit_signal.bind("item_stored_bool",true))

func take_item_in_slot(slot:int)->Object:
	var item:Object = get_item_in_slot(slot)
	remove_item(item)
	return item

func take_item(item:Object)->Object:
	contents.erase( get_item_slot(item) )
	remove_item(item)
	return item

func store_item(item:Object, slot:int = AUTO_SORT_SLOT)->bool:
#	if not item or (not validClasses.is_empty() and not validClasses.has(item.get_class())): push_error("Tried to store "+ str(item) +" invalid class of object."); return false
	if not item: push_error("Tried to store "+ str(item) +" which isn't an object."); return false
	
	var spaceOccupied:int = 1
	if item.get("spaceOccupied"): spaceOccupied = item.spaceOccupied
	
	assert(contents.size() <= invSize)
	var spaceLeft:int = get_space_left()
	if get_space_left() < spaceOccupied or maxItemSize < spaceOccupied:
		emit_signal("item_store_status", "This item won't fit in the backpack!"); return false
		
	#Intercept AUTO_SORT_SLOT
	var _slot:int
	if slot == AUTO_SORT_SLOT or contents.has(slot): _slot = get_next_free_slot()
	else: _slot = slot
	
	#If the slot is still AUTO_SORT_SLOT or the slot is occupied...
	if _slot == AUTO_SORT_SLOT: 
		emit_signal("item_store_status","Could not get a free slot!"); return false
	else: 
		contents[_slot] = item; emit_signal("contents_changed"); return true#Otherwise, store it
	
	
func get_item_slot(item:Object)->int:
	var key = contents.find_key(item)
	return key
	
func get_item_in_slot(key:int)->Object:
	if contents.has(key):
		return contents[key]
	else:
		push_error("The requested slot is empty.")
		return null

func remove_item(item:Object)->bool:
	var key = contents.find_key(item)
	if key!=null: contents.erase(key); emit_signal("contents_changed"); return true
	else: return false

func remove_item_in_slot(key:int)->bool:
	if contents.has(key): contents.erase(key); emit_signal("contents_changed"); return true
	else: push_error("Tried to remove non-existant item."); return false
	
func transfer_from_slot_to_inventory(inventory:Inventory, localSlot:int, targetSlot:int = AUTO_SORT_SLOT)->bool:
	var item = get_item_in_slot(localSlot)
	var success:bool = inventory.store_item(item, targetSlot)
	
	if success: remove_item_in_slot(localSlot); return true
	else: return false
	
func get_next_free_slot()->int:
	for slot in range(invSize):
		if not contents.has(slot):
			return slot
	return AUTO_SORT_SLOT

func is_full()->bool:
	if get_space_left() <= 0: return true
	else: return false 

func get_space_left()->int:
	var spaceOccupied:int = 0
	for item in contents.values():
		if item.get("spaceOccupied"): spaceOccupied += item.spaceOccupied
		else: spaceOccupied += 1
		
	return abs(invSize-spaceOccupied)
