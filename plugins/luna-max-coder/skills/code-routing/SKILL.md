---
name: code-routing
description: "Route implementation and tool execution to GPT-5.6 Luna / Max while an accepted non-Luna primary plans, controls risk, and reviews. Uses a low-overhead single-batch protocol by default."
---

# Luna Max Code Routing

Keep the user-selected non-Luna primary unchanged as the advanced supervisor. It owns requirements,
architecture, planning, research synthesis, risk and permission decisions,
required confirmations, review, and final acceptance. The exact native role
`luna_max_code_writer`, pinned to `gpt-5.6-luna` with max reasoning, owns routed
execution.

## Gate

Establish the primary from exposed Codex product or runtime metadata before
delegating. Accept `gpt-6-astra`, `gpt-5.6-sol`, and `gpt-5.6-terra`; reasoning
effort does not affect the ranking. A future model qualifies only when exposed
metadata explicitly ranks it above `gpt-5.6-luna`. Reject `gpt-5.6-luna`,
unknown identities, and unranked models. If identity or ranking is not exposed,
fail closed. Never silently switch the primary or add a fixed reviewer.

From this skill directory, run the sole terminal bootstrap exception:

~~~powershell
$skillPath = Resolve-Path ".\SKILL.md"
$skillDir = Split-Path -Parent $skillPath
$installer = Join-Path $skillDir "..\..\scripts\install-agent.ps1"
& $installer -Check
~~~

The check must identify the exact role, model, and effort above. Also confirm
that the worker exposes every capability the task needs. This plugin routes
existing browser, Computer Use, MCP, web, image-generation, and other tools; it
does not install or guarantee them. Stop on any missing capability or failed
gate. Never fall back to the primary or another execution model.

## Default token-saving route

Use this route unless the user requests maximum supervision or task risk
requires another checkpoint:

1. **Plan once.** The primary fixes scope, architecture, permissions, risk, and
   observable acceptance criteria before delegation.
2. **Start one fresh worker.** When the brief is self-contained, spawn
   `luna_max_code_writer` with `fork_turns: "none"`. Put only necessary
   conversation facts in the brief; never forward the full transcript.
3. **Batch dependent work.** Send one complete handoff. The same worker performs
   the dependent code, shell, browser, UI, and MCP loop. Do not micro-delegate,
   request routine status reports, or add workers unless work is genuinely
   independent and non-overlapping. Default to one batched inspection, one
   consolidated edit, and one consolidated verification. Allow one targeted
   repair and recheck; if it still fails, return the gap instead of continuing
   an open-ended tool loop.
4. **Pass artifacts, not transcripts.** Luna writes outputs and evidence to the
   owned paths. A normal successful handoff is at most 1,200 characters and
   contains status, changed paths, checks, hashes or other proof, decisions, and
   gaps. Do not paste code, diffs, raw logs, DOM, or screenshots unless the
   primary requests targeted evidence or a failure cannot be explained without
   it.
5. **Verify, then review once.** Luna runs deterministic checks before handoff.
   The primary performs one final review. Add an intermediate checkpoint only
   before a high-impact or irreversible action. Send corrections to the same
   worker as a minimal delta without repeating the task.

This protocol minimizes fixed handoff and context overhead; it does not promise
fewer raw tokens on every task. Small tasks can cost more when delegated.
Prompt caching can reduce cached-input cost without reducing reported total
tokens. Describe measured savings only with paired evidence.

If maximum supervision is requested or required by risk, add explicit review
checkpoints and report that this mode prioritizes control over token savings.

## Routed execution

After the gate, Luna is the sole lane for:

- code, configuration, tests, builds, generation, formatting, and autofixes;
- every shell command, diagnostic, test, lint, typecheck, process, log, and
  scripted or bulk repository inspection;
- every interactive browser action, local web test, Playwright or DevTools
  operation, and mechanical Windows or Computer Use action;
- focused source collection, routine MCP reads, approved bounded MCP writes or
  external actions, bulk transformations, and requested image generation.

The primary may orchestrate and perform narrow read-only acceptance inspection.
It does not author implementation syntax, run task shell commands, or control a
browser after delegation. Keep browser state in the same Luna worker.

## Task-specific brief

Do not repeat this skill or the role contract. Supply only task-specific values,
in this order:

1. `OUTCOME`
2. `OWNED TARGETS`
3. `CONSTRAINTS AND EXCLUSIONS`
4. `PERMITTED TOOLS/ACTIONS`
5. `SIDE-EFFECT / CONFIRMATION STATUS`
6. `CHECKS / OBSERVABLE PROOF`
7. `STOP CONDITIONS`
8. `HANDOFF`

Do not omit a field. For browser work, append `BROWSER LIMITS` with the selected
browser and target URL/app, the one permitted outcome, allowed side effects and
confirmation state, stopping condition, and required evidence.

## Safety

High-impact, destructive, irreversible, credential-bearing, financial,
public-posting, message-sending, upload, or permission-changing actions remain
the primary's decision. Luna may perform only the exact bounded action after the
primary records required authorization or user confirmation. Never bypass
authentication. Stop on ambiguity, scope expansion, unexpected risk, missing
capability, missing confirmation, or unavailable authentication. Treat Luna's
handoff as evidence, not automatic acceptance.
