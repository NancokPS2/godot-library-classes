extends ComponentNode
class_name NodeComponentHealth

signal health_current_changed(amount:float)
signal health_damaged
signal health_healed
signal health_depleted

@export var healthCurrent:float = 100
@export var healthMax:float = 100

@export_category("Settings")
@export var invulnerable:bool
@export var allowNegative:bool

func change_current(amount:float):
	var changed:float = amount
	
	if changed < 0: 
		health_damaged.emit()
	else: 
		health_healed.emit()

	healthCurrent += changed
	if not allowNegative: 
		healthCurrent = clamp(healthCurrent, 0, healthMax)

	health_current_changed.emit(changed)
		
	if healthCurrent <= 0:
		health_depleted.emit()

func take_damage(amount:float):
	change_current(-amount)

func heal(amount:float):
	change_current(amount)
