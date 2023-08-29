extends ECS
class_name ECSComponent

const NOTIFICATION_EMISSION:int = 15000

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_EMISSION:
			_component_emission()
	pass

func component_emission():
	notification(NOTIFICATION_EMISSION)
#	_component_emission()

func _component_emission():
	pass
