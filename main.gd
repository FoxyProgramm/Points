extends Node3D

@onready var points_mesh:MultiMeshInstance3D = $points
#var points = []
var mesh:Mesh
var immediate_mesh:ImmediateMesh

var def_material:StandardMaterial3D = preload("res://def_material.tres")
var wire_material:StandardMaterial3D = preload("res://wire_material.tres")
var currect_count:int = 0

var rnd:RandomNumberGenerator = RandomNumberGenerator.new()
var seed:int = 0

func get_random_point_box(size_x:float, size_y:float, size_z:float) -> Vector3:
	return Vector3(rnd.randf_range(-size_x, size_x), rnd.randf_range(-size_y, size_y), rnd.randf_range(-size_z, size_z))

func get_random_point_circle(min_radius:float, max_radius:float) -> Vector3:
	return Vector3((rnd.randf()-0.5)*2.0, (rnd.randf()-0.5)*2.0, (rnd.randf()-0.5)*2.0).normalized() * rnd.randf_range(min_radius, max_radius)

func generate_points2(count:int) -> void:
	var new_multimesh := MultiMesh.new()
	new_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	new_multimesh.mesh = mesh
	new_multimesh.instance_count = count
	
	#await get_tree().create_timer(1.0).timeout
	Globals.all_points.clear()
	var _current_count:int = currect_count
	for i in range(count):
		var random_position:Vector3 = get_random_point_circle(10,40)
		var new_point:Point = Point.new()
		new_point.idx = i
		new_point.position = random_position
		#points.append(random_position)
		var trans := Transform3D(Basis.IDENTITY, random_position)
		new_multimesh.set_instance_transform(i, trans)
		Globals.all_points.append(new_point)
	points_mesh.multimesh = new_multimesh

func generate_points3() -> void:
	var file_data:Array[String] = []
	var file = FileAccess.open("res://input_files/points.csv", FileAccess.READ)
	var count:int
	var new_multimesh := MultiMesh.new()
	
	while file.get_position() < file.get_length():
		count += 1
		file_data.append(file.get_line())
	
	new_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	new_multimesh.mesh = mesh
	new_multimesh.instance_count = count
	file.get_reference_count()
	
	#await get_tree().create_timer(1.0).timeout
	Globals.all_points.clear()
	var _current_count:int = currect_count
	var i:int = 0
	for raw_data in file_data:
		var data = raw_data.split('	')
		#var random_position:Vector3 = get_random_point_circle(10,40)
		var random_position:Vector3 = Vector3(float(data[1]), float(data[2]), float(data[3]))*0.08
		var new_point:Point = Point.new()
		new_point.idx = int(data[0])
		new_point.position = random_position
		#points.append(random_position)
		var trans := Transform3D(Basis.IDENTITY, random_position)
		new_multimesh.set_instance_transform(i, trans)
		Globals.all_points.append(new_point)
		i+=1
	points_mesh.multimesh = new_multimesh
	file.close()


func generate_lines(radius:float, min_connections:int, max_connections:int) -> void:
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, wire_material)
	for point:Point in Globals.all_points:
		for i in range(min_connections):
			if point.connected_with_points.size() >= max_connections: break
			var point_to_connect:Point = point.find_closest_point(Point.TYPE_OF_FIND_POINTS.without_connections, radius, max_connections)
			if point_to_connect == null: break
			point.connect_to(point_to_connect)
			immediate_mesh.surface_add_vertex(point.position)
			immediate_mesh.surface_add_vertex(point_to_connect.position)
	immediate_mesh.surface_end()

func generate_lines2() -> void:
	var file = FileAccess.open("res://input_files/links.csv", FileAccess.READ)
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, wire_material)
	while file.get_position() < file.get_length():
		var raw_points:String = file.get_line()
		var points:PackedStringArray = raw_points.split("	")
		
		immediate_mesh.surface_add_vertex(Globals.get_point_by_idx(points[0]).position)
		immediate_mesh.surface_add_vertex(Globals.get_point_by_idx(points[1]).position)
	immediate_mesh.surface_end()
	file.close()
	
func generate_thing() -> void:
	var count:int = 500
	var start_time:float = Time.get_ticks_msec()/1000.0
	#await generate_points2(count)
	await generate_points3()
	#Globals.all_points[1].need_to_connect_with=[
		#2,3,4,5,6,7,8,9,10
	#]
	await generate_lines2()
	#await generate_lines(0.0, 2, 3)
	var end_time:float = Time.get_ticks_msec()/1000.0
	print('time to load: ', end_time-start_time)
	print("random seed: ", rnd.seed)
	rnd.seed += 1
	#rnd.state = 0

func _ready() -> void:
	#await get_tree().create_timer(1.0).timeout
	mesh = BoxMesh.new()
	mesh.size = Vector3(0.1,0.1,0.1)
	mesh.material = def_material
	immediate_mesh = ImmediateMesh.new()
	$wires.mesh = immediate_mesh
	#generate_points(10000, 0.0)
	rnd.state = 0
	rnd.seed = seed
	
	generate_thing()
