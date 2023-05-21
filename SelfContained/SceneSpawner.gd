extends Node3D
class_name SceneSpawner3D
## This class simply needs scenes to spawn and it will proceed to do so in a steady manner.
## By default all scenes will be spawned as a child of this spawner at it's origin.

signal spawned_node(node:Node, where:Vector3)
signal spawn_prevented_by_limit #Emmited if a spawn was attempted but the limit prevented it.

##Pauses or unpauses the spawning timer.
@export var active:bool=true:
	set(val): 
		active = val
		spawnTimer.paused = !active

## Which node will be the parent of the spawned nodes, by default the spawner will be the parent
@export var spawnParent:Node = self

## How many instances of the scene can be spawned
@export var spawnLimit:int = 5

## If true, a node's reference will be removed if it stops being a child of spawnParent. More performant when enabled.
@export var nodesMustRemainInParent:bool = true

## The time between spawns. If set to 0, the spawner stops altogheter.
@export var timing:float =  2.0:
	set(val):
		timing = val
		if spawnTimer and spawnTimer.is_inside_tree():
			if timing <= 0:
				spawnTimer.stop()
			elif spawnTimer:
				spawnTimer.start(timing)
		else:
			push_warning("The timer is not ready for use yet.")
	

	
## Sets the order of scenes to spawn. Leave empty to pick a random one.
@export var spawnOrder:Array[int] = [0]

## Private, used to track the spawnOrder
var _spawnOrderCounter:int = 0:
	set(val):
		if val < 0: push_error("This is an index so it cannot be negative.")
		elif val >= spawnOrder.size(): push_error( "Index out of bounds. spawnOrder size is {0} but the value was {1}".format([spawnOrder.size(), val]) )
		else: _spawnOrderCounter = val

## Scenes that will be spawned.
@export var scenesToSpawn:Array[PackedScene]

## Initial positions of the scenes.
@export var spawnLocations:Array[Vector3] = [Vector3.ZERO]


var spawnTimer:Timer=Timer.new()
var spawnedSceneRefs:Array[Node]


func _ready():
	add_child(spawnTimer, INTERNAL_MODE_FRONT)
	spawnTimer.timeout.connect(spawn_scene)
	timing = timing
	
## Spawns once of the scenes in any of the provided locations.
func spawn_scene():
	#spawnLimit checks
	if spawnedSceneRefs.size() >= spawnLimit:
		clean_spawn_refs()
		if spawnedSceneRefs.size() >= spawnLimit: 
			emit_signal("spawn_prevented_by_limit")
			return
	
	if spawnLocations.is_empty(): push_error("No location to spawn has been set."); return
	if not spawnParent: push_error("Cannot spawn scenes without a spawnParent set."); return
	
	var node:Node = get_next_node()
		
	node.position = spawnLocations.pick_random()
	reference_node(node)
	spawnParent.add_child(node)
	emit_signal("spawned_node", node, node.position)
	
## Check to ensure everything is ready to spawn.
func validate_spawn_order()->bool:
	if _spawnOrderCounter >= scenesToSpawn.size(): _spawnOrderCounter = 0; push_warning("_spawnOrderCounter was out of bounds, fixed but this is not intended.")
	
	var anyOutOfBounds:bool = spawnOrder.any( func(val): return val < scenesToSpawn.size())
	if anyOutOfBounds: push_error("spawnOrder has out of bounds integers. Switching to random mode."); spawnOrder = []
	else: return true
	
## Attempts to clear any invalid references. Like freed nodes.
func clean_spawn_refs():
	if nodesMustRemainInParent:
	for node in spawnedSceneRefs:
		if not node or (node and node.get_parent() != spawnParent):
			unreference_node(node)
	else:
		for node in spawnedSceneRefs:
			if not ( node and is_valid_instance(node) ): 
				unreference_node(node)
		
func unreference_node(node:Node):
	if not spawnedSceneRefs.has(node): push_error("This node is not referenced in this spawner")
	else: spawnedSceneRefs.erase(node)
	
func reference_node(node:Node):
	if spawnedSceneRefs.has(node): push_warning("This node is already referenced in this spawner.")
	else: spawnedSceneRefs.append(node)
	
func get_next_node()->Node:
	if spawnOrder.is_empty():
		var node:Node = scenesToSpawn.pick_random().duplicate().instantiate()
	else:
		if not validate_spawn_order(): return
		var node:Node = scenesToSpawn[_spawnOrderCounter].instantiate()
		_spawnOrderCounter+=1
		if _spawnOrderCounter >= scenesToSpawn.size(): _spawnOrderCounter = 0
	return node
