# Luna Max Coder benchmarks

## Current bounded-loop protocol

Measurement date: **2026-09-15**

Three fresh gpt-5.6-sol / max direct runs were compared with three fresh
gpt-5.6-sol / max supervisors. Each supervisor delegated one four-task batch
to exactly one fresh gpt-5.6-luna / max worker. The routed worker budget was one
batched inspection, one consolidated edit, one consolidated verification, and
at most one targeted repair and recheck.

Across 12 Python standard-library tasks per lane:

- Advanced Sol cumulative tokens fell from 2,487,921 to 694,280, a **72.1% reduction**.
- Combined Sol and Luna cumulative tokens fell to 1,765,109, a **29.1% reduction**.
- Combined uncached input fell from 295,090 to 213,227, a **27.7% reduction**.
- Both lanes passed the same 159 independent checks.
- Routed outer task time was 35m14.0s versus 34m57.6s direct, **0.8% slower**.

Two routed Sol preflight turns could not initially spawn their Luna worker.
Both succeeded on one retry, and both failed turns are included in every
aggregate. Coordinator, benchmark construction, verification, and reporting
tokens are excluded.

The full machine-readable record is
[runtime-results.json](runtime-results.json).

## Cumulative results

Cumulative usage is the final turn_token_usage value for every completed
benchmark turn, counted once. It includes every model and tool loop. Cached
input is included in input and total tokens.

| Batch | Direct Sol | Routed Sol | Luna worker | Routed combined | Sol reduction | Combined reduction | Quality per lane |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 478,309 | 298,617 | 342,765 | 641,382 | 37.6% | -34.1% | 49/49 |
| 2 | 1,168,636 | 137,086 | 277,051 | 414,137 | 88.3% | 64.6% | 47/47 |
| 3 | 840,976 | 258,577 | 451,013 | 709,590 | 69.3% | 15.6% | 63/63 |
| **Total** | **2,487,921** | **694,280** | **1,070,829** | **1,765,109** | **72.1%** | **29.1%** | **159/159** |

A negative combined reduction in batch 1 means routing used 34.1% more raw
tokens for that batch. The larger batches outweighed it in this sample.

## Aggregate accounting

Reasoning output is a subset of output and is not added again.

| Lane | Input | Cached input | Uncached input | Output | Reasoning output | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Direct Sol | 2,397,746 | 2,102,656 | 295,090 | 90,175 | 57,442 | 2,487,921 |
| Routed Sol | 683,272 | 588,032 | 95,240 | 11,008 | 7,546 | 694,280 |
| Luna worker | 977,123 | 859,136 | 117,987 | 93,706 | 56,286 | 1,070,829 |
| Routed combined | 1,660,395 | 1,447,168 | 213,227 | 104,714 | 63,832 | 1,765,109 |

## Why the loop budget matters

The earlier single-batch protocol passed the same quality gate but consumed
5,433,430 routed tokens. Luna made 70 model calls, including 41 in batch 3.
With the explicit loop budget, routed usage fell **67.5%** to 1,765,109 and
Luna made 20 model calls, a **71.4% reduction**. Luna cumulative tokens alone
fell **77.9%**.

The previous record remains available as
[runtime-results-v1.json](runtime-results-v1.json).

## Interactive browser guardrail replay

An anonymized interactive stress run exposed a cross-turn failure mode that the
original single-batch wording did not prevent. The worker continued across six
turns and recorded 66 tool-related calls, including 12 failed calls. Its final
reported cumulative total was 7,410,225 tokens: 7,359,067 input tokens,
7,091,200 cached input tokens, and 51,158 output tokens. Reasoning output is
already included in output.

Version 0.2.0 adds one worker-lifetime ledger that does not reset on a resume,
correction, interruption, compaction, or later turn. The deterministic replay
in the repository verifies that the same aggregate is stopped no later than the
twelfth tool call or second failed call, that a bare resume cannot reset the
ledger, and that stop permits no additional tool call. This is a policy replay,
not a second live-model benchmark.

The sanitized machine-readable aggregate and policy limits are in
[browser-guardrail.json](browser-guardrail.json). Reported cumulative tokens
include cached input and are not equivalent to billing or subscription usage.

## Final-request footprint

For comparison with the earlier pilot, the final per-request usage record
before each completed turn was also summed. This is a context-footprint
snapshot, not cumulative consumption.

| Lane | Completed turns | Input | Cached input | Output | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| Direct Sol | 5 | 317,797 | 245,760 | 9,062 | 326,859 |
| Routed Sol | 5 | 182,347 | 169,472 | 3,936 | 186,283 |
| Luna worker | 3 | 182,482 | 174,336 | 7,420 | 189,902 |
| Routed combined | 8 | 364,829 | 343,808 | 11,356 | 376,185 |

Advanced Sol fell **43.0%** on this narrower metric, while routed combined
rose **15.1%**. The two failed preflight turns make this terminal snapshot
especially conservative.

## Quality notes

The direct lane needed one TTL correction and one configuration-type
correction. The routed lane needed no correction from the independent verifier.
Batch 1 used one targeted worker repair and exceeded the intended verification
attempt ceiling because its own harness failed twice. In batch 3, the worker
reported a false-negative self-check, but the unchanged implementation passed
all 63 independent checks.

## Static context measurement

The benchmarked pre-budget revision reduced its four fixed routing files from
15,451 to 9,640 UTF-8 bytes, **37.61%**. Adding the explicit loop budget brings
the current installed context to 10,175 bytes, still **34.15%** below the
original. The public export is seven bytes smaller because its manifest uses a
shorter version string. See
[context-overhead.json](context-overhead.json). File bytes are not model
tokens.

## Reproducing the quality gate

The exact specifications, starter files, and independent verifier are in
[runtime-harness](runtime-harness). Copy one batch template into a fresh lane
named `batch1-lane`, let the selected implementation path edit only workload.py,
and run:

~~~powershell
python .\runtime-harness\verify.py --batch 1 --root .\batch1-lane
~~~

Use batch 2 or 3 with the matching template. The harness reproduces behavior
checks, not Codex token counters; those come from local completed-turn usage
records.

## Limitations

This is a preliminary engineering benchmark with three paired batches and 12
task units per lane, not a statistically powered model study. The bounded
routed runs happened after the baseline runs, so cache and time effects are not
fully counterbalanced. Results depend on environment, prompts, cache state,
model behavior, and tool-loop count. Subscription usage cannot be inferred
directly from these token fields.

The original three-task pilot remains in [results.json](results.json).
