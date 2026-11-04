"""Independent Python port of spec 4.1, 4.2, 4.6, 5.2, the wall island decoration of spec 7.1, the
main-path Items of play-improvements spec Part 1, and the Labyrinth measure, the seed search, and
the fixed seed table of its Part 3.

It gives the pinned values of the GDScript tests (tests/test_generator.gd, tests/test_items.gd,
tests/test_island_look.gd, tests/test_labyrinth_measure.gd, and the scene tests that sail
Labyrinths 1, 2, 7, and 14). It does not read the
GDScript code, so a pin from this port checks the GDScript code against the spec.

Run: python3 tests/spec_port.py
"""

M = 0xFFFFFFFF


class Prng:
    """xorshift32 (13, 17, 5). Seed 0 becomes seed 1 (spec 4.1)."""

    def __init__(self, seed):
        self.x = seed & M or 1

    def next(self):
        x = self.x
        x ^= (x << 13) & M
        x ^= x >> 17
        x ^= (x << 5) & M
        self.x = x
        return x


N, E, S, W = 1, 2, 4, 8
# Direction, its wall bit, the wall bit of the neighbour. Order north, east, south, west.
DIRS = [((0, -1), N, S), ((1, 0), E, W), ((0, 1), S, N), ((-1, 0), W, E)]


def generate(w, h, prng):
    """Recursive backtracker of spec 4.2. The search never goes on from the Goal square."""
    goal = (w - 1, h - 1)
    walls = [[15] * w for _ in range(h)]
    seen = [[False] * w for _ in range(h)]
    seen[0][0] = True
    stack = [(0, 0)]
    while stack:
        x, y = stack[-1]
        choices = []
        for (dx, dy), bit, other in DIRS:
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not seen[ny][nx]:
                choices.append(((dx, dy), bit, other))
        if not choices:
            stack.pop()
            continue
        (dx, dy), bit, other = choices[prng.next() % len(choices)]
        nx, ny = x + dx, y + dy
        walls[y][x] &= ~bit
        walls[ny][nx] &= ~other
        seen[ny][nx] = True
        if (nx, ny) != goal:
            stack.append((nx, ny))
    return walls


def open_sides(walls, x, y):
    return sum(1 for (_, bit, _) in DIRS if not walls[y][x] & bit)


def bfs(walls, w, h, stop=None):
    """Distances from the start. The search does not go on from the square `stop`."""
    dist = {(0, 0): 0}
    queue = [(0, 0)]
    for (x, y) in queue:
        if (x, y) == stop:
            continue
        for (dx, dy), bit, _ in DIRS:
            if not walls[y][x] & bit:
                n = (x + dx, y + dy)
                if n not in dist:
                    dist[n] = dist[(x, y)] + 1
                    queue.append(n)
    return dist


def behind_goal(walls, w, h):
    """The squares that the boat can reach only through the Goal square."""
    reached = bfs(walls, w, h, stop=(w - 1, h - 1))
    return [(x, y) for y in range(h) for x in range(w) if (x, y) not in reached]


def shuffle(a, prng):
    for i in range(len(a) - 1, 0, -1):
        j = prng.next() % (i + 1)
        a[i], a[j] = a[j], a[i]


def dead_ends(walls, w, h):
    """Free dead ends (spec 4.6 rule 1) in row order."""
    goal = (w - 1, h - 1)
    return [(x, y) for y in range(h) for x in range(w)
            if (x, y) not in ((0, 0), goal) and open_sides(walls, x, y) == 1]


def on_path_count(count, length):
    """Play-improvements Part 1: k = min(max(1, count div 3), L - 1)."""
    return min(max(1, count // 3), length - 1)


def place(walls, w, h, prng, count, k=None):
    """Item squares of spec 4.6 with play-improvements Part 1, in placement order: Item 1 on the
    farthest free dead end, then the k on-path squares P[j * L div (k + 1)] (j = 1 to k) from the
    start to the Goal, then the shuffled other dead ends, then the shuffled other squares without
    the k path squares. Candidates are in row order before a shuffle. k=None uses the rule for k;
    k=0 gives the placement before Part 1."""
    goal = (w - 1, h - 1)
    de = dead_ends(walls, w, h)
    dist = bfs(walls, w, h)
    first = min(de, key=lambda s: (-dist[s], s[1], s[0]))
    rest = [s for s in de if s != first]
    path = main_path(walls, w, h)
    length = len(path) - 1
    if k is None:
        k = on_path_count(count, length)
    on_path = [path[j * length // (k + 1)] for j in range(1, k + 1)]
    others = [(x, y) for y in range(h) for x in range(w)
              if (x, y) not in ((0, 0), goal) and (x, y) not in de and (x, y) not in on_path]
    shuffle(rest, prng)
    shuffle(others, prng)
    order = [first] + on_path + rest + others
    return order[:count]


SIZES = [(4, 3), (5, 3), (5, 4), (6, 4), (7, 4), (7, 5), (8, 5), (8, 6), (9, 6), (9, 7)]
# Play-improvements Part 3: Labyrinth n (1 to 20) uses seed FIXED_SEEDS[n - 1]. check_seeds() checks
# that seed_search() gives this table.
FIXED_SEEDS = [1, 17, 2, 9, 85, 10, 12, 9, 8, 23, 1, 69, 29, 73, 9, 28, 73, 127, 167, 30]


def size(n):
    return SIZES[(n - 1) // 2] if n <= 20 else (10, 7)


def count(w, h):
    return max(2, min(8, (w * h) // 6))


def valid_seed(w, h, seed):
    """Spec 4.6 rule 7: a seed with no free dead end moves to seed + 1."""
    seed = seed & M or 1
    while not dead_ends(generate(w, h, Prng(seed)), w, h):
        seed = (seed + 1) & M or 1
    return seed


def build(n, random_seed=0, k=None):
    """Labyrinth n: (w, h, walls, Item squares). k as in place()."""
    w, h = size(n)
    return build_from_seed(n, FIXED_SEEDS[n - 1] if n <= 20 else valid_seed(w, h, random_seed), k)


def build_from_seed(n, seed, k=None):
    """Labyrinth n with the seed `seed`: (w, h, walls, Item squares). The seed must have a free dead
    end. k as in place()."""
    w, h = size(n)
    prng = Prng(seed)
    walls = generate(w, h, prng)
    return w, h, walls, place(walls, w, h, prng, count(w, h), k)


def tiles(walls, w, h):
    """Tile picture of spec 4.5: '#' island, '.' water."""
    grid = [["#"] * (2 * w + 1) for _ in range(2 * h + 1)]
    for y in range(h):
        for x in range(w):
            grid[2 * y + 1][2 * x + 1] = "."
            if not walls[y][x] & E:
                grid[2 * y + 1][2 * x + 2] = "."
            if not walls[y][x] & S:
                grid[2 * y + 2][2 * x + 1] = "."
    return ["".join(row) for row in grid]


ROCKS = [49, 50, 51, 65, 66, 67]
BUSH = 70


def decorations(grid, seed):
    """Wall island decorations of spec 7.1: PRNG seed + 1, one output r for each island tile in
    row order except the Goal island. r % 6 == 0 gives a decoration: pick = (r / 6) % 12 is the
    bush for 0 to 5, else ROCKS[pick - 6]."""
    rows, cols = len(grid), len(grid[0])
    goal_island = (cols - 1, rows - 2)
    prng = Prng(seed + 1)
    out = []
    for y in range(rows):
        for x in range(cols):
            if grid[y][x] != "#" or (x, y) == goal_island:
                continue
            r = prng.next()
            if r % 6 == 0:
                pick = (r // 6) % 12
                out.append(((x, y), BUSH if pick < 6 else ROCKS[pick - 6]))
    return out


def ids(squares):
    return [f"{x},{y}" for x, y in squares]


def main_path(walls, w, h):
    """The only chain of squares from the start P[0] to the Goal P[L] (a perfect Labyrinth)."""
    goal = (w - 1, h - 1)
    came_from = {(0, 0): None}
    queue = [(0, 0)]
    for (x, y) in queue:
        for (dx, dy), bit, _ in DIRS:
            if not walls[y][x] & bit:
                n = (x + dx, y + dy)
                if n not in came_from:
                    came_from[n] = (x, y)
                    queue.append(n)
    path = [goal]
    while came_from[path[-1]] is not None:
        path.append(came_from[path[-1]])
    return path[::-1]


def wall_in(walls, square, direction):
    x, y = square
    for d, bit, _ in DIRS:
        if d == direction:
            return bool(walls[y][x] & bit)


def press(walls, w, h, square, direction, uncollected):
    """Spec 5.2 rule 3: the boat goes straight one square at a time and stops on the first square
    where the next side is a wall, the square has 3 or more open sides, the square holds an Item
    not collected, or the square is the Goal. The caller checks that the first side is open."""
    goal = (w - 1, h - 1)
    while True:
        square = (square[0] + direction[0], square[1] + direction[1])
        if (wall_in(walls, square, direction) or open_sides(walls, *square) >= 3
                or square in uncollected or square == goal):
            return square


def measure(walls, w, h, items):
    """Part 3 measure of a Labyrinth with its Item squares. All Items start not collected. The boat
    sails the main path: each press goes toward the next path square (spec 5.2), and the boat
    collects the Item where it stops (spec 5.2 rule 6)."""
    path = main_path(walls, w, h)
    index = {s: i for i, s in enumerate(path)}
    uncollected = set(items)
    presses, square = 0, path[0]
    while square != path[-1]:
        nxt = path[index[square] + 1]
        direction = (nxt[0] - square[0], nxt[1] - square[1])
        square = press(walls, w, h, square, direction, uncollected)
        uncollected.discard(square)
        presses += 1
    steps = [(b[0] - a[0], b[1] - a[1]) for a, b in zip(path, path[1:])]
    on_path = set(path)
    # Largest group of off-path squares that connect without a main-path square.
    seen, largest = set(), 0
    for y in range(h):
        for x in range(w):
            if (x, y) in on_path or (x, y) in seen:
                continue
            seen.add((x, y))
            group = [(x, y)]
            for (gx, gy) in group:
                for (dx, dy), bit, _ in DIRS:
                    n = (gx + dx, gy + dy)
                    if not walls[gy][gx] & bit and n not in on_path and n not in seen:
                        seen.add(n)
                        group.append(n)
            largest = max(largest, len(group))
    return {
        "length": len(path) - 1,
        "presses": presses,
        "decisions": sum(1 for s in path[1:-1] if open_sides(walls, *s) >= 3),
        "turns": sum(1 for a, b in zip(steps, steps[1:]) if a != b),
        "largest_side_branch": largest,
        "items_on_path": sum(1 for s in items if s in on_path),
    }


# Item IDs of Labyrinths 1 to 20 with seed n, and of the random seeds 4242 and 123456789, before
# play-improvements Part 1. The rule with k = 0 must give them (Part 1: "this rule with k = 0
# gives the placement of today").
PLACEMENT_BEFORE_PART_1 = {
    1: ["1,1", "1,2"], 2: ["0,1", "2,2"], 3: ["2,1", "4,1"], 4: ["0,1", "4,1"],
    5: ["4,0", "2,0", "3,2"], 6: ["3,3", "1,1", "1,2"], 7: ["2,0", "5,2", "1,2", "3,3"],
    8: ["0,1", "4,1", "2,3", "1,1"], 9: ["0,3", "1,1", "5,3", "3,2"], 10: ["5,1", "0,3", "4,2", "3,2"],
    11: ["0,4", "2,1", "4,2", "6,2", "3,4"], 12: ["5,1", "1,1", "5,4", "3,1", "4,2"],
    13: ["2,4", "6,1", "1,1", "5,2", "7,3", "2,0"], 14: ["4,3", "6,1", "0,4", "6,4", "1,1", "0,2"],
    15: ["7,1", "5,4", "1,4", "4,1", "2,1", "0,5", "7,0", "1,0"],
    16: ["7,2", "0,3", "4,0", "5,2", "4,5", "2,5", "4,3", "2,0"],
    17: ["7,3", "0,5", "2,2", "5,5", "5,2", "0,1", "6,0", "6,4"],
    18: ["6,3", "4,5", "8,4", "3,1", "5,1", "3,5", "0,4", "4,3"],
    19: ["4,6", "5,1", "3,3", "8,3", "2,5", "1,2", "0,6", "0,1"],
    20: ["4,2", "1,4", "3,3", "8,1", "0,6", "2,5", "6,3", "3,1"],
    4242: ["0,4", "0,6", "5,5", "9,0", "2,3", "7,3", "5,0", "3,4"],
    123456789: ["6,4", "3,6", "2,3", "1,0", "4,2", "9,5", "6,1", "0,2"],
}


def check_placement():
    """Self-checks of play-improvements Part 1. Raises AssertionError on a failure."""
    for key, expected in PLACEMENT_BEFORE_PART_1.items():
        got = ids(build_from_seed(key, key, k=0)[3]) if key <= 20 else ids(build(21, key, k=0)[3])
        assert got == expected, ("k = 0 placement", key, got, expected)
    seeds = list(range(1, 21)) + [(21, s) for s in range(1, 201)]
    for key in seeds:
        w, h, walls, items = build(key) if isinstance(key, int) else build(*key)
        path = main_path(walls, w, h)
        k = on_path_count(len(items), len(path) - 1)
        dist = bfs(walls, w, h)
        assert sum(1 for s in items if s in path) >= k, ("on-path Items", key)
        assert (0, 0) not in items and (w - 1, h - 1) not in items, ("start or Goal", key)
        assert len(set(items)) == len(items), ("Item squares differ", key)
        assert dist[items[0]] == max(dist[s] for s in dead_ends(walls, w, h)), ("farthest dead end", key)


# Play-improvements Part 3: the arrow presses T(n) along the main path of Labyrinth n.
PRESSES = [3, 5, 5, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]


def meets_conditions(n, seed):
    """Play-improvements Part 3: the seed has a free dead end, and Labyrinth n with this seed and
    its Items has presses = T(n), decisions from d to d + 2 with d = 1 + (n - 1) div 5, turns >= 2
    for n >= 2, at least 1 Item on the main path, and a largest side branch of at most
    max(6, main path length)."""
    w, h = size(n)
    if not dead_ends(generate(w, h, Prng(seed)), w, h):
        return False
    _, _, walls, items = build_from_seed(n, seed)
    m = measure(walls, w, h, items)
    d = 1 + (n - 1) // 5
    return (m["presses"] == PRESSES[n - 1] and d <= m["decisions"] <= d + 2
            and (n < 2 or m["turns"] >= 2) and m["items_on_path"] >= 1
            and m["largest_side_branch"] <= max(6, m["length"]))


def seed_search():
    """Play-improvements Part 3: for each Labyrinth n from 1 to 20 in order, the first seed from 1
    upward that meets the conditions and is not the seed of an earlier Labyrinth with the same
    size."""
    table = []
    for n in range(1, 21):
        taken = [table[i] for i in range(n - 1) if size(i + 1) == size(n)]
        seed = 1
        while seed in taken or not meets_conditions(n, seed):
            seed += 1
        table.append(seed)
    return table


# The review table of play-improvements Part 3: n -> (seed, presses, decisions, Item IDs in
# placement order). The seed search wins over this table; review_differences() lists each value
# that differs.
REVIEW_TABLE = {
    1: (1, 3, 1, "1,1 0,2"), 2: (17, 5, 2, "0,1 2,1"), 3: (2, 5, 1, "1,1 4,1"),
    4: (9, 5, 1, "2,1 3,2"), 5: (85, 5, 2, "4,0 2,1 1,1"), 6: (10, 6, 2, "0,3 2,1 4,0"),
    7: (12, 7, 2, "5,2 2,2 0,3 1,0"), 8: (9, 8, 2, "0,3 3,1 4,3 1,1"),
    9: (8, 9, 2, "0,1 3,1 6,0 5,3"), 10: (23, 10, 2, "6,0 1,3 0,1 6,2"),
    11: (1, 11, 3, "3,2 3,1 6,0 1,0 2,4"), 12: (69, 12, 4, "4,3 2,1 6,0 0,4 1,2"),
    13: (29, 13, 3, "0,2 3,3 6,0 4,1 6,1 2,3"), 14: (73, 14, 4, "1,0 4,1 2,4 7,0 6,2 1,3"),
    15: (9, 15, 3, "4,1 4,0 6,2 3,2 1,5 1,1 7,4 0,5"),
    16: (28, 16, 4, "3,4 3,2 6,0 1,2 1,0 4,1 5,3 6,1"),
    17: (73, 17, 4, "1,0 5,2 5,4 8,0 3,4 7,2 2,2 1,4"),
    18: (127, 18, 5, "6,3 4,2 2,2 0,1 7,5 2,4 8,0 4,4"),
    19: (167, 19, 5, "4,5 4,6 2,1 5,1 7,6 3,2 6,4 0,6"),
    20: (30, 20, 4, "8,2 3,1 3,6 1,4 3,5 2,1 7,6 0,6"),
}


def review_differences():
    """Each value of the review table that differs from the port, as (n, field, review, port)."""
    out = []
    for n, review in REVIEW_TABLE.items():
        w, h, walls, items = build(n)
        m = measure(walls, w, h, items)
        port = (FIXED_SEEDS[n - 1], m["presses"], m["decisions"], " ".join(ids(items)))
        for field, a, b in zip(["seed", "presses", "decisions", "Item IDs"], review, port):
            if a != b:
                out.append((n, field, a, b))
    return out


def check_seeds():
    """Self-checks of play-improvements Part 3. Raises AssertionError on a failure."""
    found = seed_search()
    assert found == FIXED_SEEDS, ("seed search", found, FIXED_SEEDS)


if __name__ == "__main__":
    check_placement()
    print("placement self-checks pass")
    check_seeds()
    print("seed search gives the seed table", FIXED_SEEDS)
    print("review table differences", review_differences() or "none")
    print("Labyrinth 7 before Part 3 (seed 7)", ids(build_from_seed(7, 7)[3]), "now", ids(build(7)[3]))
    for n in range(1, 21):
        w, h, walls, items = build(n)
        path = main_path(walls, w, h)
        print("placement", n, "L", len(path) - 1, "k", on_path_count(len(items), len(path) - 1),
              "on path", [i for i, s in enumerate(path) if s in items])
    w, h, walls, items = build(1)
    print("Labyrinth 1 walls", [b for row in walls for b in row])
    grid = tiles(walls, w, h)
    print("\n".join(grid))
    print("Labyrinth 1 decorations", decorations(grid, FIXED_SEEDS[0]))
    for n in range(1, 21):
        w, h, walls, items = build(n)
        print(n, (w, h), "dead_ends", len(dead_ends(walls, w, h)), "behind_goal", behind_goal(walls, w, h),
              "items", ids(items))
    for n in range(1, 21):
        w, h, walls, items = build(n)
        m = measure(walls, w, h, items)
        print("measure", n, ids(main_path(walls, w, h)) if n <= 2 else "", m)
    w, h, walls, _ = build(2)
    dist = bfs(walls, w, h)
    print("Labyrinth 2 free dead ends", [(s, dist[s]) for s in dead_ends(walls, w, h)])
    print("3x2 invalid seeds", [s for s in range(1, 200) if not dead_ends(generate(3, 2, Prng(s)), 3, 2)][:20])
    for s in [4242, 123456789]:
        print("random", s, "valid seed", valid_seed(10, 7, s), ids(build(21, s)[3]))
    behind = 0
    for s in range(1, 1001):
        w, h, walls, _ = build(21, s)
        behind += 1 if behind_goal(walls, w, h) else 0
    print("random seeds 1 to 1000 with a square behind the Goal", behind)
