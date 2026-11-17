# Brazilian Postal Code Lookup

[![Flutter 3.41.9](https://img.shields.io/badge/Flutter-3.41.9-02569B)](https://docs.flutter.dev/)
[![Dart 3.11.5](https://img.shields.io/badge/Dart-3.11.5-0175C2)](https://dart.dev/)
[![License MIT](https://img.shields.io/badge/License-MIT-555555)](LICENSE)

A Flutter classroom app for looking up Brazilian postal codes through [ViaCEP](https://viacep.com.br/). It validates input, handles service failures, and presents selectable address details in a responsive Material 3 interface. No API key, Firebase project, account, or database is needed.

![Real Web app querying ViaCEP](docs/screenshots/web-address.jpg)

## Run

Verified toolchain: Flutter **3.41.9** stable with Dart **3.11.5**, Chrome 157, and Xcode 27.2 on macOS. The manifest requires Dart >=3.11.0 <4.0.0 and Flutter >=3.41.0. Use the pinned toolchain for reproducible builds; newer SDKs have not been verified.

```sh
git clone https://github.com/kleberandrade/search-cep-aulas-flutter.git
cd search-cep-aulas-flutter
flutter pub get
flutter run -d chrome
```

Enter `01001-000` or `01001000`, then press Enter or **Buscar endereço**. The examples trigger a live lookup. **Limpar CEP** clears the input/result and restores keyboard focus. **Copiar endereço** copies plain address text. Results remain selectable if clipboard access is unavailable. Empty optional fields display an explicit fallback. The interface is in Brazilian Portuguese.

To try the bundled São Paulo example without contacting ViaCEP:

```sh
flutter run -d chrome --dart-define=DEMO=true
```

Demo mode is explicitly labelled and only supports `01001-000`. Other valid codes produce “not found” in this mode. The controlled sample lives in `assets/sao_paulo.json`. Without `DEMO=true`, all searches use the real service. No silent fallback or fabricated live results are used.

## Architecture and behavior

- `lib/domain/cep.dart`: validated CEP value object. Accepts eight ASCII digits or the standard five-three mask, trims surrounding whitespace, and preserves leading zeros. Letters and other punctuation are rejected.
- `lib/models/result_cep.dart`: immutable address, strict decoding at the network boundary, optional fields normalized to empty strings. Known original fields are retained in serialization, alongside current ViaCEP fields.
- `lib/services/`: injected HTTP client and explicit demo implementation behind `AddressLookup`. HTTPS, UTF-8, a ten-second timeout, typed failures, and response CEP matching. No automatic retries or API key.
- `lib/state/search_controller.dart`: idle/loading/success/error states; each search or input edit invalidates older responses. A slow request cannot overwrite newer input. Requests may finish in the background; stale responses are ignored.
- `lib/views/home_page.dart`: input, example actions, progress/error/empty states and address presentation. Native buttons and focus, live status announcements, one-column narrow layout, and two-column wide layout.
- `lib/main.dart`: theme, Portuguese localization and resource ownership; closes its client and disposes its controller.

**Glossary:** CEP is an eight-digit Brazilian postal code; address is a validated ViaCEP response; “not found” means a valid CEP whose response contains `erro`; generation is the identity of the latest user search/edit.

No lookup history or address data is persisted. Live searches send the entered CEP to ViaCEP. The app cannot guarantee external address freshness or service availability.

## Checks and builds

```sh
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
flutter build web
# Optional integration check: contacts the actual external service
dart run tool/smoke.dart
# Native builds require the corresponding local toolchain
flutter build macos --debug
flutter build ios --no-codesign
flutter build apk --debug
```

The deterministic suite covers normalization, model serialization, valid responses, nonexistent CEP, HTTP/JSON/schema failures, response mismatch, network failure, timeout, rapid searches, edited input, disposal, local examples, and widget states/retry. Layout tests include a narrow viewport with 200% text. `http/testing.dart` and fixtures are used only in tests. The optional smoke script is a separate real ViaCEP request, excluded from CI to avoid external-service flakiness.

The workflow `.github/workflows/flutter.yml` runs formatting, analysis, tests and Web build on `master` pushes and pull requests. Version badges identify the tested SDK, not a fabricated CI or coverage result. See [validation and action log](docs/modernization-log.md) for actual outcomes and platform limitations.

For an existing Web build preview:

```sh
python3 -m http.server 8766 --bind 127.0.0.1 --directory build/web
```

Open `http://127.0.0.1:8766`. A production host must serve the generated `build/web` folder over HTTPS. No deployment is configured by this project.

## Migration from the 2019 classroom version

Dart 2 nullable mutable fields were replaced with Dart 3 null-safe immutable boundary parsing. `RaisedButton` was replaced with Material 3 buttons, raw JSON output with address fields, and static `fetchCep` with an injected service: `ViaCepService(client).lookup(Cep.parse(input))`. The HTTP client belongs to the caller, which must close it. Code using the old internal Dart API must adopt this call; this application is not a published package.

Android now uses the Flutter plugin DSL, Kotlin 2.2.20, AGP 8.11.1, Gradle 8.14 and Java 17 source compatibility; SDK levels follow the installed Flutter defaults. INTERNET permission is present in the release manifest. Android retains `com.example.search_cep` and iOS retains `com.example.searchCep`; configure signing and a production identifier before distributing your own app. Local SDK paths and generated registrants are no longer tracked.

The iOS runner uses the modern Flutter scene lifecycle; its minimum target is iOS 15. macOS minimum is 12 to match the available Xcode toolchain. Web and macOS runners were added from the installed Flutter templates. Original iOS artwork and MIT attribution are preserved. Android licenses must be accepted by the developer, never by automation. No persistent store existed before or after this migration, so no data migration is needed.

## Classroom material and credits

Original tutorial by **Kleber de Oliveira Andrade**: [Consultando CEPs com Flutter](https://medium.com/flutter-comunidade-br/consultando-ceps-com-flutter-a395b86ce34a), originally linked as [bit.ly/2kcGFQh](http://bit.ly/2kcGFQh). The original article was updated and republished in Portuguese on 2026-11-17, preserving its URL, title and authorship. It now includes a new cover, four actual application screenshots with captions/alternative text, progressive explanations, current source excerpts, checkpoints and exercises. See the [published teaching source and assets](docs/medium/README.md) and the [technical reference](docs/medium-update.pt-BR.md).

The original [form validation article by @nitishk72](https://medium.com/@nitishk72/form-validation-in-flutter-d762fbc9212c) remains a third-party historical reference. It was not edited. Useful original learning references: [themes](https://docs.flutter.dev/cookbook/design/themes), [forms](https://docs.flutter.dev/cookbook/forms), [async exceptions video](https://www.youtube.com/watch?v=qAzxZJ8NRwI), [Panache theme editor](https://rxlabz.github.io/panache/).

Updated exercises: add theme switching with `ThemeMode`; test screen readers; add clearly labelled local examples; evaluate native sharing if needed. Input validation and error handling are now implemented. Native status widgets and SnackBar replace the old Flushbar suggestion; the old `dynamic_theme` and `share` package suggestions are historical, not dependencies of this version.

MIT — Copyright 2019 Kleber de Oliveira Andrade. See [LICENSE](LICENSE). Flutter-generated platform assets and Material icons are used under their respective upstream licenses; no third-party article or image was relicensed. Screenshots in `docs/screenshots` show the real running app and repository metadata, not design mockups.
