
extends "res://scenes/common/Sensor.gd"

# sensor for regular colosseum level

var enemyclass = preload("res://scenes/common/damagables/BaseEnemy.gd")

var waves
var currentwave = 0

func _ready():
	gatepos = Vector2(-432, -48)

func trigger_fighting():
	var level = ProjectSettings.get("levels")[ProjectSettings.get("current_level")]
	waves = level.waves
	var wave = waves[currentwave].instance()
	tilemap.add_child(wave)

func process_fighting():
	if (tilemap.has_node("EnemiesGroup")):
		var enemies_defeated = true
		# transfer any enemy drops on to next wave when it happens
		var nonenemy_objects = []
		for entity in tilemap.get_node("EnemiesGroup").get_children():
			if (entity is enemyclass):
				enemies_defeated = false
			else:
				nonenemy_objects.append(entity)
		if (enemies_defeated):
			currentwave += 1
			# no more waves left
			if (currentwave >= waves.size()):
				ProjectSettings.set("current_quest_complete", true)
				var level = ProjectSettings.get("levels")[ProjectSettings.get("current_level")]
				level.complete = true
				ProjectSettings.get("levels")[ProjectSettings.get("current_level")] = level
				var level_display = get_tree().get_root().get_node("world/gui/CanvasLayer/level")
				level_display.get_node("title/newlevel").hide()
				level_display.get_node("title").set_text("KEY_VICTORY")
				level_display.get_node("AnimationPlayer").play("quest")
				gate.queue_free()
				set_physics_process(false)
			else:
				# add next wave of enemies
				var wave = waves[currentwave].instance()
				var size = nonenemy_objects.size()
				var oldGroup = tilemap.get_node("EnemiesGroup")
				for i in range(0, size):
					var obj = nonenemy_objects[i]
					oldGroup.remove_child(obj)
					wave.add_child(obj)
				tilemap.remove_child(oldGroup)
				oldGroup.queue_free()
				tilemap.add_child(wave)
