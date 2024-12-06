extends Node3D

var collider := CollisionShape3D.new()
var colors:Array[Color] = [
	Color.AQUA,
	Color.BLUE,
	Color.BROWN,
	Color.CHOCOLATE,
	Color.SLATE_BLUE,
	Color.DARK_SLATE_BLUE
]

@export var global_count_of_points:int = 512
@export var max_count_per_call:int = 1024
@export var count_of_meshes:int = 1
@export var min_raius:float = 0.0
@export var max_radius:float = 10.0
var uvs_gap_x:float = 1.0/float(Globals.global_texture_size.x)
var uvs_gap_y:float = 1.0/float(Globals.global_texture_size.y)

var ico_sphere:ArrayMesh = preload("res://ico_sphere.obj")
var box:ArrayMesh = preload("res://box.obj")
var custom_mesh:ArrayMesh = ArrayMesh.new()
var material:StandardMaterial3D = preload("res://def_material.tres")
var all_points:PackedVector3Array
var uvs:PackedVector2Array
var mdt: MeshDataTool

func get_random_point_circle(min_radius:float, max_radius:float) -> Vector3:
	return Vector3((randf()-0.5)*2, (randf()-0.5)*2, (randf()-0.5)*2) * randf_range(min_radius, max_radius)

func get_random_point_circle_better(min_radius:float, max_radius:float) -> Vector3:
	var result := Vector3(randf_range(min_radius, max_radius)*[-1, 1].pick_random(), randf_range(min_radius, max_radius)*[-1, 1].pick_random(), randf_range(min_radius, max_radius)*[-1, 1].pick_random())
	if result.length() > max_radius:
		result *= randf_range(0.2, 0.6)
	return result

func get_random_color() -> Color:
	return Color(randf()*0.5+0.5, randf()*0.5+0.5, randf()*0.5+0.5)

func get_random_color2() -> Color:
	return colors.pick_random()

func create_box_2(count:int) -> void:
	var im = ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_POINTS, material)
	for i in range(count):
		im.surface_add_vertex(get_random_point_circle(1, 10))
	im.surface_end()
	$mesh.mesh = im

var idx_colors = 0 
var colorss:Array[Color] = [
	Color.AQUA,
	Color.BLACK,
	Color.BLUE,
	Color.BLACK,
	Color.CRIMSON,
	Color.BLACK
]

func things_of_timer() -> void:
	#$texture3/Node2D.add_point(Vector2i(randi_range(0, 512), 0),get_random_color2())
	#smooth_redraw_to(colors.pick_random())
	
	#var cur_color = Color.WEB_PURPLE
	#for i in range(int(1/0.01)):
		#$texture3/Node2D.add_rect(Rect2i(0, 0, 512, 20), cur_color )
		#cur_color = cur_color.lerp(Color.AQUA, 0.01)
	#for i in range(int(1/0.01)):
		#$texture3/Node2D.add_rect(Rect2i(0, 0, 512, 20), cur_color )
		#cur_color = cur_color.lerp(Color.WEB_PURPLE, 0.01)
	var tween = create_tween()
	tween.tween_property($texture3/TextureRect, 'modulate', Color.REBECCA_PURPLE, 1.5).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($texture3/TextureRect, 'modulate', Color.AQUA, 1.5).set_trans(Tween.TRANS_QUAD)

func _ready() -> void:
	$texture3.size = Globals.global_texture_size
	var shape := SphereShape3D.new()
	shape.radius = 0.5
	collider.shape = shape
	
	$texture.texture = $texture3.get_texture()
	
	material.albedo_texture = $texture3.get_texture()
	var start_time:float = Time.get_ticks_msec()/1000.0
	#await create_points2(global_count_of_points, count_of_meshes)
	await create_points3(global_count_of_points, max_count_per_call)
	#await create_points(global_count_of_points)
	var end_time:float = Time.get_ticks_msec()/1000.0
	print('time to load: ', end_time-start_time)
	$Timer.timeout.connect(func(): things_of_timer() )
	
	#$Timer.start()
	
	#$texture.texture = $texture3.get_texture()
	
func create_points2(count:int, itterations:int) -> void:
	#var def_arrays:PackedVector3Array = ico_sphere.surface_get_arrays(0)[0]
	var def_arrays:PackedVector3Array = Globals.box_array
	var current_uv = Vector2(uvs_gap_x/2.0, uvs_gap_y/2.0)
	
	for itteration in range(itterations):
		
		var new_instance = MeshInstance3D.new()
		var mesh := ArrayMesh.new()
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		
		all_points.clear()
		uvs.clear()
		
		for i in range(def_arrays.size()*count): uvs.append(Vector2(0, 0))
		
		for i in range(count): 
			var random_position := get_random_point_circle_better(min_raius, max_radius)
			all_points.append_array(def_arrays.duplicate())
			#print('size start: ', i*def_arrays.size(), 'size end: ', cur_array.size())
			for j in range(i*def_arrays.size(), all_points.size()):
				all_points[j] += random_position
				uvs[j] = current_uv
			current_uv.x += uvs_gap_x
			if current_uv.x >= 1.0-uvs_gap_x:
				current_uv.x = uvs_gap_x/2.0
				current_uv.y += uvs_gap_y
		print('final uv: ', current_uv)
		arrays[0] = all_points
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		all_points.clear()
		uvs.clear()
		
		new_instance.mesh = mesh
		new_instance.material_override = material
		$meshes.add_child(new_instance)
		#mdt = MeshDataTool.new()
		#mdt.create_from_surface($mesh.mesh, 0)

func create_points3(count:int, max_points_per_call:int) -> void:
	if count <= 0: return
	Globals.all_points.clear()
	#var def_arrays:PackedVector3Array = ico_sphere.surface_get_arrays(0)[0]
	var def_arrays:PackedVector3Array = Globals.box_array
	var current_uv := Vector2(uvs_gap_x/2.0, uvs_gap_y/2.0)
	var point_idx:int = 0
	
	for it in range(ceili(count/float(max_points_per_call))):
		
		var cur_points:int = 0
		var new_instance = MeshInstance3D.new()
		var mesh := ArrayMesh.new()
		var arrays:Array = []
		var loop_count:int = min(abs(count - (it * max_points_per_call)), max_count_per_call)
		arrays.resize(Mesh.ARRAY_MAX)
		
		all_points.clear()
		uvs.clear()
		
		for i in range(def_arrays.size()*loop_count): uvs.append(Vector2(0, 0))
		
		while cur_points < loop_count:
			var random_position := get_random_point_circle_better(min_raius, max_radius)
			all_points.append_array(def_arrays.duplicate())
			#print('size start: ', i*def_arrays.size(), 'size end: ', cur_array.size())
			for j in range(cur_points*def_arrays.size(), all_points.size()):
				all_points[j] += random_position
				uvs[j] = current_uv
			current_uv.x += uvs_gap_x
			if current_uv.x >= 1.0:
				current_uv.x = uvs_gap_x/2.0
				current_uv.y += uvs_gap_y
			cur_points += 1
			
			var new_point := Point.new()
			new_point.idx = point_idx
			new_point.position = random_position
			new_point.find_pixel_locaion()
			Globals.all_points.append(new_point)
			
			point_idx += 1
		print('final uv: ', current_uv)
		arrays[0] = all_points
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		all_points.clear()
		uvs.clear()
		
		new_instance.mesh = mesh
		new_instance.material_override = material
		$meshes.add_child(new_instance)
		#mdt = MeshDataTool.new()
		#mdt.create_from_surface($mesh.mesh, 0)
func create_points(count:int) -> void:
	var mesh := ArrayMesh.new()
	var def_arrays:PackedVector3Array = ico_sphere.surface_get_arrays(0)[0]
	for i in range(count):
		var random_position := get_random_point_circle(10.0, 150.0)
		var cur_array = def_arrays.duplicate()
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		for j in range(cur_array.size()):
			cur_array[j] += random_position
		arrays[0] = cur_array
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	$mesh.mesh = mesh

func smooth_redraw_to(_color:Color) -> void:
	for i in range(10):
		for itteration in range(512):
			$texture3/Node2D.add_point(Vector2i(itteration, i), _color)
		#await get_tree().create_timer(0.01).timeout

var prev_point:Vector2i = Vector2i(-1, -1)
func check_for_select() -> void:
	var camera_ray:Vector3 = $player/cam_pos/camera.project_ray_normal($player/cam_pos/camera/node2d.get_local_mouse_position())
	var closest_distance:float = 0.0
	var cur_point:Point
	
	for point in Globals.all_points:
		var point_ray:Vector3 = point.position.direction_to($player/cam_pos/camera.global_position)
		var distance_to_camera:float = point.position.distance_to($player/cam_pos/camera.global_position)
		if camera_ray.dot(point_ray) < (-1 + (0.05/distance_to_camera)):
			if closest_distance == 0.0 or distance_to_camera < closest_distance:
				cur_point = point
				closest_distance = distance_to_camera
				continue
				
	if cur_point == null:
		return
	if prev_point != Vector2i(-1, -1):
		$texture3/Node2D.add_point(prev_point, Color.TOMATO)
		
	$player/cam_pos/camera.move_to(cur_point.position)
	$texture3/Node2D.add_point(cur_point.pixel_position, Color.SEA_GREEN)
	prev_point = cur_point.pixel_position
	print('drawed point in: ', cur_point.pixel_position, ' with idx: ', cur_point.idx)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		check_for_select()
