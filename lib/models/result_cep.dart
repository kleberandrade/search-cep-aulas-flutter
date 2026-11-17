import 'dart:convert';
import '../domain/cep.dart';

/// Immutable validated response. Empty optional fields are legitimate in ViaCEP.
final class ResultCep {
  ResultCep._(this._fields);
  final Map<String, String> _fields;

  factory ResultCep.fromJson(String source) {
    final value = jsonDecode(source);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected an address object');
    }
    return ResultCep.fromMap(value);
  }

  factory ResultCep.fromMap(Map<String, dynamic> map) {
    final fields = <String, String>{};
    for (final key in [
      'cep',
      'logradouro',
      'complemento',
      'bairro',
      'localidade',
      'uf',
      'unidade',
      'ibge',
      'gia',
      'ddd',
      'siafi',
      'estado',
      'regiao',
    ]) {
      final value = map[key];
      if (value != null && value is! String) {
        throw FormatException('Invalid $key');
      }
      fields[key] = (value as String? ?? '').trim();
    }
    fields['cep'] = Cep.parse(fields['cep']!).formatted;
    if (fields['localidade']!.isEmpty ||
        !RegExp(r'^[A-Z]{2}$').hasMatch(fields['uf']!)) {
      throw const FormatException('Missing city or state');
    }
    return ResultCep._(Map.unmodifiable(fields));
  }

  String get cep => _fields['cep']!;
  String get logradouro => _fields['logradouro']!;
  String get complemento => _fields['complemento']!;
  String get bairro => _fields['bairro']!;
  String get localidade => _fields['localidade']!;
  String get uf => _fields['uf']!;
  String get ibge => _fields['ibge']!;
  String get ddd => _fields['ddd']!;
  Map<String, String> toMap() => Map.of(_fields);
  String toJson() => jsonEncode(_fields);
}
