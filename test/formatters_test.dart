import 'package:flutter_test/flutter_test.dart';
import 'package:incupo_costos/utils/formatters.dart';
import 'package:incupo_costos/utils/validators.dart';

void main() {
  test('dinero, porcentajes y cantidades con formato argentino', () {
    expect(dinero(2353.6733333333336), r'$ 2.353,67');
    expect(dinero(0), r'$ 0,00');
    expect(dinero(-1234.56), r'$ -1.234,56');
    expect(porcentaje(0.04), '4,00 %');
    expect(numeroArgentino(1389.0522723160118), '1.389,05');
  });
  test('parsea coma o punto decimal sin redondear', () {
    expect(leerNumero(' 1560,25 '), 1560.25);
    expect(leerNumero('1560.25'), 1560.25);
    expect(leerNumero('0'), 0);
    expect(leerNumero('1.234'), 1.234);
    expect(leerNumero(numeroEditable(2353.6733333333336)), 2353.6733333333336);
    expect(leerNumero(numeroEditable(1e-8)), 1e-8);
    expect(leerNumero(numeroEditable(1e25)), 1e25);
  });
  test('rechaza vacíos, agrupaciones, negativos y valores no finitos', () {
    for (final texto in [
      '',
      ' ',
      '-1',
      'NaN',
      'Infinity',
      '1.560,25',
      '2,3,4',
      'abc',
      '1e400',
    ]) {
      expect(() => leerNumero(texto), throwsA(isA<ValidacionException>()));
    }
    expect(errorNumero('0', positivo: true), isNotNull);
    expect(errorNumero('0'), isNull);
    expect(obligatorio('  '), isNotNull);
  });
}
