extends Node2D


@onready var pathfinding = $PointsOfInterest/PathfindingLogic as PathfinderLogic
var pathfinding_array : Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready():
	pathfinding_array =  $PointsOfInterest.get_children().filter(func(node): return node is PathfinderLogic )
	for node in pathfinding_array:
		pass
		#node.pathfinding_init()
	#
	#var point = NavigationServer2D.map_get_closest_point(get_world_2d().navigation_map, $Marker2D.position)
	#print(point)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
