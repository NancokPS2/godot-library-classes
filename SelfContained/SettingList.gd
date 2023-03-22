extends GridContainer
class_name SettingList
#enum SettingTypes {INT=TYPE_INT,FLOAT=TYPE_FLOAT,BOOL=TYPE_BOOL,STRING=TYPE_STRING}
signal setting_added(element)
signal settings_ready

const settingFormat = {
	"key":"",
	"defaultValue":null,
	"tooltip":""
}

#Setting format:
#{"canJump":true, "gravity":false}

#Tooltip format
#{"canJump":"Enables or disables jumping", "gravity":"TOOLTIP_FUNNYTEXT"}

@export var settings:Dictionary:
	set(value):
		settings = value
		if settings: generate_settings()

func generate_settings(_settings:Dictionary = settings, tooltipDict:Dictionary={}):
	for child in get_children(): child.queue_free()
	for key in _settings:
		var defaultValue = _settings[key] 
		var tooltip = tooltipDict.get(key,"")
		var element:SettingElement = SettingElement.new({"key":key, "defaultValue":defaultValue, "tooltip":tooltip})
		add_child(element)
		emit_signal("added_setting",element)
	emit_signal("settings_ready")
	queue_sort()
	pass


class SettingElement extends Label:
	
	signal changed_value(key,value)
	
	var settingType:int:
		set(value):
			settingType = value
			if get_tree(): add_control()
	var settingDict:Dictionary#Used to store information about the current setting
	
	var control_added:bool
	
	var controlNode:Control
	var controlNode2:Control

	func _init(dict:Dictionary):
		settingDict = dict
		text = settingDict.key
		settingType = typeof(settingDict.defaultValue)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		set_anchor(SIDE_RIGHT,1.0)
		text=tr(text)
		tooltip_text = settingDict.tooltip
	
	func _ready() -> void:
		add_control()
		
	func add_control():
		if controlNode: controlNode.queue_free(); if controlNode2: controlNode2.queue_free()
		
		match settingType:
			TYPE_BOOL:
				controlNode = CheckButton.new()
				add_child(controlNode)
				controlNode.button_pressed = settingDict.defaultValue
				controlNode.set_anchors_preset(PRESET_CENTER_RIGHT)
				controlNode.toggled.connect(update_nodes)
				
			TYPE_INT:
				controlNode = HSlider.new()
				controlNode2 = Label.new()
				add_child(controlNode)
				add_child(controlNode2)
				controlNode.value = settingDict.defaultValue
				controlNode.set_anchors_preset(PRESET_BOTTOM_LEFT)
				controlNode2.set_anchors_preset(PRESET_CENTER_RIGHT)
				controlNode.drag_ended.connect(update_nodes)
			_:
				push_error("Invalid type" + str(settingType) +". Cannot add a control node.")
				
		
	func update_nodes(_val):
		match settingType:
			TYPE_BOOL:
				emit_signal("changed_value", settingDict.key, _val)
				
			TYPE_INT:
				controlNode2.text = str(_val)
				emit_signal("changed_value", settingDict.key, _val)
				
#Example:
#	$SettingList.generate_settings(Global.profileFile.settings,SaveManager.ProfileData.SettingToolTips)
#	for child in $SettingList.get_children():
#		if child is SettingList.SettingElement:
#			child.changed_value.connect(Callable(Global,"update_setting"))
