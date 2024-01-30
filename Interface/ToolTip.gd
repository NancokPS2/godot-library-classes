extends Node2D
class_name Tooltip

enum PopupDirections {
	UP, 
	DOWN,
	LEFT,
	RIGHT,
	}

signal visibility_update_required

@export_category("Settings")
@export var debug_mode: bool = false
@export var allow_sub_tooltips: bool = false
@export var pin_action: String = "ui_accept"

@export_category("Appereance")
@export var auto_choose_direction: bool = true

@export var popup_dir: PopupDirections = PopupDirections.UP

@export var minimum_size: Vector2 = Vector2(80,40):
	set(value):
		minimum_size = value
		panel.custom_minimum_size = minimum_size
		
@export var text: String = "Placeholder":
	set(value):
		if label: 
			text = value
			label.text = text
			visibility_update_required.emit()
		
@export var sub_tooltips_to_display: Dictionary = {
	"help" : "Every 'help' word will invoke this tooltip."
}
			
var target_hovered: bool:
	set(val):
		target_hovered = val
		visibility_update_required.emit()
			
var pinned: bool = false:
	set(val):
		pinned = val
		visibility_update_required.emit()
		
		
var keyword_rect_dict: Dictionary
var panel := Panel.new()
var label := Label.new()

var sub_tooltip: Tooltip
var sub: bool = false

func _init() -> void:
	hide()
	visibility_update_required.connect(on_visibility_update_required)

func _ready() -> void:		
	add_child(panel)
	panel.add_child(label)
	
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.gui_input.connect(on_label_gui_input)
	
	if sub:
		assert(get_parent() is Label)
		assert(get_parent().get_parent().get_parent() is Tooltip)
		
		set_name("SubTooltip")
		sub_tooltips_to_display.clear()
		allow_sub_tooltips = false
		auto_choose_direction = false
		popup_dir = get_parent().get_parent().get_parent().popup_dir
		return
	
	add_to_control(label, true)
	
	pinned = pinned
	connect_target_signals(get_target())
	
	visibility_update_required.emit()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(pin_action) and not target_hovered:
		pinned = false
		
	
func connect_target_signals(target: Control):
	if not target is Control:
		return
		
	target.gui_input.connect(on_target_gui_input)
	target.mouse_entered.connect(on_mouse_hover_changed.bind(true))
	target.mouse_exited.connect(on_mouse_hover_changed.bind(false))


func get_target()->Control:
	return get_parent() if get_parent() is Control else null


func get_auto_direction()->PopupDirections:
	var viewport_rect: Rect2 = get_viewport_rect()
	
	var direction_dist_dict: Dictionary = {
		PopupDirections.UP : global_position.distance_to( Vector2(viewport_rect.position.x + viewport_rect.size.x / 2, viewport_rect.position.y) ),
		PopupDirections.DOWN : global_position.distance_to( Vector2(viewport_rect.position.x + viewport_rect.size.x / 2, viewport_rect.end.y) ),
		PopupDirections.LEFT : global_position.distance_to( Vector2(viewport_rect.position.x, viewport_rect.position.y + viewport_rect.size.y / 2) ),
		PopupDirections.RIGHT : global_position.distance_to( Vector2(viewport_rect.end.x, viewport_rect.position.y + viewport_rect.size.y / 2) ),
	}
	
	var closest_dir_to_border: PopupDirections
	var smallest_value: float = INF
	
	for direction: PopupDirections in direction_dist_dict:
		var value: float = direction_dist_dict[direction]
		if value < smallest_value:
			closest_dir_to_border = direction
			smallest_value = value
	
	match closest_dir_to_border:
		PopupDirections.UP:
			return PopupDirections.DOWN
		PopupDirections.DOWN:
			return PopupDirections.UP
		PopupDirections.LEFT:
			return PopupDirections.RIGHT
		PopupDirections.RIGHT:
			return PopupDirections.LEFT
		_:
			push_error("Could not determine a direction automatically, returning the current one.")
			return popup_dir
		
		
func adjust_position(direction: PopupDirections):
	
	var target_size: Vector2 = get_target().size
	
	match direction:
		PopupDirections.UP:
			position = Vector2(
				target_size.x / 2,
				0
				)
			panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
			panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
			
		PopupDirections.DOWN:
			position = Vector2(
				target_size.x / 2,
				target_size.y
				)
			panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
			panel.grow_vertical = Control.GROW_DIRECTION_END
			
		PopupDirections.LEFT:
			position = Vector2(
				0,
				target_size.y / 2
				)
			panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			panel.grow_vertical = Control.GROW_DIRECTION_BOTH
			
		PopupDirections.RIGHT:
			position = Vector2(
				target_size.x,
				target_size.y / 2
				)
			panel.grow_horizontal = Control.GROW_DIRECTION_END
			panel.grow_vertical = Control.GROW_DIRECTION_BOTH
		
		_:
			push_error("Invalid direction." + str(direction))

	
func update_size():
	panel.custom_minimum_size = minimum_size
	label.custom_minimum_size = Vector2(panel.size.x, label.get_line_count() * label.get_line_height()) 


func update_input_processing():
	set_process_input.call_deferred(pinned)
	if allow_sub_tooltips:
		label.mouse_filter = Control.MOUSE_FILTER_PASS
	else:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pass


func update_rects():
	
	pass

func on_target_gui_input(event: InputEvent):
	if event.is_action_pressed(pin_action):
		pinned = !pinned
	
	
func on_mouse_hover_changed(inside: bool):
	target_hovered = inside


func on_visibility_update_required():
	if pinned:
		show()
	elif target_hovered:
		show()
	elif not target_hovered:
		hide()
	
	if auto_choose_direction:
		popup_dir = get_auto_direction()
		
	adjust_position(popup_dir)
	update_size()
	update_input_processing()


func on_label_gui_input(event: InputEvent):
	if not event is InputEventMouseMotion:
		return
		
	var position_hovered: Vector2 = label.get_local_mouse_position()
	
	for keyword: String in keyword_rect_dict:
		pass
		
		
func update_keyword_rects(keywords: Array[String]):
	var to_fill: Array[Rect2]
	
	for keyword: String in keywords:
		var last_find_index: int = 0
		while last_find_index != -1:
			last_find_index = text.find(keyword)
			var text_rect: Rect2
			
			to_fill.append(text_rect)
			
		keyword_rect_dict[keyword] = to_fill

func find_character_position(node: Label, char_pos: String):
	var size: Vector2 = node.get_size()
	var theme_type: String = node.theme.get_stylebox_type_list()[0]
	var style_box: String = node.theme.get_stylebox_list(theme_type)[0]
	var style: StyleBox = node.theme.get_stylebox(style_box, theme_type)
	
	var line_spacing: int
	if node.label_settings:
		line_spacing = node.label_settings.line_spacing
	else:
		line_spacing = node.get_theme_constant("line_spacing", theme_type)

	var total_h: int = 0.0;
	var lines_visible: int = 0;

	# Get number of lines to fit to the height.
	var starting_index: int = node.lines_skipped
	for index in range(starting_index, node.get_line_count()): 
		total_h += node.get_line_height() + line_spacing
		if total_h > ( node.get_size().y - style.get_minimum_size().y + line_spacing):
			break
			
		lines_visible += 1

	lines_visible = min(lines_visible, node.max_lines_visible)
	
	var last_line: int = min(lines_rid.size(), lines_visible + lines_skipped);

	# Get real total height.
	total_h = 0;
	for index in range(lines_skipped, last_line):
		total_h += node.get_line_height() + line_spacing

	total_h += style.content_margin_top + style.content_margin_bottom

	var vbegin: int = 0
	var vsep: int = 0
	if lines_visible > 0:
		match node.vertical_alignment:
			VERTICAL_ALIGNMENT_TOP: 
				# Nothing.
				pass

			VERTICAL_ALIGNMENT_CENTER:
				vbegin = (size.y - (total_h - line_spacing)) / 2;
				vsep = 0;

			VERTICAL_ALIGNMENT_BOTTOM:
				vbegin = size.y - (total_h - line_spacing);
				vsep = 0;

			VERTICAL_ALIGNMENT_FILL:
				vbegin = 0;
				if lines_visible > 1:
					vsep = (size.y - (total_h - line_spacing)) / (lines_visible - 1)
				else:
					vsep = 0;

	Vector2 ofs;
	ofs.y = style->get_offset().y + vbegin;
	for (int i = lines_skipped; i < last_line; i++) {
		Size2 line_size = TS->shaped_text_get_size(lines_rid[i]);
		ofs.x = 0;
		switch (horizontal_alignment) {
			case HORIZONTAL_ALIGNMENT_FILL:
				if (rtl && autowrap_mode != TextServer::AUTOWRAP_OFF) {
					ofs.x = int(size.width - style->get_margin(SIDE_RIGHT) - line_size.width);
				} else {
					ofs.x = style->get_offset().x;
				}
				break;
			case HORIZONTAL_ALIGNMENT_LEFT: {
				if (rtl_layout) {
					ofs.x = int(size.width - style->get_margin(SIDE_RIGHT) - line_size.width);
				} else {
					ofs.x = style->get_offset().x;
				}
			} break;
			case HORIZONTAL_ALIGNMENT_CENTER: {
				ofs.x = int(size.width - line_size.width) / 2;
			} break;
			case HORIZONTAL_ALIGNMENT_RIGHT: {
				if (rtl_layout) {
					ofs.x = style->get_offset().x;
				} else {
					ofs.x = int(size.width - style->get_margin(SIDE_RIGHT) - line_size.width);
				}
			} break;
		}
		int v_size = TS->shaped_text_get_glyph_count(lines_rid[i]);
		const Glyph *glyphs = TS->shaped_text_get_glyphs(lines_rid[i]);

		float gl_off = 0.0f;
		for (int j = 0; j < v_size; j++) {
			if ((glyphs[j].count > 0) && ((glyphs[j].index != 0) || ((glyphs[j].flags & TextServer::GRAPHEME_IS_SPACE) == TextServer::GRAPHEME_IS_SPACE))) {
				if (p_pos >= glyphs[j].start && p_pos < glyphs[j].end) {
					float advance = 0.f;
					for (int k = 0; k < glyphs[j].count; k++) {
						advance += glyphs[j + k].advance;
					}
					Rect2 rect;
					rect.position = ofs + Vector2(gl_off, 0);
					rect.size = Vector2(advance, TS->shaped_text_get_size(lines_rid[i]).y);
					return rect;
				}
			}
			gl_off += glyphs[j].advance * glyphs[j].repeat;
		}
		ofs.y += TS->shaped_text_get_ascent(lines_rid[i]) + TS->shaped_text_get_descent(lines_rid[i]) + vsep + line_spacing;
	}
	return Rect2();
}

static func add_to_control(target: Control, sub: bool = false) -> Tooltip:
	var new_tooltip := Tooltip.new()
	new_tooltip.sub = sub
	if sub:
		target.add_child(target, false, Node.INTERNAL_MODE_FRONT)
	else:
		target.add_child(new_tooltip)
	return new_tooltip
	
