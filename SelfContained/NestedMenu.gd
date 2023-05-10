extends VBoxContainer
class_name NestedButtonMenu
## You can use childrenPreset to take nodes from a scene or add them trough code with add_to_menu(what:Control, menuName:String)
## To navigate trough nested menus, a button must be connected 

## Used to take buttons created in the editor and adding them to self
@export var childrenPreset:Dictionary #MenuName:Control


## TODO: Auto generates buttons to navigate trough menus
@export var navigationButtons:Dictionary #MenuWhereTheButtonIsPlaced:WhereTheButtonLeads

## When true, automatically creates a back button to return to the previous menu
@export autoAddBackButton:bool = true

var currentMenu:String

var menuStack:Array[String]= []

## Stores a pair of menu name and control node
var menus:Dictionary #String:Array[Control]

func _ready():
	for menu in childrenPreset:
		var control:Control = childrenPreset[menu]
		remove_child(control)
		
		add_to_menu(control, menu)

func get_menus()->Array[String]:
	return menus.keys()

## Takes all children from a control node and optionally removes it as well
func strip_from_parent(control:Control, toMenuName:String, removeParent:bool=false):
	if control.get_children().is_empty(): push_error("This node has no children"); return
	
	for child in control.get_children():
		control.remove_child(child)
		add_to_menu(child, toMenuName)
	
	if removeParent: control.queue_free()



func add_to_menu(what:Control, menuName:String):
	if menuName == "": push_error("Menu name cannot be empty."); return
	if not menus.has(menuName): menus[menuName]=[]
	
	menus[menuName].append(what)


##SLOW! Scans each menu and removes the referenced control	
func remove_from_menu(what:Control):
	for menu in menus[menuName]:
		menu.erease(what)
		
		
func delete_menu(menuName:String):
	menus.erease(menuName)


## Changes the current menu, if it's not going back, the menu that was just left is added to the stack
func change_current_menu(menuName:String, goingBack:bool=false):
	for child in get_children():
		remove_child(child)
		
	for control in menus[menuName]:
		add_child(control)
	
	if not goingBack:
		menuStack.append(currentMenu)
		
	currentMenu = menuName
	
	
func go_to_prev_menu():
	if not menuStack.is_empty() and menus.has(menuStack.back()):
		change_current_menu( menuStack.pop_back(), true )
		
		
class NavigationButton extends Button:

	func _init(nestedMenu:NestedButtonMenu, menuLocation:String, targetMenu:String):
		nestedMenu.add_to_menu(self,menuLocation)
		pressed.connect( Callable(nestedMenu, "change_current_menu").bind(targetMenu) )
		