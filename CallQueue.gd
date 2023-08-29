extends Node
class_name CallQueue

signal call_performed(call:Callable)
signal failed
signal finished

@export var defaultInterval:float = 0.5

var intervalTimer:=Timer.new()

var queue:Array[Call]

var _is_running:bool
var _queueProgress:int

func _ready() -> void:
	add_child(intervalTimer)

func add_queued(call:Callable, atIndex:int=queue.size()):
	if not call.is_valid(): push_error("Invalid Callable"); return
	var newCall := Call.new()
	newCall.callable = call
	newCall.postWait = defaultInterval
	queue.insert(atIndex, newCall)
	assert(not queue.is_empty())
	
	##Sets arguments to a callable, targets the last one added by default
func set_queued_arguments(arguments:Array, index:int = -1):
	queue[index].arguments = arguments
	
func set_queued_identifier(identifier:String, index:int = -1):
	queue[index].identifier = identifier
	
func set_queued_post_wait(time:float, index:int = -1):
	queue[index].postWait = time
	
	## Lower numbers are a higher priority
func set_queued_priority(priority:int, index:int = -1):
	queue[index].priority = priority

func get_queued_by_index(index:int)->Call:
	assert(index > -1 and index < queue.size(), "index out of bounds!")
#	if queue.size() >= index: push_error("Index is larger than the queue"); return error_callable
#	elif index < 0: push_error("Index is under 0"); return error_callable
	return queue[index]

func get_queued_by_identifier(identifier:String)->Call:
	if identifier == "": push_error("identifier is empty"); return null
	for call in queue:
		if call.identifier == identifier: return call
	return null
	
func remove_queued(index:int):
	queue.remove_at(index)
	


func run_queue(fromIndex:int = 0):
	assert(not _queueProgress < 0, "Should not start below 0")
	intervalTimer.paused = false
	_sort_by_priority()
	_queueProgress = fromIndex
	_run_loop()
	
func pause_queue():
	intervalTimer.paused = true
	
func terminate_queue(successful:bool=true, alsoClear:bool=true):
	if is_running(): 
		if intervalTimer.timeout.is_connected(_run_loop): intervalTimer.timeout.disconnect(_run_loop)			
		intervalTimer.stop()
		if alsoClear: clear_queue()
		
		if successful: finished.emit()
		else: failed.emit()
		
	else: push_error("The queue is not running.")
	
	
func clear_queue():
	queue.clear()
	
func is_running():
	return false if intervalTimer.paused or intervalTimer.is_stopped() else true

	##Private
func _sort_by_priority():
	var sortingFunc := func(a:Call, b:Call):
		return a.priority < b.priority
	queue.sort_custom(sortingFunc)

	##Private
func _run_loop():
	var queuedCallRef:Call = queue[_queueProgress]
	
	#Validate the call
	if not queuedCallRef.callable.is_valid(): 
		push_error("Invalid callable found at index " + str(_queueProgress))
		terminate_queue(false)
		return
	
	#Perform the call
#	queuedCallRef.callable.callv(queuedCallRef.arguments) #callv NOT WORKING
	queuedCallRef.callable = queuedCallRef.callable.bindv(queuedCallRef.arguments)
	queuedCallRef.callable.call()

	call_performed.emit()
	print_debug("Performed call for method " +  queuedCallRef.callable.get_method() + " with arguments " + str(queuedCallRef.arguments))
	_queueProgress+=1
	
	#Abort if there's no more to call
	if _queueProgress >= queue.size(): 
		terminate_queue(true)
		return
	
	#Continue the loop.
	intervalTimer.timeout.connect(_run_loop, CONNECT_ONE_SHOT)
	intervalTimer.start(queuedCallRef.postWait)

class Call extends RefCounted:
	var callable:Callable
	var arguments:Array = []
	
	var postWait:float
	var priority:int
	var identifier:String

	
