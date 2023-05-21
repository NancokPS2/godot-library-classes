extends Node
class_name TweenPresets

enum Presets {GLOW}
const IncompatibleError:String = "Incompatible node for this Tween"

static func get_preset(node:Node, preset:Presets, duration:float=1.0)->Tween:
	var tween:=node.create_tween()
	match preset:
		
		Presets.GLOW:
			if node.get("modulate") == null: push_error(IncompatibleError); return
			tween.tween_property(node, "modulate", node.modulate*1.5, duration)
			tween.tween_property(node, "modulate", node.modulate, duration)
			tween.finished.connect(Callable(node,"set").bind("modulate",node.modulate))
			
	tween.finished.connect(Callable(tween,"queue_free"))
	return tween
