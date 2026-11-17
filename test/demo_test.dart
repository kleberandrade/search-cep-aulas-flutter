import 'package:flutter_test/flutter_test.dart';
import 'package:search_cep/domain/cep.dart';
import 'package:search_cep/services/demo_cep_service.dart';
import 'package:search_cep/services/via_cep_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('bundled demo is deterministic and reports missing examples', () async {
    final service = DemoCepService();
    final result = await service.lookup(Cep.parse('01001000'));
    expect(result.logradouro, 'Praça da Sé');
    await expectLater(
      service.lookup(Cep.parse('00000000')),
      throwsA(isA<LookupFailure>()),
    );
  });
}
