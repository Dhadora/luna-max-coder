# Contributing

Thank you for helping improve Luna Max Coder. Keep contributions focused on
the documented supervisor and Luna execution workflow.

## Setup

Work from a Windows checkout with PowerShell and the Codex CLI installed. Open
PowerShell at the repository root, install the local plugin as described in the
[README](README.md), and start a new Codex conversation after installation.
Do not add credentials, private configuration, caches, generated archives, or
local research files to the checkout.

## Scope and style

Preserve the single native execution role, its pinned model and effort, the
fail-closed supervisor gate, and the capability and confirmation boundaries.
Prefer the smallest change that satisfies a clear requirement. Use standard US
English, active voice, complete sentences, and descriptive filenames. Keep
PowerShell compatible with the supported Windows environment. Do not add a
dependency when an existing command or standard-library feature is sufficient.

## Verification

Run the verifier from the repository root:

~~~powershell
pwsh -NoProfile -File .\plugins\luna-max-coder\scripts\verify.ps1
~~~

For changes to JSON, TOML, YAML, workflows, or documentation, inspect the
complete diff, run the relevant parser or workflow check, and confirm that
relative links resolve. Add a focused test or check when a non-trivial rule
changes. Do not weaken a safety, confirmation, capability, or provenance check
to make validation pass.

## Pull requests

Describe the user-visible behavior, the files changed, the checks you ran, and
any remaining limitation. Keep each pull request focused and reviewable. Avoid
unrelated formatting churn, speculative abstractions, and new architecture
layers. Preserve concurrent work and do not overwrite a conflicting installed
role file.

## Provenance

Keep the MIT license and
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) with every distributed copy.
Do not claim that derived work is clean-room, wholly original, or unrelated to
its disclosed third-party components. Add any new third-party code or asset to
the notice before distributing it, with its required copyright and license
text. Never remove a copyright or permission notice.
