---
name: code-routing
description: "Use for implementation, testing, configuration, routine tool work, or interactive browser control. Keep the selected non-Luna primary as advanced supervisor and route execution to GPT-5.6 Luna / Max."
---

# Luna Max Code Routing

The user-selected non-Luna primary model is the advanced supervisor only when
exposed Codex product or runtime metadata establishes that it is an accepted
advanced model. It owns requirements, planning, architecture, decomposition,
research synthesis, risk and permission decisions, required user confirmations,
review, and final acceptance. Keep that primary unchanged. Never silently
switch it or create a fixed paid reviewer.

## Supervisor gate

Before the first delegation, establish the primary model from exposed Codex
product or runtime metadata. Accept these currently ranked advanced supervisor
families: `gpt-6-astra`, `gpt-5.6-sol`, and `gpt-5.6-terra`; the primary's
reasoning effort does not change this gate. A future model qualifies only when
exposed metadata explicitly describes it as more capable than
`gpt-5.6-luna`. Reject `gpt-5.6-luna`, unknown identities, and unranked models.
Do not infer that every non-Luna model is advanced. If the identity or ranking
is not exposed, stop before claiming this invariant or delegating work and
state that the advanced-supervisor identity must be established. Never silently
switch the primary or add a reviewer.

Resolve the Windows companion role relative to this skill and run its
non-mutating preflight before routed work:

~~~powershell
# Run this from the installed code-routing skill directory.
$skillPath = Resolve-Path ".\SKILL.md"
$skillDir = Split-Path -Parent $skillPath
$installer = Join-Path $skillDir "..\..\scripts\install-agent.ps1"
& $installer -Check
~~~

The preflight must identify the exact native role
`luna_max_code_writer`, pinned to `gpt-5.6-luna` with max reasoning. The
primary may run this provided non-mutating `install-agent.ps1 -Check` bootstrap
before Luna is available; it is the sole terminal bootstrap exception. After
delegation, every shell or terminal command routes to Luna. The primary may
perform narrow read-only acceptance inspection, but it does not resume shell
execution.

Before task execution, enumerate every capability the task requests and confirm
that the worker has each one, including browser, Computer Use, MCP, web, and
image-generation capabilities. The plugin routes existing capabilities; it
does not install or guarantee them. If preflight, role discovery, model ranking,
capability discovery, or any requested capability fails, stop and report the
specific gap. Never fall back to the primary, a built-in role, Terra, Sol, or
another model.

## Routed execution

After the supervisor gate passes, the one Luna worker is the sole execution lane
for every category below:

- Every code-producing or code/config/test/build artifact mutation, including
  formatting, autofix, and generation.
- Every shell or terminal command, including build, test, lint, typecheck,
  diagnostics, log collection, process management, and scripted file inspection.
- Bulk codebase exploration, including file search, call-site discovery,
  dependency mapping, and routine read-only inspection.
- Every interactive browser action: browser discovery, setup, recovery, tab or
  window selection, navigation, visible or interactive page inspection,
  screenshots, clicks, scrolling, hovering, keypresses or typing, forms and
  submission, dialogs, uploads, downloads, local web testing, Playwright,
  DevTools, Browser, Chrome, and Computer Use operations that control a browser.
- Mechanical Windows app and Computer Use actions outside the browser.
- Focused web or source collection and routine MCP reads. The primary supplies
  the research question and later synthesizes conclusions.
- Bounded MCP writes and external actions only after the primary defines the
  exact scope, assesses risk, and obtains or records required authorization or
  user confirmation.
- Requested bulk extraction, classification, transformation, structured
  reporting, and image-generation tool execution or variant production. The
  primary chooses the concept, constraints, and accepted result.

The primary may use orchestration tools and the narrow read-only acceptance
inspection needed to review Luna's evidence. Apart from the provided
non-mutating installer-check bootstrap above, it must not run a shell command,
take over bulk execution, control a browser, or author implementation syntax.
Every correction returns to the same Luna worker.

Keep dependent code, shell, browser, UI, and MCP loops in one worker so state
and evidence remain continuous. Additional workers are allowed only for
genuinely independent, non-overlapping work.

## Delegation brief

Give each worker request this compact brief, in this order:

1. `OUTCOME` — the observable result the primary wants.
2. `OWNED TARGETS` — the exact files, pages, apps, or records the worker may touch.
3. `CONSTRAINTS AND EXCLUSIONS` — architecture, repository rules, safety limits,
   and explicitly excluded scope.
4. `PERMITTED TOOLS/ACTIONS` — the exact commands, tools, and interactions allowed.
5. `SIDE-EFFECT / CONFIRMATION STATUS` — whether the work is read-only; for any
   external effect, state its bound and the primary's authorization or user
   confirmation.
6. `CHECKS / OBSERVABLE PROOF` — commands or artifacts that must prove the result.
7. `STOP CONDITIONS` — ambiguity, scope expansion, missing capability,
   authentication, missing confirmation, or any stated risk that requires return.
8. `HANDOFF` — the concise status, actions, evidence, decisions needed, and gaps
   the worker must report.

Do not omit a field. The brief must be sufficient for the worker to act without
making a new architecture, permission, or risk decision.

## Browser limits

For any interactive browser delegation, append a `BROWSER LIMITS` block with:

- `selected/requested browser` and `target URL/app`;
- the single browser outcome and permitted interactions;
- `allowed side effects` and `confirmation state`;
- the `stopping condition`; and
- the `required evidence`, such as a screenshot, URL, downloaded artifact, or
  visible result.

The worker must stop when the bounded browser objective is met or when a listed
stop condition occurs. It must not continue into unrelated navigation or
external-state changes.

## Safety and review

High-impact, destructive, irreversible, credential-bearing, financial,
public-posting, message-sending, upload, or permission-changing actions remain
the primary's decision. The primary must establish the normal authorization or
user-confirmation boundary before the worker performs the exact bounded action.
The worker never bypasses authentication, unavailable tools, or a required
confirmation.

If Luna reports ambiguity, expanded scope, unexpected risk, or missing
confirmation, resolve it in the primary session and send a corrected brief back
to the same worker. Treat its report as evidence to review, not as automatic
acceptance. If the exact role, model, effort, or requested capability cannot be
confirmed, fail closed.
