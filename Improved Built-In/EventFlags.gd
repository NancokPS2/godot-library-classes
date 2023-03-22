extends Node
class_name EventFlags

export (Dictionary) var flags:Dictionary

func validate_entry(flagName:String,category:String):
	if not flags.has(category):
		flags[category] = {}
	if not flags[category].has(flagName):
		flags[category][flagName] = false
	pass

func set_flag(flagName:String, value:bool=true, category:String = "Main"):
	validate_entry(flagName,category)
	flags[category][flagName] = value
	
	
func check_flag(flagName:String, category:String = "Main")->bool:
	validate_entry(flagName,category)
	return flags[category][flagName]

		
func remove_flag(flagName:String, category:String = "Main"):
	validate_entry(flagName,category)
	flags.erase(flagName)
	
	
