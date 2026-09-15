# Conversational examples

The primary performs discovery and all operational work. It starts Luna only
for one exact code edit or one bounded browser action. Every brief uses a fresh
worker, `fork_turns: "none"`, a stable route ID, and the matching lifetime
ledger.

## 1. Code edit

User prompt:

~~~text
Add the smallest input-validation guard needed for the reported failure.
~~~

Expected routing:

- The primary finds the cause, reads the validator and test, and supplies exact
  current snippets and acceptance criteria.
- Luna receives `ROUTE_KIND: CODE_EDIT` and
  `calls=0/2; failures=0/2; followups=0/1`.
- Luna uses `apply_patch` only. It does not inspect files or run commands.
- The primary reviews the diff and runs the focused test, lint, and build.

If a patch anchor is stale, Luna reports the rejected hunk. The primary rereads
that location and may send one correction with the same route ID and exact
ledger. A shell command, file read, or browser request ends this route without
executing that tool.

## 2. Browser action

User prompt:

~~~text
Open the local page already available for this task, select Settings, and report
the current URL and visible heading. Do not submit forms or change account data.
~~~

Expected routing:

- The primary checks the browser capability and supplies the browser, page,
  allowed interactions, side effects, stop conditions, and evidence.
- Luna receives `ROUTE_KIND: BROWSER_ACTION` and
  `calls=0/8; failures=0/2; followups=0/1`.
- Luna uses browser tools only for preflight, bounded actions, and postflight.
- The primary reviews the compact URL and heading evidence.

The route stops on authentication, an unexpected domain, a disallowed action,
or 90 seconds without observable progress. Shell, web search, MCP, source
inspection, and non-browser application control are not fallbacks.

## 3. Operational task with no Luna worker

User prompt:

~~~text
Inspect the remote service over SSH, classify the current sessions, run the
existing verifier, and report the result. Do not edit code or use a browser.
~~~

Expected routing:

- The primary performs SSH, file reads, discovery, diagnostics, and verification.
- No Luna worker is started because the task contains neither `CODE_EDIT` nor
  `BROWSER_ACTION`.

If the inspection later proves that code must change, the primary finishes its
analysis and starts a separate code-edit route containing only that patch.
