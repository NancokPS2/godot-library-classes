extends Node
class_name Utility

class SignalFuncs extends Node:
	
	## receiver should usually be self
	static func disconnect_signals_from(receiver:Object, emitter:Object):
		var connections:Array[Dictionary] = receiver.get_incoming_connections()
		
		for connection in connections:
			var signa:Signal = connection["signal"]
			var callable:Callable=connection["callable"]
			var signalOwnerID:int = signa.get_object_id()

			if signalOwnerID == emitter.get_instance_id() and callable.get_object_id()==receiver.get_instance_id():
				connection["signal"].disconnect(callable)
		
class NodeFuncs extends Node:
	
	static func get_all_children(node:Node,typeFilter:String=""):
		
		var nodes : Array = []

		for child in node.get_children():

			if child.get_child_count() > 0:
					nodes.append(child)

					nodes.append_array(get_all_children(child))

			else:

				nodes.append(child)

		return nodes
	static func remove_all_children(node:Node):
		for child in node.get_children():
			node.remove_child(child)
