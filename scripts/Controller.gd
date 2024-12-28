extends RigidBody2D

@export var is_skeleton_animation: bool = false
@export var max_speed: float = 400.0
@export var stopping_damping: float = 0.1
@export var turning_damping: float = 0.6
@export var max_jump_force: float = 750.0
@export var min_jump_force: float = 500.0
@export var coyote_time: float = 0.2
@export var jump_cooldown_time: float = 0.4
@export var wall_jump_cooldown_time: float = 0.2
@export var raycast: ShapeCast2D
@export var rope_scene: PackedScene
@export var rope_cooldown_time: float = 0.1
@export var acceleration: float = 12000

@onready var left_wall_raycast = $LeftWallRayCast
@onready var right_wall_raycast = $RightWallRayCast
@onready var animation = $AnimatedSprite2D if not is_skeleton_animation else $AnimationPlayer

var rope_cooldown_counter: float = 0.0
var active_rope: Node2D = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2.0
var is_on_ground: bool = false
var is_jumping: bool = false
var can_buffer_jump = false
var wall_jump_buffer_counter: float = 0.0
var coyote_time_counter: float = 0.0
var jump_cooldown_counter: float = 0.0

var lengthen_requested = false
var shorten_requested = false

func _ready() -> void:
	$AnimatedSprite2D.visible = not is_skeleton_animation
	$Skeleton2D.visible = is_skeleton_animation

func _physics_process(delta: float) -> void:
	rope_cooldown_counter = max(0.0, rope_cooldown_counter - delta)
	apply_central_force(Vector2(0, gravity * mass))

	if active_rope and not is_on_ground:
		handle_rope_movement(delta)
		check_player_position_to_rope()
	else:
		handle_ground_movement(delta)

	if is_on_ground:
		coyote_time_counter = coyote_time
	else:
		coyote_time_counter -= delta

	if Input.is_action_just_pressed("Jump") and jump_cooldown_counter <= 0.0:
		can_buffer_jump = true

	if can_buffer_jump and coyote_time_counter > 0.0 and not is_jumping and jump_cooldown_counter <= 0.0:
		jump()

	if is_jumping and Input.is_action_just_released("Jump"):
		if linear_velocity.y < -min_jump_force:
			linear_velocity.y = -min_jump_force  
		is_jumping = false

	jump_cooldown_counter = max(0.0, jump_cooldown_counter - delta)
	if active_rope != null and !is_on_ground:	
		lock_rotation = false
	else:
		rotation = 0
		lock_rotation = true
	
	rotation_degrees = clamp(rotation_degrees, -90.0, 90.0)

	update_animation()
	update_raycast()
	
	if lengthen_requested:
		active_rope.lengthen_rope() 
		rope_cooldown_counter = rope_cooldown_time
		player_rope_move()
		lengthen_requested=false

	if shorten_requested:
		active_rope.shorten_rope()
		rope_cooldown_counter = rope_cooldown_time
		player_rope_move()
		shorten_requested=false

func handle_rope_movement(delta: float) -> void:
	can_buffer_jump = false
	var gravity_vector = Vector2(0, 100) * mass
	if Input.is_action_pressed("Right") and linear_velocity.length() < 400.0:
		apply_central_impulse(global_transform.x * 365.0 + gravity_vector)
	elif Input.is_action_pressed("Left") and linear_velocity.length() < 400.0:
		apply_central_impulse(global_transform.x * -365.0 + gravity_vector)

func handle_ground_movement(delta: float) -> void:
	var target_direction = 0
	if(wall_jump_buffer_counter>0):
		wall_jump_buffer_counter -= delta
	elif !is_on_ground and (left_wall_raycast.is_colliding() or right_wall_raycast.is_colliding()) and Input.is_action_just_pressed("Jump"):
		wall_jump()	
	elif Input.is_action_pressed("Left"):
		target_direction = -1
	elif Input.is_action_pressed("Right"):
		target_direction = 1

	if target_direction != 0:
		var current_velocity = linear_velocity.x
		var target_velocity = target_direction * max_speed
		var force = (target_velocity - current_velocity) *  mass / delta #*acceleration
		apply_central_force(Vector2(force, 0))
	else:
		var damping_force = -linear_velocity.x * stopping_damping * mass
		apply_central_force(Vector2(damping_force, 0))


func wall_jump() -> void:
	can_buffer_jump = false
	var jump_direction = Vector2.ZERO

	if left_wall_raycast.is_colliding():
		jump_direction = Vector2(max_speed, -max_jump_force)  
	elif right_wall_raycast.is_colliding():
		jump_direction = Vector2(-max_speed, -max_jump_force)  

	apply_central_impulse(jump_direction * mass)

	is_jumping = true
	jump_cooldown_counter = jump_cooldown_time  
	wall_jump_buffer_counter = wall_jump_cooldown_time

func jump() -> void:
	apply_central_impulse(Vector2.UP * max_jump_force * mass*1.1)
	is_jumping = true
	coyote_time_counter = 0.0
	can_buffer_jump = false
	jump_cooldown_counter = jump_cooldown_time

func update_animation() -> void:
	if active_rope and not is_on_ground:
		animation.play("jumping")
	elif is_on_ground:
		if abs(linear_velocity.x) < 0.5:
			animation.play("idle")
		else:
			animation.play("walking")
	elif linear_velocity.y > 0.0:
		animation.play("falling")
	else:
		animation.play("jumping")
		
	if not is_skeleton_animation and !active_rope and !(left_wall_raycast.is_colliding() or right_wall_raycast.is_colliding()):
		animation.flip_h = linear_velocity.x < 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SpawnRope"):
		spawn_rope()
	elif event.is_action_pressed("RemoveRope"):
		remove_rope()
		
	if event is InputEventMouseButton and active_rope and rope_cooldown_counter <= 0.0:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed and !is_on_ground:
			lengthen_requested = true

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			shorten_requested = true


func player_rope_move() -> void:
	rotation = 0
	var player_pin_joint = $PinJoint2D
	var player_pin_joint2 = $PinJoint2D2
	var last_piece_position = active_rope.last_piece.global_position
	
	var duration = 0.1
	var ease_type = EaseType.EASE_IN_OUT_QUAD
	var tween = Tweens.tween(self, "global_position", global_position, last_piece_position, duration, ease_type)

	while not tween.is_done():
		await get_tree().process_frame
	player_pin_joint.node_a = self.get_path()
	player_pin_joint.node_b = active_rope.last_piece.get_path()
	player_pin_joint2.node_a = self.get_path()
	player_pin_joint2.node_b = active_rope.last_piece.get_path()
	rotation = 0
	
func update_raycast() -> void:
	raycast.global_position = global_position
	raycast.target_position = (get_global_mouse_position() - global_position) * 2.0

func spawn_rope() -> void:
	remove_rope()
	if not raycast.is_colliding() or active_rope:
		return

	var rope_start = global_position
	var collision_count = raycast.get_collision_count()
	var rope_end = raycast.get_collision_point(randi() % collision_count)

	active_rope = rope_scene.instantiate()
	get_tree().root.get_node("Scene").add_child(active_rope)

	var last_rope_piece = active_rope.call("spawn_rope", rope_start, rope_end)
	$PinJoint2D.node_b = last_rope_piece.get_path()
	$PinJoint2D2.node_b = last_rope_piece.get_path()

func remove_rope() -> void:
	if active_rope:
		if linear_velocity.y <= 0:
			linear_velocity *= 2.6
		else:
			linear_velocity *= 0.8
		
		active_rope.queue_free()
		active_rope = null

func check_player_position_to_rope() -> void:
	var last_piece_position = active_rope.last_piece.global_position
	var distance_to_last_piece = global_position.distance_to(last_piece_position)
	
	if distance_to_last_piece > 90:
		var duration = 0.001
		var ease_type = EaseType.EASE_IN_OUT_QUAD
		var tween = Tweens.tween(self, "global_position", global_position, last_piece_position, duration, ease_type)
		rotation=0
		while not tween.is_done():
			await get_tree().process_frame

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ground"):
		is_on_ground = true
		is_jumping = false

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Ground"):
		is_on_ground = false

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.get_parent().is_in_group("ground"):
		is_on_ground = false

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.get_parent().is_in_group("ground"):
		is_on_ground = false
