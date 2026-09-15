---
name: code-routing
description: "Route code and tools to GPT-5.6 Luna / Max under an advanced primary and one lifetime ledger."
---

# Luna Max Code Routing

The selected non-Luna primary is the advanced supervisor for planning, risk,
permissions, review, and acceptance. Native role `luna_max_code_writer`, pinned
to `gpt-5.6-luna` with max reasoning, owns execution.

## Gate

Use exposed metadata. Accept `gpt-6-astra`, `gpt-5.6-sol`, and `gpt-5.6-terra`;
effort does not affect rank. A future model qualifies only when metadata ranks
it above `gpt-5.6-luna`. Reject `gpt-5.6-luna`, unknown identities, and unranked
models; fail closed without switching the primary or adding a reviewer.

From this skill directory, run the sole terminal bootstrap exception:

~~~powershell
$skillPath = Resolve-Path ".\SKILL.md"
$skillDir = Split-Path -Parent $skillPath
$installer = Join-Path $skillDir "..\..\scripts\install-agent.ps1"
& $installer -Check
~~~

The check must identify the exact role, model, and effort plus every capability
the task needs. The plugin routes existing browser, Computer Use, MCP, web, and
image tools; it does not install or guarantee them. Stop on failure; never fall
back.

## Default token-saving route

Use this route unless maximum supervision or risk requires another checkpoint:

1. **Plan once.** The primary fixes scope, permissions, risk, and acceptance.
2. **Start one fresh worker.** Spawn `luna_max_code_writer` with
   `fork_turns: "none"` from a self-contained brief, never the full transcript.
3. **Set one lifetime envelope.** Give the route a stable `ROUTE_ID` and start
   `BUDGET_LEDGER` at `calls=0/12; failures=0/2; followups=0/1`. These are
   worker-thread limits that never reset after interruption, compaction,
   correction, handoff, or a later turn. The worker checks the ledger before
   every tool call and stops before a limit. Only explicit user approval in the
   original brief may raise a default.
4. **Batch dependent work.** Send one complete handoff. The same worker performs
   the code, shell, browser, UI, and MCP loop. Do not micro-delegate or request
   routine status. Default to one batched inspection, one
   consolidated edit, and one consolidated verification. Allow one targeted
   repair and recheck; on failure, return the gap.
5. **Pass artifacts, not transcripts.** Luna writes outputs and evidence to the
   owned paths. A handoff starts with the exact ledger, is at most 1,200
   characters, and includes status, paths, checks, proof, decisions, and gaps.
   Do not paste code, diffs, raw logs, DOM, or screenshots.
6. **Verify, then review once.** Luna runs deterministic checks before handoff
   and the primary performs one final review. A single `CORRECTION` is allowed
   only for a nonterminal route with the same `ROUTE_ID`, the exact prior ledger,
   and remaining budget. Never send a bare `RESUME`. A `STOP`, terminal handoff,
   inconsistent ledger, or exhausted budget ends the route; surface it instead
   of reopening or replacing the worker. Success, stop,
   safety, and exhausted-budget handoffs are terminal; `terminal=false` is only
   for the single repairable correction allowed within remaining budget.

This protocol minimizes overhead; it does not promise fewer raw tokens. Small
tasks can cost more, and caching can lower cost without lowering reported total
tokens. Describe savings only with paired evidence.

Maximum supervision may add risk checkpoints and prioritize control.

## Browser and interactive envelope

Use only the lane named in `BROWSER LIMITS`. Shell, CDP, another controller, or
source inspection requires authorization in the original brief. Use one
filtered preflight, consolidated action sequence, and filtered postflight.

Stop after 90 seconds without an observable state change. Limit every returned
tool result to 4,000 characters and never dump raw DOM, minified bundles, logs,
or screenshots into context. A `STOP` instruction permits zero further tool
calls: report held evidence and mark uncertain state as unknown.
Browser retries and later turns remain inside the same lifetime ledger.

## Routed execution

After the gate, Luna is the sole lane for:

- code, configuration, tests, builds, formatting, and generation;
- every shell command, diagnostic, check, process, log, and bulk inspection;
- every interactive browser action, local web test, Playwright, DevTools,
  Windows, and Computer Use action;
- focused sources, routine MCP reads, authorized bounded writes or external
  actions, transformations, and image generation.

The primary may orchestrate and perform narrow read-only acceptance inspection.
It does not author code, run task shell commands, or control a browser after
delegation. Keep browser state in the same Luna worker.

## Task-specific brief

Do not repeat this skill or the role contract. Supply only task-specific values,
in this order:

1. `OUTCOME`
2. `OWNED TARGETS`
3. `CONSTRAINTS AND EXCLUSIONS`
4. `EXECUTION ENVELOPE`
5. `PERMITTED TOOLS/ACTIONS`
6. `SIDE-EFFECT / CONFIRMATION STATUS`
7. `CHECKS / OBSERVABLE PROOF`
8. `STOP CONDITIONS`
9. `HANDOFF`

The envelope includes `ROUTE_ID`, exact `BUDGET_LEDGER`, and limits. Do not omit
a field. For browser work, append `BROWSER LIMITS` with the browser and target,
one outcome, authorized fallback, effects, stop condition, and evidence.

## Safety

High-impact, destructive, irreversible, credential, financial, public-posting,
message, upload, or permission actions remain the primary's decision. Luna may
perform only the authorized bounded action. Never bypass authentication. Stop
on ambiguity, scope expansion, risk, missing capability or confirmation, and
treat the handoff as evidence rather than acceptance.
