extends VBoxContainer
class_name NestedMenu
## Stores sets of Control nodes in a dictionary, allowing you to change between them.

## Buttons that will be automatically generated, which can allow you to travel around the menus.
## Each button is made out of an Array with the following format: ["Menu where the button is created", "Menu where it leads to"]
@export var navigationButtons:Array[Array] =[] #[ [MenuWhereTheButtonIsPlaced,WhereTheButtonLeads] ]
	
## If this node has Control nodes, they will be considered a menu (with the menu's name being the node's name) and the children of said node will be part of said menu
@export var autoStripChildControls:bool=true

## When true, automatically creates a back button to return to the previous menu.
## If there's no previous menu to return to, the button will not appear.
@export var autoAddBackButton:bool = true

var currentMenu:String

## Every time a menu is entered without using a back button, it is added to this stack. Pressing a back button will change to the last menu added to this array.
var menuStack:Array[String] = []

## Stores a pair of menu name and control node
@export var menus:Dictionary #String:Array[Control]

func _init() -> void:
	for array in navigationButtons:
		NavigationButton.new(self,array[0],array[1])
		

func _ready():
	if autoStripChildControls: 
		for child in self.get_children():
			if not child is Control: continue
			strip_from_parent(child, child.get_name(), true)	
		
	if not menus.is_empty(): change_current_menu(menus.keys()[0],true)

func reorder_buttons():
	for button in get_children():
		if button is NavigationButtonBack and menuStack.is_empty(): remove_child(button)
		elif button is NavigationButtonBack: move_child(button, -1)
		elif button is NavigationButton: move_child(button, 0)

## Adds a menu, it overwrites any existing menu with the same name.
func create_menu(menuName:String):
	menus[menuName]=[]
	#It is automatically added
	if autoAddBackButton: NavigationButtonBack.new(self,menuName)
  
## Returns the names of all the menus
func get_menus()->Array[String]:
	return menus.keys()
	

## Removes all children from a control node and optionally removes the control node as well
func strip_from_parent(control:Control, toMenuName:String, removeParent:bool=false):
	if control.get_children().is_empty(): push_error("This node has no children"); return
	
	for child in control.get_children():
		if not child is Control: continue
		control.remove_child(child)
		add_to_menu(child, toMenuName)
	
	if removeParent: control.queue_free()


## Adds a node to a menu, the node should be an orphan when doing so or you may set autoOrphan to true so it does it for you.
func add_to_menu(what:Control, menuName:String, autoOrphan:bool=false):
	if menuName == "": push_error("Menu name cannot be empty."); return
	if not menus.has(menuName): create_menu(menuName)
	if autoOrphan and what.get_parent() != null: what.get_parent().remove_child(what)
	menus[menuName].append(what)


##SLOW! Scans each menu in search of "what" and removes it when found.
func remove_from_menu(what:Control):
	for menu in menus:
		menu.erase(what)
  
## Removes all elements from a menu.
func clear_menu(menuName:String):
	if menus.has(menuName): menus[menuName].clear()
	else: push_warning(menuName + " does not exist.")
		  
## Deletes a menu and all it's contents. The nodes are not freed as part of this function. So you may use a reference somewhere else to keep them alive.
func delete_menu(menuName:String):
	menus.erase(menuName)


## Changes the current menu. If not going back, the previous menu is added to the menuStack so you can return to it.
func change_current_menu(menuName:String, goingBack:bool=false):
	for child in get_children():
		remove_child(child)
		
	for control in menus[menuName]:
		add_child(control)
	
	if not goingBack:
		menuStack.append(currentMenu)
		
	currentMenu = menuName
	reorder_buttons()
	
## Sends you to the previous menu you where in. Warns you if there's no previous menu
func go_to_prev_menu():
	if not menuStack.is_empty() and menus.has(menuStack.back()):
		change_current_menu( menuStack.pop_back(), true )
	else: push_warning("There's no previous menu")
		
class NavigationButtonBack extends Button:

	func _init(nestedMenu:NestedMenu, menuLocation:String):
		nestedMenu.add_to_menu(self,menuLocation)
		nestedMenu.move_child(self,-1)
		pressed.connect( Callable(nestedMenu, "go_to_prev_menu") )
		text = "Back"

class NavigationButton extends Button:
	var destination:String
	
	func _init(nestedMenu:NestedMenu, menuLocation:String, targetMenu:String):
		nestedMenu.add_to_menu(self,menuLocation)
		pressed.connect( Callable(nestedMenu, "change_current_menu").bind(targetMenu) )
		destination = targetMenu
		text = ">"+destination
		
