
extends KinematicBody2D
# the great majority of character behavior and interaction implementation is modelled after this article: http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/comment-page-1
# please note that this blog link sometimes doesn't work, but you might still be able to see it through archive.org

const DEFAULT_GRAVITY = 1
# in order not to jump off 0-31 slopes, keep run speed below 10
const RUN_SPEED = 7
const JUMP_SPEED = 20
const TILE_SIZE = 32
const WATER = 0.25
const LAVA = 0.75
const SNOW = 0.5
const DEFAULT_FALL_HEIGHT = JUMP_SPEED * (JUMP_SPEED - 1)/2
# restrict vertical speed to prevent skipping and other weirdness
const SPEED_LIMIT = 30

# Collision Layers
# 0 - General Area2D
# 1 - Slopes
# 2 - Fakes
# 3 - Sunbeams
# 19 - Solids

var is_delay = false
var hud
var pos = Vector2()
var current_animation = "idle"
var direction = 1
var falling = false
var accel = DEFAULT_GRAVITY
var sprite_offset = Vector2()
var collision
var animation_player
var climb_platform = null
var climbing_platform = false
var hanging = false
var movingPlatform = null
var movingPlatformPos = null
var onMovingPlatform = false
var damage_rect
var is_hurt = false
var current_gravity = DEFAULT_GRAVITY
var underwater = false
var fall_height = 0
var runspeed = RUN_SPEED
var jumpspeed = JUMP_SPEED
var defaultfallheight = DEFAULT_FALL_HEIGHT
var area2d_blacklist = []
var has_kinematic_collision = false
var on_ladder = false
var jumpPressed = false
var hpclass = preload("res://gui/hud/hp.tscn")
var ignore_gravity = false
var _collider
var is_snow = false
var fluid_tile

var MovingPlatform = preload("res://scenes/dungeon/movingplatform/MovingPlatform.gd")

var atk = 0
var def = 0
var hp = 0
var current_hp = 0
var ep = 0

var elemental_weaknesses = []
var elemental_protection = []

func get_def_adjusted_damage(damage):
	return round(damage * (1 - def / 512.0))

func get_elemental_constant(type):
	if (elemental_weaknesses.find(type) >= 0):
		return 1.5
	if (elemental_protection.find(type) >= 0 || elemental_protection.find("all") >= 0):
		return 0
	return 1

func get_atk_adjusted_damage(damage, type):
	# calculate effects of elemental weaknesses/immunity
	
	return round(get_elemental_constant(type) * (damage * 2 + randf()*0.1*damage))

func merge(a, b):
	var c = []
	var size = a.size()
	for j in range(size):
		c.append(a[j])
	size = b.size()
	for i in range(size):
		c.append(b[i])
	return c

func min_array(array):
	if (array.size() == 1):
		return array[0]
	elif (array.size() > 1):
		var min_float = array[0]
		for i in range(1, array.size() - 1):
			min_float = min(array[i], min_float)
		return min_float
	else:
		return null

func input_left():
	# check if input (AI or actual player) is left
	return false

func input_right():
	# check if input (AI or actual player) is right
	return false

func input_up():
	# check if input (AI or actual player) is up
	return false

func input_down():
	# check if input (AI or actual player) is down
	return false

func input_jump():
	# check if input (AI or actual player) is jump
	return false

func check_hanging_disengage():
	pass

func check_ladder_horizontal(space_state):
	pass

# add and remove magic spell and other special effect collisions
# to prevent interfering with regular collision detection
func remove_from_blacklist(item):
	var size = area2d_blacklist.size()
	for i in range(size):
		if (i < area2d_blacklist.size() && area2d_blacklist[i] == item):
			area2d_blacklist.remove(i)

func add_to_blacklist(item):
	area2d_blacklist.append(item)

func check_blacklist(item):
	var size = area2d_blacklist.size()
	for i in range(size):
		if (i < area2d_blacklist.size() && area2d_blacklist[i] == item):
			return true
	return false

# slopes have the format slope#-#, where # denotes the
# position (from the top) of the corner of the slope from left to right
func isSlope(name):
	return name.match("slope*-*")

func is_colliding():
	return _collider != null && _collider.collider != null

func getSlopes(space_state):
	var relevantSlopeTile = space_state.intersect_ray(Vector2(get_global_position().x, get_global_position().y+sprite_offset.y), Vector2(get_global_position().x, get_global_position().y+sprite_offset.y+8), area2d_blacklist, 2)
	if (relevantSlopeTile.has("collider")):
		var collider = relevantSlopeTile["collider"]
		if (isSlope(collider.get_name())):
			return collider
	return null

func getOneWayTile(space_state, desiredY):
	var leftX = get_global_position().x - sprite_offset.x
	var rightX = get_global_position().x + sprite_offset.x
	var oneWayTile = space_state.intersect_ray(Vector2(leftX, get_global_position().y + sprite_offset.y + desiredY), Vector2(rightX, get_global_position().y + sprite_offset.y + desiredY), area2d_blacklist, 2147483647)
	if (oneWayTile.has("collider")):
		if (oneWayTile["collider"].get_name() == "oneway"):
			return oneWayTile["collider"]
	return null

# we reused the damage rect to also check AB slopes from the side since they're not
# normal collisions and can be ignored.
func checkABSlope():
	var collisionTiles = damage_rect.get_overlapping_areas()
	for i in collisionTiles:
		if (i.get_name() == "slopea-b" && i.get_global_position().y + TILE_SIZE/2 > int(get_position().y - sprite_offset.y) && i.get_global_position().y - TILE_SIZE/2 < int(get_position().y + sprite_offset.y)):
			return true
	return false

func parseSlopeType(name):
	var values = name.split("slope")
	# slope#-#
	# extract #; first is left corner and last is right corner
	var slopes = values[1].split("-")
	if (slopes[0] == "a" && slopes[1] == "b"):
		return null
	return values[1].split_floats("-")

func clearMovingPlatform():
	movingPlatform = null
	movingPlatformPos = null

func closestXTile(desired_direction, desiredX, space_state):
	# -1 = check left side
	# 1 = check right side
	if (has_kinematic_collision):
		if (is_colliding()):
			# standing on moving platforms shouldn't block player from moving horizontally
			if (onMovingPlatform && (_collider.collider.get_name() == "blockR" || _collider.collider.get_name() == "blockL") && _collider.collider.get_parent() is MovingPlatform
			&& _collider.collider.get_parent().speed.y > 0):
				_collider = move_and_collide(Vector2(0, movingPlatform.global_position.y - TILE_SIZE/2 - global_position.y - sprite_offset.y))
				return desiredX
			if (_collider.position.y > int(get_position().y - sprite_offset.y) && _collider.position.y < int(get_position().y + sprite_offset.y)):
				return 0
	else:
		desiredX = closestXTile_area_check(desired_direction, desiredX, space_state)
	return desiredX

func closestXTile_area_check(desired_direction, desiredX, space_state):
	var frontTile = space_state.intersect_ray(Vector2(get_global_position().x + desired_direction * sprite_offset.x + desiredX, get_global_position().y - sprite_offset.y), Vector2(get_global_position().x + desired_direction * sprite_offset.x + desiredX, get_global_position().y + sprite_offset.y - 1), [self], 524288)
	if (frontTile != null && frontTile.has("collider")):
		return 0
	return desiredX

func closestYTile(tileA, tileB):
	if (!tileA.has("position")):
		return tileB["position"].y
	elif (!tileB.has("position")):
		return tileA["position"].y
	else:
		return min(tileA["position"].y, tileB["position"].y)

func check_moving_platforms(normalTileCheck, relevantTileA, relevantTileB, space_state, oneWayTile):
	movingPlatform = null
	onMovingPlatform = false

	if (normalTileCheck):
		var movingPlatform_check = null
		if (relevantTileA.has("collider")):
			movingPlatform_check = relevantTileA["collider"]
		else:
			movingPlatform_check = relevantTileB["collider"]
		if((movingPlatform_check.get_name() == "blockR" || movingPlatform_check.get_name() == "blockL") && movingPlatform_check.get_parent() is MovingPlatform):
			onMovingPlatform = true
			if (movingPlatform_check.get_global_position().y - TILE_SIZE/2 >= int(get_position().y + sprite_offset.y)):
				_collider = move_and_collide(Vector2(0, movingPlatform_check.global_position.y - TILE_SIZE/2 - int(position.y + sprite_offset.y)))
			movingPlatform = movingPlatform_check
		else:
			clearMovingPlatform()

	# clear moving platforms if landing on one way platform tiles
	var onOneWayTile = false
	if (oneWayTile != null):
		onOneWayTile = oneWayTile.get_global_position().y - TILE_SIZE/2 >= get_position().y + sprite_offset.y
		clearMovingPlatform()

	if (climb_platform != null):
		var climb_platform_ref = weakref(climb_platform)
		if (climb_platform_ref != null && climb_platform_ref.get_ref()):
			if ((climb_platform_ref.get_ref().get_name() == "blockR" || climb_platform_ref.get_ref().get_name() == "blockL") && climb_platform_ref.get_ref().get_parent() is MovingPlatform):
				movingPlatform = climb_platform_ref.get_ref()
				onMovingPlatform = true
			else:
				clearMovingPlatform()

	if (movingPlatform != null):
		var newPos = Vector2(movingPlatform.get_global_position().x, movingPlatform.get_global_position().y)
		movingPlatformPos = movingPlatform.get_parent()["previousPos_" + movingPlatform.get_name()]
		var movingDeltaX = newPos.x - movingPlatformPos.x
		# only move with the platform if landed on it
		# merely detecting it is there doesn't count
		if (int(get_position().y + sprite_offset.y) >= newPos.y - TILE_SIZE/2 - 2 && !climbing_platform && !hanging):
			var platformDeltaX = 0
			if (get_global_position().x + movingDeltaX > newPos.x + TILE_SIZE/2 || get_global_position().x + movingDeltaX < newPos.x - TILE_SIZE/2):
				movingDeltaX = 0
		_collider = move_and_collide(Vector2(movingDeltaX, movingPlatform.get_parent().speed.y))
	return onOneWayTile

func check_underwater(areaTiles):
	if (!ignore_gravity):
		var watertile = false
		for i in areaTiles:
			if (i.get_name() == "water" || i.get_name() == "lava" || i.get_name() == "snow"):
				var fluid_constant = WATER
				if (i.get_name() == "lava"):
					fluid_constant = LAVA
				if (i.get_name() == "snow"):
					is_snow = true
				watertile = true
				fluid_tile = weakref(i)
				if (!check_blacklist(i)):
					area2d_blacklist.append(i)
				if (i.get_global_position().y - TILE_SIZE * i.get_scale().y/2 <= get_position().y - sprite_offset.y):
					if (!underwater && has_node("sound/splash_down")):
						get_node("sound/splash_down").play()
						get_node("sound/splash_down").set_volume_db((fall_height/defaultfallheight*current_gravity - 1)*10)
					underwater = true
					current_gravity = fluid_constant
		if (!watertile):
			if (underwater && has_node("sound/splash_up")):
				get_node("sound/splash_up").play()
				get_node("sound/splash_up").set_volume_db(0)
			underwater = false
			is_snow = false
			current_gravity = DEFAULT_GRAVITY
			if (fluid_tile):
				remove_from_blacklist(fluid_tile.get_ref())

func horizontal_input_permitted():
	return !is_hurt

func step_horizontal(space_state):
	pos.y = 0
	var new_animation = current_animation
	var horizontal_motion = false
	var forwardY = get_position().y + sprite_offset.y
	var onSlope = false
	var slopeX = 0
	var relevantSlopeTile = null
	if (horizontal_input_permitted()):
		if (input_left()):
			pos.x = closestXTile(-1, -runspeed, space_state)
			# can't tell right now if we are on a slope tile and can ignore
			# the a-b slope tile
			# so delay horizontal motion until slope check
			if (checkABSlope()):
				slopeX = pos.x
				pos.x = 0
			new_animation = "run"
			direction = -1
			horizontal_motion = true
		elif (input_right()):
			pos.x = closestXTile(1, runspeed, space_state)
			if (checkABSlope()):
				slopeX = pos.x
				pos.x = 0
			new_animation = "run"
			direction = 1
			horizontal_motion = true
		else:
			pos.x = 0
			new_animation = "idle"

		check_hanging_disengage()

		if (ignore_gravity):
			current_gravity = DEFAULT_GRAVITY

		pos.x = pos.x * snow_modifier()

		_collider = move_and_collide(pos)

		pos.x = 0

		# check ladder after horizontal movement
		check_ladder_horizontal(space_state)

	if (!on_ladder):
		# check slope tiles
		relevantSlopeTile = getSlopes(space_state)

		var onZeroSlope = false
		var currentSlopeTile = null
		var b = null
		forwardY = get_position().y + sprite_offset.y
		if (relevantSlopeTile != null):
			b = parseSlopeType(relevantSlopeTile.get_name())
			if (b != null):
				if (b[0] == 0 || b[1] == 0):
					_collider = move_and_collide(Vector2(slopeX, 0))
				onSlope = true
				b = parseSlopeType(relevantSlopeTile.get_name())
				# ignore bottom slopes if we're not close enough to them
				if ((b[0] == TILE_SIZE - 1 || b[1] == TILE_SIZE - 1) && (get_global_position().x < relevantSlopeTile.get_global_position().x - TILE_SIZE / 2 || get_global_position().x > relevantSlopeTile.get_global_position().x + TILE_SIZE / 2)):
					pass
				else:
					var t = (get_global_position().x - relevantSlopeTile.get_global_position().x + TILE_SIZE / 2)/TILE_SIZE
					var slopeY = (1 - t) * b[0] + t * b[1]

					var slopeAdjustedTileY = relevantSlopeTile.get_global_position().y - TILE_SIZE / 2 + int(slopeY)

					# clamp to slope only if not jumping
					# unfortunately, the extra height from the default jump speed isn't enough to clear
					# neighboring slopes. Playing with the values yields 5 as sufficient to do so
					if ((forwardY > slopeAdjustedTileY - (jumpspeed - 5)*snow_modifier()) || !jumpPressed):
						pos.y = slopeAdjustedTileY - forwardY
						_collider = move_and_collide(pos)
	return {"animation": new_animation, "slope": onSlope, "slopeTile": relevantSlopeTile, "slopeX": slopeX, "motion": horizontal_motion}

func check_climb_platform_horizontal(space_state):
	pass

func snow_modifier():
	if (is_snow):
		return SNOW
	return current_gravity

func check_jump():
	if (input_jump()):
			accel = -jumpspeed * current_gravity
			falling = true
			jumpPressed = true

func check_vertical_input(space_state, normalTileCheck, onOneWayTile, relevantTileA, relevantTileB, animation_speed):
	return 0

func check_throwback():
	pass

func check_ladder_top(normalTileCheck, closestTileY, desiredY):
	pass

func falling_modifier(desiredY):
	return 1 * current_gravity * current_gravity

func step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile):
	jumpPressed = false

	var forwardY = get_global_position().y + sprite_offset.y

	var ladderY = check_vertical_input(space_state, normalTileCheck, onOneWayTile, relevantTileA, relevantTileB, animation_speed)

	# don't register throwback if jumping
	check_throwback()

	var desiredY = 0

	var abSlope = null
	# don't bother checking regular tiles below character if on ladder
	if (!on_ladder):
		desiredY = accel

		if (falling):
			desiredY += falling_modifier(desiredY)
		else:
			desiredY = 1

		var s = 1

		if (desiredY < 0):
			s = -1

		relevantSlopeTile = getSlopes(space_state)

		var closestTileY = desiredY

		# check regular static blocks
		if (normalTileCheck && !onMovingPlatform):
			closestTileY = closestYTile(relevantTileA, relevantTileB)

			closestTileY -= get_position().y+sprite_offset.y
			closestTileY = int(closestTileY)

			# prevent sticking to ceiling
			if (closestTileY == 0):
				if s == -1:
					closestTileY = jumpspeed - 1
				# landed on a platform; not falling anymore
				if s == 1:
					falling = false

			# ensure we are falling if not mediated by jumping
			if (abs(desiredY) < abs(closestTileY)):
				falling = true
		forwardY = get_position().y + sprite_offset.y

		# check slopea-b tiles from above
		var collisionTiles = damage_rect.get_overlapping_areas()
		for i in collisionTiles:
			if (i.get_name() == "slopea-b" && i.get_global_position().y + TILE_SIZE/2 >= int(get_position().y - sprite_offset.y) && i.get_global_position().y - TILE_SIZE/2 < int(get_position().y - sprite_offset.y)):
				#closestTileY = max(i.get_global_position().y + TILE_SIZE/2 - get_position().y + sprite_offset.y, desiredY)
				_collider = move_and_collide(Vector2(0, i.get_global_position().y + TILE_SIZE/2 - get_position().y + sprite_offset.y))

		# check slope tiles
		if (relevantSlopeTile != null):
			var closestSlopeTile = null
			var t
			var b
			var slopeY = 0
			var closest_level = null
			# find relevant distances to slope tiles
			b = parseSlopeType(relevantSlopeTile.get_name())
			if (b != null):
				t = (get_global_position().x - relevantSlopeTile.get_global_position().x + TILE_SIZE/2) / TILE_SIZE
				slopeY = (1 - t) * b[0] + t * b[1]
				if (forwardY <= relevantSlopeTile.get_global_position().y - TILE_SIZE/2 + int(slopeY)):
					closest_level = relevantSlopeTile.get_global_position().y - TILE_SIZE/2 - forwardY
					b = parseSlopeType(relevantSlopeTile.get_name())
					t = (get_global_position().x - relevantSlopeTile.get_global_position().x + TILE_SIZE/2)/TILE_SIZE
					slopeY = (1 - t) * b[0] + t * b[1]

					# check that we are really standing on a slope tile
					if (relevantSlopeTile.get_global_position().y - TILE_SIZE/2 + slopeY - forwardY < jumpspeed - 1):
						onSlope = true
						falling = false

					# don't need to check slope on ceilings
					if (forwardY >= relevantSlopeTile.get_global_position().y + TILE_SIZE/2):
						closestTileY = forwardY - relevantSlopeTile.get_global_position().y - TILE_SIZE/2 - TILE_SIZE
					elif (forwardY <= relevantSlopeTile.get_global_position().y - TILE_SIZE/2 + slopeY):
						closestTileY = relevantSlopeTile.get_global_position().y - TILE_SIZE/2 + slopeY - forwardY
						if (jumpPressed):
							closestTileY = desiredY

					closestTileY = int(closestTileY)
			else:
				# not standing on a slope. This is just a block whose collision
				# is ignorable when standing on a slope tile next to it.
				abSlope = relevantSlopeTile
				if (abSlope.get_global_position().y - TILE_SIZE/2 <= forwardY):
					_collider = move_and_collide(Vector2(0, abSlope.get_global_position().y - TILE_SIZE/2 - forwardY - 1))
					forwardY = get_position().y + sprite_offset.y
				closestTileY = min(abSlope.get_global_position().y - TILE_SIZE/2 - forwardY - 1, desiredY)
				closestTileY = int(closestTileY)
				falling = false

		# handle one way tiles
		if (onOneWayTile):
			if (oneWayTile.get_global_position().y - TILE_SIZE/2 <= int(forwardY) + 1):
				_collider = move_and_collide(Vector2(0, oneWayTile.get_global_position().y - TILE_SIZE/2 - int(forwardY) - 1))
				forwardY = get_position().y + sprite_offset.y
				falling = false
			closestTileY = min(oneWayTile.get_global_position().y - TILE_SIZE/2 - int(forwardY) - 1, desiredY)
			closestTileY = int(closestTileY)

		# handle standing on a ladder_top tile
		check_ladder_top(normalTileCheck, closestTileY, desiredY)
		accel = min(min(abs(desiredY), abs(closestTileY)), SPEED_LIMIT * current_gravity * current_gravity) * s
	return {"desiredY": desiredY, "slope": onSlope, "slopeTile": relevantSlopeTile, "abSlope": abSlope, "animationSpeed": animation_speed, "ladderY": ladderY}

func check_falling(normalTileCheck, relevantSlopeTile, onSlope, abSlope, ladder_top, oneWayTile):
	if (!normalTileCheck && ((relevantSlopeTile == null || !onSlope) && abSlope == null) && ladder_top == null && oneWayTile == null):
			falling = true

func check_on_moving_platform(desiredY):
	if (desiredY > - jumpspeed + 1 && movingPlatform != null && !hanging && !climbing_platform && movingPlatform.get_global_position().y - TILE_SIZE/2 >= get_position().y + sprite_offset.y):
		falling = false
	if (onMovingPlatform):
		falling = false

func check_animations(new_animation, animation_speed, horizontal_motion, ladderY):
	pass

func calculate_fall_height():
	if (falling):
		fall_height += max(0, pos.y)
	else:
		fall_height = 0

func _physics_process(delta):
	if (is_physics_processing() && !is_delay):
		step_player(delta)
	elif (is_delay):
		is_delay = false

func step_player(delta):
	var space = get_world_2d().get_space()
	var space_state = Physics2DServer.space_get_direct_state(space)
	var animation_speed = 1

	# position at character's feet
	var forwardY = get_global_position().y + sprite_offset.y
	var leftX = get_global_position().x - sprite_offset.x
	var rightX = get_global_position().x + sprite_offset.x

	# bottom left ray check
	var relevantTileA = space_state.intersect_ray(Vector2(leftX, forwardY-1), Vector2(leftX, forwardY+16), [self], 524288)
	# bottom right ray check
	var relevantTileB = space_state.intersect_ray(Vector2(rightX, forwardY-1), Vector2(rightX, forwardY+16), [self], 524288)

	# check regular blocks
	var normalTileCheck = !relevantTileA.empty() || !relevantTileB.empty()

	# check moving platforms before everything else
	var oneWayTile = getOneWayTile(space_state, max(accel, TILE_SIZE))
	var onOneWayTile = check_moving_platforms(normalTileCheck, relevantTileA, relevantTileB, space_state, oneWayTile)

	var areaTiles = damage_rect.get_overlapping_areas()
	# check underwater
	check_underwater(areaTiles)

	# step horizontal motion first
	var horizontal = step_horizontal(space_state)
	var new_animation = horizontal["animation"]
	var horizontal_motion = horizontal["motion"]
	var onSlope = horizontal["slope"]
	var slopeX = horizontal["slopeX"]
	var relevantSlopeTile = horizontal["slopeTile"]
	forwardY = get_global_position().y + sprite_offset.y

	# check vertical motion
	var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile)

	relevantSlopeTile = vertical["slopeTile"]
	onSlope = vertical["slope"]
	var abSlope = vertical["abSlope"]
	var desiredY = vertical["desiredY"]
	animation_speed = vertical["animationSpeed"]
	var ladderY = vertical["ladderY"]

	if (!on_ladder):
		# final falling status check for all kinds of collisions
		check_falling(normalTileCheck, relevantSlopeTile, onSlope, abSlope, null, oneWayTile)

		# don't fall while standing on moving platforms moving up
		check_on_moving_platform(desiredY)

		pos.y = accel

	# check animations
	var animations = check_animations(new_animation, animation_speed, horizontal_motion, ladderY)
	animation_speed = animations["animationSpeed"]
	new_animation = animations["animation"]

	calculate_fall_height()

	move(pos)
	play_animation(new_animation, animation_speed)

func _ready():
	hud = get_tree().get_root().get_node("world/gui/hpcontainer")
	set_physics_process(true)

func play_animation(animation, speed):
	animation_player.playback_speed = speed
	if (current_animation != animation):
		animation_player.play(animation)
		current_animation = animation

