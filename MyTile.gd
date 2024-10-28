# This script defines the Tile class and constants for each tile asset

# Define a custom class for a tile
class_name MyTile

# Tile properties
var name: String
var id: int
var atlas_position: Vector2i
var tileset_id: int  # The ID of the tileset where this tile is stored

# Initialize the Tile class
func _init(name: String, id: int, atlas_position: Vector2i, tileset_id: int):
	self.name = name
	self.id = id
	self.atlas_position = atlas_position
	self.tileset_id = tileset_id
