"""Batch 1 implementation target."""

MISSING = object()
DELETE = object()


class PointerError(ValueError):
    pass


def normalize_intervals(intervals, merge_adjacent=True):
    raise NotImplementedError


def subtract_intervals(base, cuts):
    raise NotImplementedError


def deep_merge(base, overlay, list_policy="replace"):
    raise NotImplementedError


def pointer_get(document, pointer, default=MISSING):
    raise NotImplementedError


def pointer_set(document, pointer, value, create_missing=False):
    raise NotImplementedError


def pointer_remove(document, pointer):
    raise NotImplementedError


def join_rows(left, right, keys, how="inner", suffixes=("_left", "_right")):
    raise NotImplementedError
