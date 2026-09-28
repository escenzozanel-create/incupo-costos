import 'package:flutter_test/flutter_test.dart';
import 'package:incupo_costos/models/calculo_costos.dart';
import 'package:incupo_costos/models/item_costo.dart';
import 'package:incupo_costos/services/calculadora_service.dart';
import 'package:incupo_costos/utils/porcentajes.dart';
import 'package:incupo_costos/utils/validators.dart';

import 'fixtures/caso_pan.dart';

const motor = CalculadoraService();
const tolerancia = 1e-8;

CalculoCostos datos({
  String producto = 'Producto',
  String unidad = 'unidad',
  double cantidad = 10,
  double tasa = 0.04,
  List<ItemCosto> variables = const [],
  List<ItemCosto> fijos = const [],
}) => CalculoCostos(
  producto: producto,
  cantidadMensual: cantidad,
  unidadProduccion: unidad,
  tasaGanancia: tasa,
  costosVariables: variables,
  costosFijos: fijos,
);

ItemCosto item({
  double cantidad = 1,
  double precio = 100,
  String concepto = 'Gasto',
}) => ItemCosto(
  id: 'item',
  concepto: concepto,
  cantidad: cantidad,
  precioUnitario: precio,
);

void main() {
  group('Caso del pan: resultados originales sin redondear', () {
    final resultado = motor.calcular(casoPan());
    final comparaciones = <String, (double?, double)>{
      'variables E45': (resultado.costosVariablesTotales, 2383010),
      'fijos E64': (resultado.costosFijosTotales, 1147500),
      'total C73': (resultado.costoTotal, 3530510),
      'variable unitario E46': (
        resultado.costoVariableUnitario,
        1527.5705128205129,
      ),
      'total unitario C75': (resultado.costoTotalUnitario, 2263.147435897436),
      'ganancia por unidad K11': (
        resultado.gananciaPorUnidad,
        90.52589743589745,
      ),
      'precio K16': (resultado.precioSugerido, 2353.6733333333336),
      'ventas L28': (resultado.ventasEstimadas, 3671730.4000000004),
      'utilidad J36': (resultado.utilidad, 141220.40000000037),
      'ganancia relativa J38': (
        resultado.gananciaEstimadaSobreCosto,
        0.040000000000000105,
      ),
      'aporte PUNTO EQUILIBRIO D10': (
        resultado.aportePorUnidad,
        826.1028205128207,
      ),
      'equilibrio PUNTO EQUILIBRIO C13': (
        resultado.puntoEquilibrio,
        1389.0522723160118,
      ),
    };
    for (final entry in comparaciones.entries) {
      test(
        entry.key,
        () => expect(entry.value.$1, closeTo(entry.value.$2, tolerancia)),
      );
    }
    test('el precio mostrado no sustituye el precio interno', () {
      expect(
        resultado.ventasEstimadas - 2353.67 * 1560,
        closeTo(5.2, tolerancia),
      );
      expect(resultado.motivoPuntoEquilibrioNoDisponible, isNull);
      expect(resultado.motivoGananciaNoDisponible, isNull);
    });
  });

  test(
    'amortización mensual manual suma una sola vez y propaga resultados',
    () {
      final resultado = motor.calcular(casoPan(amortizacionMensual: 25000));
      expect(resultado.costosVariablesTotales, 2383010);
      expect(resultado.costosFijosTotales, 1172500);
      expect(resultado.costoTotal, 3555510);
      expect(resultado.precioSugerido, closeTo(2370.34, tolerancia));
      expect(resultado.ventasEstimadas, closeTo(3697730.4, tolerancia));
      expect(resultado.utilidad, closeTo(142220.4, tolerancia));
    },
  );

  test(
    'listas vacías son válidas; razones no definidas tienen explicación',
    () {
      final resultado = motor.calcular(datos());
      expect(resultado.costosVariablesTotales, 0);
      expect(resultado.costosFijosTotales, 0);
      expect(resultado.costoTotal, 0);
      expect(resultado.precioSugerido, 0);
      expect(resultado.ventasEstimadas, 0);
      expect(resultado.utilidad, 0);
      expect(resultado.gananciaEstimadaSobreCosto, isNull);
      expect(resultado.motivoGananciaNoDisponible, isNotEmpty);
      expect(resultado.puntoEquilibrio, isNull);
      expect(resultado.motivoPuntoEquilibrioNoDisponible, isNotEmpty);
    },
  );

  test('cantidad y precio cero en un ítem completo son válidos', () {
    final resultado = motor.calcular(
      datos(variables: [item(cantidad: 0), item(precio: 0)]),
    );
    expect(resultado.costoTotal, 0);
  });

  test('ganancia cero con costos fijos: equilibrio igual a producción', () {
    final resultado = motor.calcular(
      datos(tasa: 0, variables: [item()], fijos: [item(precio: 50)]),
    );
    expect(resultado.gananciaPorUnidad, 0);
    expect(resultado.precioSugerido, 15);
    expect(resultado.utilidad, 0);
    expect(resultado.gananciaEstimadaSobreCosto, 0);
    expect(resultado.puntoEquilibrio, 10);
  });

  test('sin costos fijos y con aporte positivo, equilibrio cero', () {
    expect(motor.calcular(datos(variables: [item()])).puntoEquilibrio, 0);
  });

  test('una categoría vacía no impide calcular la otra', () {
    final resultado = motor.calcular(datos(fijos: [item(precio: 50)]));
    expect(resultado.costosVariablesTotales, 0);
    expect(resultado.costosFijosTotales, 50);
    expect(resultado.precioSugerido, 5.2);
  });

  test('porcentaje cero sin costos fijos produce equilibrio no disponible', () {
    final resultado = motor.calcular(datos(tasa: 0, variables: [item()]));
    expect(resultado.puntoEquilibrio, isNull);
  });

  for (final precio in [100.0, 90.0, 0.0]) {
    test('equilibrio con aporte no positivo (precio $precio)', () {
      final equilibrio = motor.calcularPuntoEquilibrio(
        costosFijosTotales: 1000,
        precioSugerido: precio,
        costoVariableUnitario: 100,
      );
      expect(equilibrio.cantidad, isNull);
      expect(equilibrio.motivo, isNotEmpty);
    });
  }
  // Con las entradas permitidas y precio derivado del costo, el aporte negativo
  // no es un escenario ordinario. Se prueba la protección en la operación pura.

  test('equilibrio fraccionario conserva precisión', () {
    final resultado = motor.calcularPuntoEquilibrio(
      costosFijosTotales: 100,
      precioSugerido: 40,
      costoVariableUnitario: 10,
    );
    expect(resultado.cantidad, closeTo(3.3333333333333335, tolerancia));
  });

  test(
    '4 % se convierte una sola vez; se admiten porcentajes mayores a 100',
    () {
      expect(porcentajeATasa(4), 0.04);
      expect(tasaAPorcentaje(0.04), 4);
      final resultado = motor.calcular(
        datos(tasa: porcentajeATasa(150), variables: [item()]),
      );
      expect(resultado.precioSugerido, 25);
      expect(resultado.gananciaEstimadaSobreCosto, 1.5);
    },
  );

  for (final valor in [
    0.0,
    -1.0,
    double.nan,
    double.infinity,
    double.negativeInfinity,
  ]) {
    test('rechaza producción $valor', () {
      expect(
        () => motor.calcular(datos(cantidad: valor)),
        throwsA(isA<ValidacionException>()),
      );
    });
  }

  for (final valor in [
    -1.0,
    double.nan,
    double.infinity,
    double.negativeInfinity,
  ]) {
    test('rechaza tasa y porcentaje $valor', () {
      expect(
        () => motor.calcular(datos(tasa: valor)),
        throwsA(isA<ValidacionException>()),
      );
      expect(() => porcentajeATasa(valor), throwsA(isA<ValidacionException>()));
      expect(() => tasaAPorcentaje(valor), throwsA(isA<ValidacionException>()));
    });
    for (final fijo in [false, true]) {
      test(
        'rechaza cantidad/precio $valor en ${fijo ? 'fijos' : 'variables'}',
        () {
          for (final costo in [item(cantidad: valor), item(precio: valor)]) {
            expect(
              () => motor.calcular(
                datos(
                  variables: fijo ? [] : [costo],
                  fijos: fijo ? [costo] : [],
                ),
              ),
              throwsA(isA<ValidacionException>()),
            );
          }
        },
      );
    }
  }

  test('rechaza textos obligatorios vacíos e ítems incompletos', () {
    for (final calculo in [
      datos(producto: ' '),
      datos(unidad: ''),
      datos(variables: [item(concepto: ' ')]),
      datos(fijos: [item(concepto: '')]),
    ]) {
      expect(
        () => motor.calcular(calculo),
        throwsA(isA<ValidacionException>()),
      );
    }
  });

  test('números finitos que desbordan no producen Infinity o NaN', () {
    for (final calculo in [
      datos(variables: [item(cantidad: 1e308, precio: 1e308)]),
      datos(variables: [item(precio: 1e308), item(precio: 1e308)]),
      datos(cantidad: 1e-308, variables: [item(precio: 1e308)]),
      datos(tasa: 1e308, variables: [item(precio: 1e308)]),
    ]) {
      expect(
        () => motor.calcular(calculo),
        throwsA(isA<ValidacionException>()),
      );
    }
    expect(() => tasaAPorcentaje(1e308), throwsA(isA<ValidacionException>()));
  });

  test('equilibrio desbordado devuelve motivo', () {
    final resultado = motor.calcularPuntoEquilibrio(
      costosFijosTotales: 1e308,
      precioSugerido: 1e-308,
      costoVariableUnitario: 0,
    );
    expect(resultado.cantidad, isNull);
    expect(resultado.motivo, isNotEmpty);
  });

  test('las listas del modelo no cambian desde referencias externas', () {
    final lista = [item()];
    final calculo = datos(variables: lista);
    lista.clear();
    expect(motor.calcular(calculo).costosVariablesTotales, 100);
    expect(() => calculo.costosVariables.clear(), throwsUnsupportedError);
  });

  test(
    'nuevo cálculo usa producción e ítems actuales, sin resultados antiguos',
    () {
      expect(motor.calcular(datos(variables: [item()])).precioSugerido, 10.4);
      expect(
        motor
            .calcular(datos(cantidad: 20, variables: [item(precio: 200)]))
            .precioSugerido,
        10.4,
      );
      expect(
        motor.calcular(datos(cantidad: 20, variables: [item()])).precioSugerido,
        5.2,
      );
    },
  );
}
