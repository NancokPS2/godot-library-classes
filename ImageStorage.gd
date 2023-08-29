extends RefCounted
class_name ImageDataStorage

const MAX_VALUE = 765

static func read_data_on_image(image:Image)->Array[int]:
	var values:Array
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var pixel:Color = image.get_pixelv( Vector2(x,y) )
			values.append(pixel.r8 + pixel.g8 + pixel.b8)
	return values
	
	

static func insert_data_on_image(image:Image, values:Array[int]):
	var max:int = values.max()
	var vals:Array[int]=values.duplicate()
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			if vals.is_empty(): return
#			image.set_pixelv(Vector2i(x,y), vals.pop_back())
			insert_data_on_pixel(image, Vector2i(x,y), vals.pop_back(), max)
			
	
static func insert_data_on_pixel(image:Image, pos:Vector2i, value:int, max:int=100):
#	if not ( pos.x >= 0 and pos.x <= image.get_width() ): push_error("Out of bounds in X"); return
#	if not ( pos.y >= 0 and pos.y <= image.get_height() ): push_error("Out of bounds in Y"); return
	var totalPercent:float = float(value) / float(max)
	
	var percents:Array[float]
	percents.append(randf_range(0,1.0))
	percents.append(randf_range(percents[0],1.0)/randf_range(2,6))
	percents.append(1.0 - (percents[0]+percents[1]))
	percents.shuffle()
	
#	assert(percents[0]+percents[1]+percents[2] == 1.0)
	var color:=Color(totalPercent*percents[0],totalPercent*percents[1],totalPercent*percents[2],1.0)
	image.set_pixelv(pos, color)
	var temp:float = get_value_in_pixel(image,pos)
	
#	assert(get_value_in_pixel(image,pos) == totalPercent)

static func get_value_in_pixel(image:Image, pos:Vector2i)->float:
	var pixel:Color = image.get_pixelv(pos)
	return pixel.r + pixel.g + pixel.b

