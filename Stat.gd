extends Resource
class_name Stat

signal dummy_signal

signal current_changed(amount:float)
signal values_changed
signal depleted

@export var name:StringName
@export var maxVal:float:
	set(val):
		if useAsInt: maxVal = val as int
		else: maxVal = val
		values_changed.emit()
		if autoSignalOnChange is Signal: autoSignalOnChange.emit()

@export var current:float:
	set(val):
		if forceMax: current = clamp(val, 0, maxVal)
		else: current = val
		
		if useAsInt: current = current as int
		values_changed.emit()
		if autoSignalOnChange is Signal: autoSignalOnChange.emit()

@export var useAsInt:bool = false
@export var forceMax:bool = true ## WIll automatically limit currentAmount to maxAmount

@export var autoSignalOnChange:Signal

func _init(_max:float, _current:float, _name:StringName):
	maxVal = _max
	current = _current
	name = _name
#		areaUsed = _areaUsed
	
func change(amount:float, modifiers:Dictionary={}):
	current += amount
	current_changed.emit(amount)
	if current <= 0: depleted.emit()
	
func get_current_percent()->float:
	return current / maxVal
