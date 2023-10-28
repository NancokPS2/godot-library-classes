extends ComponentNode
class_name Node2DComponentAreaInteractor
## Emulates mouse_entered, mouse_exited and input_event signals on an Area2D that is within it's reach.
## As well as emit signals of it's own.  
## If the mouse goes over an erea that is both within range of the user and has no obstacles between the user and the area. The area's signals are emitted as if it was detecting inputs with input_pickable
## Area2D.input_pickable should be off for the emulation of signals to work properly, otherwise the filtering will have no effect.

signal hovered_area(area:Area2D)
signal interacted_area(area:Area2D)

const METADATA_NAME_KEYS:String = "KEY_REQUIRED_COMP"

const NO_INTERACTION:StringName = &""
const NO_KEY:String = ""

const STRING_ARRAY_EMPTY:PackedStringArray = []

@export var user:Node
@export var maxDistance:float = 300
@export var useMousePos:bool
@export_flags_2d_physics var areaDetectionMask:int = Const.Layers.INTERACT
@export_flags_2d_physics var obstacleDetectionMask:int = Const.Layers.OBSTACLE

@export var interactActions:Array[StringName] = [&"interact"]
@export var sendInputToArea:bool = true

## If an area has metadata of type METADATA_NAME_KEYS:PackedStringArray that's not empty.  
## Any interactions with it will fail unless currentKeys also has all the Strings.
@export var currentKeys:PackedStringArray

var queriedPointGlobal:Vector2


var hoveredAreas:Array[Area2D]
var hoveredAreasLastFrame:Array[Area2D]

var _directSpaceState:PhysicsDirectSpaceState2D
var _forcedInteractionInput:bool

func _is_node_valid_parent(node:Node)->bool:
	return node is Node2D

func _parent_update():	
	if targetNode:
		_directSpaceState = targetNode.get_world_2d().direct_space_state
		set_physics_process(true)
	else:
		set_physics_process(false)
		
#New funcs
func _physics_process(_delta: float) -> void:
	if useMousePos:
		queriedPointGlobal = targetNode.get_global_mouse_position()
		
	hoveredAreas = get_areas_at_point(queriedPointGlobal)
	
	if hoveredAreas.is_empty(): 
		return
	if not is_point_reachable(queriedPointGlobal): 
		return
	
	for area in hoveredAreas:
		if key_check(area):
			process_collision(area)
		else:
			push_error("Failed KEY check.")
	
	
func process_collision(area:Area2D):
	assert(area is Area2D)
	for hoveredArea in hoveredAreasLastFrame:
		if not hoveredArea in hoveredAreas:
			hoveredArea.mouse_exited.emit()
	
	if not area in hoveredAreasLastFrame:
		hovered_area.emit(area)
		area.mouse_entered.emit()
	
	var currentAction:StringName = get_current_pressed_action()
	
	if _forcedInteractionInput or currentAction in interactActions:
		assert(currentAction != NO_INTERACTION)
		interacted_area.emit(area)
		
		if sendInputToArea: 
			send_input_to_area(currentAction, area, true)
			send_input_to_area.call_deferred(currentAction, area, false)
			
	hoveredAreasLastFrame = hoveredAreas.duplicate()

func set_force_interaction(start:bool):
	_forcedInteractionInput = start
	pass

func send_input_to_area(action:StringName, area:Area2D, pressed:bool):
	var actionEvent:=InputEventAction.new()
	actionEvent.action = action
	actionEvent.strength = Input.get_action_strength(action)
	actionEvent.pressed = pressed
	area.input_event.emit(targetNode.get_viewport(),actionEvent,0)

func get_current_pressed_action()->StringName:
	for action in interactActions:
		if Input.is_action_just_pressed(action): return action
	return NO_INTERACTION

#DirectSpaceState stuff
func get_areas_at_point(globalPoint:Vector2)->Array[Area2D]:	
	var areasFound:Array[Area2D]
	
	var pointQuery:=DefaultPointQueryParams.new(globalPoint, areaDetectionMask)
	
	for collDict in _directSpaceState.intersect_point(pointQuery):
		if collDict.collider is Area2D:
			areasFound.append( collDict.collider )
			
	return areasFound
	
#Conditions
func key_check(area:Area2D)->bool:
	var keysRequired:PackedStringArray = area.get_meta(METADATA_NAME_KEYS, STRING_ARRAY_EMPTY)
	
	for key in keysRequired:
		if not currentKeys.has(key): 
			return false
			
	return true
	
func is_point_reachable(point:Vector2)->bool:
	if point.distance_to(targetNode.global_position) > maxDistance: return false
	
	var rayParams := DefaultRayQueryParams.new(point, targetNode.global_position, obstacleDetectionMask)
	var obstacleCollsion:Dictionary = _directSpaceState.intersect_ray( rayParams)
#	var obstacleCollsion:Dictionary = _directSpaceState.intersect_ray( DefaultRayQueryParams.new(targetNode.global_position, point, obstacleDetectionMask) )
	if not obstacleCollsion.is_empty(): return false
		
	return true
	





class DefaultPointQueryParams extends PhysicsPointQueryParameters2D:
	func _init(pos:Vector2, collMask:int) -> void:
		collide_with_areas = true
		collide_with_bodies = false
		collision_mask = collMask
		position = pos
		
class DefaultRayQueryParams extends PhysicsRayQueryParameters2D:
	func _init(origin:Vector2, target:Vector2, collMask:int) -> void:
		from = origin
		to = target
		collision_mask = collMask
