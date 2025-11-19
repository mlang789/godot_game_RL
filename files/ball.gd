extends RigidBody2D


func _integrate_forces(state):
	if linear_velocity.length() > 400:
		linear_velocity = linear_velocity.normalized() * 400
