extends Node
class_name Cheat

var internalName:String = "Unnamed cheat"
var debug = Glob.settings["debugMode"]
var cheat:int = "TESTCHEA".hash()


func trigger(vars:Array=[]):
	_trigger(vars)
	if debug:
		print("Cheat " + get_name() + " triggered")
	else:
		print("Cheat triggered")

func _trigger(vars:Array=[]):
	pass
