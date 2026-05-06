# ADR 007: Keep Snapshot Tests Local Until CI Is Stabilized

## Status

Accepted

## Context

Apricot includes snapshot tests for its main SwiftUI screens. Snapshot tests compare rendered views against stored reference images. When the rendered output diverges from the reference, the test fails.

The problem is that snapshot rendering is sensitive to the environment: font rendering, display scale, simulator resolution, and OS version can all cause pixel-level differences between a developer's machine and a CI runner. This means a snapshot test that passes locally can fail on CI — not because the UI regressed, but because the rendering environment differs.

Running snapshot tests on CI also consumes GitHub Actions minutes for a class of failures that are often false positives.

## Decision

Snapshot tests are written and maintained locally. They are excluded from the CI test run until the CI environment can be made consistent enough to produce reliable results.

The CI pipeline runs unit tests and KMP tests but skips the snapshot test target. Reference images are committed to the repository and reviewed in pull requests as visual diffs, but the CI check does not fail on snapshot mismatches.

## Consequences

**Positive:**
- CI remains green and reliable. Flaky snapshot failures do not block merges or waste GitHub Actions credits.
- Snapshot tests still provide value: developers run them locally before opening a PR, and reference images in the repo make visual regressions visible in PR diffs.

**Negative:**
- Snapshot tests are not enforced automatically. A contributor could break a screen and merge without a CI failure if they do not run snapshots locally.
- Reference images committed by one developer on one machine may not match another developer's environment exactly, causing spurious local failures for new contributors.

## Path Forward

To enable snapshot tests on CI reliably, options include:

- Using a fixed simulator model and OS version in CI via `xcodebuild -destination` and pinning the macOS runner version.
- Adopting a snapshot library that supports per-environment reference images or tolerance thresholds.
- Generating reference images on CI and storing them as build artifacts for manual review.

This decision will be revisited once the CI environment is stable enough to produce consistent rendering output.

## Alternatives Considered

**Run snapshots on CI with a tolerance threshold:** Some libraries support pixel-difference thresholds. This reduces false positives but can mask real regressions if the threshold is too loose.

**Disable snapshot tests entirely:** Removes the maintenance burden but loses the visual regression safety net. Keeping tests local preserves their value while deferring the CI stabilization work.
