import sys
from collections import defaultdict
from itertools import chain, combinations

import aoc


def get_antinodes(a, b):
    ax, ay = a
    bx, by = b
    dx = bx - ax
    dy = by - ay
    yield (ax - dx, ay - dy)
    yield (bx + dx, by + dy)


def main(file_name):
    grid = aoc.Grid.from_file(file_name)
    max_x, max_y = grid.shape
    anthenas = defaultdict(list)

    for x, y, c in grid:
        if c == ".":
            continue
        anthenas[c].append((x, y))

    antinodes1 = set()
    for anthena_group in anthenas.values():
        for pair in combinations(anthena_group, 2):
            for antinode in get_antinodes(*pair):
                if not antinode in grid:
                    continue
                antinodes1.add(antinode)

    print("pt 1:", len(antinodes1))

    antinodes2 = set()
    for anthena_group in anthenas.values():
        for pair in combinations(anthena_group, 2):
            antinodes2.update(pair)
            (ax, ay), (bx, by) = pair
            dx, dy = bx - ax, by - ay
            while (ax, ay) in grid or (bx, by) in grid:
                if (a := (ax - dx, ay - dy)) in grid:
                    antinodes2.add(a)

                if (b := (bx + dx, by + dy)) in grid:
                    antinodes2.add(b)

                ax, ay = (ax - dx, ay - dy)
                bx, by = (bx + dx, by + dy)

    print("pt 2:", len(antinodes2))


if __name__ == "__main__":
    main(*sys.argv[1:])
