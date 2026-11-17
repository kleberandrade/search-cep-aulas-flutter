import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:search_cep/domain/cep.dart';
import 'package:search_cep/models/result_cep.dart';
import 'package:search_cep/services/via_cep_service.dart';
import 'package:search_cep/state/search_controller.dart';

void main() {
  final fixture = File('test/fixtures/address.json').readAsStringSync();
  test(
    'model round trips every supported field without changing source data',
    () {
      final address = ResultCep.fromJson(fixture);
      expect(ResultCep.fromJson(address.toJson()).toMap(), address.toMap());
      final copy = address.toMap();
      copy['logradouro'] = 'Changed';
      expect(address.logradouro, 'Praça da Sé');
      final municipal = ResultCep.fromMap({
        'cep': '01001-000',
        'localidade': 'São Paulo',
        'uf': 'SP',
      });
      expect(municipal.logradouro, isEmpty);
      expect(municipal.bairro, isEmpty);
    },
  );
  test(
    'completion after controller disposal does not notify listeners',
    () async {
      final pending = Completer<http.Response>();
      final controller = SearchController(
        ViaCepService(MockClient((_) => pending.future)),
      );
      var notifications = 0;
      controller.addListener(() => notifications++);
      final search = controller.search('01001000');
      controller.dispose();
      pending.complete(http.Response(fixture, 200));
      await search;
      expect(notifications, 1);
    },
  );
  test('normalizes only eight digits or the standard mask', () {
    expect(Cep.parse(' 01001-000 ').digits, '01001000');
    expect(Cep.parse('01001000').formatted, '01001-000');
    for (final value in [
      '',
      '123',
      'abcdefgh',
      'a01001000',
      '0100-1000',
      '010010000',
    ]) {
      expect(() => Cep.parse(value), throwsFormatException);
    }
  });
  test('requests HTTPS with normalized CEP and decodes UTF-8', () async {
    final service = ViaCepService(
      MockClient((request) async {
        expect(
          request.url.toString(),
          'https://viacep.com.br/ws/01001000/json/',
        );
        return http.Response(
          fixture,
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    final address = await service.lookup(Cep.parse('01001-000'));
    expect(address.logradouro, 'Praça da Sé');
    expect(address.localidade, 'São Paulo');
    expect(address.toMap()['ibge'], '3550308');
  });
  for (final body in ['{"erro":true}', '{"erro":"true"}']) {
    test('treats ViaCEP not found marker $body separately', () async {
      final service = ViaCepService(
        MockClient((_) async => http.Response(body, 200)),
      );
      await expectLater(
        service.lookup(Cep.parse('00000000')),
        throwsA(
          isA<LookupFailure>().having(
            (e) => e.kind,
            'kind',
            FailureKind.notFound,
          ),
        ),
      );
    });
  }
  for (final body in [
    'oops',
    '[]',
    '{}',
    '{"cep":123}',
    '{"cep":"01001-000","localidade":"São Paulo","uf":"SP","bairro":5}',
  ]) {
    test('rejects malformed response $body', () async {
      final service = ViaCepService(
        MockClient((_) async => http.Response(body, 200)),
      );
      await expectLater(
        service.lookup(Cep.parse('01001000')),
        throwsA(
          isA<LookupFailure>().having(
            (e) => e.kind,
            'kind',
            FailureKind.invalidResponse,
          ),
        ),
      );
    });
  }
  test('rejects a response for a different CEP', () async {
    final service = ViaCepService(
      MockClient((_) async => http.Response(fixture, 200)),
    );
    await expectLater(
      service.lookup(Cep.parse('30140071')),
      throwsA(isA<LookupFailure>()),
    );
  });
  test('HTTP failure is recoverable', () async {
    final service = ViaCepService(
      MockClient((_) async => http.Response('', 503)),
    );
    await expectLater(
      service.lookup(Cep.parse('01001000')),
      throwsA(
        isA<LookupFailure>().having(
          (e) => e.kind,
          'kind',
          FailureKind.unavailable,
        ),
      ),
    );
  });
  test('network failure is recoverable', () async {
    final service = ViaCepService(
      MockClient((_) async => throw http.ClientException('offline')),
    );
    await expectLater(
      service.lookup(Cep.parse('01001000')),
      throwsA(
        isA<LookupFailure>().having((e) => e.kind, 'kind', FailureKind.network),
      ),
    );
  });
  test('timeout has its own message', () async {
    final service = ViaCepService(
      MockClient((_) => Completer<http.Response>().future),
      timeout: const Duration(milliseconds: 1),
    );
    await expectLater(
      service.lookup(Cep.parse('01001000')),
      throwsA(
        isA<LookupFailure>().having((e) => e.kind, 'kind', FailureKind.timeout),
      ),
    );
  });
  test(
    'a late response cannot overwrite a newer search or edited input',
    () async {
      final pending = <Completer<http.Response>>[];
      final controller = SearchController(
        ViaCepService(
          MockClient((_) {
            final completer = Completer<http.Response>();
            pending.add(completer);
            return completer.future;
          }),
        ),
      );
      final first = controller.search('01001000');
      final second = controller.search('00000000');
      await Future<void>.delayed(Duration.zero);
      pending[1].complete(http.Response('{"erro":true}', 200));
      await second;
      pending[0].complete(http.Response(fixture, 200));
      await first;
      expect(controller.state, isA<SearchError>());
      final third = controller.search('01001000');
      controller.inputChanged();
      await Future<void>.delayed(Duration.zero);
      pending[2].complete(http.Response(fixture, 200));
      await third;
      expect(controller.state, isA<SearchIdle>());
      controller.dispose();
    },
  );
  test('invalid input never reaches HTTP', () async {
    var calls = 0;
    final controller = SearchController(
      ViaCepService(
        MockClient((_) async {
          calls++;
          return http.Response(fixture, 200);
        }),
      ),
    );
    await controller.search('abc');
    expect(calls, 0);
    expect(controller.state, isA<SearchError>());
    controller.dispose();
  });
}
