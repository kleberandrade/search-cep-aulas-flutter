/// Brazilian postal code: eight ASCII digits; leading zeros are significant.
final class Cep {
  const Cep._(this.digits);
  final String digits;

  factory Cep.parse(String input) {
    final value = input.trim();
    if (!RegExp(r'^[0-9]{5}-?[0-9]{3}$').hasMatch(value)) {
      throw const FormatException('Informe um CEP com 8 dígitos.');
    }
    return Cep._(value.replaceAll('-', ''));
  }

  String get formatted => '${digits.substring(0, 5)}-${digits.substring(5)}';
}
