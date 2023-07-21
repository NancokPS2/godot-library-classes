extends HitBox
class_name HitBoxHitter

#static var HITSCAN_CLASS:Script = Hitscan
#static var HURTBOX_CLASS:Script = Hurtbox
#enum Modes {CONTINUOUS, LIMITED_TRIGGERS}

signal hit_something

const INFINITE_TRIGGERS = 999999999999999

@export var damage:float = 10

@export var freeIfNoTriggers:bool = true
@export var triggersLeft:int = INFINITE_TRIGGERS
#@export var useDefaultLayers:bool ##Puts collisions in layer 32


#func _init() -> void:
#	collision_mask = DEFAULT_LAYER
#	collision_layer = DEFAULT_LAYER
	
func trigger(hitBox:HitBoxReceiver):
	assert(hitBox is HitBoxReceiver)
	if triggersLeft != INFINITE_TRIGGERS: triggersLeft -= 1 
	
	if triggersLeft < 0 and freeIfNoTriggers: queue_free()
	elif triggersLeft < 0: monitoring = false; monitorable = false
	
	hit_something.emit(hitBox)




