extends Node

class_name CustomTween

var t = 0
var duration = 1

var start_time
var end_time

var start_value
var end_value

var target_obj
var property 
var ease_type


func _init(_target_obj, _property, _start_value,_end_value, _duration, ease_type = null) -> void:
	start_time = Time.get_ticks_msec() / 1000.0
	duration = _duration
	end_time = start_time + duration
	
	start_value = _start_value
	end_value = _end_value
	
	target_obj = _target_obj
	property = _property
	self.ease_type = ease_type
	

func update(delta: float):
	t=(Time.get_ticks_msec()/1000.0 - start_time)/(end_time - start_time)
	#t += delta / duration
	if t >= 1:
		t=1
	
	var eased = 	EaseType.interpolate(t, self.ease_type);
	var interpolated = lerp(start_value, end_value, eased)
	#var interpolated =  start_value + (end_value - start_value) * t
	target_obj.set(property,interpolated)
	
	#ease_in : 1 - (1-t)(1-t)
	#ease_out: t*t

func is_done() -> bool:
		# Task 1 - implement this
	return t >= 1
