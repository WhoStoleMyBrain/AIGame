extends TileMapLayer

# Load the Config and TileData scripts
# Variables for grid and constraints from config
var grid_size: Vector2i
var tiles = {}
var constraints = {}

var superposition_grid = []
var all_tiles = Config1.TILES

func load_config():
	grid_size = Config1.GRID_SIZE

	# Initialize tiles from Config.TILES
	for tile in Config1.TILES:
		tiles[tile.name] = tile

	# Load constraints from Config.CONSTRAINTS
	constraints = Config1.CONSTRAINTS

func _ready():
	load_config()
	initialize_grid()
	generate_wave_collapse()

# Initialize grid with all tile types possible at each location
func initialize_grid():
	superposition_grid.clear()
	for x in range(grid_size.x):
		var row = []
		for y in range(grid_size.y):
			row.append(all_tiles.duplicate())  # Duplicate to ensure a separate instance per cell
		superposition_grid.append(row)

# Main WFC algorithm
func generate_wave_collapse():
	var iteration_count = 0
	while not is_grid_collapsed():
		var cell = select_least_entropy_cell()
		collapse_cell(cell.x, cell.y)
		propagate_constraints(cell.x, cell.y)
		
		# Resolve unsolved cells after excessive iterations
		if iteration_count > grid_size.x * grid_size.y:
			print('iteration done. repeating...')
			count_empty_cells()
			resolve_empty_cells()
			iteration_count = 0  # Reset count after handling empty cells
		
		iteration_count += 1
		

# Function to check for empty cells and modify constraints
func resolve_empty_cells():
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			# If a cell has no valid options, attempt to reset it
			if superposition_grid[x][y].size() == 0:
				reset_cell(x, y)
				
func count_empty_cells():
	var count = 0
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			if superposition_grid[x][y].size() == 0:
				count += 1
	print('resetting a total of ', count, ' cells')
# Function to reset an empty cell by altering nearby constraints
func reset_cell(x, y):
	superposition_grid[x][y] = all_tiles.duplicate()
	for neighbor in get_neighbors(x, y):
		var nx = neighbor.x
		var ny = neighbor.y
		if is_in_bounds(nx, ny):
			if superposition_grid[nx][ny].size() == 0:
				superposition_grid[nx][ny] = all_tiles.duplicate()
			var neighbor_tile = superposition_grid[nx][ny][0] if superposition_grid[nx][ny].size() == 1 else null
			if neighbor_tile != null:
				superposition_grid[x][y] = superposition_grid[x][y].filter(func(t): return t in constraints[neighbor_tile.name])
			if superposition_grid[x][y].size() == 1:
				collapse_cell(x, y)
				propagate_constraints(x, y)

# Check if the entire grid is collapsed
func is_grid_collapsed() -> bool:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			if superposition_grid[x][y].size() > 1 || superposition_grid[x][y].size() == 0:
				return false
	return true

# Select the cell with the least entropy (fewest possible states)
func select_least_entropy_cell() -> Vector2:
	var min_entropy = 10000
	var selected_cell = Vector2(0, 0)
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var entropy = superposition_grid[x][y].size()
			if entropy > 1 and entropy < min_entropy:
				min_entropy = entropy
				selected_cell = Vector2(x, y)
	return selected_cell

# Collapse the cell by choosing one possible tile
func collapse_cell(x, y):
	var possible_tiles = superposition_grid[x][y]
	if possible_tiles.size() == 0:
		return
	var chosen_tile = possible_tiles[randi() % possible_tiles.size()]
	set_cell(Vector2i(x, y), chosen_tile.tileset_id, chosen_tile.atlas_position)
	superposition_grid[x][y] = [chosen_tile]

# Propagate constraints to neighboring cells
func propagate_constraints(x, y):
	var collapsed_tile
	if (superposition_grid[x][y].size() == 0): # no option set, so use a random one
		collapsed_tile = all_tiles[randi()% all_tiles.size()]
	else:
		collapsed_tile = superposition_grid[x][y][0]
	var neighbors = get_neighbors(x, y)

	for neighbor in neighbors:
		var neighbor_x = neighbor.x
		var neighbor_y = neighbor.y
		var allowed_tiles = constraints[collapsed_tile.name]

		if collapsed_tile == global_constants.SAND:
			var is_next_to_water = false
			var is_next_to_grass = false
			for n in neighbors:
				var nx = n.x
				var ny = n.y
				if is_in_bounds(nx, ny):
					var neighbor_tile = superposition_grid[nx][ny][0] if superposition_grid[nx][ny].size() == 1 else null
					if neighbor_tile == global_constants.WATER:
						is_next_to_water = true
					elif neighbor_tile == global_constants.GRASS:
						is_next_to_grass = true
			if is_next_to_water and not is_next_to_grass:
				allowed_tiles = allowed_tiles.filter(func(t): return t != global_constants.WATER)

		superposition_grid[neighbor_x][neighbor_y] = superposition_grid[neighbor_x][neighbor_y].filter(func(t): return t in allowed_tiles)

# Get the neighboring cells (up, down, left, right)
func get_neighbors(x, y) -> Array:
	var neighbors = []
	if x > 0:
		neighbors.append(Vector2(x - 1, y))
	if x < grid_size.x - 1:
		neighbors.append(Vector2(x + 1, y))
	if y > 0:
		neighbors.append(Vector2(x, y - 1))
	if y < grid_size.y - 1:
		neighbors.append(Vector2(x, y + 1))
	return neighbors

# Check if the given coordinates are within the grid bounds
func is_in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < grid_size.x and y >= 0 and y < grid_size.y
