.PHONY: bootstrap kmp xcode lint format format-check clean record-snapshots

SWIFTLINT ?= swiftlint
SWIFTFORMAT ?= swiftformat

# First-time setup: build the KMP XCFramework, then generate the Xcode project.
bootstrap: kmp xcode

# Build the shared KMP module as an XCFramework (required before opening Xcode).
kmp:
	./gradlew assembleSharedDebugXCFramework

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
