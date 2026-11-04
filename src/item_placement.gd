## Item placement of spec 4.6: the squares and kinds of the Items of one Labyrinth.
class_name ItemPlacement
extends RefCounted


## Dead ends (squares with exactly one open side) that are not the start or the Goal square, in
## row order: lowest y, then lowest x.
static func free_dead_ends(labyrinth: Labyrinth) -> Array[Vector2i]:
	var dead_ends: Array[Vector2i] = []
	for square in _free_squares(labyrinth):
		if labyrinth.open_side_count(square) == 1:
			dead_ends.append(square)
	return dead_ends


## A Labyrinth with no free dead end is not valid (spec 4.6 rule 7).
static func has_free_dead_end(labyrinth: Labyrinth) -> bool:
	return not free_dead_ends(labyrinth).is_empty()


## Places `count` Items. `prng` continues after the generator. Item i gets the kind
## `kinds[i % kinds.size()]`. The Labyrinth must have a free dead end.
static func place(labyrinth: Labyrinth, prng: Prng, count: int, kinds: PackedStringArray) -> Array[Item]:
	var dead_ends := free_dead_ends(labyrinth)
	var first := _farthest(labyrinth, dead_ends)
	dead_ends.erase(first)
	var others: Array[Vector2i] = []
	for square in _free_squares(labyrinth):
		if labyrinth.open_side_count(square) != 1:
			others.append(square)
	_shuffle(dead_ends, prng)
	_shuffle(others, prng)
	var squares: Array[Vector2i] = [first]
	squares.append_array(dead_ends)
	squares.append_array(others)
	var items: Array[Item] = []
	for i in mini(count, squares.size()):
		items.append(Item.new(squares[i], kinds[i % kinds.size()]))
	return items


## All squares except the start and the Goal, in row order.
static func _free_squares(labyrinth: Labyrinth) -> Array[Vector2i]:
	var squares: Array[Vector2i] = []
	for y in labyrinth.height:
		for x in labyrinth.width:
			var square := Vector2i(x, y)
			if square != labyrinth.start_square() and square != labyrinth.goal_square():
				squares.append(square)
	return squares


## The square with the largest breadth-first search distance from the start. `squares` is in row
## order, so on a tie the first one has the lowest y, then the lowest x.
static func _farthest(labyrinth: Labyrinth, squares: Array[Vector2i]) -> Vector2i:
	var distances := labyrinth.distances_from(labyrinth.start_square())
	var best := squares[0]
	for square in squares:
		if distances[square.y * labyrinth.width + square.x] > distances[best.y * labyrinth.width + best.x]:
			best = square
	return best


## Fisher-Yates with prng.next() % (i + 1).
static func _shuffle(squares: Array[Vector2i], prng: Prng) -> void:
	for i in range(squares.size() - 1, 0, -1):
		var j := prng.next() % (i + 1)
		var kept := squares[i]
		squares[i] = squares[j]
		squares[j] = kept
