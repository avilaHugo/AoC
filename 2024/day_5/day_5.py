import sys
from dataclasses import dataclass

from cytoolz import compose, curry
from cytoolz.curried import filter, map, reduce


def iter_file(file_name):
    with open(file_name) as f:
        yield from map(str.rstrip, f)


def lines_as_records(file_name):
    return lambda sub: compose(
        tuple,
        map(lambda s: compose(tuple, map(int))(s.split(sub))),
        filter(lambda s: sub in s),
        iter_file,
    )(file_name)


def acc_rules(rules):
    return compose(
        dict,
        map(lambda rule: (rule[0], set(rule[1]))),
        lambda d: d.items(),
        lambda rules: reduce(
            lambda d, t: {**d, t[0]: [*d.get(t[0], []), t[1]]}, rules, {}
        ),
    )(rules)


@dataclass
class Page:
    n: int
    l: set
    r: set

    def __lt__(self, other):
        return self.n in other.r

    def __gt__(self, other):
        return other.n in self.r

    def __eq__(self, other):
        return self.n == other.n


def order_updates(updates):
    return compose(
        tuple,
        map(lambda u: u.n),
        sorted,
        map(lambda i: Page(i, L_rules.get(i, set()), R_rules.get(i, set()))),
    )(updates)


def is_ordered(updates):
    return updates == order_updates(updates)


def main(file_name):
    rules = lines_as_records(file_name)("|")
    updates = lines_as_records(file_name)(",")

    global L_rules
    L_rules = acc_rules(rules)

    global R_rules
    R_rules = acc_rules(map(lambda t: t[::-1], rules))

    print(
        "pt1",
        compose(sum, map(lambda l: l[(-(len(l) // -2)) - 1]), filter(is_ordered))(
            updates
        ),
    )

    print(
        "pt2",
        compose(
            sum,
            map(lambda l: l[(-(len(l) // -2)) - 1]),
            map(order_updates),
            filter(lambda u: not is_ordered(u)),
        )(updates),
    )


if __name__ == "__main__":
    main(*sys.argv[1:])
