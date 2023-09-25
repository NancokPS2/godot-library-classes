extends ComponentNode
class_name Area3DComponentTemperature
## Update required to mimic it's 2D counterpart.


const GROUP_NAME:String = "_AREA3D_TEMPERATURE_COMPONENT_GROUP"
const CELSIUS_ZERO:float = 273.15

signal temperature_changed

@export var temperatureCurrent:float = CELSIUS_ZERO + 20
@export_range(0,1) var temperatureChangeRate:float = 0.1

func _is_node_valid_parent(node:Node)->bool:
	return node is Area3D
	
func _parent_update():
	add_to_group(GROUP_NAME, true)



#New funcs

func _physics_process(delta: float) -> void:
	equalize_temperatures(get_temperature_components_overlapping(), delta)

func get_temperature_components_overlapping()->Array[Area3DComponentTemperature]:
	var overlappedAreas:Array[Area3D] = targetNode.get_overlapping_areas()
	
	#Get all components using their group
	var components:Array[Area3DComponentTemperature]
	components.assign(get_tree().get_nodes_in_group(GROUP_NAME))
	
	#Ensure that the component is in an area touching this one's
	components.filter(func(component:Area3DComponentTemperature):
		return component.targetNode in overlappedAreas 
		)
		
	return components
	
func equalize_temperatures(temperatureComponents:Array[Area3DComponentTemperature], delta:float):
	var totalTempChange:float
	for tempComponent in temperatureComponents:
		assert(tempComponent is Area3DComponentTemperature)
		temperatureCurrent = lerp(temperatureCurrent, tempComponent.temperatureCurrent, temperatureChangeRate) * delta
#		totalTempChange = temperatureCurrent - tempComponent.temperatureCurrent
	temperature_changed.emit()
#	totalTempChange = totalTempChange / temperatureComponents.size()
