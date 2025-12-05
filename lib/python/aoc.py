from collections.abc import Callable, Iterable, Iterator
from itertools import islice, takewhile
from typing import Self, TypeVar


def iter_file(file_name: str) -> Iterator[str]:
    with open(file_name, mode="r", encoding="utf-8") as f:
        yield from map(str.rstrip, f)


class Grid:
    def __init__(self, data: tuple[str, ...]) -> None:
        self.data = data

    @classmethod
    def from_file(cls, file_name: str) -> Self:
        return cls(tuple(iter_file(file_name)))

    @property
    def shape(self) -> tuple[int, int]:
        return len(self.data), len(self.data[0])

    def __contains__(self, position: tuple[int, int]) -> bool:
        x, y = position
        max_x, max_y = self.shape
        return 0 <= x < max_x and 0 <= y < max_y

    def __iter__(self) -> Iterable[tuple[int, int, str]]:
        x, y = self.shape
        yield from ((i, j, self[i][j]) for i in range(x) for j in range(y))

    def __getitem__(self, i: int) -> str:
        return self.data[i]

    def __str__(self) -> str:
        return f"{type(self).__name__}{self.data}"

    def render(self) -> None:
        print(*self.data, sep="\n")
