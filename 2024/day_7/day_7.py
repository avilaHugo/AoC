import sys
from collections.abc import Callable, Iterable
from itertools import chain
from operator import add, mul

from cytoolz import compose, curry
from cytoolz.curried import filter, map, reduce


def iter_file(file_name: str) -> Iterable[str]:
    with open(file_name) as f:
        yield from map(str.rstrip, f)


@curry
def sum_set_and_int(
    operations: Callable[[int, int], int], s: frozenset, i: int
) -> frozenset:
    return frozenset(
        chain.from_iterable(map(lambda I: map(lambda op: op(I, i), operations), s))
    )


def process_records(reducer: Iterable[Callable[[int, int], int]]) -> int:
    return compose(
        sum,
        map(lambda t: t[0]),
        filter(lambda t: t[0] in t[1]),
        map(
            compose(
                lambda t: (
                    t[0],
                    reduce(reducer, t[1][1:], frozenset((t[1][0],))),
                ),
                lambda it: (next(it), tuple(it)),
                map(int),
                lambda s: s.replace(":", "").split(),
            )
        ),
    )


def main(file_name):
    apply_operations = lambda ops: process_records(sum_set_and_int(ops))
    print("pt1", apply_operations([add, mul])(iter_file(file_name)))
    print(
        "pt2",
        apply_operations([add, mul, lambda a, b: int(str(a) + str(b))])(
            iter_file(file_name)
        ),
    )


if __name__ == "__main__":
    main(*sys.argv[1:])
