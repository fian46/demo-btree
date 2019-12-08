extends RigidBody2D

var hide = preload("res://hide.gd")
var cha = preload("res://character.gd")

var hide_points = []
var speed = Vector2.ZERO
var target_speed = Vector2.ZERO
var max_speed = 300
var player = null
var health = 100
var ammo = 10

func _on_Area2D_body_entered(body):
	if  body is cha:
		player = weakref(body)
	return

func _on_Area2D_area_entered(area):
	if  area is hide:
		hide_points.append(area)
	return

func _on_Area2D_area_exited(area):
	if  area is hide:
		var idx = hide_points.find(area)
		if  idx >= 0:
			hide_points.remove(idx)

func _physics_process(delta):
	speed = speed.linear_interpolate(target_speed, 0.5)
	speed *= 0.8
	linear_velocity = speed
	$Label.text = str("HP : ", health)
	return

func get_player():
	if  not player:
		return null
	return player.get_ref()
#########################
#BEGIN
#########################

func task_look_at_player(task):
	if  get_player():
		$AnimatedSprite.look_at(get_player().global_position)
	task.succeed()
	return

var pivot = Vector2.ZERO

func task_pivot(task):
	if  get_player():
		pivot = get_player().global_position()
		task.succeed()
	else:
		task.failed()
	return

func task_prob(task):
	var r = randf()
	if  r < 0.5:
		task.succeed()
	else:
		task.failed()
	return

func task_strafe_left(task):
	var dir = global_position - pivot
	location = (Vector2(dir.y, dir.x).normalized() * 50) + global_position
	task.succeed()
	return

func task_strafe_right(task):
	var dir = global_position - pivot
	location = (Vector2(dir.y, -dir.x).normalized() * 50) + global_position
	task.succeed()
	return

func task_can_shoot_player(task):
	if  not get_player() or get_player().is_queued_for_deletion():
		task.failed()
		return
	var result = get_world_2d().direct_space_state.intersect_ray(global_position, get_player().global_position)
	if  result.collider == get_player():
		task.succeed()
	else:
		task.failed()
	return

var bs = preload("res://bullet.tscn")

func task_fire(task):
	var bi = bs.instance()
	var ang = Vector2(cos($AnimatedSprite.global_rotation), sin($AnimatedSprite.global_rotation))
	bi.linear_velocity = ang * task.get_param(0)
	bi.global_position = $AnimatedSprite/shoot.global_position
	get_parent().add_child(bi)
	ammo -= 1
	task.succeed()
	return

func task_succeed(task):
	task.succeed()
	return

func task_destroy(task):
	queue_free()
	task.succeed()
	return

func task_is_died(task):
	if  health <= 0:
		task.succeed()
	else:
		task.failed()
	return

func task_is_player(task):
	if  get_player():
		task.succeed()
	else:
		task.failed()
	return

func task_is_not_player(task):
	if  not get_player():
		task.succeed()
	else:
		task.failed()
	return

var location = Vector2.ZERO

func task_pick_random_save_hide(task):
	var save_hide = []
	if  not get_player():
		save_hide = hide_points
	else:
		for i in hide_points:
			if  i.global_position.distance_to(get_player().global_position) > 500:
				save_hide.append(i)
	if  save_hide and save_hide.size() > 0:
		location = save_hide[randi() % save_hide.size()].global_position
		task.succeed()
	else:
		task.failed()
	return

func task_pick_random_hide(task):
	if  hide_points and hide_points.size() > 0:
		location = hide_points[randi() % hide_points.size()].global_position
		task.succeed()
	else:
		task.failed()
	return

var curve:Curve2D

func task_compute_path(task):
	if  not global.nav:
		task.failed()
		return
	var nav:Navigation2D = global.nav
	var path = nav.get_simple_path(global_position, location)
	curve = Curve2D.new()
	for i in path:
		curve.add_point(i)
	task.succeed()
	return

func task_run_curve(task):
	if  not curve:
		task.failed()
		return
	var coff = curve.get_closest_offset(global_position)
	coff += max_speed * (1.0 / 60.0)
	var end = curve.interpolate_baked(coff)
	var dir = end - global_position
	target_speed = dir.normalized() * max_speed
	if  abs(coff - curve.get_baked_length()) < 6:
		curve = null
		target_speed = Vector2.ZERO
		task.succeed()
	return

func task_look_at_speed(task):
	$AnimatedSprite.global_rotation = speed.angle()
	task.succeed()
	return
