extends HitBox
class_name DamageHitBox

export(int) var damageFlags
export(int) var damageAmount


func _init(damAmount:int = 0, flags:int = 0) -> void:
	._init()
	
	damageFlags = flags
	damageAmount = damAmount



func can_trigger(object:Node)->bool:#Virtual check to filter targets and other sheneanigans
	if !object.has_method("take_damage"):
		return true		
	return false
	
func _trigger(object):
	object.take_damage(damageAmount,damageFlags)

	
		
