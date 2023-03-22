extends Node
class_name WorldController

const groups = {"WORLD INTERACTABLE":1}

func disable_object_group(group:String):
	get_tree().call_group(group,"toggle",false)
	pass
