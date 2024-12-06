extends Node2D

@export var draw_points_per_tick:int = 10

var queue = [
	#[Vector2i(0,0), Color.RED]
]

var draw_queue = [
	
]

var rect:Rect2i
var color:Color

const CONST_DELIMITER: int = 255

var delimiter:int = 255
var i:float = 0.0

func add_point(_position:Vector2i, _color:Color) -> void:
	queue.append([Rect2i(_position, Vector2i.ONE), _color])
	#queue_redraw()

func add_rect(_rect:Rect2i, _color:Color) -> void:
	queue.append([_rect, _color])
	#queue_redraw()

func _process(delta: float) -> void:
	#if queue.size() > draw_points_per_tick:
		#draw_queue = []
		#for i in range(draw_points_per_tick):
			#draw_queue.append([queue[0][0], queue[0][1]])
			#queue.remove_at(0)
		#queue_redraw()
	if queue.size() > 0 :
		draw_queue = [[queue[0][0], queue[0][1]]]
		queue.remove_at(0)
		queue_redraw()

func _draw() -> void:
	if draw_queue.size() == 0: return
	for item in draw_queue:
		draw_rect(item[0], item[1])
