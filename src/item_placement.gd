## Item placement of spec 4.6 with the main-path Items of play-improvements Part 1: the squares and
## kinds of the Items of one Labyrinth.
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
## `kinds[i % kinds.size()]`. The Labyrinth must have a free dead end. The placement order is
## Item 1 on the farthest free dead end, then the on-path squares from the start to the Goal. Then
## come the shuffled other dead ends, then the shuffled other squares.
static func place(labyrinth: Labyrinth, prng: Prng, count: int, kinds: PackedStringArray) -> Array[Item]:
	var dead_ends := free_dead_ends(labyrinth)
	var first := _farthest(labyrinth, dead_ends)
	dead_ends.erase(first)
	var path_squares := _on_path_squares(labyrinth.main_path(), count)
	var others: Array[Vector2i] = []
	for square in _free_squares(labyrinth):
		if labyrinth.open_side_count(square) != 1 and not path_squares.has(square):
			others.append(square)
	_shuffle(dead_ends, prng)
	_shuffle(others, prng)
	var squares: Array[Vector2i] = [first]
	squares.append_array(path_squares)
	squares.append_array(dead_ends)
	squares.append_array(others)
	var items: Array[Item] = []
	for i in mini(count, squares.size()):
		items.append(Item.new(squares[i], kinds[i % kinds.size()]))
	return items


## The k on-path squares P[j * L div (k + 1)] for j = 1 to k, from the start to the Goal, with
## k = min(max(1, count div 3), L - 1). L is the main path length in moves. A square is never the
## start or the Goal, and no square repeats.
static func _on_path_squares(path: Array[Vector2i], count: int) -> Array[Vector2i]:
	var length := path.size() - 1
	var k := mini(maxi(1, count / 3), length - 1)
	var squares: Array[Vector2i] = []
	for j in range(1, k + 1):
		squares.append(path[j * length / (k + 1)])
	return squares


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
