extends ProgressBar
class_name ProgressBarNumbered

export (bool) var displayCurrentAndMax = true
var label:Label = Label.new()

func _ready() -> void:
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	add_child(label)
	connect("changed",self,"display_as_number")
	connect("value_changed",self,"display_as_number")
	enable_numbers(displayCurrentAndMax)
	pass
	
func enable_numbers(enable:bool):
	if enable:
		display_as_number()
	else:
		label.hide()
		percent_visible = true

func display_as_number():
	percent_visible = false
	label.text = str(value + max_value)
	pass
