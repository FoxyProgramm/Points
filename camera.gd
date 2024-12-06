extends Camera3D

@onready var cam_look = $"../../cam_look"

enum TYPE_CONTROL {player, orbit}
var current_control:int = TYPE_CONTROL.orbit

var actual_zoom:Vector3 = Vector3(0, 0, 4)

var speed:float = 50.0
var acceleration:float = 1.0
var velocity:Vector3 = Vector3()
var can_move:bool = false

var move:bool = false
var drag:bool = false

func _process(delta: float) -> void:
	match current_control:
		TYPE_CONTROL.player:
			var raw_direction = Input.get_vector('left', 'right', 'toward', 'backward')
			var direction = Vector3(raw_direction.x, Input.get_axis('down', 'up'), raw_direction.y)
			velocity = velocity.move_toward(self.basis * direction*speed, acceleration*delta*60 )
			self.global_position += velocity * delta
			self.quaternion = self.quaternion.slerp(cam_look.quaternion, min(delta*10, 1.0))
		TYPE_CONTROL.orbit:
			drag = Input.is_action_pressed("drag")
			move = Input.is_action_pressed("move")
			$"..".quaternion = $"..".quaternion.slerp(cam_look.quaternion, min(delta*10, 1.0))
			self.position = self.position.lerp(actual_zoom, min(delta*5,1.0))
			$"..".position = $"..".position.lerp($"../../cam_pos_to".position, min(delta*5,1.0))
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if can_move and current_control == TYPE_CONTROL.player:
			cam_look.rotation.x = clamp(cam_look.rotation.x - event.relative.y*0.005, -1.45, 1.45)
			cam_look.rotation.y -= event.relative.x*0.005
		if drag and current_control == TYPE_CONTROL.orbit:
			cam_look.rotation.x = clamp(cam_look.rotation.x - event.relative.y*0.005, -1.45, 1.45)
			cam_look.rotation.y -= event.relative.x*0.005
		if move and current_control == TYPE_CONTROL.orbit:
			$"../../cam_pos_to".position -= global_transform.basis * Vector3(event.relative.x, -event.relative.y, 0) * actual_zoom.length() * 0.005
	if current_control == TYPE_CONTROL.orbit:
		if event.is_action_pressed("zoom_out"):
			actual_zoom.z *= 1.2
		elif event.is_action_pressed("zoom_in"):
			actual_zoom.z *= 0.8
	
	if event.is_action_pressed("debug"):
		Input.mouse_mode = abs(Input.mouse_mode - 2)
		if Input.mouse_mode == 0:
			can_move = false
		else :
			can_move = true
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("gen"):
		$"../../..".generate_thing()

func move_to(pos:Vector3) -> void:
	$"../../cam_pos_to".global_position = pos
	actual_zoom = Vector3(0, 0, 4)
