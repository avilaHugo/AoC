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
        lambda it: next(it, None),
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


def walk_up(grid):
    curr_i, curr_j = grid.guard.pos
    f = grid.guard.is_facing
    old_cols = grid.cols()
    new_col = fill_x(old_cols[curr_j][::-1].replace(f, "@"))[::-1].replace("@", f)
    return Grid(Grid((*old_cols[:curr_j], new_col, *old_cols[curr_j + 1 :])).cols())


def walk_down(grid):
    curr_i, curr_j = grid.guard.pos
    f = grid.guard.is_facing
    old_cols = grid.cols()
    new_col = fill_x(old_cols[curr_j].replace(f, "@")).replace("@", f)
    return Grid(Grid((*old_cols[:curr_j], new_col, *old_cols[curr_j + 1 :])).cols())


def walk_right(grid):
    curr_i, curr_j = grid.guard.pos
    f = grid.guard.is_facing
    old_rows = grid.grid
    new_row = fill_x(old_rows[curr_i].replace(f, "@")).replace("@", f)
    return Grid((*old_rows[:curr_i], new_row, *old_rows[curr_i + 1 :]))


def walk_left(grid):
    curr_i, curr_j = grid.guard.pos
    f = grid.guard.is_facing
    old_rows = grid.grid
    new_row = fill_x(old_rows[curr_i][::-1].replace(f, "@"))[::-1].replace("@", f)
    return Grid((*old_rows[:curr_i], new_row, *old_rows[curr_i + 1 :]))


def walk(grid):
    match grid.guard.is_facing:
        case "^":
            return walk_up(grid).turn_guard()
        case "v":
            return walk_down(grid).turn_guard()
        case ">":
            return walk_right(grid).turn_guard()
        case "<":
            return walk_left(grid).turn_guard()


def fill_x(s):
    def replace_with_x(s):
        return (
            s.replace("@", "X").replace(".#", "@#").replace("X#", "@").replace(".", "X")
        )

    guard = s.find("@")
    obst_i = s[guard:].find("#")
    l = s[:guard]
    if not obst_i > -1:
        return l + replace_with_x(s[guard])
    obst = len(s[:guard]) + obst_i
    r = s[obst + 1 :]
    return l + replace_with_x(s[guard : obst + 1]) + r


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
        )(*(find_guard(grid) or (-1, -1)))


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

    def turn_guard(self):
        if self.guard.pos == (-1, -1):
            return self

        return type(self)(
            tuple(
                (
                    *self.grid[: self.guard.pos[0]],
                    self.grid[self.guard.pos[0]].replace(
                        self.guard.is_facing,
                        self.guard.possible_faces[self.guard.is_facing],
                    ),
                    *self.grid[self.guard.pos[0] + 1 :],
                )
            )
        )

    def __str__(self):
        return "\n".join(self.grid)

    def __add__(self, other):
        return type(self)(compose(tuple, map("\t".join))(zip(self.grid, other.grid)))


def main(file_name):
    g = Grid.from_file(file_name)

    try:
        while find_guard(g.grid):
            g = walk(g)
    except TypeError:
        pass

    print(g)
    print(compose(sum, map(lambda l: l.count("X")))(g.grid))


if __name__ == "__main__":
    main(*sys.argv[1:])
