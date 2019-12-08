extends RigidBody2D

var ammo = 10
var input = Vector2.ZERO
var max_speed = 40
var health = 100
var agro = []


func task_heal(task):
	health += 2
	task.succeed()
	return

func task_is_health_not_full(task):
	if  health < 100:
		task.succeed()
	else:
		task.failed()
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

func task_is_alive(task):
	if  health > 0:
		task.succeed()
	else:
		task.failed()
	return

func task_is_reload(task):
	if  Input.is_key_pressed(KEY_R) and ammo < 10:
		task.succeed()
	else:
		task.failed()
	return

var start_reload = false

func task_start_reload(task):
	start_reload = true
	task.succeed()
	return

func task_end_reload(task):
	start_reload = false
	task.succeed()
	return

func task_is_reloading(task):
	if  start_reload:
		task.succeed()
	else:
		task.failed()
	return

func task_do_reload(task):
	ammo = 10
	task.succeed()
	return

func _process(delta):
	input = Vector2.ZERO
	if  Input.is_key_pressed(KEY_A):
		input.x -= 1
	if  Input.is_key_pressed(KEY_D):
		input.x += 1
	if  Input.is_key_pressed(KEY_W):
		input.y -= 1
	if  Input.is_key_pressed(KEY_S):
		input.y += 1
	$ammo.text = str(ammo, "/10")
	$hp.text = str("HP : ", health)
	return

func task_speed(task):
	max_speed = task.get_param(0)
	task.succeed()
	return

func task_is_input(task):
	if  input.length() > 0.1:
		task.succeed()
	else:
		task.failed()
	return

func task_do_move(task):
	tspeed = input.normalized() * max_speed
	task.succeed()
	return

var speed = Vector2.ZERO
var tspeed = Vector2.ZERO

func _physics_process(delta):
	speed = speed.linear_interpolate(tspeed, 0.5)
	linear_velocity = speed
	tspeed *= 0.8
	return

func task_is_dash(task):
	if  Input.is_key_pressed(KEY_SHIFT):
		task.succeed()
	else:
		task.failed()
	return

func task_is_not__dash(task):
	if  not Input.is_key_pressed(KEY_SHIFT):
		task.succeed()
	else:
		task.failed()
	return

func task_look_at_mouse(task):
	$AnimatedSprite.look_at(get_global_mouse_position())
	task.succeed()
	return

func task_is_firing(task):
	if  Input.is_mouse_button_pressed(BUTTON_LEFT):
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

func task_say(task):
	$say.text = task.get_param(0)
	$Timer.stop()
	$Timer.start()
	task.succeed()
	return

func task_anim(task):
	$AnimatedSprite.play(task.get_param(0))
	task.succeed()
	return

func task_print(task):
#	for i in range(task.get_param_count()):
#		print(task.get_param(i))
	task.succeed()
	return

func task_is_out_of_ammo(task):
	if  ammo <= 0:
		task.succeed()
	else:
		task.failed()
	return

func _on_Timer_timeout():
	$say.text = ""
	return
