import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/cep.dart';
import '../models/result_cep.dart';

enum FailureKind { notFound, unavailable, invalidResponse, timeout, network }

final class LookupFailure implements Exception {
  const LookupFailure(this.kind);
  final FailureKind kind;
  String get message => switch (kind) {
    FailureKind.notFound =>
      'CEP não encontrado. Confira os números e tente outro CEP.',
    FailureKind.unavailable =>
      'O ViaCEP está indisponível. Tente novamente em instantes.',
    FailureKind.invalidResponse =>
      'O serviço retornou uma resposta inválida. Tente novamente.',
    FailureKind.timeout => 'A consulta demorou demais. Tente novamente.',
    FailureKind.network =>
      'Não foi possível conectar. Verifique sua conexão e tente novamente.',
  };
}

abstract interface class AddressLookup {
  Future<ResultCep> lookup(Cep cep);
}

class ViaCepService implements AddressLookup {
  ViaCepService(this.client, {this.timeout = const Duration(seconds: 10)});
  final http.Client client;
  final Duration timeout;

  @override
  Future<ResultCep> lookup(Cep cep) async {
    try {
      final response = await client
          .get(Uri.https('viacep.com.br', '/ws/${cep.digits}/json/'))
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw const LookupFailure(FailureKind.unavailable);
      }
      return _decode(utf8.decode(response.bodyBytes), cep);
    } on TimeoutException {
      throw const LookupFailure(FailureKind.timeout);
    } on http.ClientException {
      throw const LookupFailure(FailureKind.network);
    } on FormatException {
      throw const LookupFailure(FailureKind.invalidResponse);
    }
  }

  ResultCep _decode(String body, Cep requested) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected object');
    }
    if (decoded['erro'] == true || decoded['erro'] == 'true') {
      throw const LookupFailure(FailureKind.notFound);
    }
    final address = ResultCep.fromMap(decoded);
    if (address.cep != requested.formatted) {
      throw const FormatException('Unexpected CEP');
    }
    return address;
  }
}
