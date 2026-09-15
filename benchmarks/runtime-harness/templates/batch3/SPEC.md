# Batch 3: parsing and policy

Implement every public name already present in `workload.py`. Use only the
Python standard library and deterministic behavior.

## 9. Semantic versions and ranges

`SemVer` is an immutable, totally ordered value with integer `major`, `minor`,
`patch`, tuple `prerelease`, and optional string `build`. `SemVer.parse(text)`
accepts strict SemVer 2.0.0 syntax and rejects leading zeroes in numeric core or
numeric prerelease identifiers. String conversion reproduces the normalized
version. Build metadata does not affect equality or ordering. Release versions
sort after prereleases; numeric prerelease identifiers sort before nonnumeric
ones and shorter equal prefixes sort first.

`satisfies(version, expression)` accepts a string or `SemVer`. Support `||` OR
groups; whitespace-separated AND terms; comparators `< <= > >= =`; exact
versions; wildcards `x`, `X`, or `*` in minor or patch positions; caret ranges;
and tilde ranges. Bare partial versions behave as wildcards. Invalid or empty
expressions raise `ValueError`. Prerelease versions satisfy a comparator group
only when that group contains a comparator with the same major/minor/patch and
a prerelease identifier.

## 10. URL canonicalization

`canonicalize_url(url, drop_params=(), sort_values=False)` supports absolute
HTTP and HTTPS URLs only. Lowercase scheme and host, IDNA-encode the host,
remove default ports, preserve nondefault ports, reject credentials, remove the
fragment, normalize an empty path to `/`, resolve `.` and `..` path segments,
and preserve a trailing slash. Percent-decode unreserved path characters and
emit uppercase percent escapes for all other encoded bytes. Parse query pairs
with blank values, drop names in `drop_params`, sort by decoded key, preserve
same-key value order unless `sort_values` is true, and encode using `%20` rather
than `+`.

## 11. Retry policy

`parse_retry_after(value, now)` accepts nonnegative integer seconds or an HTTP
date and returns nonnegative seconds as a float. `now` is an aware datetime or
Unix timestamp. Reject booleans, malformed values, and naive datetimes with
`ValueError`.

`retry_delays(attempts, base=1, factor=2, cap=60, jitter=0, seed=None,
retry_after=None)` returns `attempts - 1` floats. Validate positive attempts,
base, factor, and cap and `0 <= jitter <= 1`. Delay `i` is
`min(cap, base * factor**i)`, multiplied by a seeded uniform factor in
`[1-jitter, 1+jitter]`, then capped again. When supplied, `retry_after` is an
iterable of numbers or `None`; each value is a floor for its matching delay.
Reject a length mismatch or invalid floor.

## 12. Typed configuration resolution

`resolve_config(schema, defaults=None, file_values=None, env=None, cli=None,
env_prefix="APP_")` resolves schema keys in defaults, file, environment, and
CLI precedence. A schema entry is a dictionary supporting `type` (`str`, `int`,
`float`, `bool`, or `list`), `required`, `default`, `choices`, `min`, and `max`.
Reject unknown schema options and unknown keys in defaults, file values, or CLI.
Environment names are the prefix plus the uppercased key with dots replaced by
underscores; unrelated environment keys are ignored. `None` means absent in
CLI only.

Convert strings strictly: booleans accept true/false, yes/no, on/off, and 1/0;
lists accept comma-separated strings with surrounding whitespace removed.
Non-string values must already have the requested type, with booleans rejected
as integers or floats. Enforce choices and numeric min/max after conversion.
Return `(values, origins)`, where origins maps every resolved key to `schema`,
`defaults`, `file`, `env`, or `cli`. Missing required values and all invalid
inputs raise `ValueError`. Return fresh values with no shared mutable inputs.
