extends Area3D
class_name AdvancedArea3D

signal body_inside(body:Node3D)
signal area_inside(area:Area3D)

signal body_entered_custom(body:Node3D)
signal area_entered_custom(area:Area3D)

signal body_exited_custom(body:Node3D)
signal area_exited_custom(area:Area3D)

@export_group("Continuous Trigger")
@export var contSignal:bool = false
@export var contDetectBody:bool
@export var contDetectArea:bool

@export_group("Tags")
@export var defaultTagPropertyPath:String = "areaTags"
@export var requiredTags:Array[String]

@export_group("Debug")
@export var debugMode:bool = true:
	set(val):
		debugMode = val
		if debugMode:
			body_entered_custom.connect(printer.bind("Body entered."))
			
		else:
			if body_entered_custom.is_connected(printer):
				body_entered_custom.disconnect(printer)

func _init() -> void:
	body_entered.connect(on_body_entered)
	area_entered.connect(on_area_entered)

func _ready() -> void:
	debugMode = debugMode

func _physics_process(delta: float) -> void:
	if contSignal:
		if contDetectArea:
			for area in get_bodies_inside():
				area_inside.emit(area)
				
		if contDetectBody:
			for body in get_overlapping_bodies():
				body_inside.emit(body)
	
func check_tags(node:Node3D, tagPropertyPath:String = defaultTagPropertyPath)->bool:
	var tags:Array[String] = node.get_indexed(tagPropertyPath)
	if tags is Array[String]:
		
		
		for tag in requiredTags:
			if not tag in tags: return false
		
	else:
		push_error("The property must be of type Array[String]")
		return false
		
	return true

##########

func on_body_entered(body:Node3D):
	if check_tags(body) and _body_filter(body): body_entered_custom.emit(body)
	
func on_body_exited(body:Node3D):
	if check_tags(body) and _body_filter(body): body_entered_custom.emit(body)
	
##########

func on_area_entered(area:Area3D):
	if check_tags(area) and _area_filter(area): area_exited_custom.emit(area)

func on_area_exited(area:Area3D):
	if check_tags(area) and _area_filter(area): area_exited_custom.emit(area)

##########

func get_bodies_inside()->Array[Node3D]:
	var bodies:Array[Node3D] = get_overlapping_bodies().filter(_body_filter)
	if not requiredTags.is_empty(): bodies.filter(check_tags)
	return bodies

func get_areas_inside()->Array[Area3D]:
	var areas:Array[Area3D] = get_overlapping_areas().filter(_area_filter)
	if not requiredTags.is_empty(): areas.filter(check_tags)
	return areas

##########
	
func _body_filter(body:Node3D)->bool:
	return true
	
func _area_filter(area:Area3D):
	return true

##########

func printer(body:Node3D, text:String):
	print_debug(text)
