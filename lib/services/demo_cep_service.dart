import 'package:flutter/services.dart';
import '../domain/cep.dart';
import '../models/result_cep.dart';
import 'via_cep_service.dart';

/// Explicit offline classroom sample; never silently replaces live data.
final class DemoCepService implements AddressLookup {
  @override
  Future<ResultCep> lookup(Cep cep) async {
    if (cep.digits != '01001000') {
      throw const LookupFailure(FailureKind.notFound);
    }
    return ResultCep.fromJson(
      await rootBundle.loadString('assets/sao_paulo.json'),
    );
  }
}
