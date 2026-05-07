# TestFlight / App Store Release Checklist

> Work through this list top-to-bottom before submitting each build.

---

## 1. Code & Build

- [ ] `make bootstrap` runs cleanly on a fresh clone
- [ ] `./gradlew :shared:allTests` passes
- [ ] `xcodebuild … build` succeeds with no warnings treated as errors
- [ ] All snapshot tests pass locally (`xcodebuild test -scheme Apricot …`)
- [ ] No `TODO` / `FIXME` / force-unwrap regressions introduced since last release
- [ ] Bundle identifier is `com.demiantejo.apricot` in `project.yml`
- [ ] `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` are set correctly in `project.yml`
- [ ] Minimum deployment target is iOS 17.0
- [ ] Release KMP XCFramework built: `make kmp-release` (Xcode project references `release/shared.xcframework`)

---

## 2. Secrets & Configuration

- [ ] `APRICOT_POSTHOG_API_KEY` and `APRICOT_POSTHOG_HOST` are set in the CI/signing xcconfig — **not committed to git**
- [ ] `.gitignore` confirms `*.xcconfig` (secrets) and `Secrets/` are excluded
- [ ] Verify `Apricot.xcodeproj` is not committed (generated artifact)
- [ ] Verify `shared/build/` is not committed (generated artifact)
- [ ] No hardcoded API keys, tokens, or secrets anywhere in source

---

## 3. App Store Connect Setup

- [ ] App record created in App Store Connect
- [ ] Bundle ID registered in the Apple Developer Portal
- [ ] App Store Connect: App Information filled in
  - [ ] App name: **Apricot**
  - [ ] Subtitle: **Bitcoin Address Explorer**
  - [ ] Primary language: English
  - [ ] Category: Finance / Utilities
  - [ ] Content rights declaration completed
- [ ] Privacy Policy URL entered (must be a live, publicly accessible URL)
- [ ] Support URL entered

---

## 4. Metadata & Copy (see `docs/app-store/metadata.md`)

- [ ] Promotional text reviewed and finalized
- [ ] Description reviewed — disclaimer paragraph present
- [ ] Keywords within 100-character limit
- [ ] Age rating questionnaire completed (expected: 4+)
- [ ] Copyright field set (e.g., `© 2026 Demian Tejo`)
- [ ] Version and build number correct

---

## 5. Screenshots

- [ ] iPhone 6.9" screenshots captured (required)
- [ ] Screenshots show real-looking but non-sensitive data
- [ ] No personal/private data visible in screenshots
- [ ] Status bar is clean (9:41 AM, full bars, full battery)
- [ ] Screenshots reviewed against `docs/app-store/metadata.md` screenshot checklist

---

## 6. Privacy

- [ ] Privacy Policy is hosted at a live, publicly accessible URL
- [ ] App Store Connect: Data Collection section completed accurately:
  - [ ] **Usage Data** — Yes (PostHog analytics events)
  - [ ] **Identifiers** — Yes (PostHog session ID, device type — not linked to identity)
  - [ ] **Diagnostics** — No
  - [ ] **Financial Info** — No
  - [ ] **Location** — No
  - [ ] **Contacts / Health / Sensitive Info** — No
  - [ ] Confirm: data is **not** used for tracking, advertising, or sold to third parties
- [ ] `docs/app-store/privacy-policy.md` is hosted and URL entered in App Store Connect
- [ ] App does not request any permissions (camera, location, contacts, etc.)

---

## 7. Legal & Compliance

- [ ] Disclaimer visible in the app (home screen footer)
- [ ] Description does not contain financial advice, investment recommendations, or price claims
- [ ] App does not offer trading, wallet creation, or custody functionality
- [ ] Export compliance: app uses HTTPS (standard encryption) — answer "Yes" to standard encryption, "No" to proprietary encryption
- [ ] COPPA: app not directed to children; age rating reflects 4+

---

## 8. TestFlight

> See `docs/app-store/testflight-checklist.md` for the full step-by-step upload guide.

- [ ] Internal testers added in App Store Connect
- [ ] Build uploaded via Xcode Organizer or `xcrun altool` / `xcrun notarytool`
- [ ] TestFlight build passes Apple's automated review checks
- [ ] Beta App Description and Feedback Email set in TestFlight section
- [ ] At least one full test run on a physical device (not just Simulator)
- [ ] Test the following flows on device:
  - [ ] Search a known mainnet address → address screen loads
  - [ ] Tap a transaction → transaction detail loads
  - [ ] Flow diagram renders correctly
  - [ ] Error states render (test with invalid address, airplane mode)
  - [ ] Recent searches persist across app launches
  - [ ] App cold-start time is acceptable

---

## 9. App Store Submission

- [ ] All TestFlight issues resolved
- [ ] App Review notes written (explain what the app does, mention it uses public API data)
- [ ] Demo account not required (app has no login)
- [ ] Build selected for submission in App Store Connect
- [ ] Release type chosen: Manual or Automatic after approval
- [ ] Submission sent

---

## Post-Approval

- [ ] Monitor crash reports in Xcode Organizer / App Store Connect
- [ ] Monitor PostHog dashboard for event volume and error rates
- [ ] Tag the release commit: `git tag v1.0.0`
