import sys
from dataclasses import dataclass
from typing import ClassVar

from cytoolz import compose, curry
from cytoolz.curried import filter, map, reduce


def iter_file(file_name):
    with open(file_name) as f:
        yield from map(str.rstrip, f)


def find_guard(grid):
    def find_guard_on_line(line):
        return compose(
            lambda it: next(it, None),
            filter(lambda i: i > -1),
            map(lambda sub: line.find(sub)),
        )(Guard.possible_faces.keys())

    return compose(
        next,
        filter(lambda t: t[1]),
        map(lambda t: (t[0], find_guard_on_line(t[1]))),
        enumerate,
    )(grid)


def rotate_grid(grid):
    return compose(
        tuple,
        map(lambda j: compose("".join, map(lambda s: s[j]))(grid)),
        reversed,
        range,
        lambda grid: len(grid[0]),
    )(grid)


def render(grid):
    print(*grid, sep="\n")
    # print([Grid((">",) * len(grids[0].grid)), *grids])
    # print(
    #     *compose(map("\t".join), zip, map(lambda g: g.grid))(
    #         *[Grid((">",) * len(grids[0].grid)), *grids]
    #     ),
    #     sep="\n"
    # )


def walk_up(grid):
    curr_i, curr_j = grid.guard.pos
    f = grid.guard.is_facing
    old_cols = grid.cols()
    new_col = fill_x(old_cols[curr_j][::-1].replace(f, "@"))[::-1].replace("@", f)
    return (*old_cols[:curr_j], new_col, *old_cols[curr_j + 1 :])


def walk(grid):
    match grid.guard.is_facing:
        case "^":
            return walk_up(grid)


def fill_x(s):
    def replace_with_x(s):
        return (
            s.replace("@", "X").replace(".#", "@#").replace("X#", "@").replace(".", "X")
        )

    guard = s.find("@")
    obst = len(s[:guard]) + s[guard:].find("#")
    l = s[:guard]
    r = s[obst + 1 :]
    return l + replace_with_x(s[guard : obst + 1]) + r


def rotate_n(grid, n):
    return reduce(lambda grid, _: rotate_grid(grid), range(n), grid)


# ^ @ > @ v @ < @ ^
@dataclass
class Guard:
    pos: tuple[int]
    is_facing: str
    possible_faces: ClassVar[dict[str, str]] = {"^": ">", ">": "v", "v": "<", "<": "^"}

    def turn(self):
        return type(self)(self.pos, possible_faces[self.is_facing])

    @classmethod
    def from_grid(cls, grid):
        return (
            lambda i, j: cls(
                pos=(i, j),
                is_facing=grid[i][j],
            )
        )(*find_guard(grid))


@dataclass
class Grid:
    grid: tuple[str]

    def __post_init__(self):
        self.guard = Guard.from_grid(self.grid)

    @classmethod
    def from_file(cls, file_name):
        return cls(tuple(iter_file(file_name)))

    def cols(self):
        return compose(
            tuple,
            map(lambda j: compose("".join, map(lambda s: s[j]))(self.grid)),
            range,
        )(len(self.grid[0]))


def main(file_name):
    g = Grid.from_file(file_name)
    print(walk(g))


if __name__ == "__main__":
    main(*sys.argv[1:])
