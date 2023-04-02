extends GridContainer
class_name SettingList
#enum SettingTypes {INT=TYPE_INT,FLOAT=TYPE_FLOAT,BOOL=TYPE_BOOL,STRING=TYPE_STRING}
signal setting_added(element)
signal settings_ready
signal description_updated(desc)

## Stores the tooltip of the currently hovered setting.
var settingDescription:String:
	set(val):
		settingDescription = val
		emit_signal("description_updated", settingDescription)

#Setting format:
#{"canJump":true, "gravity":false}

#Tooltip format
#{"canJump":"Enables or disables jumping", "gravity":"TOOLTIP_FUNNYTEXT"}

@export var settings:Dictionary: #{"key":variant}
	set(value):
		settings = value
		if settings: generate_settings()
		
## If true, some values may be handled differently depending on their contents. Like detecting "en" as a language type
@export var allowSpecialSettings:bool = true

func generate_settings(_settings:Dictionary = settings, tooltipDict:Dictionary={}):
	for child in get_children(): child.queue_free()
	for key in _settings:
		var defaultValue = _settings[key] 
		var tooltip = tooltipDict.get(key,"")
		var element:SettingElement = SettingElement.new({"key":key, "defaultValue":defaultValue, "tooltip":tooltip})
		add_child(element)
		emit_signal("setting_added",element)
		element.mouse_entered.connect(setting_hovered.bind(element))
		element.mouse_exited.connect(clear_description)
	emit_signal("settings_ready")
	queue_sort()
	pass

func setting_hovered(element:SettingElement):
	settingDescription = element.settingDict.tooltip
	
func clear_description():
	settingDescription = ""

class SettingElement extends Label:
	
	signal changed_value(key,value)
	
	enum SpecialSettings {LANGUAGE=-1}
	const settingFormat = {
		"key":"",
		"defaultValue":null,
		"tooltip":""}
	var settingType:int:
		set(value):
			settingType = value
			if get_tree(): add_control()
			
	var settingDict:Dictionary#Used to store information about the current setting
	
	var control_added:bool
	
	var controlNode:Control
	var controlNode2:Control

	func _init(dict:Dictionary, allowSpecialTypes:bool=true):
		mouse_default_cursor_shape = Control.CURSOR_HELP
		mouse_filter = Control.MOUSE_FILTER_PASS
		settingDict = dict
		text = settingDict.key
		clip_text = true
		set_type(settingDict.defaultValue, allowSpecialTypes)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		set_anchor(SIDE_RIGHT,1.0)
		text=tr(text)
		#tooltip_text = settingDict.tooltip #TEMP
	
	func _ready() -> void:
		add_control()

	func set_type(variant, allowSpecial):
		settingType = typeof(variant)
		if allowSpecial:
			#LANGUAGE
			if typeof(variant) == TYPE_STRING and TranslationServer.get_loaded_locales().has(variant):
				settingType = SpecialSettings.LANGUAGE
		

	func add_control():
		if controlNode: controlNode.queue_free(); if controlNode2: controlNode2.queue_free()
		
		match settingType:
			TYPE_BOOL:
				controlNode = CheckButton.new()
				add_child(controlNode)
				controlNode.button_pressed = settingDict.defaultValue
				controlNode.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT,Control.PRESET_MODE_MINSIZE)
				controlNode.toggled.connect(update_nodes)
				
			TYPE_INT:
				controlNode = HSlider.new()
				controlNode2 = Label.new()
				add_child(controlNode)
				add_child(controlNode2)
				controlNode.value = settingDict.defaultValue
				controlNode.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT,Control.PRESET_MODE_MINSIZE)
				controlNode2.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT,Control.PRESET_MODE_MINSIZE)
				controlNode.drag_ended.connect(update_nodes)
				
			SpecialSettings.LANGUAGE:
				var languagesAvailable:PackedStringArray = TranslationServer.get_loaded_locales()
				controlNode = MenuButton.new()
				var popup:PopupMenu = controlNode.get_popup()
				var index:=0
				for lang in languagesAvailable:
					popup.add_item(lang)
					popup.set_item_text(index, lang)
					index+=1
				popup.index_pressed.connect(update_nodes)
				
				controlNode.custom_minimum_size = Vector2(32,8)
				controlNode.text = TranslationServer.get_locale()
				
				add_child(controlNode)
				controlNode.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT,Control.PRESET_MODE_MINSIZE)
					
			_:
				push_error("Invalid type" + str(settingType) +". Cannot add a control node for the setting.")
				
		
	func update_nodes(_val):
		match settingType:
			TYPE_BOOL:
				emit_signal("changed_value", settingDict.key, _val)
				
			TYPE_INT:
				controlNode2.text = str(_val)
				emit_signal("changed_value", settingDict.key, _val)
			
			SpecialSettings.LANGUAGE:
#				if controlNode is MenuButton:
				var popup:PopupMenu = controlNode.get_popup()
				var lang = popup.get_item_text(_val)
				controlNode.text = lang
				emit_signal("changed_value", settingDict.key, lang)
					
					
#Example:
#	$SettingList.generate_settings(Global.profileFile.settings,SaveManager.ProfileData.SettingToolTips)
#	for child in $SettingList.get_children():
#		if child is SettingList.SettingElement:
#			child.changed_value.connect(Callable(Global,"update_setting"))
