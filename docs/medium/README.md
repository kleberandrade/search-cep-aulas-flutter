# Medium teaching article assets

- `article.pt-BR.html`: complete revised Portuguese teaching article, with progressive explanations, actual source excerpts, exercises and image captions.
- `cover.png`: original editorial cover generated using the built-in image generator; illustrative, not an app screenshot.
- `../screenshots/web-*.jpg`: real running Web application captures used in the lesson.
- `../screenshots/android-*.png`: native Android integration-test surface captures (Android 16/API 36 ARM64), not browser device emulation.

Target article: https://medium.com/flutter-comunidade-br/consultando-ceps-com-flutter-a395b86ce34a

Cover prompt: landscape editorial illustration for “Consultando CEPs com Flutter”, subtitle “Da validação ao endereço com ViaCEP”, ivory/teal/sage palette, envelope, map pin and Brazil-inspired contours, generous typography and crop-safe margins. No fabricated app UI.

Generated with the built-in image tool on 2026-11-17. Flutter branding remains subject to its upstream trademark rights.

## Verified publication

Updated and republished on 2026-11-17 at the original URL above. Title, subtitle, authorship and publication identity were preserved. The cover is also the page's sharing image. All five images loaded successfully with captions/alternative text, and all 13 imported code blocks matched the prepared excerpts. No subscriber email/newsletter was sent.

Evidence: `published-cover.jpg`, `published-lesson.jpg`. Local application validation after checking all packages: analyze clean, 21 tests passed. All direct/development packages were current; Flutter 3.50.0 / Dart 3.14.0 now advance eight of the original nine outdated transitives; two latest versions remain blocked by exact official SDK pins. The article explains both constraints.

The archived `../medium-update.pt-BR.md` is a complete technical reference; `article.pt-BR.html` is the didactic publication source.

## App 2.0.1+3: tested overrides

The teaching source now explains exact overrides for material_color_utilities 0.13.1 and test_api 0.7.15, how resolution differs from compatibility, which checks were executed and when overrides should be removed. It distinguishes app version/build from Flutter/Dart versions.

## Editorial convention

Every student-facing article must end with exactly **five app-improvement challenges**. Put credits/references before that final section. Each challenge should name a concrete feature and a checkable acceptance criterion. Do not append a closing paragraph after the challenges. This convention was explicitly requested by the author.


## App 2.0.2+4: Android validation

The current source adds a didactic Android section: build versus device interaction, the official Flutter 3.50 Android configuration, exact build/device commands, release startup and a separate debug integration flow with six real-service/clipboard checks. Four native screenshots are archived; the address capture appears as Figure 5. Physical-phone testing, performance measurement and production signing are not claimed. The final five challenges remain the last content section. Publication evidence is recorded after republishing.
