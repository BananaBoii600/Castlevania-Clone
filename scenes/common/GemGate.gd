
extends Node

export var key = "ITEM_TOPAZKEY"

var keysprite
var aura
var collision
var detection

const keycolors = {
	"ITEM_RUBYKEY": Color(1, 0, 0),
	"ITEM_EMERALDKEY": Color(0, 1, 130/255.0),
	"ITEM_SAPPHIREKEY": Color(72/255.0, 178/255.0, 1),
	"ITEM_DIAMONDKEY": Color(1, 1, 1),
	"ITEM_TOPAZKEY": Color(1, 125/255.0, 0),
	"ITEM_PERIDOTKEY": Color(175/255.0, 1, 0),
	"ITEM_AMETHYSTKEY": Color(145/255.0, 0 , 1)
	}

func _ready():
	keysprite = get_node("key")
	collision = get_node("StaticBody2D")
	detection = get_node("Area2D")
	aura = get_node("gate").get_material()
	var sprite = Image.new()
	sprite.load(ProjectSettings.get("itemfactory").items[key].image)
	var imageTexture = ImageTexture.new()
	imageTexture.create_from_image(sprite)
	keysprite.texture = imageTexture
	#print("setup gem gate")
	#print(aura)
	#print(get_node(".").get_name())
	aura.set_shader_param("aura_color", keycolors[key])
	set_physics_process(false)

func _physics_process(delta):
	if (collision.get_parent() != null):
		var collisions = detection.get_overlapping_bodies()
		for i in collisions:
			if (i.get_name() == "player" && ProjectSettings.get("inventory").inventory.has(key)):
				get_node("AnimationPlayer").play("open")
				remove_child(collision)

func enter_screen():
	set_physics_process(true)


func exit_screen():
	set_physics_process(false)

