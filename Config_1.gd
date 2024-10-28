# Config.gd - Configuration for environment generation using TileData

# Import TileData for access to tile constants

# const MyTileData = preload("res://MyTileData.gd")
extends Node
# Grid size for environment generation
const GRID_SIZE = Vector2i(64, 64)

# Available tiles (referencing TileData constants)
var TILES = global_constants.ALL_TILES

# Constraints for each tile
var CONSTRAINTS = {
	global_constants.GRASS.name: [global_constants.GRASS, global_constants.SAND],
	global_constants.WATER.name: [global_constants.WATER, global_constants.SAND],
	global_constants.SAND.name: [global_constants.SAND, global_constants.GRASS, global_constants.WATER]
}
