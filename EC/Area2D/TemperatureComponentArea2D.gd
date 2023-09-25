extends ComponentNode
class_name Area2DComponentTemperature
## Equalizes a value when the parent area is in contact with another area with a component of this type

const GROUP_NAME:String = "_AREA2D_TEMPERATURE_COMPONENT_GROUP"
const CELSIUS_ZERO:float = 273.15

signal temperature_changed(newAmount:float)

@export var temperatureCurrent:float = CELSIUS_ZERO + 20
@export_range(0,1) var temperatureChangeRate:float = 0.001

func _is_node_valid_parent(node:Node)->bool:
	return node is Area2D
	
func _parent_update():
	add_to_group(GROUP_NAME, true)



#New funcs

func _physics_process(delta: float) -> void:
	var temperatureComponents:Array[Area2DComponentTemperature] = get_temperature_components_overlapping()
	if not temperatureComponents.is_empty():
		equalize_temperatures(temperatureComponents, delta)

func get_temperature_components_overlapping()->Array[Area2DComponentTemperature]:
	var overlappedAreas:Array[Area2D] = targetNode.get_overlapping_areas()
	
	#Get all components using their group
	var components:Array[Area2DComponentTemperature]
	components.assign(get_tree().get_nodes_in_group(GROUP_NAME))
	
	#Ensure that the component is in an area touching this one's
	components.filter(func(component:Area2DComponentTemperature):
		return component.targetNode in overlappedAreas 
		)
		
	return components
	
func equalize_temperatures(temperatureComponents:Array[Area2DComponentTemperature], delta:float):
	var totalTempChange:float
	for tempComponent in temperatureComponents:
		assert(tempComponent is Area2DComponentTemperature)
		temperatureCurrent = lerp(temperatureCurrent, tempComponent.temperatureCurrent, temperatureChangeRate)
#		totalTempChange = temperatureCurrent - tempComponent.temperatureCurrent
	
	if totalTempChange != 0:
		temperature_changed.emit(temperatureCurrent)
#	totalTempChange = totalTempChange / temperatureComponents.size()
