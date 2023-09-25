extends ComponentNode
class_name NodeComponentCounter

signal ran_out
signal counter_remaining(amount:float)

var counterLeft:float:
	set(val):
		counterLeft = val
		if counterLeft <= 0:
			set_process(false)
		else:
			set_process(false)
			
func set_counterLeft(amount:float):
	counterLeft = amount
			
func _process(delta: float) -> void:
	counterLeft-=delta
	counter_remaining.emit(clamp(counterLeft,0,2147483648))
