extends Node

var GRASS:MyTile = MyTile.new("grass", 0, Vector2i(17, 4), 0)
var WATER:MyTile = MyTile.new("water", 1, Vector2i(8, 28), 0)
var SAND:MyTile = MyTile.new("sand", 2, Vector2i(9, 12), 0)

# Store all tiles in an array for easy access
var ALL_TILES = [GRASS, WATER, SAND]
