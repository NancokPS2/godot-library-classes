extends Node
class_name MusicPlayer

@export var streamNode:Node:
	set(val):
		if streamNode is AudioStreamPlayer or streamNode is AudioStreamPlayer2D or streamNode is AudioStreamPlayer3D:
			streamNode = val
			streamNode.finished.connect(song_ended)
		else: push_error("Can only use derivatives of AudioStreamPlayer")

@export var musicFolders:Array[String]
@export var autoPlay:bool=true
@export var autoStart:bool=true
@export var loop:bool=true

var musicFound:Array[String]
var musicQueue:Array[String]


var currSongID:int:
	set(val):
		currentSong = clamp(val, 0, musicFound.size())
		
var currentSong:AudioStream:
	set(val):
		currentSong = val
		if streamNode: streamNode.stream = currentSong
var nextSong:AudioStream
		
		
func play_song(songID:int=currSongID):
	var loadedSong:AudioStream = load(musicFound[songID])
	if not loadedSong is AudioStream: push_error("This is not a song."); return
	
	currentSong = loadedSong
	if streamNode: streamNode.play()

func song_ended():
	var stop:bool 
	var looped:bool = false
	currSongID+=1
	if currSongID == musicFound.size(): currSongID = 0; looped = true
	
	if looped and not loop: stop = true
	
	if autoPlay and not stop: play_song()


func scan_folders(clearPrevious:bool=true):
	if clearPrevious: musicFound.clear()
	
	for folder in musicFolders:
		var files:PackedStringArray = DirAccess.get_files_at(folder)
		for file in files:
			musicFound.append(folder+file)
