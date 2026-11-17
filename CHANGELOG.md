# Changelog

## 2.0.2+4 — 2026-11-17

- Fix Android builds for Flutter 3.50 using its official Gradle/AGP/Kotlin template and migrator compatibility flags; keep source targets at Java/Kotlin 17 with JDK 21.
- Validate debug/release APKs, release startup on Android 16/API 36 ARM64, and one live debug integration flow with six checks, including real ViaCEP and Android clipboard access.
- Add reproducible SDK integration-test capture/report tooling and Android release build CI. Refresh README and Portuguese lesson with actual native screenshots and validation limits.

## 2.0.1+3 — 2026-11-17

- Adopt exact compatibility overrides for material_color_utilities 0.13.1 and test_api 0.7.15 after analysis, 21 tests and available release builds passed with Flutter 3.50.0 / Dart 3.14.0.
- Record resolver reports with and without overrides, maintenance/removal instructions and the updated application version/build.
- Improve the Portuguese teaching material and end the article with five concrete app-improvement challenges and acceptance criteria.
