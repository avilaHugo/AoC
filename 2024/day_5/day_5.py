import sys
from dataclasses import dataclass

from cytoolz import compose, curry, groupby
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

    def __eq__(self, other):
        return self.n == other.n

    def unwrap(self):
        return self.n


def take_middle(update):
    return update[(-(len(update) // -2)) - 1]


def pt1(updates):
    return compose(
        sum,
        map(compose(Page.unwrap, take_middle)),
        filter(lambda u: u == compose(tuple, sorted)(u)),
    )(updates)


def pt2(updates):
    return compose(
        sum,
        map(compose(Page.unwrap, take_middle, compose(tuple, sorted))),
        filter(lambda u: not u == compose(tuple, sorted)(u)),
    )(updates)


def main(file_name):
    rules = lines_as_records(file_name)("|")
    L_rules = acc_rules(rules)
    R_rules = acc_rules(map(lambda t: t[::-1], rules))  # flip rules to get R
    int_to_page = lambda i: Page(i, L_rules.get(i, set()), R_rules.get(i, set()))
    updates = lambda: map(lambda update: compose(tuple, map(int_to_page))(update))(
        lines_as_records(file_name)(",")
    )
    print(f"pt1: {pt1(updates())}")
    print(f"pt2: {pt2(updates())}")


if __name__ == "__main__":
    main(*sys.argv[1:])
