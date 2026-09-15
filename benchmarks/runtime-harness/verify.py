#!/usr/bin/env python3
"""Independent verifier for the three benchmark batches."""

from __future__ import annotations

import argparse
import copy
import importlib.util
import json
import math
import sys
from datetime import datetime, timezone
from pathlib import Path


class Verification:
    def __init__(self) -> None:
        self.counts: dict[str, int] = {}
        self.failures: list[str] = []

    def check(self, task: str, condition: bool, message: str) -> None:
        self.counts[task] = self.counts.get(task, 0) + 1
        if not condition:
            self.failures.append(f"{task}: {message}")

    def equal(self, task: str, actual, expected, message: str) -> None:
        self.check(task, actual == expected, f"{message}: got {actual!r}, expected {expected!r}")

    def close(self, task: str, actual: float, expected: float, message: str) -> None:
        self.check(task, math.isclose(actual, expected, rel_tol=1e-9, abs_tol=1e-9), f"{message}: got {actual!r}, expected {expected!r}")

    def raises(self, task: str, exception, action, message: str) -> None:
        expected = exception if isinstance(exception, tuple) else (exception,)
        expected_name = " or ".join(item.__name__ for item in expected)
        try:
            action()
        except exception:
            self.check(task, True, message)
        except Exception as exc:  # noqa: BLE001
            self.check(task, False, f"{message}: raised {type(exc).__name__}, expected {expected_name}")
        else:
            self.check(task, False, f"{message}: did not raise {expected_name}")


def load_workload(root: Path):
    path = root / "workload.py"
    spec = importlib.util.spec_from_file_location(f"benchmark_{root.name}_{id(root)}", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Cannot import {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def run_group(v: Verification, task: str, action) -> None:
    try:
        action()
    except Exception as exc:  # noqa: BLE001
        v.check(task, False, f"group crashed with {type(exc).__name__}: {exc}")


def verify_batch1(m, v: Verification) -> None:
    def intervals() -> None:
        v.equal("01_intervals", m.normalize_intervals([(5, 7), (1, 2), (3, 4)]), [(1, 7)], "adjacent merge")
        v.equal("01_intervals", m.normalize_intervals([(5, 7), (1, 2), (3, 4)], False), [(1, 2), (3, 4), (5, 7)], "adjacency off")
        v.equal("01_intervals", m.normalize_intervals([(2, 8), (-3, -1), (4, 5), (2, 8)]), [(-3, -1), (2, 8)], "sort overlap and deduplicate")
        source = [[3, 4], [1, 1]]
        before = copy.deepcopy(source)
        v.equal("01_intervals", m.normalize_intervals(iter(source)), [(1, 1), (3, 4)], "iterable input")
        v.equal("01_intervals", source, before, "input preserved")
        v.equal("01_intervals", m.subtract_intervals([(1, 10)], [(3, 4), (7, 20)]), [(1, 2), (5, 6)], "closed subtraction")
        v.equal("01_intervals", m.subtract_intervals([(1, 2), (8, 12)], [(-5, 0), (10, 10)]), [(1, 2), (8, 9), (11, 12)], "multiple bases")
        v.equal("01_intervals", m.subtract_intervals([], [(1, 2)]), [], "empty base")
        v.raises("01_intervals", ValueError, lambda: m.normalize_intervals([(True, 2)]), "boolean rejected")
        v.raises("01_intervals", ValueError, lambda: m.normalize_intervals([(3, 2)]), "reversed rejected")
        v.raises("01_intervals", ValueError, lambda: m.normalize_intervals([(1, 2, 3)]), "malformed rejected")

    def merge() -> None:
        base = {"a": {"x": 1, "items": [1, {"k": "v"}]}, "drop": 9}
        overlay = {"a": {"y": 2, "items": [2]}, "drop": m.DELETE}
        before_base, before_overlay = copy.deepcopy(base), copy.deepcopy(overlay)
        result = m.deep_merge(base, overlay)
        v.equal("02_merge", result, {"a": {"x": 1, "y": 2, "items": [2]}}, "recursive replace and delete")
        v.equal("02_merge", base, before_base, "base preserved")
        v.check("02_merge", overlay["drop"] is m.DELETE and overlay["a"] == before_overlay["a"], "overlay preserved")
        appended = m.deep_merge({"x": [1, {"a": 2}]}, {"x": [{"a": 2}, 3]}, "append_unique")
        v.equal("02_merge", appended, {"x": [1, {"a": 2}, 3]}, "append unique equality")
        appended["x"][1]["a"] = 99
        v.equal("02_merge", base["a"]["items"][1]["k"], "v", "result deeply independent")
        v.equal("02_merge", m.deep_merge({}, {"missing": m.DELETE}), {}, "delete absent is no-op")
        v.raises("02_merge", (TypeError, ValueError), lambda: m.deep_merge([], {}), "base type rejected")
        v.raises("02_merge", (TypeError, ValueError), lambda: m.deep_merge({}, [], "replace"), "overlay type rejected")
        v.raises("02_merge", ValueError, lambda: m.deep_merge({}, {}, "extend"), "policy rejected")

    def pointers() -> None:
        doc = {"a/b": {"~key": [10, {"x": 20}]}, "empty": {"": 3}}
        v.equal("03_pointer", m.pointer_get(doc, "/a~1b/~0key/1/x"), 20, "escaped traversal")
        v.check("03_pointer", m.pointer_get(doc, "") is doc, "root selection")
        v.equal("03_pointer", m.pointer_get(doc, "/empty/"), 3, "empty token")
        marker = object()
        v.check("03_pointer", m.pointer_get(doc, "/missing", marker) is marker, "default returned")
        v.raises("03_pointer", m.PointerError, lambda: m.pointer_get(doc, "missing"), "leading slash required")
        v.raises("03_pointer", m.PointerError, lambda: m.pointer_get(doc, "/a~2b"), "bad escape rejected")
        v.raises("03_pointer", m.PointerError, lambda: m.pointer_get({"a": [1]}, "/a/01"), "noncanonical index rejected")
        changed = m.pointer_set(doc, "/a~1b/~0key/1/x", 30)
        v.equal("03_pointer", m.pointer_get(changed, "/a~1b/~0key/1/x"), 30, "set nested")
        v.equal("03_pointer", m.pointer_get(doc, "/a~1b/~0key/1/x"), 20, "set is immutable")
        v.equal("03_pointer", m.pointer_set(doc, "", {"root": True}), {"root": True}, "replace root")
        v.equal("03_pointer", m.pointer_set({"a": [1]}, "/a/-", 2), {"a": [1, 2]}, "append list")
        v.equal("03_pointer", m.pointer_set({}, "/a/b/c", 4, True), {"a": {"b": {"c": 4}}}, "create dictionary parents")
        v.raises("03_pointer", m.PointerError, lambda: m.pointer_set({"a": []}, "/a/0/x", 1, True), "does not invent list item")
        v.equal("03_pointer", m.pointer_remove({"a": [1, 2, 3]}, "/a/1"), {"a": [1, 3]}, "remove list item")
        v.equal("03_pointer", m.pointer_remove({"a": 1, "b": 2}, "/a"), {"b": 2}, "remove dict item")
        v.raises("03_pointer", m.PointerError, lambda: m.pointer_remove({}, ""), "root removal rejected")

    def joins() -> None:
        left = [{"id": 2, "v": "L2", "a": [1]}, {"id": 1, "v": "L1", "a": [2]}]
        right = [{"id": 1, "v": "R1", "b": 3}, {"id": 1, "v": "R2", "b": 4}, {"id": 3, "v": "R3", "b": 5}]
        left_before, right_before = copy.deepcopy(left), copy.deepcopy(right)
        inner = m.join_rows(left, right, "id")
        v.equal("04_join", [row["v_right"] for row in inner], ["R1", "R2"], "duplicate order")
        v.equal("04_join", inner[0], {"id": 1, "v_left": "L1", "a": [2], "v_right": "R1", "b": 3}, "collision suffixes")
        outer = m.join_rows(left, right, "id", "full")
        v.equal("04_join", [row["id"] for row in outer], [2, 1, 1, 3], "full stable order")
        v.equal("04_join", outer[0]["v_right"], None, "unmatched right fields")
        v.equal("04_join", outer[-1]["v_left"], None, "unmatched left fields")
        v.equal("04_join", left, left_before, "left preserved")
        v.equal("04_join", right, right_before, "right preserved")
        inner[0]["a"].append(9)
        v.equal("04_join", left[1]["a"], [2], "joined rows deeply copied")
        multi = m.join_rows([{"a": 1, "b": 2, "x": 3}], [{"a": 1, "b": 2, "y": 4}], ["a", "b"], "left")
        v.equal("04_join", multi, [{"a": 1, "b": 2, "x": 3, "y": 4}], "multi-key join")
        v.raises("04_join", ValueError, lambda: m.join_rows([{"id": 1}], [], [], "inner"), "empty keys rejected")
        v.raises("04_join", ValueError, lambda: m.join_rows([{}], [], "id"), "missing key rejected")
        v.raises("04_join", ValueError, lambda: m.join_rows([], [], "id", "outer"), "mode rejected")
        v.raises("04_join", ValueError, lambda: m.join_rows([{"id": 1, "v": 2, "v_left": 3}], [{"id": 1, "v": 4}], "id"), "generated collision rejected")

    run_group(v, "01_intervals", intervals)
    run_group(v, "02_merge", merge)
    run_group(v, "03_pointer", pointers)
    run_group(v, "04_join", joins)


def verify_batch2(m, v: Verification) -> None:
    def topo() -> None:
        graph = {"ship": ["test", "build"], "test": ["build"], "build": [], "docs": []}
        v.equal("05_dag", m.topological_layers(graph), [["build", "docs"], ["test"], ["ship"]], "layer ordering")
        v.equal("05_dag", m.topological_layers({"b": ["a"]}), [["a"], ["b"]], "dependency-only node")
        v.equal("05_dag", m.topological_layers({}), [], "empty graph")
        try:
            m.topological_layers({"b": ["c"], "c": ["a"], "a": ["b"]})
        except m.CycleError as exc:
            v.equal("05_dag", exc.cycle, ["a", "b", "c", "a"], "deterministic cycle")
        else:
            v.check("05_dag", False, "cycle did not raise CycleError")
        try:
            m.topological_layers({"z": ["z"]})
        except m.CycleError as exc:
            v.equal("05_dag", exc.cycle, ["z", "z"], "self cycle")
        else:
            v.check("05_dag", False, "self cycle did not raise")
        v.raises("05_dag", ValueError, lambda: m.topological_layers([]), "graph type rejected")
        v.raises("05_dag", ValueError, lambda: m.topological_layers({1: []}), "node type rejected")
        v.raises("05_dag", ValueError, lambda: m.topological_layers({"a": [1]}), "dependency type rejected")

    def cache() -> None:
        now = [0.0]
        clock = lambda: now[0]
        c = m.TTLCache(2, 10, clock)
        c.set("a", 1)
        c.set("b", 2)
        v.equal("06_cache", len(c), 2, "live length")
        v.equal("06_cache", c.get("a"), 1, "cache hit")
        c.set("c", 3)
        v.raises("06_cache", KeyError, lambda: c.get("b"), "LRU eviction")
        v.equal("06_cache", c.stats(), {"hits": 1, "misses": 1, "evictions": 1, "size": 2}, "stats after eviction")
        now[0] = 11
        v.equal("06_cache", c.get("a", "missing"), "missing", "expired default")
        v.equal("06_cache", len(c), 0, "length purges expiration")
        v.equal("06_cache", c.stats()["misses"], 2, "expiration counts as miss on get")
        now[0] = 20
        c.set("x", 1, ttl=0)
        v.equal("06_cache", c.purge(), 1, "zero TTL expires immediately")
        c.set("y", 2)
        v.check("06_cache", c.delete("y") and not c.delete("y"), "delete boolean")
        v.raises("06_cache", ValueError, lambda: m.TTLCache(0, 1, clock), "capacity validation")
        v.raises("06_cache", ValueError, lambda: m.TTLCache(True, 1, clock), "boolean capacity rejected")
        v.raises("06_cache", ValueError, lambda: m.TTLCache(1, math.inf, clock), "finite TTL required")
        v.raises("06_cache", ValueError, lambda: c.set("z", 1, -1), "negative item TTL rejected")

    def bucket() -> None:
        now = [0.0]
        b = m.TokenBucket(10, 2, lambda: now[0])
        v.close("07_bucket", b.available(), 10, "starts full")
        v.check("07_bucket", b.consume(7), "consume succeeds")
        v.close("07_bucket", b.available(), 3, "balance reduced")
        v.check("07_bucket", not b.consume(4), "insufficient consume fails")
        now[0] = 1.5
        v.close("07_bucket", b.available(), 6, "lazy refill")
        v.close("07_bucket", b.time_until(8), 1, "time until amount")
        b.refund(9)
        v.close("07_bucket", b.available(), 10, "refund caps")
        now[0] = 0.5
        v.close("07_bucket", b.available(), 10, "backwards clock no negative refill")
        b.consume(10)
        now[0] = 1.5
        v.close("07_bucket", b.available(), 2, "baseline reset after backwards clock")
        v.raises("07_bucket", ValueError, lambda: m.TokenBucket(0, 1, lambda: 0), "capacity validation")
        v.raises("07_bucket", ValueError, lambda: m.TokenBucket(1, math.inf, lambda: 0), "refill finite")
        v.raises("07_bucket", ValueError, lambda: b.consume(True), "boolean amount rejected")
        v.raises("07_bucket", ValueError, lambda: b.refund(-1), "refund validation")

    def journal() -> None:
        times = iter([10.0, 11.0, 12.0])
        j = m.EventJournal(lambda: next(times))
        payload = {"items": [1]}
        first = j.append("created", payload)
        payload["items"].append(2)
        first["payload"]["items"].append(3)
        second = j.append("updated", {"value": 2})
        third = j.append("created", {"value": 3})
        v.equal("08_journal", j.query()[0]["payload"], {"items": [1]}, "append and return are copied")
        v.equal("08_journal", [e["id"] for e in j.query("created")], [1, 3], "kind query")
        v.equal("08_journal", [e["id"] for e in j.query(since_id=1, until_id=2)], [2], "ID bounds")
        replayed = j.replay(lambda state, event: state + [event["kind"]], [], kinds=["updated", "created"])
        v.equal("08_journal", replayed, ["created", "updated", "created"], "replay order")
        text = j.to_jsonl()
        v.check("08_journal", text.endswith("\n") and len(text.splitlines()) == 3, "JSONL shape")
        no_clock = lambda: (_ for _ in ()).throw(AssertionError("clock called"))
        restored = m.EventJournal.from_jsonl(text, no_clock)
        v.equal("08_journal", restored.query(), j.query(), "round trip without clock")
        copy_out = restored.query()
        copy_out[0]["payload"]["items"].append(9)
        v.equal("08_journal", restored.query()[0]["payload"], {"items": [1]}, "query returns copies")
        v.equal("08_journal", m.EventJournal(lambda: 0).to_jsonl(), "", "empty JSONL")
        v.raises("08_journal", ValueError, lambda: j.append("", {}), "empty kind rejected")
        v.raises("08_journal", ValueError, lambda: j.append("x", []), "payload type rejected")
        bad_gap = '{"id":2,"timestamp":1,"kind":"x","payload":{}}\n'
        v.raises("08_journal", ValueError, lambda: m.EventJournal.from_jsonl(bad_gap, lambda: 0), "contiguous IDs required")
        v.raises("08_journal", ValueError, lambda: m.EventJournal.from_jsonl("not json\n", lambda: 0), "malformed JSON rejected")
        v.check("08_journal", first["id"] == 1 and second["id"] == 2 and third["id"] == 3, "sequential IDs")

    run_group(v, "05_dag", topo)
    run_group(v, "06_cache", cache)
    run_group(v, "07_bucket", bucket)
    run_group(v, "08_journal", journal)


def verify_batch3(m, v: Verification) -> None:
    def semver() -> None:
        s = m.SemVer.parse("1.2.3-alpha.1+build.5")
        v.equal("09_semver", str(s), "1.2.3-alpha.1+build.5", "string round trip")
        v.check(
            "09_semver",
            (s.major, s.minor, s.patch, s.build) == (1, 2, 3, "build.5")
            and s.prerelease in (("alpha", "1"), ("alpha", 1)),
            "parsed fields",
        )
        v.check("09_semver", m.SemVer.parse("1.0.0+one") == m.SemVer.parse("1.0.0+two"), "build ignored for equality")
        order = ["1.0.0-alpha", "1.0.0-alpha.1", "1.0.0-alpha.beta", "1.0.0-beta", "1.0.0-beta.2", "1.0.0-beta.11", "1.0.0-rc.1", "1.0.0"]
        v.equal("09_semver", [str(x).split("+")[0] for x in sorted(map(m.SemVer.parse, reversed(order)))], order, "SemVer precedence")
        v.raises("09_semver", ValueError, lambda: m.SemVer.parse("01.2.3"), "core leading zero rejected")
        v.raises("09_semver", ValueError, lambda: m.SemVer.parse("1.2.3-01"), "prerelease leading zero rejected")
        cases = [
            ("1.2.3", "1.2.3", True),
            ("1.5.0", ">=1.2.0 <2.0.0", True),
            ("2.0.0", ">=1.2.0 <2.0.0", False),
            ("1.2.9", "1.2.x", True),
            ("1.9.0", "1", True),
            ("1.9.9", "^1.2.3", True),
            ("2.0.0", "^1.2.3", False),
            ("0.2.9", "^0.2.3", True),
            ("0.3.0", "^0.2.3", False),
            ("1.2.9", "~1.2.3", True),
            ("1.3.0", "~1.2.3", False),
            ("3.0.0", "^1.0.0 || >=3.0.0", True),
            ("1.2.3-alpha.2", ">=1.2.3 <2.0.0", False),
            ("1.2.3-alpha.2", ">=1.2.3-alpha.1 <2.0.0", True),
        ]
        for version, expression, expected in cases:
            v.equal("09_semver", m.satisfies(version, expression), expected, f"range {version} {expression}")
        v.raises("09_semver", ValueError, lambda: m.satisfies("1.0.0", ""), "empty range rejected")

    def urls() -> None:
        v.equal("10_url", m.canonicalize_url("HTTP://ExAmPle.COM:80"), "http://example.com/", "case and default port")
        v.equal("10_url", m.canonicalize_url("https://example.com:443/a"), "https://example.com/a", "HTTPS default port")
        v.equal("10_url", m.canonicalize_url("https://example.com:8443/a"), "https://example.com:8443/a", "nondefault port")
        v.equal("10_url", m.canonicalize_url("https://example.com/a/./b/../c/"), "https://example.com/a/c/", "dot path and trailing slash")
        v.equal("10_url", m.canonicalize_url("https://example.com/%7e/%2f/%E2%82%AC"), "https://example.com/~/%2F/%E2%82%AC", "percent normalization")
        v.equal("10_url", m.canonicalize_url("https://example.com/€"), "https://example.com/%E2%82%AC", "Unicode path")
        url = "https://example.com/p?b=2&a=hello+world&a=&b=1#frag"
        v.equal("10_url", m.canonicalize_url(url), "https://example.com/p?a=hello%20world&a=&b=2&b=1", "query sorting and stable values")
        v.equal("10_url", m.canonicalize_url(url, sort_values=True), "https://example.com/p?a=&a=hello%20world&b=1&b=2", "query value sorting")
        v.equal("10_url", m.canonicalize_url("https://example.com/?utm=1&a=2", {"utm"}), "https://example.com/?a=2", "drop parameters")
        v.equal("10_url", m.canonicalize_url("https://münich.example/"), "https://xn--mnich-kva.example/", "IDNA host")
        v.raises("10_url", ValueError, lambda: m.canonicalize_url("/relative"), "relative rejected")
        v.raises("10_url", ValueError, lambda: m.canonicalize_url("ftp://example.com/x"), "scheme rejected")
        v.raises("10_url", ValueError, lambda: m.canonicalize_url("https://user:pass@example.com/"), "credentials rejected")

    def retry() -> None:
        now = datetime(2026, 1, 1, 0, 0, tzinfo=timezone.utc)
        v.close("11_retry", m.parse_retry_after(5, now), 5, "integer seconds")
        v.close("11_retry", m.parse_retry_after("12", now), 12, "string seconds")
        v.close("11_retry", m.parse_retry_after("Thu, 01 Jan 2026 00:00:20 GMT", now), 20, "HTTP date")
        v.close("11_retry", m.parse_retry_after("Wed, 31 Dec 2025 23:59:00 GMT", now), 0, "past date clamps")
        v.raises("11_retry", ValueError, lambda: m.parse_retry_after(True, now), "boolean rejected")
        v.raises("11_retry", ValueError, lambda: m.parse_retry_after("bad", now), "malformed rejected")
        v.raises("11_retry", ValueError, lambda: m.parse_retry_after(1, datetime(2026, 1, 1)), "naive datetime rejected")
        v.equal("11_retry", m.retry_delays(5, base=1, factor=2, cap=5), [1.0, 2.0, 4.0, 5.0], "exponential capped delays")
        v.equal("11_retry", m.retry_delays(4, retry_after=[None, 5, 1]), [1.0, 5.0, 4.0], "retry-after floors")
        first = m.retry_delays(4, jitter=0.5, seed=7)
        second = m.retry_delays(4, jitter=0.5, seed=7)
        v.equal("11_retry", first, second, "seeded jitter deterministic")
        v.check("11_retry", 0.5 <= first[0] <= 1.5 and 1 <= first[1] <= 3 and 2 <= first[2] <= 6, "jitter bounds")
        v.raises("11_retry", ValueError, lambda: m.retry_delays(0), "attempt validation")
        v.raises("11_retry", ValueError, lambda: m.retry_delays(2, jitter=2), "jitter validation")
        v.raises("11_retry", ValueError, lambda: m.retry_delays(3, retry_after=[1]), "floor length validation")

    def config() -> None:
        schema = {
            "host": {"type": "str", "default": "localhost"},
            "port": {"type": "int", "min": 1, "max": 65535},
            "debug": {"type": "bool", "default": False},
            "ratio": {"type": "float", "min": 0, "max": 1},
            "tags": {"type": "list", "default": ["base"]},
            "mode": {"type": "str", "choices": ["dev", "prod"], "required": True},
            "db.pool": {"type": "int", "default": 5},
        }
        values, origins = m.resolve_config(
            schema,
            defaults={"port": 80, "mode": "dev"},
            file_values={"port": "8080", "ratio": "0.5", "tags": "a, b"},
            env={"APP_PORT": "9000", "APP_DEBUG": "yes", "APP_DB_POOL": "7", "OTHER": "x"},
            cli={"port": 10000, "mode": "prod", "host": None},
        )
        v.equal("12_config", values, {"host": "localhost", "port": 10000, "debug": True, "ratio": 0.5, "tags": ["a", "b"], "mode": "prod", "db.pool": 7}, "values and precedence")
        v.equal("12_config", origins, {"host": "schema", "port": "cli", "debug": "env", "ratio": "file", "tags": "file", "mode": "cli", "db.pool": "env"}, "origin tracking")
        values["tags"].append("changed")
        v.equal("12_config", schema["tags"]["default"], ["base"], "mutable defaults copied")
        bool_schema = {"x": {"type": "bool", "required": True}}
        for raw, expected in [("true", True), ("NO", False), ("on", True), ("0", False)]:
            v.equal("12_config", m.resolve_config(bool_schema, file_values={"x": raw})[0]["x"], expected, f"boolean conversion {raw}")
        v.raises("12_config", ValueError, lambda: m.resolve_config({"x": {"type": "int"}}, file_values={"x": True}), "boolean is not integer")
        v.raises("12_config", ValueError, lambda: m.resolve_config({"x": {"type": "float"}}, file_values={"x": True}), "boolean is not float")
        v.raises("12_config", ValueError, lambda: m.resolve_config({"x": {"type": "int", "min": 2}}, file_values={"x": 1}), "minimum enforced")
        v.raises("12_config", ValueError, lambda: m.resolve_config({"x": {"type": "str", "choices": ["a"]}}, file_values={"x": "b"}), "choices enforced")
        v.raises("12_config", ValueError, lambda: m.resolve_config({"x": {"type": "str", "unknown": 1}}), "schema option rejected")
        v.raises("12_config", ValueError, lambda: m.resolve_config({"x": {"type": "str"}}, defaults={"y": 1}), "unknown source key rejected")
        v.raises("12_config", ValueError, lambda: m.resolve_config({"x": {"type": "str", "required": True}}), "required value enforced")
        v.raises("12_config", ValueError, lambda: m.resolve_config({"x": {"type": "bool"}}, file_values={"x": "maybe"}), "invalid boolean rejected")

    run_group(v, "09_semver", semver)
    run_group(v, "10_url", urls)
    run_group(v, "11_retry", retry)
    run_group(v, "12_config", config)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch", type=int, choices=(1, 2, 3), required=True)
    parser.add_argument("--root", type=Path, required=True)
    args = parser.parse_args()

    v = Verification()
    try:
        module = load_workload(args.root.resolve())
    except Exception as exc:  # noqa: BLE001
        result = {"batch": args.batch, "passed": False, "checks": 0, "counts": {}, "failures": [f"import: {type(exc).__name__}: {exc}"]}
        print(json.dumps(result, ensure_ascii=False, sort_keys=True))
        return 1

    {1: verify_batch1, 2: verify_batch2, 3: verify_batch3}[args.batch](module, v)
    result = {
        "batch": args.batch,
        "passed": not v.failures,
        "checks": sum(v.counts.values()),
        "counts": v.counts,
        "failures": v.failures,
    }
    print(json.dumps(result, ensure_ascii=False, sort_keys=True))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
