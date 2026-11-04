## The measure of one Labyrinth (play-improvements spec Part 3). The Item placement and the seed
## search use the same numbers from here.
class_name LabyrinthMeasure
extends RefCounted


## The main path P: the only chain of squares from the start P[0] to the Goal P[L]. L is
## size() - 1, the length in moves. It does not read the Items, so the placement can use it before
## the Items exist.
static func main_path(labyrinth: Labyrinth) -> Array[Vector2i]:
	var came_from := {labyrinth.start_square(): labyrinth.start_square()}
	var queue: Array[Vector2i] = [labyrinth.start_square()]
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		for direction in Labyrinth.DIRECTIONS:
			var next := current + direction
			if not labyrinth.has_wall(current, direction) and not came_from.has(next):
				came_from[next] = current
				queue.append(next)
	var path: Array[Vector2i] = [labyrinth.goal_square()]
	while path[-1] != labyrinth.start_square():
		path.append(came_from[path[-1]])
	path.reverse()
	return path


## The measure of a Labyrinth with its Items, which are all not collected. Keys:
## - "path": the main path, as main_path() gives it.
## - "length": the main path length in moves.
## - "presses": the arrow presses from the start to the Goal along the main path, with the move
##   rule of spec 5.2. Each Item on the path is a stop.
## - "decisions": the main-path squares with 3 or more open sides, without the start and the Goal.
## - "turns": the direction changes along the main path.
## - "largest_side_branch": the square count of the largest group of off-path squares that connect
##   without a main-path square. 0 when all squares are on the main path.
## - "items_on_path": the count of Items on main-path squares.
static func measure(labyrinth: Labyrinth) -> Dictionary:
	var path := main_path(labyrinth)
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
	return {
		"path": path,
		"length": path.size() - 1,
		"presses": presses,
		"decisions": decisions,
		"turns": turns,
		"largest_side_branch": _largest_side_branch(labyrinth, on_path),
		"items_on_path": items_on_path,
	}


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
