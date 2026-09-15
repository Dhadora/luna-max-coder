# Batch 2: stateful algorithms

Implement every public name already present in `workload.py`. Use only the
Python standard library. Validate constructor arguments and preserve caller
data where the specification requires copies.

## 5. Deterministic dependency layers

`CycleError` subclasses `ValueError` and exposes a `.cycle` list whose first
and last entries are equal. `topological_layers(graph)` accepts a dictionary
mapping string nodes to iterables of string dependencies. Dependency-only nodes
are included. Reject non-string nodes and dependencies with `ValueError`.
Return lexicographically sorted layers, with each layer containing all nodes
whose dependencies were satisfied by earlier layers. On a cycle, raise
`CycleError` with a deterministic cycle starting at the lexicographically
smallest node participating in the selected cycle.

## 6. LRU cache with TTL

`TTLCache(capacity, default_ttl, clock)` requires positive integer capacity,
nonnegative finite default TTL, and a callable monotonic clock. `set(key,
value, ttl=None)` stores a value with an optional nonnegative finite TTL and
marks it most recently used. Expiration occurs when `clock() >= deadline`.
`get(key, default=MISSING)` refreshes LRU order; a missing or expired key raises
`KeyError` unless a default was supplied. `delete(key)` returns a boolean,
`purge()` removes expired entries and returns their count, and `len(cache)`
counts only live entries. `stats()` returns integer `hits`, `misses`,
`evictions`, and current `size`. Expiry purges are not misses; capacity removals
are evictions.

## 7. Token bucket

`TokenBucket(capacity, refill_rate, clock)` requires finite positive numbers
and starts full. Refill lazily according to elapsed nonnegative time, capped at
capacity. A backwards clock contributes zero elapsed time and resets the refill
baseline to the observed time. `consume(amount=1)` validates a finite positive
amount and returns a boolean. `available()` returns the current float balance.
`time_until(amount=1)` returns zero when available, otherwise the required
seconds. `refund(amount)` validates a finite positive amount and caps at
capacity.

## 8. Immutable event journal

`EventJournal(clock)` uses a callable clock. `append(kind, payload)` requires a
nonempty string kind and dictionary payload, deep-copies the payload, and
returns a deep copy of an event dictionary with sequential integer `id`
starting at 1, `timestamp`, `kind`, and `payload`.

`query(kinds=None, since_id=0, until_id=None)` returns deep copies in ID order.
`kinds` may be one string or an iterable; `since_id` is exclusive and
`until_id` inclusive. `replay(reducer, initial, **query_options)` applies the
callable reducer as `reducer(state, event_copy)` and returns the final state.
`to_jsonl()` emits canonical compact JSON, one event per line, ending in a
newline when nonempty. `from_jsonl(text, clock)` builds a journal without
calling the supplied clock, validates the complete schema and contiguous IDs,
and rejects malformed input with `ValueError`.
