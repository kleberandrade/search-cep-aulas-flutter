# Medium teaching article assets

- `article.pt-BR.html`: complete revised Portuguese teaching article, with progressive explanations, actual source excerpts, exercises and image captions.
- `cover.png`: original editorial cover generated using the built-in image generator; illustrative, not an app screenshot.
- `../screenshots/web-*.jpg`: real running Web application captures used in the lesson.
- `../screenshots/android-*.png`: native Android integration-test surface captures (Android 16/API 36 ARM64), not browser device emulation.

Target article: https://medium.com/flutter-comunidade-br/consultando-ceps-com-flutter-a395b86ce34a

Cover prompt: landscape editorial illustration for “Consultando CEPs com Flutter”, subtitle “Da validação ao endereço com ViaCEP”, ivory/teal/sage palette, envelope, map pin and Brazil-inspired contours, generous typography and crop-safe margins. No fabricated app UI.

Generated with the built-in image tool on 2026-11-17. Flutter branding remains subject to its upstream trademark rights.

## Publication history

The original article was republished in Portuguese on 2026-11-17, preserving its URL, title, subtitle, authorship and publication identity. The editorial cover is also the sharing image. Earlier stages used five images and 13 code blocks; the override revision added a 14th block. Publication evidence and exact checks for each stage are retained in `../modernization-log.md` and `published-*.jpg`. No subscriber email/newsletter was sent.

The archived `../medium-update.pt-BR.md` is a complete technical reference; `article.pt-BR.html` is the didactic publication source. The two exact overrides remove the last official SDK resolution constraints for this tested app. Both resolver reports were rechecked after adding integration_test; no outdated packages were reported with overrides enabled.

## App 2.0.1+3: tested overrides

The teaching source now explains exact overrides for material_color_utilities 0.13.1 and test_api 0.7.15, how resolution differs from compatibility, which checks were executed and when overrides should be removed. It distinguishes app version/build from Flutter/Dart versions.

## Editorial convention

Every student-facing article must end with exactly **five app-improvement challenges**. Put credits/references before that final section. Each challenge should name a concrete feature and a checkable acceptance criterion. Do not append a closing paragraph after the challenges. This convention was explicitly requested by the author.


## App 2.0.2+4: Android validation

The current source adds a didactic Android section: build versus device interaction, the official Flutter 3.50 Android configuration, exact build/device commands, release startup and a separate debug integration flow with six real-service/clipboard checks. Four native screenshots are archived; the address capture appears as Figure 5. Physical-phone testing, performance measurement and production signing are not claimed. The final five challenges remain the last content section. Republished and verified at the original URL on 2026-11-17 after both CI jobs passed (run 44097659142). All 15 published code blocks matched the prepared excerpts; the six images have captions/alternative text, the Android image loaded on the public page, and the final ordered list contains exactly five challenges. The cover remains the sharing image (`0*Ya4LTZDAvFprISd5.png`). Evidence: `published-android.jpg`, `published-android-capture.jpg`, `published-android-challenges.jpg`. No newsletter or subscriber message was sent.
