extends Node
class_name TimeControl

enum ControlModes {PHYSICS=1<<0, PROCESS=1<<1, CUSTOM_PHYSICS=1<<2, CUSTOM_PROCESS=1<<3}

@export var controlledNodes:Array[Node]

@export_flags("PHYSICS", "PROCESS") var controlMode:int=ControlModes.PROCESS:
	set(val):
		controlMode = val
		if controlMode & ControlModes.PHYSICS:
			set_physics_process(true)
		else:
			set_physics_process(false)
			
		if controlMode & ControlModes.PROCESS:
			set_process(true)
		else:
			set_process(false)
			
		if controlMode & ControlModes.CUSTOM_PROCESS:
			set_process(true)
		else:
			set_process(false)

@export_range(0,10,0.01) var timeScale:float = 1.0

@export var autoPauseControlled:bool=true

func _ready() -> void: controlMode = controlMode

func _process(delta: float) -> void:
	for node in controlledNodes: node._process(delta*timeScale)

func _physics_process(delta: float) -> void:
	for node in controlledNodes: node._physics_process(delta*timeScale)

func control_group(group:String):
	for node in get_tree().get_nodes_in_group(group):
		add_node(node)
	
func set_time_scale_deferred(scale:float):
	set.call_deferred("timeScale",scale)

func pause_all_controlled(pause:bool=true):
	if pause:
		for node in controlledNodes:
			node.process_mode = Node.PROCESS_MODE_DISABLED
		for node in controlledNodes:
			node.process_mode = Node.PROCESS_MODE_INHERIT

func add_node(node:Node):
	if autoPauseControlled:
		node.process_mode = Node.PROCESS_MODE_DISABLED
	controlledNodes.append(node)
	
	
