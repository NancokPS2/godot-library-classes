extends Node
class_name SaveSystem

var config:ConfigFile

export (Dictionary) var settings

func store_object_dicts(arrayOfObjects:Array):
	config.erase_section("Objects")
	var tempDict
	var key = 0
	
	for object in arrayOfObjects:
		tempDict.append( object.inst2dict() )
		
