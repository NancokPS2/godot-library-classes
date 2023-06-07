extends VBoxContainer
class_name ButtonMenu

signal button_created(IDRefDict)
signal button_triggered(btnIdentifier)

@export var buttonIdentifiers:Array[String]
@export var buttonMinSize:=Vector2(0,80)
@export var autoGenerateButtons:bool = true
var buttonRefs:Array[Button]

func _ready():
	if autoGenerateButtons: generate_buttons()


func generate_buttons(identifiers:Array[String]=buttonIdentifiers):
	for child in get_children(): child.queue_free(); buttonRefs.clear()
	
	for identifier in buttonIdentifiers:
		var button:=Button.new()
		var label:=Label.new(); label.text = identifier
		buttonRefs.append(button) 
		
		button.custom_minimum_size = buttonMinSize
		button.pressed.connect( Callable(emit_signal.bind("button_triggered",identifier)) )
		
		add_child(button)
		button.add_child(label)
		
		emit_signal("button_created",{"identifier":identifier, "buttonRef":button})
		
		
	
