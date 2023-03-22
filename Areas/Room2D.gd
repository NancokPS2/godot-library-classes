extends Area2D
class_name Room2D

export (String) var roomName

export (Rect2) var boundaries

export (Array,Dictionary) var doors = [{
	"Name":"Default",
	"Position":Vector2.ZERO
}]

