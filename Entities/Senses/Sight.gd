extends Area2D
class_name SightArea

var collision:CollisionShape2D = CollisionShape2D.new()
var shape:ConvexPolygonShape2D = ConvexPolygonShape2D.new()
var sightLine:RayCast2D = RayCast2D.new()
var detectionInterval:Timer = Timer.new()

func _init(sightRange:float=500,sightWidth:int=35,detectFrequency:float=0.1, col_mask:int=0, col_layer:int=0) -> void:
	monitorable = false
	set_name("Sight")
	collision.shape = shape#Put the shape in the collision
	set_sight(sightRange,sightWidth)
	detectionInterval.wait_time = detectFrequency

func _ready() -> void:
			
	add_child(collision)#Add the collision
	add_child(sightLine)#Add the check
	add_child(detectionInterval)
	
	connect("body_entered",self,"sight_check")#Connect it

func set_sight(sightRange:int,sightWidth:int):
	shape.points.resize(0)
	shape.points.append(Vector2.ZERO)
	shape.points.append(Vector2(sightRange,sightWidth))
	shape.points.append(Vector2(sightRange,-sightWidth))
	
signal object_spotted
func sight_check(spottedObject):
	sightLine.enabled = true
	sightLine.cast_to = spottedObject.position
	sightLine.force_raycast_update()
	
	while sightLine.is_colliding():#As long as there is something to collide with
		var collider = sightLine.get_collider()
		
		if collider.get("properties") && Structure.PropertyFlags.TRANSPARENT:#If it collided with something transparent
			sightLine.add_exception(collider)#Ignore the transparent spottedObject
			sightLine.force_raycast_update()#Check again
			
		elif collider != spottedObject:#If it collides with something other than the spottedObject
			return false
		
		else:
			emit_signal("object_spotted",spottedObject)
			return true
			
func sight_check_all()->Array:
	var seenBodies:Array
	for body in get_overlapping_bodies():
		if sight_check(body) == true:
			seenBodies.append(body)
	return seenBodies

func auto_check(enabled:bool):
	if enabled:
		detectionInterval.start()
	else:
		detectionInterval.stop()
		
func set_interval(value:float):
	detectionInterval.time_left = value
