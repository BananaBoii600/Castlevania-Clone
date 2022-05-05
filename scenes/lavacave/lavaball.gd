extends Node

# Fireball that shoots straight up and down

var active = false
export var height = 8
export var cycle = 6
var fireball
var ball
const DORMANT_DELAY = 500
var current_delay = 0
var accum = 0
var motion

func _ready():
	ball = get_node("ball")
	fireball = ball.get_node("fireball")
	fireball.process_material.emission_box_extents = Vector3(5, 32, 1)
	fireball.process_material.gravity.y = 16
	motion = -height * 32
	set_physics_process(true)

func _physics_process(delta):
	if (!active):
		current_delay += 1
		if (current_delay >= DORMANT_DELAY):
			current_delay = 0
			active = true
			fireball.process_material.emission_box_extents = Vector3(5, 5, 1)
			fireball.process_material.gravity.y = 80
	else:
		var diff = (delta/cycle)*PI*2.0
		accum += diff
		accum = fmod(accum, PI*2.0)
		var d = sin(accum)
		ball.set_position(Vector2(0, motion * d))
		if (cos(accum) >= -1 - diff && cos(accum) <= -1 + diff):
			fireball.process_material.emission_box_extents = Vector3(5, 32, 1)
			fireball.process_material.gravity.y = 16
			ball.set_position(Vector2(0, 0))
			active = false
			accum = 0
