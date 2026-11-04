## Makes a perfect Labyrinth with the recursive backtracker (spec 4.2): an iterative depth-first
## search with a stack. It removes no extra walls, so the Labyrinth has no loops.
class_name LabyrinthGenerator
extends RefCounted


## Uses `prng` for each choice. The caller can keep using the same PRNG after this call.
static func generate(width: int, height: int, prng: Prng) -> Labyrinth:
	var labyrinth := Labyrinth.new(width, height)
	var visited := PackedByteArray()
	visited.resize(width * height)
	var start := labyrinth.start_square()
	visited[start.y * width + start.x] = 1
	var stack: Array[Vector2i] = [start]
	while not stack.is_empty():
		var square: Vector2i = stack.back()
		var choices: Array[Vector2i] = []
		for direction in Labyrinth.DIRECTIONS:
			var neighbour := square + direction
			if labyrinth.contains(neighbour) and visited[neighbour.y * width + neighbour.x] == 0:
				choices.append(direction)
		if choices.is_empty():
			stack.pop_back()
			continue
		var direction := choices[prng.next() % choices.size()]
		var next := square + direction
		labyrinth.open_wall(square, direction)
		visited[next.y * width + next.x] = 1
		stack.push_back(next)
	if not labyrinth.all_squares_reachable():
		push_error("The generator left a square that the start cannot reach (%d x %d)." % [width, height])
	return labyrinth
