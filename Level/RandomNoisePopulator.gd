extends Node2D
class_name RandomNoisePopulator

@export var tile_map: TileMapLayer 
@export var noise: Noise

##From 0 to 1. The value of the noise must be higher than this to count as a spawning point.
@export var tree_frequency: float = 0.6

var trees_spawned_dict: Dictionary

func find_spawn_points( player_pos: Vector2, area: Vector2i) -> Array[Vector2i]:
  var output: Array[Vector2i]

  ##This will work using tilemap coordinates.
  var player_cell: Vector2i = tile_map.local_to_map(player_pos)

  ##Creates a rectangle for facilitating the math, tree spawn points will be searched for inside this.
  var boundaries := Rect2i(player_cell - area, area)

  ##Sweep the rectangle
  for x: int in range(boundaries.position.x, boundaries.end.x):
    for y: int in range(boundaries.position.y, boundaries.end.y):

      ##If these coordinates yield a noise value that's high enough, add it to the list. 
      if noise.get_noise_2d(x,y) > tree_frequency:
        output.append(Vector2i(x,y))
        
  return output
  

func add_tree(spot: Vector2i):
  ##If this spot already has a tree, skip all this.
  if trees_spawned_dict.has(spot): 
    return
  ##Otherwise, create a new one.
  else: 
    var new_tree: Node2D = load("path_to_tree_scene").instantiate()
    trees_spawned_dict[spot] = new_tree
    add_child(new_tree)

func remove_tree(spot: Vector2i):
  var tree_found: Node2D = trees_spawned_dict.get(spot, null)
  if tree_found == null: 
    return
  else:
    trees_spawned_dict.erase(spot)
    tree_found.queue_free()
      
func remove_far_trees(player_pos: Vector2, max_spawn_dist: float):
  for spot: Vector2i in trees_spawned_dict:
    var real_coord: Vector2 = tile_map.map_to_local(spot)
    if real_coord.distance_to(player_pos) > max_spawn_dist:
      remove_tree(spot)

func add_trees(player_position: Vector2i, max_spawn_dist: float):
  var spawn_spots: Array[Vector2i] = find_spawn_points(player_position, Vector2i(30,30)) 

  for spot: Vector2i in spawn_spots:
    add_tree(spot)
  