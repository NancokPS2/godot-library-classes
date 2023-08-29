extends ECSSystem
class_name ECSSystemElectricalNetwork

const PROPERTY_ELEC_GENERATION:String = "electricityGenerated"
const PROPERTY_ELEC_CONSUMPTION:String = "electricityConsumed"
const PROPERTY_ELEC_STORED:String = "electricityStored"
const PROPERTY_ELEC_STORED_MAX:String = "electricityStoredMax"

const PROPERTY_ARRAY:Array[String] = [
	PROPERTY_ELEC_CONSUMPTION,
	PROPERTY_ELEC_GENERATION,
	PROPERTY_ELEC_STORED,
	PROPERTY_ELEC_STORED_MAX
]

#const SIGNAL_ELEC_GENERATION:String = "electricity_generated"
#const SIGNAL_ELEC_CONSUMPTION:String = "electricity_consumed"
#const SIGNAL_ELEC_STORED:String = "electricity_stored"

#var electricityGeneratedComps:Array[ECSComponent]
#var electricityConsumedComps:Array[ECSComponent]
#var electricityStoredComps:Array[ECSComponent]

func _init() -> void:
	pass


#func _register_node(node:Node):
#	for child in node.get_children():
##		if child.has_signal(SIGNAL_ELEC_CONSUMPTION):
##			Signal(node, SIGNAL_ELEC_CONSUMPTION).connect(on_electricity_changed.bind(false))
##
##		if child.has_signal(SIGNAL_ELEC_GENERATION):
##			Signal(node, SIGNAL_ELEC_GENERATION).connect(on_electricity_changed.bind(true))
#		if child.get(PROPERTY_ELEC_CONSUMPTION) != null:
#			electricityConsumedComps.append(child)
#			componentsRegistered.append(child)
#
#		if child.get(PROPERTY_ELEC_GENERATION) != null:
#			electricityGeneratedComps.append(child)
#			componentsRegistered.append(child)
#
#		if child.get(PROPERTY_ELEC_STORED) != null:
#			assert(child.get(PROPERTY_ELEC_STORED_MAX))
#			electricityStoredComps.append(child)
#			componentsRegistered.append(child)
			


func _tick():
	
	#Get energy from generators and storage
	var electricityRemaining:float = get_electricity_generator_gain() + get_electricity_storage_gain()

	#Give energy to consumers
	electricityRemaining = apply_electricity_consumer_drain(electricityRemaining)

	#Give energy to storage
	electricityRemaining = apply_electricity_storage_drain(electricityRemaining)
		


	
func get_electricity_generator_gain()->float:
	var total:float
	for node in get_all_components_with_property(PROPERTY_ELEC_GENERATION):
		total += node.get(PROPERTY_ELEC_GENERATION)
	return total
	
func get_electricity_storage_gain():
	var total:float
	for node in get_all_components_with_property(PROPERTY_ELEC_STORED):
		total += node.get(PROPERTY_ELEC_STORED)
	return total
	
func apply_electricity_consumer_drain(electricityAvailable:float):
	var totalConsumed:float
	for consumer in get_all_components_with_property(PROPERTY_ELEC_CONSUMPTION):
		#Must be able to store energy
#		if not (storage.get(PROPERTY_ELEC_STORED) and storage.get(PROPERTY_ELEC_STORED_MAX)): continue
		
		#Calculate how much the component can store
		var elecMax:float = electricityAvailable / get_all_components_with_property(PROPERTY_ELEC_CONSUMPTION).size()
		var elecConsumed:float = min(consumer.get(PROPERTY_ELEC_CONSUMPTION), elecMax)# = clamp(consumer.get(PROPERTY_ELEC_STORED) - consumer.get(PROPERTY_ELEC_STORED_MAX), 0, maxEnergyPerDevice)
		
		if elecConsumed > electricityAvailable: push_warning("Ran out of electricity during the consumption calculation, this shouldn't happen."); break
		
		totalConsumed += elecConsumed
	return electricityAvailable - totalConsumed

func apply_electricity_storage_drain(electricityAvailable:float)->float:
	var totalStored:float
	for storage in get_all_components_with_property(PROPERTY_ELEC_STORED):
		#Must be able to store energy
#		if not (storage.get(PROPERTY_ELEC_STORED) and storage.get(PROPERTY_ELEC_STORED_MAX)): continue
		
		#Calculate how much the component can store
		var elecCurrent:float = storage.get(PROPERTY_ELEC_STORED)
		var elecMax:float = min(storage.get(PROPERTY_ELEC_STORED_MAX), electricityAvailable / get_all_components_with_property(PROPERTY_ELEC_STORED).size())
		var elecStored:float = min(elecMax - elecCurrent, electricityAvailable)# = clamp(consumer.get(PROPERTY_ELEC_STORED) - consumer.get(PROPERTY_ELEC_STORED_MAX), 0, maxEnergyPerDevice)
		
		#If there's not enough energy, stop
		if elecStored > electricityAvailable: push_warning("Ran out of electricity during the storage calculation, this shouldn't happen."); break
		
		#Give the energy to the storage
		storage.set(PROPERTY_ELEC_STORED, elecCurrent + elecStored)
		
		totalStored += elecStored
	return electricityAvailable - totalStored

func get_expected_consumption()->float:
	var total:float
	for node in get_all_components_with_property(PROPERTY_ELEC_CONSUMPTION):
		total += node.get(PROPERTY_ELEC_CONSUMPTION)
	return total


