extends Control
class_name FlowChart

@export defaultNodeTexture:Texture

func add_node(pos:Vector2, text:String):
  var node:=ChartNode.new()
  node.position = pos
  node.label.text = text
  add_child(node)


class ChartNode extends TextureRect:
  var label:=Label.new()

  func _ready():
    add_child(label)

