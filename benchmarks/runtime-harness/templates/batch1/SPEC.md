# Batch 1: data structures

Implement every public name already present in `workload.py`. Use only the
Python standard library, preserve inputs, and raise the stated exception types.

## 1. Closed integer intervals

`normalize_intervals(intervals, merge_adjacent=True)` accepts an iterable of
two-item integer pairs. Booleans are invalid. Reject malformed pairs and
`start > end` with `ValueError`. Sort, deduplicate, and merge overlaps; also
merge touching integer intervals when `merge_adjacent` is true. Return a list
of `(start, end)` tuples.

`subtract_intervals(base, cuts)` treats both inputs as closed integer intervals.
Return the normalized portions of `base` not covered by any cut.

## 2. Immutable deep merge

`deep_merge(base, overlay, list_policy="replace")` requires two dictionaries
and returns a deep copy. Nested dictionaries merge recursively. A value equal
by identity to the exported `DELETE` sentinel removes that key. Other values
replace the base value. For lists, `replace` replaces the list and
`append_unique` appends only overlay items not equal to an existing result
item, preserving order. Reject other policies with `ValueError`.

## 3. JSON Pointer

`PointerError` subclasses `ValueError`. Pointer strings use RFC 6901 escaping:
`~0` means `~` and `~1` means `/`; any other `~` escape is invalid. The empty
pointer selects the root and nonempty pointers must start with `/`.

`pointer_get(document, pointer, default=MISSING)` traverses dictionaries and
lists. List indexes are canonical nonnegative decimals with no leading zero,
except `0`. Missing paths raise `PointerError`, or return `default` when it was
supplied.

`pointer_set(document, pointer, value, create_missing=False)` returns a deep
copy. An empty pointer replaces the root. `-` appends only at the final list
token. Other list indexes must already exist. When `create_missing` is true,
missing dictionary parents are created as dictionaries; it never invents a
list.

`pointer_remove(document, pointer)` returns a deep copy with the selected item
removed. Removing the root is invalid.

## 4. Stable relational join

`join_rows(left, right, keys, how="inner", suffixes=("_left", "_right"))`
accepts iterables of dictionaries and one key string or a nonempty sequence of
key strings. Every row must contain every key. Supported joins are `inner`,
`left`, and `full`. Duplicate keys produce the Cartesian product. Preserve
left-row order and matching right-row order; append unmatched right rows in
their original order for `full`.

Build each output from deep copies. Non-key columns present on both sides use
the two suffixes. Unmatched rows include all known columns from the other side
with `None`. Reject invalid modes, suffixes, rows, keys, or a generated suffixed
name that collides with another input column using `ValueError`.
