extends ECS
class_name ECSSystem

enum TickModes {TIMER, IDLE, PHYSICS, OFF}

const DEFAULT_PROPERTIES:Array[String] = []
const DEFAULT_TICK_RATE:float = 0.05

static var tickTimer:=Timer.new()
static var tickRate:float = DEFAULT_TICK_RATE:
	set(val):
		tickRate = val
		tickTimer.wait_time = tickRate



@export var tickMode:TickModes = TickModes.TIMER:
	set = set_tick_mode

@export var nodesToRegister:Array[Node]

@export var componentsRegistered:Dictionary


func _ready() -> void:
	ensure_timer()
	tickMode = tickMode
	register_nodes()
	
func ensure_timer():
	#Do not try anything until this node is inside the tree
	if not is_node_ready():
		ready.connect(ensure_timer, CONNECT_ONE_SHOT)
		
	#Ensure sure it exists
	if not tickTimer is Timer: 
		tickTimer = Timer.new()
	
	#Ensure it has a parent
	if not tickTimer.get_parent():
		get_tree().current_scene.add_child.call_deferred(tickTimer)
	
	if tickTimer.is_stopped():
		tickTimer.start.call_deferred(tickRate)


func set_tick_mode(mode:TickModes):
	#If not in the tree yet, set it to set the mode once it enters
	if not tickTimer.is_inside_tree():
		tickTimer.tree_entered.connect( set_tick_mode.bind(mode), CONNECT_ONE_SHOT + CONNECT_DEFERRED )
		return
	
	if tickTimer.timeout.is_connected(tick):
		tickTimer.timeout.disconnect(tick)
	if tickTimer.get_tree().process_frame.is_connected(tick):
		tickTimer.get_tree().process_frame.disconnect(tick)
	if tickTimer.get_tree().physics_frame.is_connected(tick):
		tickTimer.get_tree().physics_frame.disconnect(tick)
	
	match mode:
		TickModes.TIMER:
			tickTimer.timeout.connect(tick)
		TickModes.IDLE:
			tickTimer.get_tree().process_frame.connect(tick)
		TickModes.PHYSICS:
			tickTimer.get_tree().physics_frame.connect(tick)
			
	tickMode = mode

func tick():
	_tick()
	tick_all_nodes()
	
func _tick():
	pass

func tick_all_nodes():
	for componentArray in componentsRegistered.values():
		for component in componentArray: 
			component.component_emission()

func register_nodes(propertiesExpected:Array[String] = get("PROPERTY_ARRAY")):
	if propertiesExpected == null:
		push_error("A constant PROPERTY_ARRAY:String must exist. It will ask for the required properties that the components must have.")
		return 
		
	register_properties(propertiesExpected)
	
	for node in nodesToRegister:
		register_components_from_node(node, propertiesExpected)

func register_properties(properties:Array[String]):
	for property in properties:
		if not componentsRegistered.has(property): 
			componentsRegistered[property] = []

func register_components_from_node(node:Node, properties:Array[String]):
	for child in node.get_children():
		for property in properties:		
			if child.get(property) != null:
				componentsRegistered[property].append(child)

func get_all_components_with_property(property:String)->Array[ECSComponent]:
	var typedArr:Array[ECSComponent]
	typedArr.assign(componentsRegistered.get(property,[])) 
	
	return typedArr
	pass

func get_all_components()->Array[ECSComponent]:
	var completeArray:Array
	var typedArray:Array[ECSComponent]
	for componentArray in componentsRegistered.values():
		completeArray.append_array(componentArray)
		
	typedArray.assign(completeArray)
	return typedArray
