# Luna Max Coder benchmark

Measurement date: **2026-09-15**

This is a small, paired execution measurement for three implementation tasks. Each task was completed once by a `gpt-5.6-sol` baseline and once by a routed `gpt-5.6-sol` supervisor using the `luna_max_code_writer` / `gpt-5.6-luna` / `max` execution lane. Luna correction turns are included in the task that they corrected.

The raw machine-readable record is [results.json](results.json). The local audit record also contains the same measurements and turn accounting.

## Specifications

1. **Range compactor** — validate an integer list (booleans are invalid), sort and deduplicate it, and render runs of at least three consecutive integers as `start-end`; expose the same behavior through a JSON CLI.
2. **JSONL event summary** — accept records with a non-empty string `status` and a non-negative integer `duration_ms`, count accepted and rejected records, count statuses, and report total and maximum duration with deterministic status-key ordering.
3. **Deep configuration merge** — recursively merge dictionaries, replace lists/scalars/null values from the override, deep-copy inputs and results, and expose the same behavior through a JSON CLI requiring exactly `base` and `override` objects.

## Measurement protocol

Usage came from completed `event_msg` records whose `payload.type` is `token_count`. For each completed task turn, the final `payload.info.last_token_usage` record was selected. Luna had five completed usage turns: task 1 plus one correction, task 2 plus one correction, and task 3. The baseline and routed supervisors each had three task turns. Cumulative `total_token_usage` snapshots were not summed. Coordinator, setup, and publication turns were excluded.

The canonical total is `total_tokens`. In the observed events, `total_tokens = input_tokens + output_tokens`; `cached_input_tokens` is part of `input_tokens`, not an additional amount. `cache_write_input_tokens` is reported separately. `reasoning_output_tokens` is part of `output_tokens`.

Both lanes were run through their own test suites and through the same independent standard-library verifier with 65 checks per lane. The verifier exercises direct APIs, invalid inputs, deep-copy behavior, and CLI behavior without changing the task directories.

## Raw results

All values below are token counts from the selected final per-turn usage records. The routed Luna row for tasks 1 and 2 includes its correction turn.

| Task | Lane | Completed turns | Input | Cached input | Cache write | Output | Reasoning output | Total |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | Baseline Sol | 1 | 36,341 | 35,712 | 0 | 500 | 432 | 36,841 |
| 1 | Routed Sol | 1 | 38,452 | 36,992 | 0 | 632 | 504 | 39,084 |
| 1 | Routed Luna | 2 | 82,101 | 80,384 | 0 | 2,532 | 1,148 | 84,633 |
| 2 | Baseline Sol | 1 | 42,323 | 41,728 | 0 | 197 | 131 | 42,520 |
| 2 | Routed Sol | 1 | 45,900 | 44,928 | 0 | 432 | 296 | 46,332 |
| 2 | Routed Luna | 2 | 113,772 | 112,128 | 0 | 2,764 | 185 | 116,536 |
| 3 | Baseline Sol | 1 | 47,954 | 47,232 | 0 | 189 | 123 | 48,143 |
| 3 | Routed Sol | 1 | 50,533 | 48,128 | 0 | 1,033 | 886 | 51,566 |
| 3 | Routed Luna | 1 | 70,830 | 70,400 | 0 | 2,596 | 511 | 73,426 |

### Raw aggregate

| Lane | Input | Cached input | Cache write | Output | Reasoning output | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Baseline Sol | 126,618 | 124,672 | 0 | 886 | 686 | 127,504 |
| Routed Sol | 134,885 | 130,048 | 0 | 2,097 | 1,686 | 136,982 |
| Routed Luna | 266,703 | 262,912 | 0 | 7,892 | 1,844 | 274,595 |

## Derived results

Advanced-model token change (a positive value would be savings; a negative value means no savings) is **Baseline Sol total − Routed Sol total**. A negative value means the routed supervisor used more tokens. Combined routed change means **Routed Sol total + Routed Luna total − Baseline Sol total**; a positive value is an increase, not a saving.

| Task | Advanced Sol savings (negative = no savings) | Savings % (negative = no savings) | Routed combined total | Combined delta | Delta % |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 | -2,243 | -6.1% | 123,717 | +86,876 | +235.8% |
| 2 | -3,812 | -9.0% | 162,868 | +120,348 | +283.0% |
| 3 | -3,423 | -7.1% | 124,992 | +76,849 | +159.6% |
| **Aggregate** | **-9,478** | **-7.4%** | **411,577** | **+284,073** | **+222.8%** |

## Interpretation and limitations

Across these three observations, this small-task sample found no token savings: Routed Sol increased from 127,504 to 136,982 (+9,478, +7.4%). Including Luna execution, combined Sol+Luna was 411,577 (+284,073, +222.8%). These are three paired implementation tasks with one observation per task, not a statistically significant model benchmark or a general cost claim. The tasks had heavy cached context and include delegation/report overhead; results are dependent on environment, date, prompt/context, cache state, correction behavior, and implementation details.
