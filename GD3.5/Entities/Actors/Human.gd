extends Entity
class_name Human

func _init() -> void:
	senses += EntitySenses.SIGHT + EntitySenses.HEARING

func _take_damage(amount,flags):
	if flags && Const.damageFlags.EMP:
		return
	else:
		hitPoints -= amount

