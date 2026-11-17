import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:search_cep/main.dart';

/// Optional device smoke: uses the actual ViaCEP service and Android clipboard.
/// Run separately from the deterministic unit/widget suite and CI.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android live lookup, validation, copy, clear and missing CEP', (
    tester,
  ) async {
    expect(defaultTargetPlatform, TargetPlatform.android);
    await tester.pumpWidget(const CepApp());
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('android-initial');

    final search = find.text('Buscar endereço');
    final input = find.byType(TextField);
    await tester.ensureVisible(search);
    await tester.tap(search);
    await tester.pumpAndSettle();
    final invalid = find.textContaining('Informe um CEP com 8 dígitos.');
    expect(invalid, findsOneWidget);
    await tester.ensureVisible(invalid);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('android-validation');

    await tester.ensureVisible(input);
    await tester.enterText(input, '01001-000');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(search);
    await tester.tap(search);
    await waitFor(tester, find.text('São Paulo / SP'));
    expect(find.text('Praça da Sé'), findsOneWidget);
    expect(find.text('Sé'), findsOneWidget);
    final copy = find.text('Copiar endereço');
    await tester.ensureVisible(copy);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('android-address');
    await tester.tap(copy);
    await tester.pumpAndSettle();
    expect(find.text('Endereço copiado.'), findsOneWidget);
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    expect(clipboard?.text, contains('01001-000'));
    expect(clipboard?.text, contains('Praça da Sé'));
    expect(clipboard?.text, contains('São Paulo / SP'));

    final clear = find.byTooltip('Limpar CEP');
    await tester.ensureVisible(clear);
    await tester.tap(clear);
    await tester.pumpAndSettle();
    expect(find.text('Seu próximo destino começa aqui'), findsOneWidget);
    expect(find.text('São Paulo / SP'), findsNothing);
    // Let the copy confirmation expire before capturing a different state.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.enterText(input, '00000000');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(search);
    await tester.tap(search);
    final missing = find.textContaining('CEP não encontrado.');
    await waitFor(tester, missing);
    await tester.ensureVisible(missing);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('android-not-found');
    binding.reportData!['checked'] = [
      'initial state',
      'invalid input',
      'real ViaCEP address with UTF-8',
      'real Android clipboard',
      'clear removes prior result',
      'real nonexistent CEP response',
    ];
  });
}

Future<void> waitFor(WidgetTester tester, Finder target) async {
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (target.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(
    target,
    findsOneWidget,
    reason: 'Live ViaCEP response within 30 seconds',
  );
  await tester.pumpAndSettle();
}
