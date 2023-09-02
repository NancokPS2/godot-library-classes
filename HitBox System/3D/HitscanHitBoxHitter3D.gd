extends RayCast3D
class_name HitBoxHitter3DRayCast

signal hit_something(hitBox:HitBoxReceiver3D)

const INFINITE_HITS = -1

@export var damage:float = 10

@export var hitsLeft:int = INFINITE_HITS
@export var triggerFlags:Array[String]
#@export var useDefaultLayers:bool ##Puts collisions in layer 32
	
func _init() -> void:
	collide_with_areas = true
	collide_with_bodies = false
	
func _physics_process(delta: float) -> void:
#	force_shapecast_update()
	var collider:Object = get_collider()
	if collider is HitBoxReceiver3D: 
		on_touched(collider)
	
	
func on_touched(hitBox:HitBoxReceiver3D):
	assert(hitBox is HitBoxReceiver3D)
	if hitsLeft != INFINITE_HITS: 
		hitsLeft -= 1 
		if hitsLeft <= 0: enabled = false
	
	hitBox.trigger(self)
	
	hit_something.emit(hitBox)




