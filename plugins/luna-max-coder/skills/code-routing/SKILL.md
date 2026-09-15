---
name: code-routing
description: "Route only code edits and browser actions to GPT-5.6 Luna / Max while an advanced primary performs every other operation and reviews the result."
---

# Luna Max Code Routing

The selected non-Luna primary is the advanced supervisor. Native role
`luna_max_code_writer`, pinned to `gpt-5.6-luna` with max reasoning, receives
only code-edit or browser-action work.

## Gate

Use exposed metadata. Accept `gpt-6-astra`, `gpt-5.6-sol`, and `gpt-5.6-terra`;
effort does not affect rank. A future model qualifies only when metadata ranks
it above `gpt-5.6-luna`. Reject `gpt-5.6-luna`, unknown identities, and unranked
models; fail closed without switching the primary.

The primary runs this check from the skill directory before spawning Luna:

~~~powershell
$skillPath = Resolve-Path ".\SKILL.md"
$skillDir = Split-Path -Parent $skillPath
$installer = Join-Path $skillDir "..\..\scripts\install-agent.ps1"
& $installer -Check
~~~

The check must identify the exact role, model, and effort. The plugin routes
existing capabilities; it does not install or guarantee them.

## Routing boundary

Luna receives exactly one `ROUTE_KIND`: `CODE_EDIT` or `BROWSER_ACTION`. Split a
mixed task into separate routes. If a task contains neither, do not spawn Luna.

The primary owns shell, SSH, repository discovery, code and file reads, Git,
web research, MCP, data work, generic Windows or Computer Use actions, tests and
builds, linting, diagnostics, permissions, review, and acceptance. It loads this
skill and checks the role; Luna never performs discovery or self-bootstrap.

### CODE_EDIT

The primary inspects the repository, identifies exact code targets, and supplies
current snippets or reliable patch anchors plus the requested behavior. Code
includes source, tests, executable scripts, and configuration syntax. Plain
documentation and data edits stay with the primary.

Luna uses `apply_patch` only; when a dispatcher wrapper is required, its only
nested operation is `apply_patch`. It must not use `exec_command`, read files,
run shell or SSH, invoke Git, execute tests and builds, browse, call MCP or web
tools, or control Windows. The primary reviews the diff and runs every check.
If context is stale, Luna returns the failed hunk; the primary rereads it and
may send one bounded correction.

### BROWSER_ACTION

The primary supplies the exact browser, target, allowed interactions, side
effects, confirmation state, and evidence. Luna uses browser tools only. A
generic Computer Use tool is allowed only when the brief names a browser window
as its target. Luna must not use shell, SSH, source inspection, web search, MCP,
code edits, or another app as a fallback.

Use one filtered preflight, a bounded action sequence, and one filtered
postflight. Stop after 90 seconds without an observable state change. Limit each
tool result to 4,000 characters; never return raw DOM, minified source, large
logs, or screenshots unless the primary requested a specific screenshot.

## Lifetime budget

Each route has a stable `ROUTE_ID` and exact `BUDGET_LEDGER`:

- `CODE_EDIT`: `calls=0/2; failures=0/2; followups=0/1`
- `BROWSER_ACTION`: `calls=0/8; failures=0/2; followups=0/1`

The worker checks the route kind, permitted tool family, and ledger before every
call. Count every issued call and every failed result, including path, syntax,
and setup mistakes. Never exclude a failure. Limits never reset after
interruption, compaction, correction, handoff, or a later turn. Only explicit
user approval in the original brief may raise a default.

A disallowed tool, `STOP`, bare `RESUME`, mismatched ledger, terminal handoff,
or exhausted limit ends the route with zero additional calls. One `CORRECTION`
is valid only with the same `ROUTE_ID`, route kind, exact previous ledger, and
remaining budget. Never replace the worker to reset limits.

A successful route is terminal. `terminal=false` is allowed only after a
correctable failed patch or browser gap when one correction and budget remain.
Stop, safety, disallowed-tool, and exhausted-budget handoffs are terminal.

## Task brief and handoff

Spawn one fresh `luna_max_code_writer` with `fork_turns: "none"`. Supply:

1. `OUTCOME`
2. `ROUTE_KIND`
3. `OWNED TARGETS`
4. `CURRENT CONTEXT` or `BROWSER LIMITS`
5. `CONSTRAINTS AND EXCLUSIONS`
6. `EXECUTION ENVELOPE`
7. `SIDE-EFFECT / CONFIRMATION STATUS`
8. `OBSERVABLE PROOF`
9. `STOP CONDITIONS`

Do not mention `$code-routing`, attach this skill, or include its filesystem path
in the worker brief. The native role already contains the execution contract.

The worker returns the exact ledger and at most 1,000 characters of status,
changed paths or browser evidence, decisions, and gaps. Pass artifact evidence,
not transcripts. The primary performs the final review and all verification.

## Safety

High-impact, destructive, irreversible, credential, financial, public-posting,
message, upload, or permission actions remain the primary's decision. Luna may
perform only the authorized browser action or code edit. Never bypass
authentication or confirmation. Stop on ambiguity, scope expansion, missing
capability, or risk.
