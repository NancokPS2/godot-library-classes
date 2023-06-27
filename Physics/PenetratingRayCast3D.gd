extends RayCast3D
class_name PenetratingRayCast3D

const Getters = {
	COLLIDER = "get_collider", 
	COL_RID = "get_collider_rid",
	COL_SHAPE = "get_collider_shape",
	COL_NORMAL = "get_collision_normal",
	COL_POINT = "get_collision_point"}

## How much penetration power it looses whenever it goes trough something, Setting it to 0 will cause it to behave like get_all_colliders, but slower.
@export var penetrationLossFactor:float

## How far it can penetrate
@export var maxPenetrationDepth:float

## How many objects it can penetrat
@export var maxChecks:int

#@export_enum("") var returnedValues:int


func get_all_colliders(details:Callable = get_collider)->Array:
#	force_raycast_update()
	assert( Getters.values().has(details.get_method()) )
	var totalDetails:Array
	
	for check in maxChecks:
		force_raycast_update()
		var currCollider:Object = get_collider()
		var currDetail = details.call()
		
		if currCollider is Object: 
			totalDetails.append(currDetail)
			add_exception(currCollider)
		
		else: break
		
	clear_exceptions()
	return totalDetails

## Uses the penetration system. Do not use with factor 0
func get_all_colliders_with_penetration(details:Callable = get_collider):
	assert( Getters.values().has(details.get_method()) )
	var totalDetails:Array
	var currPenetration:float = maxPenetrationDepth

	
	for check in maxChecks:
		force_raycast_update()
		var currCollider:Object = get_collider()
		var intersectPoint = get_collision_point()
		var currDetail = details.call()
		
		if currCollider is Object: 
			var outerEnd:Vector3 = check_back_for_point(intersectPoint+intersectPoint.normalized()*currPenetration, intersectPoint)
			var penetrationDistance:float = intersectPoint.distance_to(outerEnd)
			#Check how far it went trough
			if penetrationDistance <= currPenetration: break
			else: currPenetration -= penetrationDistance * penetrationLossFactor
			
			totalDetails.append(currDetail)
			add_exception(currCollider)
		
		else: break
		
	clear_exceptions()
	return totalDetails
	pass

func check_back_for_point(origin:Vector3, target:Vector3)->Vector3:
	var auxiliaryRayCast:=self.duplicate()
	auxiliaryRayCast.position = origin
	auxiliaryRayCast.target_position = target.inverse()
	add_child(auxiliaryRayCast)
	auxiliaryRayCast.force_raycast_update()
	return auxiliaryRayCast.get_collider()
