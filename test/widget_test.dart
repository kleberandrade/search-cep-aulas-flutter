import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:search_cep/main.dart';
import 'package:search_cep/services/via_cep_service.dart';
import 'package:search_cep/state/search_controller.dart' as search;

void main() {
  testWidgets('empty, invalid, loading, address and clear are usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pending = Completer<http.Response>();
    final controller = search.SearchController(
      ViaCepService(MockClient((_) => pending.future)),
    );
    await tester.pumpWidget(CepApp(controller: controller));
    expect(find.text('Seu próximo destino começa aqui'), findsOneWidget);
    await tester.tap(find.text('Buscar endereço'));
    await tester.pump();
    expect(
      find.textContaining('Informe um CEP com 8 dígitos.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), '01001-000');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(find.text('Consultando o ViaCEP…'), findsOneWidget);
    pending.complete(
      http.Response(
        File('test/fixtures/address.json').readAsStringSync(),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Praça da Sé'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Praça da Sé'), findsOneWidget);
    semantics.dispose();
    expect(find.text('São Paulo / SP'), findsOneWidget);
    await tester.tap(find.byTooltip('Limpar CEP'));
    await tester.pump();
    expect(find.text('Seu próximo destino começa aqui'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
  testWidgets('not found allows correction and retry', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = search.SearchController(
      ViaCepService(
        MockClient(
          (request) async => http.Response(
            request.url.path.contains('00000000')
                ? '{"erro":true}'
                : File('test/fixtures/address.json').readAsStringSync(),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      ),
    );
    await tester.pumpWidget(CepApp(controller: controller));
    await tester.enterText(find.byType(TextField), '00000000');
    await tester.tap(find.text('Buscar endereço'));
    await tester.pumpAndSettle();
    expect(find.textContaining('CEP não encontrado.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '01001-000');
    await tester.tap(find.text('Buscar endereço'));
    await tester.pumpAndSettle();
    expect(find.text('01001-000'), findsWidgets);
    expect(find.text('São Paulo / SP'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
  testWidgets('narrow layout and large text do not overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final controller = search.SearchController(
      ViaCepService(
        MockClient((_) async => http.Response('{"erro":true}', 200)),
      ),
    );
    await tester.pumpWidget(CepApp(controller: controller));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
