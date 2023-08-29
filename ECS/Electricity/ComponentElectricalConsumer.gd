extends ECSComponent
class_name ECSComponentElectricalConsumer

signal electricity_consumed(amount:float)

@export var electricityConsumed:float

func _component_emission():
	electricity_consumed.emit( electricityConsumed ) ##Cannot consume more than it has


