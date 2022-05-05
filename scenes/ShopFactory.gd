
extends Node

var shops = {}
var shopclass = preload("res://scenes/Shop.gd")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _init():
	var kaleva = shopclass.new()
	kaleva.title = "SHOP_KALEVA"
	kaleva.inventory = [{"type": "item", "id": "ITEM_POTION", "quantity": -1},
						{"type": "item", "id": "ITEM_POTION+", "quantity": -1},
						{"type": "item", "id": "ITEM_MANAPOTION", "quantity": -1},
						{"type": "item", "id": "ITEM_STRENGTHPOTION", "quantity": 3}]
						#{"type": "scroll", "id": "SCROLL_FIGHT", "quantity": 1},
						#{"type": "magic", "id": "MAGIC_THUNDER", "quantity": 1}]
	kaleva.sellrate = 0.5
	shops[kaleva.title] = kaleva

	var potionsmaster0 = shopclass.new()
	potionsmaster0.title = "SHOP_POTIONSMASTER0"
	potionsmaster0.display_title = "SHOP_POTIONSMASTER"
	potionsmaster0.inventory = [{"type": "item", "id": "ITEM_POTION", "quantity": -1},
		{"type": "item", "id": "ITEM_POTION+", "quantity": -1}]
	potionsmaster0.sellrate = 0.5
	shops[potionsmaster0.title] = potionsmaster0

	var potionsmaster1 = shopclass.new()
	potionsmaster1.title = "SHOP_POTIONSMASTER1"
	potionsmaster1.display_title = "SHOP_POTIONSMASTER"
	potionsmaster1.inventory = [{"type": "item", "id": "ITEM_POTION+", "quantity": -1},
		{"type": "item", "id": "ITEM_POTION++", "quantity": -1},
		{"type": "item", "id": "ITEM_MANAPOTION", "quantity": -1}]
	potionsmaster1.sellrate = 0.5
	shops[potionsmaster1.title] = potionsmaster1

	var potionsmaster2 = shopclass.new()
	potionsmaster2.title = "SHOP_POTIONSMASTER2"
	potionsmaster2.display_title = "SHOP_POTIONSMASTER"
	potionsmaster2.inventory = [{"type": "item", "id": "ITEM_POTION", "quantity": -1},
		{"type": "item", "id": "ITEM_POTION+", "quantity": -1},
		{"type": "item", "id": "ITEM_MANAPOTION", "quantity": -1}]
	potionsmaster2.sellrate = 0.5
	shops[potionsmaster2.title] = potionsmaster2

	var lucifer = shopclass.new()
	lucifer.title = "SHOP_LUCIFER"
	lucifer.inventory = [{"type": "magic", "id": "MAGIC_WIND", "quantity": 1},
						{"type": "item", "id": "ITEM_MYSTICPOTION", "quantity": 3}]
	lucifer.sellrate = 1
	shops[lucifer.title] = lucifer

	var gabriel = shopclass.new()
	gabriel.title = "SHOP_GABRIEL"
	gabriel.inventory = [{"type": "magic", "id": "MAGIC_HEX", "quantity": 1}]

	gabriel.sellrate = 0.25
	shops[gabriel.title] = gabriel

	var jalo = shopclass.new()
	jalo.title = "SHOP_JALO"
	jalo.inventory = [{"type": "magic", "id": "MAGIC_VOID", "quantity": 1}]

	jalo.sellrate = 0.1
	shops[jalo.title] = jalo

	var vance = shopclass.new()
	vance.title = "SHOP_VANCE"
	vance.inventory = [{"type": "item", "id": "ITEM_POTION", "quantity": -1},
						{"type": "item", "id": "ITEM_MANAPOTION", "quantity": -1},
						{"type": "item", "id": "ITEM_SHIELDPOTION", "quantity": 5}]
	vance.sellrate = 0.5
	shops[vance.title] = vance

	var pepper = shopclass.new()
	pepper.title = "SHOP_PEPPER"
	pepper.inventory = [{"type": "magic", "id": "MAGIC_VOID", "quantity": 1}]

	pepper.sellrate = 0.5
	shops[pepper.title] = pepper

	var goddess = shopclass.new()
	goddess.title = "SHOP_GODDESS"
	goddess.inventory = [{"type": "magic", "id": "MAGIC_SHIELD", "quantity": 1}]

	goddess.sellrate = 1.5
	shops[goddess.title] = goddess

	var nystev = shopclass.new()
	nystev.title = "SHOP_NYSTEV"
	nystev.inventory = [{"type": "item", "id": "ITEM_SHIELDPOTION", "quantity": 2},
						{"type": "item", "id": "ITEM_STRENGTHPOTION", "quantity": 2}]

	nystev.sellrate = 2
	shops[nystev.title] = nystev

	var taevica = shopclass.new()
	taevica.title = "SHOP_TAEVICA"
	taevica.inventory = [{"type": "item", "id": "ITEM_CHARMPOTION", "quantity": 2},
						{"type": "item", "id": "ITEM_MYSTICPOTION", "quantity": 2}]

	taevica.sellrate = 0.5
	shops[taevica.title] = taevica

	var nero = shopclass.new()
	nero.title = "SHOP_NERO"
	nero.inventory = [{"type": "item", "id": "ITEM_STRENGTHPOTION", "quantity": 10}]

	nero.sellrate = 0.25
	shops[nero.title] = nero

	var aethea = shopclass.new()
	aethea.title = "SHOP_AETHEA"
	aethea.inventory = [{"type": "magic", "id": "MAGIC_MAGICMINE", "quantity": 1},
						{"type": "item", "id": "ITEM_STRENGTHPOTION", "quantity": 3},
						{"type": "item", "id": "ITEM_SHIELDPOTION", "quantity": 3},
						{"type": "item", "id": "ITEM_MYSTICPOTION", "quantity": 3},
						{"type": "item", "id": "ITEM_CHARMPOTION", "quantity": 3},
						{"type": "item", "id": "ITEM_MANAPOTION", "quantity": 3},
						{"type": "item", "id": "ITEM_POTION++", "quantity": -1},
						{"type": "item", "id": "ITEM_POTION+", "quantity": -1},
						{"type": "item", "id": "ITEM_MANAPOTION++", "quantity": -1},
						{"type": "item", "id": "ITEM_MANAPOTION+", "quantity": -1}]

	aethea.sellrate = 0.5
	shops[aethea.title] = aethea