extends Node2D
class_name BodyParts

const parts = {"HAND":1}
func get_body_part(part:int)->Node:
	if part == parts.HAND:
		return $Arm
	else:
		return null
