# Modernization action and validation log

Date: 2026-11-17 (America/Sao_Paulo).

## Actions and reasons

1. Cloned the authorized repository and checked Git status, branch, manifests, all four original Dart sources, platform files, README and license. The checkout was clean; no project/parent AGENTS.md applied. Preserved MIT, original authorship and original mobile application identifiers.
2. Read the requested reduced-principles instructions and testing guidance. Replaced the Dart 2 constraint and obsolete HTTP API with the verified Flutter 3.41.9 / Dart 3.11.5 toolchain and HTTP 1.6.0. Removed unused Cupertino dependency. No shared SDK was installed or updated.
3. Added controlled fixtures and tests for boundary validation, error categories and request races. Created widget/demo tests before their respective implementations and observed missing-API/compiler failures. Domain/service tests were authored first, but package resolution overlapped implementation, so their first observed run was after implementation; this is not claimed as a full red/green TDD cycle. Later test failures exposed test synchronization and UTF-8 fixture setup errors, which were corrected rather than hidden.
4. Introduced an immutable CEP/address boundary, injected service interface and explicit UI state with generation invalidation. No cache/history was added: the previous version did not persist data, and no storage migration is necessary. Serialization round-trip and optional original fields are covered by tests.
5. Rebuilt the UI with responsive panels, typography/spacing hierarchy, labelled input, native keyboard/focus controls, copy action, address fields, live status messages and empty/loading/error views. Added an explicitly labelled offline São Paulo sample.
6. Generated runners/configuration using the existing Flutter installation. Replaced old imperative Android Gradle integration, enabled release INTERNET access, modernized iOS lifecycle, added Web/macOS, preserved original iOS artwork. Removed tracked build caches, SDK paths and generated registrants. Raised Apple minimums to macOS 12 / iOS 15 for Xcode 27 compatibility.
7. Ran the real ViaCEP smoke script separately from mocks. Opened the compiled Web app in Chrome, enabled accessibility and exercised invalid input and Enter-to-search against ViaCEP. Captured real desktop and 390px responsive screenshots; no mockup was used. Narrow layout was scrolled to verify the address card.
8. Updated the English README with verified commands, architecture/glossary, migration details, demo controls and limitations. Added a deterministic Linux CI workflow for formatting, analyze, tests and Web build. Badges describe real SDK versions/license, without invented coverage or success claims.
9. Updated GitHub About in the authenticated browser and verified the saved description. Preserved and checked five relevant topics: `dart`, `education`, `flutter`, `postal-code`, `viacep`. Evidence: `docs/screenshots/github-about.jpg`.
10. Resolved http://bit.ly/2kcGFQh to the author's actual Medium article, opened/read it in this project's own tab, including class sections and challenges. Detected signed-out state (“Sign in”, “Sign up”, “Unknown user”) and no editorial access. Prepared `docs/medium-update.pt-BR.md` with concrete replacement sections and exact final code. No Medium publication occurred; no third-party article was edited and no subscriber communication was sent.

## Verification

- Flutter doctor: Flutter 3.41.9, Dart 3.11.5, Chrome 157.0.8103.79, Xcode 27.2. Android SDK 36.1.0 and JDK 21 are available; some Android licenses are not accepted. No terms were accepted by the agent.
- Deterministic suite: 21 tests passed before the final accessibility regression check; final outcome recorded below.
- `dart run tool/smoke.dart`: **passed**, real HTTPS request, output `LIVE ViaCEP OK: 01001-000, São Paulo/SP`.
- Initial `flutter build web`: **passed**, including Wasm dry-run. The build warned about an unused Cupertino font family from Flutter defaults; the app uses Material icons. No missing app icons were observed.
- `flutter build macos`: **failed** first on the generated 10.15 deployment target, then after correction on framework universal-architecture packaging. Flutter reported required `arm64 x86_64`, while `lipo` reported the same architectures in opposite order. No global SDK patch was made.
- `flutter build macos --debug`: **passed**. This is a development build, not a successful release package or a claim of desktop interaction testing.
- iOS build and final checks: see final record below. No physical device was tested. Android build was not certified because licenses remain pending.
- `crapper --no-coverage lib`, `dryer lib`, `mutator --scan lib`: executed; no supported source files found. Their installed language lists omit Dart. No CRAP, duplication or mutation score is claimed. Actual Flutter coverage output is local at `coverage/lcov.info`; this is line coverage, not mutation coverage.

## Remaining limits

No screen-reader hardware test, physical phone test, Android certification, production signing, package publication or deployment. Public service availability and clipboard permission depend on the environment. The macOS release toolchain failure remains distinct from the successful debug build. Medium requires an authenticated author/editor session before applying the prepared revision to the existing URL.

## Final verification record

- Accessibility regression reproduced in a widget test (address label absent), fixed with explicit selectable-text semantics and separate child nodes, then all 21 tests passed.
- Actual Flutter line coverage: 216/238 (90.8%); no mutation score.
- Remote default branch confirmed as `master`; branch protection endpoint reported `protected: false`. Fetched remote before committing. No force push or protection change.
- Final static analysis after the accessibility fix: **passed**, no issues found.
- Second Web build: **passed**; final accessibility build remains the last build to verify in the browser.
- Commits prepared: `be3ac78` (toolchain/platforms), `c2b0c0f` (lookup/UI/tests/CI). Documentation/evidence are committed separately after final validation.
- `flutter build ios --no-codesign`: **passed**, produced `build/ios/iphoneos/Runner.app` (15.7 MB). This is compilation without signing, not a physical-device or simulator interaction test.
- Final Web build after accessibility changes: **passed**. Reloaded the compiled app, performed a new live lookup, and verified CEP, street, district, city/state, complement, DDD and IBGE are now exposed in the browser accessibility tree. Clicked Copy and observed “Endereço copiado.” Updated `web-address.jpg` from this final running version.
- Final browser deliverable: local Web preview at `http://127.0.0.1:8766/`. Responsive screenshots are retained under `docs/screenshots/`.
