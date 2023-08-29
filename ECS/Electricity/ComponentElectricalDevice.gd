extends ECSComponent
class_name ECSComponentElectricalStorage

signal electricity_stored(amount:float)

@export var electricityStoredMax:float = 100
@export var electricityStored:float:
	set(val):
		electricityStored = min(val, electricityStoredMax)

func _component_emission():
	electricity_stored.emit(electricityStored)


