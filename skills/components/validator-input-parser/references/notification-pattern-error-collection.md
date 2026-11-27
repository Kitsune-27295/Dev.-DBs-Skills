# Notification Pattern and Error Collection

Sources: https://martinfowler.com/articles/replaceThrowWithNotification.html · Last verified 2026-11-27

## Problem

Throwing an exception on the first failed check has two flaws (Fowler, article of 9 December 2014):
1. **Wrong signal.** Exceptions mark behavior outside a code path's expected bounds; validation failures on external input are expected. Fowler's position: if a failure is expected behavior, do not use exceptions.
2. **Whack-a-mole.** Fail-fast reports one error per attempt, so the user fixes problems one by one.

## The pattern

A **Notification** object accumulates errors. Each check calls `addError` instead of throwing; the validator returns the notification; the caller asks `hasErrors()` and reads the details. Simplest form is a list of strings; a small dedicated class states intent better and can later carry error objects (message plus cause, and in our extension field path and stable code). A bare boolean result gives no diagnostics. Before writing one, check whether your platform or schema library already collects violations (author advice; the article does not name specific libraries).

## When to use it, when not

| Use a Notification | Use an exception |
|---|---|
| Raw external input (forms, JSON, CLI, files named by users) | Genuinely exceptional conditions (missing system file) |
| Failure is handled in normal flow | Re-validating data that should already be clean (guards against programmer error) |
| Client benefits from all errors at once | Failure cannot be handled locally |

Heuristic from *The Pragmatic Programmer*, cited by Fowler: would the code still work if all exception handlers were removed? If not, exceptions are used for non-exceptional cases.

## Refactoring recipe (from the worked booking example)

1. **Split:** extract the checking body into `validation()` returning a Notification; the old `check()` calls it and throws if errors exist. Behavior unchanged (watch for message changes: old callers saw only the first error).
2. **Convert checks last-to-first.** Replacing a throw with `addError` naively lets execution continue into code that assumed the earlier check stopped it (a null date then blows up in parsing). Working backwards keeps each step safe.
3. **Extract per-field methods** (`validateNumberOfSeats(note)`, `validateDate(note)`) and replace if/else with **guard clauses**: record the error and `return`.
4. **Extend the Notification** when a throw carried a cause: add `addError(message, exception)`, store small error objects.
5. **Finish:** once callers can use `validation()` directly, drop the throwing wrapper and add tests proving multiple errors are collected (author extension; the 2026-11-27 digest of the article did not list this step).

Principle: smallest behavior-preserving steps, tests green throughout.

## Design rules (some are our inference)

- **Dependent checks:** if field B's check needs field A to be valid, return after A's failure (guard), otherwise cascading nonsense errors appear.
- **Error shape:** `{field/path, code, message}`; stable codes for clients, human message separate. Map to the HTTP envelope in one place (`error-handling-problem-details`).
- **Immutability:** build the Notification inside the validator, return it; do not share one instance across requests.
- **Pair with parsing:** `parse(raw): Result<Valid, Notification>`; success gives a typed value, failure gives all errors.

```py
def parse_booking(raw: dict):
    n = Notification()
    seats = raw.get("numberOfSeats")
    if seats is None: n.add("numberOfSeats", "required")
    elif seats < 1: n.add("numberOfSeats", "min")
    date = parse_date(raw.get("date"), n)   # adds its own error, returns None on failure
    return Err(n) if n.has_errors else Ok(Booking(date, seats))
```

## Failure modes

- Notification used for programmer errors, hiding bugs.
- Proceeding after `hasErrors()` because a caller forgot to check (fix: return `Result`, so the value is unavailable on failure).
- Dozens of cascading errors from one root cause (missing guards).
- Leaking internal messages or exception causes to clients.

## How an agent should apply this

- Convert `throw` chains in input validators to a collector using the backward, step-by-step recipe, keeping tests green.
- Use guard clauses so dependent checks do not run on invalid prerequisites.
- Return `Result<Parsed, Notification>` so success and failure paths cannot be confused.
- Keep exceptions for system faults and for defensive re-validation of trusted data.
- Add a test that sends an input with several defects and asserts all are reported.
