## The measure of one Labyrinth (play-improvements spec Part 3). The seed search and the fixed seed
## check use the same numbers from here.
class_name LabyrinthMeasure
extends RefCounted


## The measure of a Labyrinth with its Items, which are all not collected.
class Measure:
	## The main path, as Labyrinth.main_path() gives it.
	var path: Array[Vector2i]
	## The main path length in moves.
	var length: int
	## The arrow presses from the start to the Goal along the main path, with the move rule of
	## spec 5.2. Each Item on the path is a stop.
	var presses: int
	## The main-path squares with 3 or more open sides, without the start and the Goal.
	var decisions: int
	## The direction changes along the main path.
	var turns: int
	## The square count of the largest group of off-path squares that connect without a main-path
	## square. 0 when all squares are on the main path.
	var largest_side_branch: int
	## The count of Items on main-path squares.
	var items_on_path: int


static func measure(labyrinth: Labyrinth) -> Measure:
	var path := labyrinth.main_path()
	var on_path := {}
	for square in path:
		on_path[square] = true
	var not_collected := {}
	var items_on_path := 0
	for item in labyrinth.items:
		not_collected[item.square] = false
		if on_path.has(item.square):
			items_on_path += 1
	var presses := 0
	var decisions := 0
	var turns := 0
	for i in range(1, path.size()):
		var direction := path[i] - path[i - 1]
		if MoveRule.stops_at(labyrinth, path[i], direction, not_collected):
			presses += 1
		if i < path.size() - 1:
			if labyrinth.open_side_count(path[i]) >= 3:
				decisions += 1
			if path[i + 1] - path[i] != direction:
				turns += 1
	var result := Measure.new()
	result.path = path
	result.length = path.size() - 1
	result.presses = presses
	result.decisions = decisions
	result.turns = turns
	result.largest_side_branch = _largest_side_branch(labyrinth, on_path)
	result.items_on_path = items_on_path
	return result


## The groups come from a breadth-first search that does not cross a main-path square. So this
## search does not use Labyrinth.distances_from(), which crosses each open wall.
static func _largest_side_branch(labyrinth: Labyrinth, on_path: Dictionary) -> int:
	var seen := on_path.duplicate()
	var largest := 0
	for y in labyrinth.height:
		for x in labyrinth.width:
			var first := Vector2i(x, y)
			if seen.has(first):
				continue
			seen[first] = true
			var group: Array[Vector2i] = [first]
			var head := 0
			while head < group.size():
				var current := group[head]
				head += 1
				for direction in Labyrinth.DIRECTIONS:
					var next := current + direction
					if not labyrinth.has_wall(current, direction) and not seen.has(next):
						seen[next] = true
						group.append(next)
			largest = maxi(largest, group.size())
	return largest
