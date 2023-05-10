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

func generate_single_setting(key:String, defaultVal, toolTip:String="", allowSpecial:bool=true, forcedType:int=0, specialParams=false):
	var element:=SettingElement.new({"key":key, "defaultValue":defaultVal, "tooltip":toolTip, "specialParams":specialParams}, allowSpecial, forcedType)
	add_child(element)
	emit_signal("setting_added",element)
	element.mouse_entered.connect(setting_hovered.bind(element))
	element.mouse_exited.connect(clear_description)	
	queue_sort()
		
func remove_setting(settingKey:String):
	var foundSetting:SettingElement
	for child in get_children():
		if child is SettingElement and child.settingDict.key == settingKey:
			foundSetting = child
	
	if foundSetting is SettingElement: foundSetting.queue_free()
	

func setting_hovered(element:SettingElement):
	settingDescription = element.settingDict.tooltip
	
func clear_description():
	settingDescription = ""

class SettingElement extends Label:
	
	signal changed_value(key,value)
	
	enum SpecialSettings {LANGUAGE=-1,SLIDER_INT=-2}
	const settingFormat = {
		"key":"",
		"defaultValue":null,
		"tooltip":"",
		"specialParams":null}
	var settingType:int:
		set(value):
			settingType = value
			if is_inside_tree(): add_control()
			
	var settingDict:Dictionary#Used to store information about the current setting
	
	var control_added:bool
	
	var controlNode:Control
	var controlNode2:Control

	func _init(dict:Dictionary, allowSpecialTypes:bool=true, forcedSpecial:int=0):
		mouse_default_cursor_shape = Control.CURSOR_HELP
		mouse_filter = Control.MOUSE_FILTER_PASS
		settingDict = dict
		text = settingDict.key
		clip_text = true
		set_type(settingDict.defaultValue, allowSpecialTypes, forcedSpecial)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		set_anchor(SIDE_RIGHT,1.0)
		text=tr(text)
			
			
		#tooltip_text = settingDict.tooltip #TEMP
	
	func _ready() -> void:
		add_control()

	func set_type(variant, allowSpecial:bool, forcedType:int):
		settingType = typeof(variant)
		
		if allowSpecial and SpecialSettings.values().has(forcedType):
			var params = settingDict.get("specialParams",false)
			if settingDict.get("specialParams",null) == null:
				push_error("No special parameters where set for this forcedType")
			else: 
				settingType = forcedType
		
		elif allowSpecial:#Guess the type
			#LANGUAGE
			if typeof(variant) == TYPE_STRING and TranslationServer.get_loaded_locales().has(variant):
				settingType = SpecialSettings.LANGUAGE
		
		

	func add_control():
		if controlNode: controlNode.queue_free(); if controlNode2: controlNode2.queue_free()
		
		match settingType:
#			TYPE_ARRAY:
#				if settingDict.defaultValue is Array[int]:

#				else: push_error("Invalid Array type.")					
			
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
					
			SpecialSettings.SLIDER_INT:
					controlNode = HSlider.new(); add_child(controlNode)

					controlNode.rounded = true
					controlNode.step = 1
					if not (settingDict.specialParams is Array or settingDict.specialParams.size()!=2):
						push_warning("Incorrect format for specialParams for this type of SpecialSettings, execution can still continue.")
					controlNode.min_value = settingDict.specialParams.min()
					controlNode.max_value = settingDict.specialParams.max()
					controlNode.value_changed.connect(update_nodes)
					controlNode.custom_minimum_size = Vector2(200,8)
					controlNode.set_value_no_signal(settingDict.defaultValue)
					
					controlNode.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT,Control.PRESET_MODE_KEEP_SIZE)
					
					controlNode2 = Label.new(); controlNode.add_child(controlNode2)
					controlNode2.text = str(settingDict.defaultValue)
					controlNode2.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT,Control.PRESET_MODE_KEEP_SIZE)
					
			_:
				push_error("Invalid type" + str(settingType) +". Cannot add a control node for the setting.")
				
		
	func update_nodes(_val):
		match settingType:
			TYPE_ARRAY:
				if settingDict.defaultValue is Array[int]:
					emit_signal("changed_value", settingDict.key, int(_val))
					
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
				
			SpecialSettings.SLIDER_INT:
				controlNode2.text = str(_val)
				emit_signal("changed_value", settingDict.key, int(_val))
				
					
					
#Example:
#	$SettingList.generate_settings(Global.profileFile.settings,SaveManager.ProfileData.SettingToolTips)
#	for child in $SettingList.get_children():
#		if child is SettingList.SettingElement:
#			child.changed_value.connect(Callable(Global,"update_setting"))
