extends Node

signal find_idx(_idx)
signal point_finded
var finded_point:Point = null

var all_points:Array[Point] = []
var fast_access_to_points:Dictionary = {}
#var all_points = []
var distance_matrix:Array = []

func resize_distance_matrix(value:int) -> void:
	distance_matrix.resize(value)
	for i in range(value):
		distance_matrix[i] = []
		distance_matrix[i].resize(value)
		
func fill_distance_matrix() -> void:
	for i in range(all_points.size()-1):
		for j in range(i+1, all_points.size()-1):
			distance_matrix[i][j] = \
			all_points[i].position.distance_to(all_points[j].position)

func delete_point(idx:int) -> void:
	for i in range(all_points.size()-1):
		distance_matrix[i][idx] = null
		distance_matrix[idx][i] = null
		
func custom_min(array:Array) -> float:
	var min:float = 10000.0
	for element in array:
		if element == null : continue
		if element < min and element > 0.0:
			min = element
	return min

func find_lower_distance_in(idx:int) -> int:
	return distance_matrix[idx].find(custom_min(distance_matrix[idx]))

func get_point_by_idx(idx:String) -> Point:
	#return all_points[idx-30000000]
	if fast_access_to_points.has(idx):
		return fast_access_to_points[idx]
	
	for point in all_points:
		if point.idx == int(idx):
			fast_access_to_points[idx] = point
			return point
	return null

func get_point_by_name(name:String) -> Point:
	for point in all_points:
		if point.name == name: return point
	return null
