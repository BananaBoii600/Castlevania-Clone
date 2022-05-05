
extends "res://gui/menu/MenuContent.gd"

# display level and map information

const MAP_HEIGHT = 214
const MAP_WIDTH = 540

func _ready():
	set_physics_process(false)

#Godot 3 doesn't provide these functions anymore...
func get_item_rect(mapobjects):
	if (mapobjects is Polygon2D):
		var boundaries = mapobjects.polygon
		return Rect2(boundaries[0], Vector2(abs(boundaries[1].x - boundaries[0].x), abs(boundaries[2].y - boundaries[0].y)))
	return Rect2(mapobjects.position, Vector2())

func get_item_and_children_rect(mapobjects):
	var rect = get_item_rect(mapobjects)

	for i in range(0, mapobjects.get_child_count()):
		var c = mapobjects.get_child(i)

		if (c != null):
			var sir = c.get_transform().xform(get_item_and_children_rect(c))
			rect = rect.merge(sir)

	return rect

func update_container():
	var level = ProjectSettings.get("levels")[ProjectSettings.get("current_level")]
	get_node("title").set_text(level.location.id)
	get_node("level").set_text(level.title)
	for icon in get_node("icons").get_children():
		if (level.type == icon.get_name()):
			icon.show()
			if (level.type == "bonus"):
				icon.get_node("counter").set_text(str(level.mincounter))
			if (level.type == "quest"):
				var image = level.item
				icon.set_texture(load(ProjectSettings.get("itemfactory").items[image].image))
		else:
			icon.hide()
	if (level.location.tiles != null):
		get_node("completion").set_text(str(level.location.tile_percent()) + "%")
	if (ProjectSettings.get("current_quest_complete")):
		get_node("complete").show()
	else:
		get_node("complete").hide()
	update_arrows()
	if (has_content):
		get_parent().get_parent().get_node("tabs/HBoxContainer/map").set_focus_neighbour(MARGIN_BOTTOM, "")
	else:
		get_parent().get_parent().get_node("tabs/HBoxContainer/map").set_focus_neighbour(MARGIN_BOTTOM, ".")
	
func unfocus_all():
	get_node("focus").release_focus()
	get_node("n-arrow/AnimationPlayer").stop()
	get_node("w-arrow/AnimationPlayer").stop()
	get_node("s-arrow/AnimationPlayer").stop()
	get_node("e-arrow/AnimationPlayer").stop()

func _on_map_focus_enter():
	if (has_content):
		set_physics_process(true)
	get_node("n-arrow/AnimationPlayer").play("move")
	get_node("w-arrow/AnimationPlayer").play("move")
	get_node("s-arrow/AnimationPlayer").play("move")
	get_node("e-arrow/AnimationPlayer").play("move")

func _on_map_focus_exit():
	if (has_content):
		set_physics_process(false)

func update_arrows():
	has_content = false
	if (has_node("mapcontainer/viewport/objects")):
		update_varrows()
		update_harrows()

func update_varrows():
	var map_objects = get_node("mapcontainer/viewport/objects")
	var map_size = get_item_and_children_rect(map_objects).size;
	var map_offset = get_item_and_children_rect(map_objects).position;
	var n_arrow = get_node("n-arrow")
	var s_arrow = get_node("s-arrow")
	if (map_objects.get_position().y + map_offset.y < 0):
		n_arrow.show()
		has_content = true
	else:
		n_arrow.hide()
	if (map_objects.get_position().y + map_offset.y + map_size.y > MAP_HEIGHT):
		s_arrow.show()
		has_content = true
	else:
		s_arrow.hide()

func update_harrows():
	var map_objects = get_node("mapcontainer/viewport/objects")
	var map_size = get_item_and_children_rect(map_objects).size;
	var map_offset = get_item_and_children_rect(map_objects).position;
	var e_arrow = get_node("e-arrow")
	var w_arrow = get_node("w-arrow")
	if (map_objects.get_position().x + map_offset.x < 0):
		w_arrow.show()
		has_content = true
	else:
		w_arrow.hide()
	if (map_objects.get_position().x + map_offset.x + map_size.x > MAP_WIDTH):
		e_arrow.show()
		has_content = true
	else:
		e_arrow.hide()

func _physics_process(delta):
	var map_objects = get_node("mapcontainer/viewport/objects")
	if (Input.is_action_pressed("ui_up") && get_node("n-arrow").is_visible()):
		map_objects.set_position(Vector2(map_objects.get_position().x, map_objects.get_position().y + 1))
		update_varrows()
	if (Input.is_action_pressed("ui_down") && get_node("s-arrow").is_visible()):
		map_objects.set_position(Vector2(map_objects.get_position().x, map_objects.get_position().y - 1))
		update_varrows()
	if (Input.is_action_pressed("ui_left") && get_node("w-arrow").is_visible()):
		map_objects.set_position(Vector2(map_objects.get_position().x + 1, map_objects.get_position().y))
		update_harrows()
	if (Input.is_action_pressed("ui_right") && get_node("e-arrow").is_visible()):
		map_objects.set_position(Vector2(map_objects.get_position().x - 1, map_objects.get_position().y))
		update_harrows()
