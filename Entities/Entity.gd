extends KinematicBody2D
class_name Entity

const EntitySenses = {
	"HEARING":1<<1,
	"SIGHT":1<<2,
	"ELECTRIC":1<<3,
	"HEATSIGHT":1<<4
	}
	
const EntityProperties = {
	"INVULNERABLE":1<<1,
	"TAKEFRIENDLYFIRE":1<<2
	}

var hitPoints
export (Dictionary) var senses = {
	"sight":0,
	"hearing":0,
	"smell":0,
	"heatSight":0
}
export (int) var properties
export (Array,String) var factions

var inventory:Array
var holding:Node

var reachArea:Area2D = Area2D.new()
var reachBubble:CollisionShape2D = CollisionShape2D.new()
export (float) var reach = 200



func _ready() -> void:
	add_reach_bubble()
	manifest_senses()
	post_ready()

func post_ready():
	pass

#Senses
func manifest_senses():
	
	if get_node_or_null("Senses") == null:#Create senses node if not there
		var node = Node.new()
		node.set_name("Senses")
		add_child(node)
	
	for child in $Senses.get_children():#Remove all existing senses
		child.queue_free()
	
	if senses.sight>0: #If it's higher than 0, create an area for it
		var area:SightArea = SightArea.new(senses.sight,senses.sight/2,0.1,collision_mask,collision_layer)
		$Senses.add_child(area)
			
var sensedEntities:Array
func sensed_entities_update():
	sensedEntities.clear()
	for sense in $Senses:
		if sense is SightArea:
			sensedEntities.append_array( sense.sight_check_all() )  
			

#Damage
signal taking_damage
func take_damage(amount:int,damageFlags:int=0):
	emit_signal("taking_damage",damageFlags)
	
	if damageFlags && Const.damageFlags.ABSOLUTE:#If absolute
		hitPoints -= amount
	_take_damage(amount,damageFlags)
	
func _take_damage(amount:int,damageFlags:int):
	pass

#Interactions

func add_reach_bubble():
	add_child(reachArea)
	var shape = CircleShape2D.new()
	shape.radius = reach
	reachBubble.shape = shape
	reachArea.add_child(reachBubble)

const actionTypes = {"PRIMARY":1,"SECONDARY":2,"TERTIARY":3,"RELOAD":4}
func use_object(object:Node = holding, actionType:String = actionTypes.PRIMARY):
	
	if object is Weapon:
		if actionType == actionTypes.PRIMARY:
			object.start_fire()
		elif actionType == actionTypes.RELOAD:
			object.start_reload()

func hold(object:Node):
	if holding != null:
		inventory.append(holding)
	holding = object
	_hold(object)

func _hold(object):
	pass

var mouseInteract
func interact(nearMouse:bool=true):
	var interactables = reachArea.get_overlapping_areas()
	var target
	var lowestDistance = reach
	if nearMouse:
		for object in interactables:#start filtering
			if get_global_mouse_position().distance_to(object.position) < lowestDistance and object.has_method("use"):
				target = object
	else:
		pass
	
	if target != null:#Use the object if it is valid
		target.use()
		
		
	
	
	pass

