extends ECSComponent
class_name ECSComponentElectricalGenerator

signal electricity_generated(amount:float)

@export var electricityGenerated:float


func _component_emission():
#	super._component_emission()
	electricity_generated.emit(electricityGenerated)
	pass

