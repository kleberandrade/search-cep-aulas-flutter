// Optional live integration check. Never part of the deterministic test suite.
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:search_cep/domain/cep.dart';
import 'package:search_cep/services/via_cep_service.dart';

Future<void> main() async {
  final client = http.Client();
  try {
    final address = await ViaCepService(client).lookup(Cep.parse('01001-000'));
    if (address.localidade != 'São Paulo' || address.uf != 'SP') {
      throw StateError('Unexpected ViaCEP response: ${address.toJson()}');
    }
    stdout.writeln(
      'LIVE ViaCEP OK: ${address.cep}, ${address.localidade}/${address.uf}',
    );
  } finally {
    client.close();
  }
}
