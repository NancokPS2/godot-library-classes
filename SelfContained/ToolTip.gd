extends Panel
class_name Tooltip

@export var dimensions:Vector2 = Vector2(80,40):
	set(value):
		dimensions = value
		custom_minimum_size = dimensions
		if label: label.custom_minimum_size = dimensions
@export var assignedNode:Control:
	set(value):
		assignedNode = value
		connect_signals()
@export var text:String:
	set(value):
		if label: 
			text = value
			label.text = text
			update_dimensions()
			
var label:=Label.new()

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE; label.mouse_filter = MOUSE_FILTER_IGNORE
	custom_minimum_size = dimensions; label.custom_minimum_size = dimensions
	label.reset_size(); reset_size()
	
	if assignedNode is Control:
		connect_signals()
	else:
		push_error("Non-Control node assigned!")

func connect_signals():
	assignedNode.mouse_entered.connect(appear.bind(true))
	assignedNode.mouse_exited.connect(appear.bind(false))

func appear(value):
	visible = value
	set_process(value)
	
func update_dimensions():
	dimensions = Vector2(dimensions.x, label.get_line_count() * label.get_line_height()) 

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()


