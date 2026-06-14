.PHONY: bootstrap kmp kmp-release kmp-all xcode lint format format-check clean clean-xcode \
	record-snapshots prepare-archive validate-archive preflight-release

SWIFTLINT ?= swiftlint
SWIFTFORMAT ?= swiftformat

# First-time setup: build both KMP XCFramework variants, then generate the Xcode project.
bootstrap: kmp-all xcode

# Build the shared KMP module as a debug XCFramework (fast, for local development).
kmp:
	./gradlew assembleSharedDebugXCFramework

# Build the shared KMP module as a release XCFramework (required for Archive / TestFlight).
kmp-release:
	./gradlew assembleSharedReleaseXCFramework

# Build both debug and release XCFrameworks.
kmp-all: kmp kmp-release

# Regenerate Apricot.xcodeproj from project.yml.
xcode:
	xcodegen generate

lint:
	@command -v $(SWIFTLINT) >/dev/null || { echo "swiftlint is not installed. Install it with: brew install swiftlint"; exit 1; }
	$(SWIFTLINT) lint --config .swiftlint.yml --no-cache

format:
	@command -v $(SWIFTFORMAT) >/dev/null || { echo "swiftformat is not installed. Install it with: brew install swiftformat"; exit 1; }
	$(SWIFTFORMAT) . --config .swiftformat --cache ignore

format-check:
	@command -v $(SWIFTFORMAT) >/dev/null || { echo "swiftformat is not installed. Install it with: brew install swiftformat"; exit 1; }
	$(SWIFTFORMAT) . --config .swiftformat --lint --cache ignore

record-snapshots: xcode
	@DEST=$$(bash scripts/ci/select-ios-simulator.sh 'iPhone 17 Pro') && \
	xcodebuild \
		-project Apricot.xcodeproj \
		-scheme ApricotSnapshotTests \
		-destination "$$DEST" \
		-derivedDataPath .build/DerivedData \
		-testenv RECORD_SNAPSHOTS=1 \
		test || true
	@echo "Snapshots recorded. Review changes in ApricotSnapshotTests/Snapshots/__Snapshots__ before committing."

clean:
	./gradlew clean
	rm -rf Apricot.xcodeproj

# Remove generated Xcode project and build artifacts (does not touch Gradle outputs).
clean-xcode:
	rm -rf Apricot.xcodeproj
	rm -rf ~/Library/Developer/Xcode/DerivedData/Apricot-*
	rm -rf build

# Get the project into a clean state ready for Product > Archive in Xcode:
# clean stale Xcode artifacts, build the release XCFramework, and regenerate the project.
prepare-archive: clean-xcode kmp-release xcode
	@echo "Ready for Archive: open Apricot.xcodeproj and run Product > Archive."

# Run a full Release archive from the console to validate the archive flow without Xcode UI.
validate-archive: prepare-archive
	xcodebuild \
		-project Apricot.xcodeproj \
		-scheme Apricot \
		-configuration Release \
		-destination "generic/platform=iOS" \
		-archivePath build/Apricot.xcarchive \
		archive

# Full pre-release validation: lint, format check, both KMP XCFrameworks,
# regenerated project, unit tests, and a Release build of the app.
# Snapshot tests are excluded: they are local-only and pending CI stabilization.
preflight-release: lint format-check kmp-all xcode
	@DEST=$$(bash scripts/ci/select-ios-simulator.sh 'iPhone 17 Pro') && \
	xcodebuild \
		-project Apricot.xcodeproj \
		-scheme ApricotUnitTests \
		-destination "$$DEST" \
		-derivedDataPath .build/DerivedData \
		test
	xcodebuild \
		-project Apricot.xcodeproj \
		-scheme Apricot \
		-configuration Release \
		-destination "generic/platform=iOS" \
		build
