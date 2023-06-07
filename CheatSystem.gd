extends Resource
class_name Cheat

signal triggered
signal activated(boolean)

@export var hash:int = "CHEAT".hash()
@export var displayName:String
@export var active:bool = false:
	set(val):
		active = val
		emit_signal("activated",active)

func trigger():
	emit_signal("triggered")
	pass

class CheatInput extends Node:#Takes each children Cheat and adds it to the list, then procs them if they are properly triggered

	var active:bool = false

	var maxLength:int = 10

	var currentString:Array = []

	@export var cheatStorage:Dictionary = {}

	func _init(_active:bool = true, _maxLength:int = 10, _cheats:Array = []) -> void:
		active = _active
		maxLength = _maxLength
		store_cheats(_cheats)
	
	func store_cheats(cheats:Array, clearPrevious:bool=false):
		if clearPrevious: cheatStorage.clear()
		
		for cheat in cheats:
			if cheat is Cheat: 
				cheatStorage[cheat.hash] = cheat
			else:
				push_error("Non-cheat provided, aborting."); return
			
	func _input(event: InputEvent) -> void:
		if not(event is InputEventKey and event.pressed and active and !event.is_echo() and event.as_text().length() == 1):
			return
		#Only accepts keys the moment they are pressed and only if they are 1 in length
		var input:String = event.as_text()
		
		currentString.append(input)#Add input
		
		if currentString.size() > maxLength:#Sanitize
			currentString.remove_at(0)
			
		cheat_proc(get_string().hash())#Check if a cheat can be triggered
		
	func cheat_proc(cheat:int):
		if cheatStorage.has(cheat):#Check if the cheat is stored
			currentString = []#Remove any typed cheat
			cheatStorage[cheat].call("trigger")#Call the node belonging to the hash
			pass
		pass

	func get_string()->String:
		var text:String
		for x in currentString:
			text += x
		return text



