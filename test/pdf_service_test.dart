import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:incupo_costos/models/calculo_costos.dart';
import 'package:incupo_costos/models/item_costo.dart';
import 'package:incupo_costos/services/calculadora_service.dart';
import 'package:incupo_costos/services/pdf_service.dart';

import 'fixtures/caso_pan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const motor = CalculadoraService();
  const pdf = PdfService();
  final casos = <String, CalculoCostos>{
    'pan': casoPan(),
    'vacio': CalculoCostos(
      producto: 'Producto sin gastos',
      cantidadMensual: 10,
      unidadProduccion: 'unidad',
      tasaGanancia: 0.04,
      costosVariables: [],
      costosFijos: [],
    ),
    'sin_equilibrio': CalculoCostos(
      producto: 'Producto al costo',
      cantidadMensual: 10,
      unidadProduccion: 'kg',
      tasaGanancia: 0,
      costosVariables: [
        const ItemCosto(
          id: 'v1',
          concepto: 'Material',
          cantidad: 1,
          precioUnitario: 100,
        ),
      ],
      costosFijos: [],
    ),
    'largo': CalculoCostos(
      producto: 'Producción artesanal de alimentos para ferias comunitarias y venta directa',
      cantidadMensual: 100,
      unidadProduccion: 'unidad',
      tasaGanancia: 0.2,
      costosVariables: List.generate(
        90,
        (i) => ItemCosto(
          id: '$i',
          concepto:
              'Insumo ${i + 1}: material de producción con descripción extensa, presentación y origen local',
          cantidad: 2,
          precioUnitario: 1500.50,
        ),
      ),
      costosFijos: [
        const ItemCosto(
          id: 'a',
          concepto: 'Amortización de bienes',
          cantidad: 1,
          precioUnitario: 25000,
        ),
      ],
    ),
  };

  for (final entry in casos.entries) {
    test('PDF válido: ${entry.key}, con resultados y fecha suministrados', () async {
      final resultado = motor.calcular(entry.value);
      final bytes = await pdf.generar(
        calculo: entry.value,
        resultado: resultado,
        fecha: DateTime(2026, 9, 28),
      );
      final estructura = latin1.decode(bytes);
      expect(estructura.startsWith('%PDF-'), isTrue);
      expect(estructura.trimRight().endsWith('%%EOF'), isTrue);
      expect(RegExp(r'/Type\s*/Catalog').hasMatch(estructura), isTrue);
      expect(RegExp(r'/Type\s*/Page\b').hasMatch(estructura), isTrue);
      final paginas = RegExp(r'/Type\s*/Page\b').allMatches(estructura).length;
      expect(paginas, entry.key == 'largo' ? greaterThan(1) : equals(1));
      expect(bytes.length, greaterThan(10000));
      final directorio = Directory('.local/pdf-qa')
        ..createSync(recursive: true);
      await File('${directorio.path}/${entry.key}.pdf').writeAsBytes(bytes);
      // La extracción independiente de texto y revisión de páginas se realiza
      // con tools/verificar_pdf.py sobre estos mismos bytes, no otro generador.
    });
  }
}
