extends StaticBody2D
func enable():
	self.set_collision_layer_value(0, true)
	
func disable():
	self.set_collision_layer_value(0, false)
