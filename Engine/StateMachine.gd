extends Node
class_name StateMachine

var state:State

var stateList:Dictionary

func change_state(stateName:String):
	state = stateList[stateName]
	pass

