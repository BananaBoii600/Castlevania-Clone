extends Node2D

# Member variables
export var motion = Vector2()
export var cycle = 1.0
export var offset = 0.0
export var linear = false
export var start_direction = 1
var accum = 0.0
var velocity = 0.0
var speed = 0
var direction = 1
var lOffset = null
var rOffset = null
var previousPos_blockR = Vector2()
var previousPos_blockL = Vector2()

func _physics_process(delta):
	previousPos_blockR = get_node("blockR").get_global_position()
	previousPos_blockL = get_node("blockL").get_global_position()
	accum += delta*(1.0/cycle)*PI*2.0
	accum = fmod(accum, PI*2.0)
	# circular motion
	var d = sin(accum)

	var posL = Vector2(motion.x*d + lOffset, motion.y*d)
	var posR = Vector2(motion.x*d + rOffset, motion.y*d)
	# linear motion
	if (linear):
		velocity += (delta/cycle)*direction
		if (abs(velocity) > 1):
			direction = direction * -1

		posL = Vector2(motion.x + motion.x*velocity + lOffset, motion.y + motion.y*velocity)
		posR = Vector2(motion.x + motion.x*velocity + rOffset, motion.y + motion.y*velocity)

	get_node("blockR").set_position(posR)
	get_node("blockL").set_position(posL)

	speed = get_node("blockR").global_position - previousPos_blockR

func _ready():
	if (lOffset == null):
		lOffset = get_node("blockL").get_position().x
	if (rOffset == null):
		rOffset = get_node("blockR").get_position().x
	var scalex = motion.x / 32.0
	var scaley = motion.y / 32.0
	accum = offset * PI / 180
	velocity = offset
	direction = start_direction
	set_physics_process(true)


