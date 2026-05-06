# ADR 003: Use XcodeGen as the Xcode Project Source of Truth

## Status

Accepted

## Context

Xcode project files (`*.xcodeproj`) are large XML files that are difficult to read in diffs, prone to merge conflicts, and must be updated whenever files are added, removed, or reorganized. In a project that also involves a KMP build step, the Xcode project has an additional concern: it must reference the XCFramework produced by Gradle, which is generated locally and git-ignored.

Committing a hand-maintained `.xcodeproj` into the repository would mean the project file references a framework path that may not exist until `make kmp` is run, and any file addition would result in noisy diffs.

## Decision

Use XcodeGen to generate `Apricot.xcodeproj` from a declarative `project.yml` file. The generated project is git-ignored. The source of truth is `project.yml`.

`make xcode` runs XcodeGen to regenerate the project. `make bootstrap` runs `make kmp` then `make xcode` in sequence, giving contributors a single command for first-time setup.

## Consequences

**Positive:**
- `project.yml` is human-readable and produces clean, minimal diffs when files or settings change.
- Merge conflicts on the project file are eliminated.
- The XCFramework reference is declared once in `project.yml` and always points to the correct local path after `make kmp`.
- New contributors follow a clear two-step setup: `make bootstrap`, then open Xcode.

**Negative:**
- Contributors must run `make xcode` after pulling changes that affect `project.yml`, or their local project file will be stale.
- Some advanced Xcode project settings are harder to express in `project.yml` and may require manual workarounds.
- XcodeGen is an external dependency that must be installed (`brew install xcodegen`). If XcodeGen drops support for a feature used by the project, a migration is required.

## Alternatives Considered

**Commit the `.xcodeproj` directly:** Simple for contributors but produces large, unreadable diffs and frequent merge conflicts. Especially problematic given that the project file must embed local framework paths.

**Tuist:** A more feature-rich alternative to XcodeGen with a Swift DSL. Heavier to set up and introduces more tooling overhead for a project of this scope. XcodeGen's YAML-based configuration is sufficient here.
