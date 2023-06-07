extends Node
class_name FileLoader

## Store files as soon as they are scanned. RAM may cry.
@export var autoLoad:bool=false
@export var foldersToScan:Dictionary = {
	"ProjDir":["res://"],
	"UserDir":["user://"]}

enum IdentificationMethods {FILE_NAME, IDENTIFIER}
@export var identificationMethod:IdentificationMethods

var scannedFiles:Dictionary = {
	"ProjDir":{"Icon":"res://icon.svg"}
	}
	

func _ready() -> void:
	pass
	
## Scans and stores the paths to files in them.
func scan_folders(preClear:bool=true):
	if preClear: scannedFiles.clear()
	for category in foldersToScan:#Iterate trough arrays of strings
		if not scannedFiles.has(category): scannedFiles[category] = []
		
		for folder in foldersToScan[category]:#Iterate trough folder paths
			var files:PackedStringArray = DirAccess.get_files_at(folder)
			
			for file in files:#Iterate trough file names
				var fileIdentifier:String = get_identifier(folder+file)
				if fileIdentifier == "": continue
				scannedFiles[category][fileIdentifier] = file
		

func load_file(category:String, fileIdentifier:String):
	var file:Resource = load(scannedFiles[category][fileIdentifier])
	if not file: push_error("Failed loading of file. Category: " + category + " | File identifier: " + fileIdentifier)
	if file: return file
	

func get_identifier(filePath:String, _identificationMethod:IdentificationMethods = identificationMethod)->String:
	match _identificationMethod:
		IdentificationMethods.FILE_NAME:
			return filePath
			
		IdentificationMethods.IDENTIFIER:
			var file = load(filePath)
			var identifier = file.get("identifier")
			if identifier:
				return identifier
			else:
				return ""
		_:
			push_error(str(_identificationMethod) + " is not a valid identification method.")
			return ""
			
