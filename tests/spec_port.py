"""Independent Python port of spec 4.1, 4.2, 4.6, and the wall island decoration of spec 7.1.

It gives the pinned values of the GDScript tests (tests/test_generator.gd, tests/test_items.gd,
tests/test_island_look.gd, and the scene tests that sail Labyrinth 1). It does not read the
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


def place(walls, w, h, prng, count):
    """Item squares of spec 4.6 in placement order. Candidates are in row order before a shuffle."""
    goal = (w - 1, h - 1)
    de = dead_ends(walls, w, h)
    dist = bfs(walls, w, h)
    first = min(de, key=lambda s: (-dist[s], s[1], s[0]))
    rest = [s for s in de if s != first]
    others = [(x, y) for y in range(h) for x in range(w)
              if (x, y) not in ((0, 0), goal) and (x, y) not in de]
    shuffle(rest, prng)
    shuffle(others, prng)
    order = [first] + rest + others
    return order[:count]


SIZES = [(4, 3), (5, 3), (5, 4), (6, 4), (7, 4), (7, 5), (8, 5), (8, 6), (9, 6), (9, 7)]


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


def build(n, random_seed=0):
    """Labyrinth n: (w, h, walls, Item squares)."""
    w, h = size(n)
    seed = n if n <= 20 else valid_seed(w, h, random_seed)
    prng = Prng(seed)
    walls = generate(w, h, prng)
    return w, h, walls, place(walls, w, h, prng, count(w, h))


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


if __name__ == "__main__":
    w, h, walls, items = build(1)
    print("Labyrinth 1 walls", [b for row in walls for b in row])
    grid = tiles(walls, w, h)
    print("\n".join(grid))
    print("Labyrinth 1 decorations", decorations(grid, 1))
    for n in range(1, 21):
        w, h, walls, items = build(n)
        print(n, (w, h), "dead_ends", len(dead_ends(walls, w, h)), "behind_goal", behind_goal(walls, w, h),
              "items", ids(items))
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
