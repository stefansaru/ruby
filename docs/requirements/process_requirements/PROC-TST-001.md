# PROC-TST-001 — Requirements Are Cited by Tests

**Tags:** Process, Testing, Traceability
**Status:** ✅ Done (2026-11-24)

## Requirement
Every id in the GEN register is cited by at least one test, and every GEN id a test cites exists in the register. A test enforces both directions. APP requirements name their tests in their own file once built.

## Why
A requirement nobody tests drifts from the code without anyone noticing; pushy enforces the same rule.

## Acceptance Criteria
- [x] `test/requirements_test.dart` fails on an uncited or unknown GEN id
- [x] A built APP requirement lists its tests under Related Tests

## Implementation
Built (2026-11-24). `test/requirements_test.dart` fails when a GEN file is cited by no test, when a test cites an id with no file, when a GEN file lacks its headings, or when the index misses an id. The APP requirements built so far (APP-QAL-001, APP-QAL-002) list their tests.

## Related Tests
`test/requirements_test.dart`.

## Related Docs
- [GEN register](../../requirements/gen/README.md)
- [Testing.md](../../Testing.md)
