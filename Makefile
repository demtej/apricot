.PHONY: bootstrap kmp xcode clean

# First-time setup: build the KMP XCFramework, then generate the Xcode project.
bootstrap: kmp xcode

# Build the shared KMP module as an XCFramework (required before opening Xcode).
kmp:
	./gradlew assembleSharedDebugXCFramework

# Regenerate Apricot.xcodeproj from project.yml.
xcode:
	xcodegen generate

clean:
	./gradlew clean
	rm -rf Apricot.xcodeproj
