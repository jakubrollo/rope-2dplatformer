extends Camera2D

@export var follow_object: RigidBody2D
@export var smoothing_speed: float = 3.5  

@export var shake_intensity: float = 2.0  
@export var shake_duration: float = 0.13  
@export var shake_speed: float = 2  
var shake_timer: float = 0.0

@export var ahead_distance: float = 200.0 

var original_position: Vector2
var shaking: bool = false

func _physics_process(delta: float) -> void:
	if not follow_object:
		return
	
	var target_position = follow_object.position
	
	if Input.is_action_pressed("Left"):
		target_position.x -= ahead_distance
	elif Input.is_action_pressed("Right"):
		target_position.x += ahead_distance
	
	position = position.lerp(target_position, smoothing_speed * delta)

"""
func apply_shake(delta: float) -> void:
	shake_timer -= delta
	if shake_timer <= 0.0:
		shaking = false
		position = original_position
		return
	var offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	offset *= sin(Time.get_ticks_msec() / 1000.0 * shake_speed)
	position += offset

func trigger_shake():
	if not shaking:
		shaking = true
		shake_timer = shake_duration
"""
