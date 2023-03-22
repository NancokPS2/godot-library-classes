extends Node
class_name CheatInput#Takes each children Cheat and adds it to the list, then procs them if they are properly triggered

var active:bool = false

export (int) var maxLength:int = 10

var currentString:Array = []

var cheatStorage:Dictionary = {#Format: nodeCheatHash(int):nodeReference(Node) 
}

func _ready() -> void:
	store_cheats()

func store_cheats():
	for child in get_children():
		if child.get("cheat") != null:
			cheatStorage[child.cheat] = child
				
func _input(event: InputEvent) -> void:
	if not(event is InputEventKey and event.pressed and active and !event.is_echo() and event.as_text().length() == 1):
		return
	#Only accepts keys the moment they are pressed and only if they are 1 in length
	var input:String
	
#	if input.is_valid_integer() and (allowedChars && NUMBERS):
#		input = event.as_text()
#	elif allowedChars && LETTERS:
#		input = event.as_text()

	input = event.as_text()
	currentString.append(input)#Add input
	
	if currentString.size() > maxLength:#Sanitize
		currentString.remove(0)
		
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
