
extends Control

# Update hud character information

const HP_DEFAULT_COLOR = Color(0, 105/255.0, 1)
const HP_LOW_COLOR = Color(1, 0, 0)
const BAR_WIDTH = 500

const DEFAULT_AURA = Color(1, 158.1/255.0, 0)
const STYX_AURA = Color(73/255.0, 0, 1)

const DEFAULT_PREBAR_COLOR = Color(1, 195 / 255.0, 15/255.0, 230 / 255.0)
const STYX_PREBAR_COLOR = Color(188 / 255.0, 1, 0, 230 / 255.0)

var playerclass = preload("res://players/player.gd")
var player
var hpbar
var mpbar
var mpprebar
var bloodbar
var bloodcounter
var level
var is_magic = false

var blood_height = 63

func _ready():
	set_physics_process(true)
	
	hpbar = get_node("hpbar/bar")
	mpbar = get_node("mpbar/bar")
	mpprebar = get_node("mpbar/prebar")
	bloodbar = get_node("bloodbar/bar")
	bloodcounter = get_node("bloodcounter")
	level = get_node("hpbar/level")
	get_node("levelup").hide()

	reset()

func reset():
	mpprebar.hide()
	var polygon = bloodbar.get_polygon()
	var blood_value = polygon[2].y
	polygon[0].y = blood_value - 1
	polygon[1].y = blood_value - 1
	bloodbar.set_polygon(polygon)
	hpbar.set_scale(Vector2(1, 1))
	mpbar.set_scale(Vector2(1, 1))

func play_levelup():
	get_node("AnimationPlayer").play("levelup")

func _physics_process(delta):
	if (get_tree().get_root().has_node("world/playercontainer/player")):
		player = get_tree().get_root().get_node("world/playercontainer/player")
	if (player != null):
		# Update HP bar and level
		if (int(level.get_text()) != player.get("level")):
			level.set_text(str(player.get("level")))
		var hpscale = player.get("current_hp") / float(player.get("hp"))
		var hpstep = hpscale - hpbar.get_scale().x
		if (abs(hpstep) > 0.01):
			hpstep = 0.01*sign(hpstep)
		hpbar.set_scale(Vector2(hpbar.get_scale().x + hpstep, 1))
		hpbar.set_color(HP_DEFAULT_COLOR.linear_interpolate(HP_LOW_COLOR, 1 - hpscale))
		var lowhp = hpscale <= 0.1
		get_node("hpbar/display").set_use_parent_material(!lowhp)
		
		var bonus = ProjectSettings.get("bonus_effects")

		# Update MP bar
		var current_mp = player.get("current_mp") / float(player.get("mp"))
		if (bonus.mprate):
			mpprebar.color = STYX_PREBAR_COLOR
		else:
			mpprebar.color = DEFAULT_PREBAR_COLOR
		if (player.get("is_charging")):
			is_magic = false
			mpbar.set_scale(Vector2(current_mp, 1))
			right_align_prebar(current_mp)
			mpprebar.show()
			var mp_required = player.get_current_spell_mp()
			var mp_consumed = max(round(mp_required * player.get("charge_counter") / float(playerclass.MAX_CHARGE)), 1)
			var mpscale = mp_consumed / float(player.get("mp"))
			mpprebar.set_scale(Vector2(mpscale, 1))
		var mpstep = current_mp - mpbar.get_scale().x
		if (abs(mpstep) > 0.01):
			mpstep = 0.01*sign(mpstep)
		mpbar.set_scale(Vector2(mpbar.get_scale().x + mpstep, 1))
		if (!player.get("is_charging") && mpprebar.is_visible() && !is_magic):
			left_align_prebar()
			is_magic = true
		if (is_magic):
			mpprebar.set_scale(Vector2(mpprebar.get_scale().x + mpstep, 1))
			if (mpprebar.get_scale().x <= 0 || round(mpstep * 100000)/100000.0  == 0):
				mpprebar.set_scale(Vector2(1, 1))
				mpprebar.hide()
				is_magic = false
		
		# Update blood bar
		var bloodscale = player.get("current_blood") / float(player.get("max_blood"))
		var polygon = bloodbar.get_polygon()
		var current_blood_value = (polygon[2].y - polygon[0].y - 1) / float(blood_height)
		var bloodstep = bloodscale - current_blood_value
		if (abs(bloodstep) > 0.01):
			bloodstep = 0.01*sign(bloodstep)
		var blood_value = polygon[0].y - bloodstep * blood_height
		polygon[0].y = blood_value
		polygon[1].y = blood_value
		bloodbar.set_polygon(polygon)
		var bloodbar_display = get_node("bloodbar/display")
		if (bonus.demonic):
			bloodbar_display.get_material().set_shader_param("aura_color", STYX_AURA)
		else:
			bloodbar_display.get_material().set_shader_param("aura_color", DEFAULT_AURA)
		bloodbar_display.set_use_parent_material(!player.get("is_demonic"))
		if (ProjectSettings.get("show_blood_counter")):
			bloodcounter.show()
			bloodcounter.get_node("counter").set_text(str(ProjectSettings.get("blood_count")))
		else:
			bloodcounter.hide()
		
func right_align_prebar(scale):
	var polygon = mpprebar.get_polygon()
	polygon[0].x = -500
	polygon[1].x = 0
	polygon[2].x = 0
	polygon[3].x = -500
	mpprebar.set_polygon(polygon)
	mpprebar.set_position(Vector2(scale*BAR_WIDTH + 40, mpprebar.get_position().y))
	
func left_align_prebar():
	var polygon = mpprebar.get_polygon()
	polygon[0].x = 0
	polygon[1].x = 500
	polygon[2].x = 500
	polygon[3].x = 0
	mpprebar.set_polygon(polygon)
	mpprebar.set_position(Vector2(mpprebar.get_position().x - mpprebar.get_scale().x * 500, mpprebar.get_position().y))
