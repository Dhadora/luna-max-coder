"""Batch 2 implementation target."""

MISSING = object()


class CycleError(ValueError):
    def __init__(self, cycle):
        self.cycle = list(cycle)
        super().__init__(" -> ".join(self.cycle))


def topological_layers(graph):
    raise NotImplementedError


class TTLCache:
    def __init__(self, capacity, default_ttl, clock):
        raise NotImplementedError


class TokenBucket:
    def __init__(self, capacity, refill_rate, clock):
        raise NotImplementedError


class EventJournal:
    def __init__(self, clock):
        raise NotImplementedError
