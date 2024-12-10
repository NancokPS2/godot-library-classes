extends CharacterBody3D
class_name Entity

signal equipped_item(item:Item)
signal dropped_item(item:Item)
signal mesh_of_item_held_update(mesh:Mesh)

const SaveableProperties:Array[String] = [] #["position","equipped"]



@export var entityName:String
@export_group("Vitals")
#@export var maxHealth:int=100
#@export var health:int=100
@export var health:HealthComp

@export_range(0,10,0.00001) var maxOxygen:float=0.27
@export_range(0,10,0.00001) var oxygen:float=0.27:
	set(val):
		oxygen = clamp(val,0,maxOxygen)

@export_group("Equipment")
@export var handLocation:=Vector3.ZERO
@export var inventory:=Inventory.new()
#var defaultEquip:Tool = ToolHand.new()
var equipped:Item:
	set = equip,
	get = get_equipped

var updateTimer:=Timer.new()

var currentArea:RoomArea

func _ready() -> void:
	add_child(updateTimer)
	updateTimer.timeout.connect(periodic_updates)
	updateTimer.start(Const.DEFAULT_UPDATE_RATE)
	pass
func _init() -> void:
	collision_layer = Global.Layers.ENTITY + Global.Layers.MAIN
	collision_mask = Global.Layers.ENTITY + Global.Layers.MAIN
	pass

func periodic_updates():
	var breathAmount:float = 0.002
	if currentArea is RoomArea and is_atmosphere_breathable(currentArea.atmosphere):
		
		if oxygen<maxOxygen: breathAmount*=5
		oxygen += breathAmount
		currentArea.atmosphere.gasComposition.OXYGEN -= breathAmount
	else:
		oxygen-=breathAmount



func get_equipped():
	if equipped and not is_instance_valid(equipped): 
		return null
	else: 
		return equipped
	
func equip(item:Item):
#		if equipped != defaultEquip:#If not the default equipment (usually hands)
#			if storeInInv:
#				var canStore:bool = inventory.store_item(equipped) #Try to store it in the inventory
#				if not canStore: drop(equipped)#If it can't, drop it.
#		if equipped is Item and equipped.must_unequip.is_connected(unequip): equipped.must_unequip.disconnect(unequip)
		#Remove previously equipped item, if there's any
		var previousItem:Item = equipped
		equipped = item
		
		if previousItem is Item: 
			previousItem.freeze = false
			unequip()
			remove_child(previousItem)
		
		if equipped is Item: 
			equipped.freeze = true
			equipped.position = handLocation
			add_child(equipped)
			emit_signal("equipped_item",item)
			emit_signal("mesh_of_item_held_update",item.mesh)
		
		if equipped is Tool: 
			equipped._equipped()
#		if equipped is Item: equipped.must_unequip.connect(unequip.bind(false))
			

func equip_from_slot(slot:int, _inventory:Inventory=inventory):
	equipped = _inventory.contents[slot]
	pass
#func equip(item:Item):
#	if equipped != defaultTool:

func unequip(toInventory:bool=true):
	var itemToUnequip:Item
	if equipped is Item:
		itemToUnequip = equipped; equipped = null
	else:
		itemToUnequip = equipped
	
	if toInventory:
		var success:bool = inventory.store_item(itemToUnequip)
		if not success: drop(itemToUnequip)
	else: drop(itemToUnequip)
	
#	if inventory.is_full() or not toInventory:
#		drop(itemToUnequip)
#	else:
#		inventory.store_item(itemToUnequip)
#	if equipped != defaultEquip and toInventory:#If not the default equipment (usually hands)
#		var canStore:bool = inventory.store_item(equipped) #Try to store it in the inventory
#		if not canStore: drop(equipped)#If it can't, drop it.
#
#	if equipped is Tool: equipped._unequipped()
#	equipped = defaultEquip
	
func drop(item:Item):
	#Set the item to drop
#	if equipped is ToolHand and equipped.held: itemToDrop = equipped.held; equipped.held = null
#	elif equipped is ToolHand: itemToDrop = null
#	else: itemToDrop = equipped
	
#	if itemToDrop==null: push_error("Tried to drop null item!"); return
#	#Set default as equipped
#	equip(defaultEquip)
	
	#Remove the item from whatever parent it has and throw it in the world
	if not item is Item: push_error("Tried to drop non-item."); return
	if item.get_parent(): item.get_parent().remove_child(item)
	item.position = position + Vector3.UP
	add_sibling(item)
	equipped = null
	
	print("Item dropped.")
	if item is Item: emit_signal("dropped_item", item)
	
func pick_up(what:Item):
	if not what is Item: push_warning("Cannot find an item"); return
	if equipped != null: push_error("Your hands are full!"); return
	
	what.get_parent().remove_child(what)
	equipped = what
	emit_signal("mesh_of_item_held_update", what.mesh)

func is_atmosphere_breathable(atmos:Atmosphere)->bool:
	if atmos.gasComposition.OXYGEN>maxOxygen: return true
	else: return false
