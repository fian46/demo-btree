extends RigidBody2D

func _on_Area2D_body_entered(body):
	queue_free()
	if  body.get("health"):
		body.health -= 10
	return
