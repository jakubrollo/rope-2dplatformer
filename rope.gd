extends Node2D

@onready var rope_end_1 = $RopeEndPiece1  
var start_pos : Vector2
var piece_length: float
var col_shape
var overlap_factor = 1
var adjusted_piece_length

var last_piece: Node2D
var rope_pieces: Array = []
var piece_angle: float

func _ready():
	col_shape = rope_end_1.get_node("CollisionShape2D")
	piece_length = col_shape.shape.size.y * col_shape.scale.y
	adjusted_piece_length = piece_length * overlap_factor
	pass

func spawn_rope(start_pos: Vector2, end_pos: Vector2):
	self.start_pos = start_pos
	rope_end_1.position = end_pos

	piece_angle = end_pos.angle_to_point(start_pos) + PI / 2
	var distance = end_pos.distance_to(start_pos)
	rope_end_1.rotate(piece_angle)

	var num_pieces = int(distance / adjusted_piece_length) + 1  

	last_piece = rope_end_1  
	rope_pieces.append(last_piece)

	for i in range(1, num_pieces):
		var rope_piece = preload("res://scenes/RopePiece.tscn").instantiate()

		var overlap_position = i * adjusted_piece_length / distance
		rope_piece.position = end_pos.lerp(start_pos, overlap_position)  
		rope_piece.rotation = piece_angle
		add_child(rope_piece)
		rope_pieces.append(rope_piece)

		if last_piece:
			var joint = rope_piece.get_node("PinJoint2D")
			joint.node_a = last_piece.get_path()
			joint.node_b = rope_piece.get_path()

		last_piece = rope_piece

	return last_piece

func lengthen_rope():
	var direction = (-last_piece.global_transform.y).normalized()
	var new_piece_pos = last_piece.position + direction * adjusted_piece_length

	var query_params = PhysicsPointQueryParameters2D.new()
	query_params.position = new_piece_pos

	var space_state = get_world_2d().direct_space_state
	var collisions = space_state.intersect_point(query_params)

	for collision in collisions:
		if collision.collider.is_in_group("Player"):
			continue
		else:

			print("Cannot spawn rope piece. Collision detected with:", collision.collider)
			return last_piece

	var rope_piece = preload("res://scenes/RopePiece.tscn").instantiate()
	rope_piece.position = new_piece_pos
	rope_piece.rotation = last_piece.rotation  
	
	add_child(rope_piece)
	rope_pieces.append(rope_piece)

	var joint = rope_piece.get_node("PinJoint2D")
	joint.node_a = last_piece.get_path()
	joint.node_b = rope_piece.get_path()

	last_piece = rope_piece

	return last_piece

func shorten_rope():
	if rope_pieces.size() <= 1:
		return last_piece  

	var piece_to_remove = rope_pieces[-1]
	var second_to_last_piece = rope_pieces[-2]

	var joint = piece_to_remove.get_node("PinJoint2D")
	if joint:
		joint.queue_free()

	rope_pieces.pop_back()  
	piece_to_remove.queue_free()

	last_piece = second_to_last_piece

	return last_piece
