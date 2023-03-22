extends Area2D
class_name HitBox

export(bool) var autoTrigger = false
export(bool) var oneshot

export(int) var collisionMask
export(int) var collisionLayer

var collision:CollisionPolygon2D = CollisionPolygon2D.new()

export (Array) var shape = []

func _init() -> void:
	monitorable = false
	
	
	collision_mask = collisionMask
	collision_layer = collisionLayer
	
	collision.polygon = shape

func _ready() -> void:
	add_child(collision)
	if autoTrigger:
		connect("body_entered",self,"trigger")
	pass

func can_trigger(object:Node)->bool:#Checked when using trigger()
	return true
	
func trigger(object):#Should NOT be used
	if can_trigger(object) == false:
		return
	_trigger(object)

func _trigger(object):#Virtual method
	pass
	
		
