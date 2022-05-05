
extends Node

var levels = {}
var levelclass = preload("res://levels/Level.gd")
var locationfactory = preload("res://levels/LocationFactory.gd").new()

func _init():
	var sandbox = levelclass.new()
	sandbox.title = "LVL_SANDBOX"
	sandbox.type = "quest"
	sandbox.position = Vector2(160, 368)
	sandbox.description = "LVL_SANDBOX_DESCRIPTION"
	sandbox.location = locationfactory.locations["LVL_SANDBOX"]
	sandbox.item = "ITEM_AMULET"
	levels[sandbox.title] = sandbox
	
	var springislandcastle = levelclass.new()
	springislandcastle.title = "LVL_SPRINGISLANDCASTLE"
	springislandcastle.type = "quest"
	springislandcastle.position = Vector2(463, 26)
	springislandcastle.description = "LVL_SPRINGISLANDCASTLE_DESCRIPTION"
	springislandcastle.reward = 70000
	springislandcastle.item = "ITEM_STYXMIRROR"
	springislandcastle.require = ["LVL_CAPECRYPT", "LVL_SUMMERISLANDCASTLE"]
	springislandcastle.location = locationfactory.locations["LVL_SPRINGISLANDCASTLE"]
	levels[springislandcastle.title] = springislandcastle
	
	var summerislandcastle = levelclass.new()
	summerislandcastle.title = "LVL_SUMMERISLANDCASTLE"
	summerislandcastle.type = "quest"
	summerislandcastle.position = Vector2(679, 328)
	summerislandcastle.description = "LVL_SUMMERISLANDCASTLE_DESCRIPTION"
	summerislandcastle.reward = 30000
	summerislandcastle.item = "ITEM_STYXBROOCH"
	summerislandcastle.require = ["LVL_HOLYRUINS", "LVL_MAUSOLEUM"]
	summerislandcastle.location = locationfactory.locations["LVL_SUMMERISLANDCASTLE"]
	levels[summerislandcastle.title] = summerislandcastle

	var winterislandcastle = levelclass.new()
	winterislandcastle.title = "LVL_WINTERISLANDCASTLE"
	winterislandcastle.type = "quest"
	winterislandcastle.position = Vector2(195, 194)
	winterislandcastle.description = "LVL_WINTERISLANDCASTLE_DESCRIPTION"
	winterislandcastle.reward = 70000
	winterislandcastle.item = "ITEM_STYXTOME"
	winterislandcastle.require = ["LVL_LAVACAVE", "LVL_AQUADUCT2"]
	winterislandcastle.location = locationfactory.locations["LVL_WINTERISLANDCASTLE"]
	levels[winterislandcastle.title] = winterislandcastle
	
	var mausoleum = levelclass.new()
	mausoleum.title = "LVL_MAUSOLEUM"
	mausoleum.type = "quest"
	mausoleum.position = Vector2(288, 288)
	mausoleum.description = "LVL_MAUSOLEUM_DESCRIPTION"
	mausoleum.reward = 4000
	mausoleum.item = "ITEM_STYXINSCRIPTION"
	mausoleum.require = ["LVL_ICECAVE", "LVL_AQUADUCT"]
	mausoleum.location = locationfactory.locations["LVL_MAUSOLEUM"]
	levels[mausoleum.title] = mausoleum
	
	var cave = levelclass.new()
	cave.title = "LVL_CAVE"
	cave.type = "quest"
	cave.position = Vector2(424, 73)
	cave.description = "LVL_CAVE_DESCRIPTION"
	cave.reward = 4000
	cave.item = "ITEM_STYXCOIN"
	cave.require = ["LVL_DUNGEON", "LVL_BERGFORTRESS"]
	cave.location = locationfactory.locations["LVL_CAVE"]
	cave.tint = Color(144.0/255, 182.0/255, 203.0/255)
	levels[cave.title] = cave
	
	var forest1 = levelclass.new()
	forest1.title = "LVL_FOREST1"
	forest1.type = "bonus"
	forest1.position = Vector2(241, 297)
	forest1.description = "LVL_FOREST1_DESCRIPTION"
	forest1.location = locationfactory.locations["LVL_NOCTURNFOREST"]
	forest1.time = 6000
	forest1.mincounter = 5
	forest1.sealevel = 112
	forest1.require = [["LVL_DUNGEON", "LVL_ICECAVE"]]
	levels[forest1.title] = forest1

	var forest2 = levelclass.new()
	forest2.title = "LVL_FOREST2"
	forest2.type = "bonus"
	forest2.position = Vector2(482, 116)
	forest2.description = "LVL_FOREST2_DESCRIPTION"
	forest2.location = locationfactory.locations["LVL_LAKEFOREST"]
	forest2.time = 6000
	forest2.mincounter = 10
	forest2.sealevel = -208
	forest2.require = [["LVL_CAVE", "LVL_MAUSOLEUM"]]
	levels[forest2.title] = forest2

	var forest3 = levelclass.new()
	forest3.title = "LVL_FOREST3"
	forest3.type = "bonus"
	forest3.position = Vector2(669, 238)
	forest3.description = "LVL_FOREST3_DESCRIPTION"
	forest3.location = locationfactory.locations["LVL_JUNGLE"]
	forest3.time = 4500
	forest3.mincounter = 10
	forest3.sealevel = 368
	forest3.require = [["LVL_AQUADUCT2", "LVL_SUMMERISLANDCASTLE"]]
	levels[forest3.title] = forest3

	var forest4 = levelclass.new()
	forest4.title = "LVL_FOREST4"
	forest4.type = "bonus"
	forest4.position = Vector2(92, 226)
	forest4.description = "LVL_FOREST4_DESCRIPTION"
	forest4.location = locationfactory.locations["LVL_EVERGREEN"]
	forest4.time = 15000
	forest4.mincounter = 15
	forest4.sealevel = -16
	forest4.require = [["LVL_WINTERISLANDCASTLE", "LVL_SPRINGISLANDCASTLE"]]
	levels[forest4.title] = forest4

	var lavacave = levelclass.new()
	lavacave.title = "LVL_LAVACAVE"
	lavacave.type = "boss"
	lavacave.position = Vector2(347, 555)
	lavacave.description = "LVL_LAVACAVE_DESCRIPTION"
	lavacave.reward = 50000
	lavacave.require = ["LVL_MANOR", "LVL_CAVE"]
	lavacave.location = locationfactory.locations["LVL_LAVACAVE"]
	levels[lavacave.title] = lavacave
	
	var bergfortress = levelclass.new()
	bergfortress.title = "LVL_BERGFORTRESS"
	bergfortress.type = "boss"
	bergfortress.position = Vector2(259, 495)
	bergfortress.description = "LVL_BERGFORTRESS_DESCRIPTION"
	bergfortress.reward = 1500
	bergfortress.require = ["LVL_START"]
	bergfortress.character = "friederich"
	bergfortress.location = locationfactory.locations["LVL_BERGFORTRESS"]
	bergfortress.windowcolor = Color(1, 209.0/255, 72.0/255)
	bergfortress.tint = Color(1, 219.0/255, 192.0/255)
	levels[bergfortress.title] = bergfortress
	
	var aquaduct = levelclass.new()
	aquaduct.title = "LVL_AQUADUCT"
	aquaduct.type = "boss"
	aquaduct.position = Vector2(131, 207)
	aquaduct.description = "LVL_AQUADUCT_DESCRIPTION"
	aquaduct.reward = 1500
	aquaduct.require = ["LVL_START"]
	aquaduct.character = "adela"
	aquaduct.location = locationfactory.locations["LVL_AQUADUCT"]
	levels[aquaduct.title] = aquaduct
	
	var aquaduct2 = levelclass.new()
	aquaduct2.title = "LVL_AQUADUCT2"
	aquaduct2.type = "quest"
	aquaduct2.position = Vector2(614, 380)
	aquaduct2.description = "LVL_AQUADUCT2_DESCRIPTION"
	aquaduct2.reward = 30000
	aquaduct2.require = ["LVL_MANOR", "LVL_CAVE"]
	aquaduct2.item = "ITEM_STYXCHALICE"
	aquaduct2.location = locationfactory.locations["LVL_AQUADUCT2"]
	levels[aquaduct2.title] = aquaduct2

	var dungeon = levelclass.new()
	dungeon.title = "LVL_DUNGEON"
	dungeon.type = "quest"
	dungeon.position = Vector2(362, 389)
	dungeon.description = "LVL_DUNGEON_DESCRIPTION"
	dungeon.reward = 1000
	dungeon.item = "ITEM_STYXCREST"
	dungeon.location = locationfactory.locations["LVL_DUNGEON"]
	dungeon.require = ["LVL_START"]
	dungeon.character = "friederich"
	dungeon.tint = Color(187.0/255, 160.0/255, 242.0/255)
	levels[dungeon.title] = dungeon
	
	var icecave = levelclass.new()
	icecave.title = "LVL_ICECAVE"
	icecave.type = "quest"
	icecave.position = Vector2(77, 198)
	icecave.description = "LVL_ICECAVE_DESCRIPTION"
	icecave.reward = 1000
	icecave.item = "ITEM_STYXFIGURINE"
	icecave.location = locationfactory.locations["LVL_ICECAVE"]
	icecave.require = ["LVL_START"]
	icecave.character = "adela"
	levels[icecave.title] = icecave
	
	var manor = levelclass.new()
	manor.title = "LVL_MANOR"
	manor.type = "boss"
	manor.position = Vector2(503, 186)
	manor.description = "LVL_MANOR_DESCRIPTION"
	manor.location = locationfactory.locations["LVL_MARBLECASTLE"]
	manor.reward = 20000
	manor.require = ["LVL_DUNGEON", "LVL_BERGFORTRESS"]
	manor.tint = Color(213.0/255, 217.0/255, 1)
	levels[manor.title] = manor
	
	var holyruins = levelclass.new()
	holyruins.title = "LVL_HOLYRUINS"
	holyruins.type = "boss"
	holyruins.position = Vector2(307, 327)
	holyruins.description = "LVL_HOLYRUINS_DESCRIPTION"
	holyruins.location = locationfactory.locations["LVL_HOLYRUINS"]
	holyruins.reward = 20000
	holyruins.require = ["LVL_ICECAVE", "LVL_AQUADUCT"]
	levels[holyruins.title] = holyruins
	
	var capecrypt = levelclass.new()
	capecrypt.title = "LVL_CAPECRYPT"
	capecrypt.type = "boss"
	capecrypt.position = Vector2(560, 424)
	capecrypt.description = "LVL_CAPECRYPT_DESCRIPTION"
	capecrypt.location = locationfactory.locations["LVL_CAPECRYPT"]
	capecrypt.reward = 50000
	capecrypt.require = ["LVL_HOLYRUINS", "LVL_MAUSOLEUM"]
	levels[capecrypt.title] = capecrypt
	
	var start = levelclass.new()
	start.title = "LVL_START"
	start.type = "quest"
	start.position = Vector2(295, 356)
	start.description = "LVL_START_DESCRIPTION"
	start.reward = 100
	start.item = "ITEM_AMULET"
	start.location = locationfactory.locations["LVL_START"]
	start.tint = Color(125.0/255, 147.0/255, 203.0/255)
	levels[start.title] = start
	
	var colosseum1 = levelclass.new()
	colosseum1.title = "LVL_COLOSSEUM1"
	colosseum1.type = "colosseum"
	colosseum1.position = Vector2(193, 360)
	colosseum1.description = "LVL_COLOSSEUM1_DESCRIPTION"
	colosseum1.reward = 1000
	colosseum1.require = [["LVL_BERGFORTRESS", "LVL_AQUADUCT"]]
	colosseum1.location = locationfactory.locations["LVL_COLOSSEUM"]
	colosseum1.waves = [preload("res://scenes/colosseum/waves/wave0-0.tscn"), preload("res://scenes/colosseum/waves/wave0-1.tscn"), preload("res://scenes/colosseum/waves/wave0-2.tscn")]
	levels[colosseum1.title] = colosseum1
	
	var colosseum2 = levelclass.new()
	colosseum2.title = "LVL_COLOSSEUM2"
	colosseum2.type = "colosseum"
	colosseum2.position = Vector2(193, 360)
	colosseum2.description = "LVL_COLOSSEUM2_DESCRIPTION"
	colosseum2.require = [["LVL_MANOR", "LVL_HOLYRUINS"]]
	colosseum2.location = locationfactory.locations["LVL_COLOSSEUM"]
	colosseum2.waves = [preload("res://scenes/colosseum/waves/wave1-0.tscn"), preload("res://scenes/colosseum/waves/wave1-1.tscn"), preload("res://scenes/colosseum/waves/wave1-2.tscn"), preload("res://scenes/colosseum/waves/wave1-3.tscn"), preload("res://scenes/colosseum/waves/wave1-4.tscn")]
	colosseum2.reward = 10000
	levels[colosseum2.title] = colosseum2

	var colosseum3 = levelclass.new()
	colosseum3.title = "LVL_COLOSSEUM3"
	colosseum3.type = "colosseum"
	colosseum3.position = Vector2(193, 360)
	colosseum3.description = "LVL_COLOSSEUM3_DESCRIPTION"
	colosseum3.require = [["LVL_LAVACAVE", "LVL_CAPECRYPT"]]
	colosseum3.location = locationfactory.locations["LVL_COLOSSEUM"]
	colosseum3.waves = [preload("res://scenes/colosseum/waves/wave2-0.tscn"), preload("res://scenes/colosseum/waves/wave2-1.tscn"), preload("res://scenes/colosseum/waves/wave2-2.tscn"), preload("res://scenes/colosseum/waves/wave2-3.tscn"), preload("res://scenes/colosseum/waves/wave2-4.tscn"), preload("res://scenes/colosseum/waves/wave2-5.tscn"), preload("res://scenes/colosseum/waves/wave2-6.tscn")]
	colosseum3.reward = 500000
	levels[colosseum3.title] = colosseum3
