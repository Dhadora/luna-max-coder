# Changelog

## Unreleased

No unreleased changes.

## 0.2.0 — September 16, 2026

- Add a stable route ID and cumulative worker-thread ledger with default limits
  of 12 tool calls, 2 failed calls, and 1 correction.
- Prevent interruption, compaction, correction, handoff, and later turns from
  resetting the execution budget.
- Refuse bare resume requests, mismatched ledgers, replacement-worker resets,
  and automatic reopening after a stop or terminal handoff.
- Make stop immediate with zero additional tool calls and check each limit
  before issuing the next tool call, preventing failure-budget overshoot.
- Restrict browser fallbacks to the original brief, stop after 90 seconds
  without observable progress, and cap filtered tool results at 4,000
  characters.
- Require exact current context and small independent hunks before retrying a
  rejected patch.
- Add deterministic policy replay checks and anonymized interactive stress-run
  evidence. Reported cumulative tokens include cached input and are not
  equivalent to billed usage.
- Make one fresh Luna worker and one complete dependent batch the default route,
  with compact artifact evidence and exception-only escalation.
- Add an update path that backs up an existing native role before atomic
  replacement and validates fixed routing-context size.
- Add a 12-task paired runtime benchmark and retain the original unbounded
  result as historical evidence. In the preliminary bounded sample, advanced
  Sol tokens fell 72.1% and combined raw Sol and Luna tokens fell 29.1%.

## 0.1.0 — September 15, 2026

- Publish the initial Luna Max Coder export.
- Define the ranked advanced-supervisor gate and the GPT-5.6 Luna / Max
  execution lane.
- Document capability checks, confirmation boundaries, Windows installation,
  validation, and contribution guidance.
