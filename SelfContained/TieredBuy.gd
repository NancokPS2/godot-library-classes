extends Resource
class_name TieredBuy

signal purchase_message(msg:String)
const SUCCESS_MSG:String = "TIEREDBUY_SUCCESS"
const FAIL_COST_MSG:String = "TIEREDBUY_FAIL_COST"
const FAIL_PREREQ_MSG:String = "TIEREDBUY_FAIL_PREREQ"

@export var identifier:String
@export var prerequisites:Array[TieredBuy]
@export var cost:int
	

func can_buy(currency:int, availableBuys:Array[TieredBuy])->bool:
	if identifier == null or identifier == "": push_error("No identifier set!"); return false
	if currency < cost: emit_signal("purchase_message",FAIL_COST_MSG); return false
#	var required:Array[TieredBuy] = prerequisites.duplicate()
	var counter:int=0
	for buy in prerequisites:
		if availableBuys.filter(func(val): return val.identifier == buy.identifier)[0].identifier == buy.identifier: 
			counter+=1
		
	if counter == prerequisites.size(): emit_signal("purchase_message",SUCCESS_MSG); return true
	else: emit_signal("purchase_message",FAIL_PREREQ_MSG); return false
