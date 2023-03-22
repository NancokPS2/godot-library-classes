extends AudioStreamPlayer
class_name AudioController

var channels:Dictionary
enum StreamerType {NON_POSITIONAL,TWO_D,THREE_D}
enum ControlOption {PLAY,STOP,SEEK}

func create_streamer(channel:String,type:StreamerType=StreamerType.NON_POSITIONAL, parent:Node=self):
	var streamer
	
	match type:
		StreamerType.NON_POSITIONAL:
			if not channels.get(channel) is AudioStreamPlayer:
				streamer = AudioStreamPlayer.new()
				
		StreamerType.TWO_D:
			if not channels.get(channel) is AudioStreamPlayer2D:
				if parent is Node2D:
					streamer = AudioStreamPlayer2D.new()
				else:
					push_error("Cannot add a 2D streamer to a non-2D node")
			else:
				push_warning("There is already an AudioStreamPlayer2D in channel " + channel)
				
		StreamerType.THREE_D:
			if not channels.get(channel) is AudioStreamPlayer3D:
				if parent is Node3D:
					streamer = AudioStreamPlayer3D.new()
				else:
					push_error("Cannot add a 3D streamer to a non-3D node")
			else:
				push_warning("There is already an AudioStreamPlayer3D in channel " + channel)
				
	channels[channel] = streamer
	add_child(streamer)

func add_stream(channel:String, audio:AudioStream):
	channels[channel].stream = audio

func control_streamer(channel:String,option:ControlOption,optionalParam=0.0):
	if not channels.has(channel):
		push_error("Channel " + channel + " does not exist.")
		return 
		
	match option:
		ControlOption.PLAY:
			channels[channel].play(optionalParam)
			#if channels[channel].playing: channels[channel].play(optionalParam)
		
		ControlOption.STOP:
			channels[channel].stop()
			
		ControlOption.SEEK:
			channels[channel].seek(optionalParam)

func play_stream_shortcut(channel:String, audio:AudioStream, streamerType:StreamerType=StreamerType.NON_POSITIONAL, autoFree:bool=true):
	create_streamer(channel, streamerType)
	add_stream(channel, audio)
	control_streamer(channel, ControlOption.PLAY)
	
	if autoFree: channels[channel].finished.connect( Callable(channels[channel],"queue_free") )
	


