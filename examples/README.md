# Conversational examples

These examples use generic targets and existing capabilities. Replace a target
with one that exists in your current task, keep the owned scope explicit, and
do not paste credentials into a prompt. In every example, the primary first
passes the supervisor and capability gates, then sends the complete delegation
brief to the same Luna worker.

## 1. Code change and shell tests

User prompt:

~~~text
Add the smallest input-validation guard needed for the reported failure. Limit
the change to the existing validator and its focused test, then run the
repository's existing test command and report the diff and output.
~~~

Expected routing:

- The primary selects the guard and the exact source and test targets.
- Luna edits only those targets and runs the test command, because code changes
  and every shell command belong to the execution lane.
- The primary reviews the complete diff and the observable test output.

Supervision and check: The packet names the outcome, owned targets, exclusions,
permitted command, read-only status, required test output, and stop conditions.
The worker returns the changed paths and the actual test result.

Stop condition: Stop if the validator or test target is ambiguous, the command
is unavailable, the scope expands, or the test needs an unapproved dependency
or external effect.

## 2. Browser interaction with evidence

User prompt:

~~~text
Open the local page already available for this task, select the Settings view,
and report the current URL and the visible heading. Do not submit forms, change
account data, or navigate outside this page.
~~~

Expected routing:

- The primary confirms that the requested browser capability is available and
  supplies the bounded page target.
- Luna performs discovery, navigation, selection, and visible inspection in
  one browser worker.
- The worker returns the current URL and a screenshot or equivalent visible
  result; the primary checks that evidence against the requested heading.

Supervision and check: The browser limits name the requested browser, target
URL or app, allowed interactions, no-side-effect confirmation, stopping
condition, and required evidence.

Stop condition: Stop at the Settings heading, on an unavailable browser
capability, an authentication prompt, an unexpected domain, or any request to
submit or change data.

## 3. Windows app or Computer Use task

User prompt:

~~~text
Use the Windows Calculator app to evaluate 37 * 24 and report the visible
result. Do not save a file, open a browser, or interact with another app.
~~~

Expected routing:

- The primary checks that Windows Computer Use is available and defines the
  Calculator-only boundary.
- Luna opens the app, enters the expression, and reads the visible result.
- The primary checks the returned screenshot or visible UI evidence.

Supervision and check: The packet records the app, expression, allowed input,
read-only side effects, evidence requirement, and the stopping condition.

Stop condition: Stop if Calculator or Computer Use is unavailable, another app
opens, a permission prompt appears, or the visible result cannot be verified.

## 4. Focused web research and an MCP read

User prompt:

~~~text
Answer one focused question using current official documentation, then read the
connected MCP record for this task and compare its status with the sources. Do
not write to the MCP service or contact anyone.
~~~

Expected routing:

- The primary defines the single research question and checks web and MCP read
  capabilities.
- Luna collects the requested sources and performs the routine MCP read.
- The primary synthesizes the conclusion, checks source URLs and the record
  identifier, and does not ask Luna to make a write.

Supervision and check: The packet limits source collection to the question,
names the MCP record, marks all operations read-only, and requires source links,
the read result, and a concise comparison.

Stop condition: Stop if a source requires credentials, the MCP record is not
available, the question broadens, or any write, message, or account action is
proposed.

## 5. Bounded MCP write after confirmation

User prompt:

~~~text
Update the connected task record's status field to "ready". Change no other
field and do not notify anyone.
~~~

Primary supervision before delegation:

~~~text
The exact target is the connected task record, the only field is status, the
new value is ready, and the action is an external write. Confirm that you want
this bounded change before I delegate it.
~~~

User confirmation:

~~~text
I confirm that exact status-only change.
~~~

Expected routing:

- The primary records the confirmation and sends Luna a packet containing the
  exact record, field, value, no-notification limit, and proof requirement.
- Luna performs only that authorized MCP write and reads back the changed field.
- The primary checks the read-back result and accepts or rejects the report.

Stop condition: Stop before writing if confirmation is absent or ambiguous, the
record or field differs, the service requests broader permission, or any
notification, upload, or unrelated change appears.

## 6. Bulk extraction and structured reporting

User prompt:

~~~text
Extract the rows matching the supplied date and status filters from the
connected read-only dataset, group them by owner, and return a Markdown report
with counts and the source row identifiers. Do not change the dataset.
~~~

Expected routing:

- The primary defines the filters, output fields, grouping, and accepted report
  shape, and checks the extraction capability.
- Luna performs the bulk read, classification, transformation, and report
  generation in one worker.
- The primary checks totals against the extracted rows and reviews the report
  for scope and omissions.

Supervision and check: The packet marks the dataset read-only, names the exact
filters and output fields, requires row counts and identifiers, and records the
stop conditions for malformed or unexpectedly large input.

Stop condition: Stop if the dataset is not read-only, a filter is ambiguous, a
credential is requested, or the result cannot be reconciled with the source
rows.

## 7. Image-generation variants with primary selection

User prompt:

~~~text
Create three image-generation variants for a simple abstract app icon. Keep a
flat two-color palette, no text, and a square canvas. Show the variants and ask
me to select one; do not publish or upload anything.
~~~

Expected routing:

- The primary chooses the concept, palette, canvas, variant count, and local
  acceptance criteria, then verifies image-generation capability.
- Luna runs the requested image-generation variant production and returns the
  generated outputs.
- The primary compares the variants with the constraints and records the user's
  selected result without publishing it.

Supervision and check: The packet names the prompt constraints, output count,
local-only side-effect boundary, required image evidence, and selection step.

Stop condition: Stop if image generation is unavailable, a generated result
contains an unrequested element that needs a new concept decision, or a request
to upload, publish, or change an account appears without confirmation.
