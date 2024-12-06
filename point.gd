class_name Point

enum TYPE_OF_FIND_POINTS {any, with_connections, without_connections}

var idx:int = 0
var name:String = ""
var description:String = ""
var position:Vector3 = Vector3()
var pixel_position:Vector2i = Vector2i()
var connected_with_points = []
var need_to_connect_with = []

func find_pixel_locaion() -> void:
	pixel_position = Vector2i(
		idx - ( int(idx/float(Globals.global_texture_size.x)) * Globals.global_texture_size.x ),
		floori(idx/float(Globals.global_texture_size.x))
		)
	

func connect_to(point:Point) -> void:
	connected_with_points.append(point.idx)
	point.connected_with_points.append(idx)

func find_closest_point(type_finding:TYPE_OF_FIND_POINTS = 0, radius:float = 0.0, max_connections:int = 0) -> Point:
	var closest_point = null
	var closest_distance:float = 0.0
	if type_finding == TYPE_OF_FIND_POINTS.with_connections:
		for _idx:int in connected_with_points:
			var point = Globals.all_points[_idx]
			var point_distance:float = point.position.distance_to(position)
			if point == self: continue
			if radius > 0.0 and point_distance > radius: continue
			if max_connections > 0 and point.connected_with_points.size() >= max_connections: continue
			if closest_point != null and point_distance > closest_distance: continue
			closest_point = point
			closest_distance = closest_point.position.distance_to(position)
		return closest_point
	for point:Point in Globals.all_points:
		if point == self: continue
		var point_distance:float = point.position.distance_to(position)
		if radius > 0.0 and point_distance > radius: continue
		if point.connected_with_points.size() >= max_connections: continue
		if closest_point != null and point_distance > closest_distance: continue
		match type_finding:
			TYPE_OF_FIND_POINTS.any:
				closest_point = point
				closest_distance = closest_point.position.distance_to(position)
			TYPE_OF_FIND_POINTS.without_connections:
				if point.idx in connected_with_points: continue
				closest_point = point
				closest_distance = closest_point.position.distance_to(position)
	return closest_point
