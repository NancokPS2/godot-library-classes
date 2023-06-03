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
	
	static func get_all_children(node:Node,typeFilter:String="")->Array[Node]:
		
		var nodes:Array[Node]

		for child in node.get_children():

			if child.get_child_count() > 0:
					nodes.append(child)

					nodes.assign(get_all_children(child))

			else:

				nodes.append(child)
		return nodes
		
	static func remove_all_children(node:Node):
		for child in node.get_children():
			node.remove_child(child)

class VectorFuncs extends Node:
	
	static func calc_manhattan_distance_3d(vecA:Vector3, vecB:Vector3)->float:
		return abs(vecA.x - vecB.x) + abs(vecA.y - vecB.y) + abs(vecA.z - vecB.z)

class GridFuncs extends Node:
	static func get_adjacent_cells(originCell:Vector3i)->Array[Vector3i]:
		var directions:Array[Vector3i]=[Vector3i.UP,Vector3i.DOWN,Vector3i.BACK,Vector3i.FORWARD,Vector3.LEFT,Vector3i.RIGHT]
		var adjacents:Array[Vector3i]
		
		for direction in directions:
			adjacents.append(Vector3i(originCell+direction))
		return adjacents
		
	static func mass_map_to_local(cells:Array[Vector3i])->Array[Vector3]:
		var returnal:Array[Vector3]
		for vec3i in cells:
			returnal.append(Vector3(vec3i))
		
		return returnal

class VisualFuncs extends Node:
	
	static func place_sphere_3d(parent:Node, position:Vector3, radius:float):
		var mesh:=SphereMesh.new(); mesh.radius = radius
		var meshInst:=MeshInstance3D.new(); meshInst.position = position; meshInst.mesh = mesh
		parent.add_child(meshInst)
		
		
		
		
		
		
