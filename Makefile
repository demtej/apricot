.PHONY: bootstrap kmp xcode lint format format-check clean

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

clean:
	./gradlew clean
	rm -rf Apricot.xcodeproj
