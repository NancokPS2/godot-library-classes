extends Label
class_name LabelFoldable

export (bool) var receivingInput = true

export (bool) var fold = false

export (String) var triggerKey = ""#Key that folds the text, characters must be uppercase

export (bool) var showHintWhileFolded = true#Show the foldHint even while folded

export (String) var foldHint = "To hide/show, press " + triggerKey#Message to show for folding/unfolding

var textHolder:String#Keeps text while folded



func toggle_fold():
	if fold:
		textHolder = text
		text = foldHint
	else:
		text = textHolder

	fold = !fold

func _input(event: InputEvent) -> void:
	if receivingInput and event is InputEventKey and event.as_text() == triggerKey:
		toggle_fold()
