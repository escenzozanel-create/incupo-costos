import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:incupo_costos/models/calculo_costos.dart';
import 'package:incupo_costos/models/item_costo.dart';
import 'package:incupo_costos/services/calculadora_service.dart';
import 'package:incupo_costos/services/pdf_service.dart';
import 'package:printing/printing.dart';

import '../test/asistente_test.dart' as recorrido;
import '../test/fixtures/caso_pan.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Ejecuta los recorridos existentes en Android sin modificar sus expectativas.
  recorrido.main();

  testWidgets('PDF en Android: pan, vacio, sin equilibrio y tablas largas', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final info = await Printing.info();
      expect(info.canRaster, isTrue);
      final casos = [
        casoPan(),
        CalculoCostos(
          producto: 'Sin gastos',
          cantidadMensual: 10,
          unidadProduccion: 'unidad',
          tasaGanancia: 0.04,
          costosVariables: [],
          costosFijos: [],
        ),
        CalculoCostos(
          producto: 'Sin equilibrio',
          cantidadMensual: 10,
          unidadProduccion: 'kg',
          tasaGanancia: 0,
          costosVariables: [
            const ItemCosto(
              id: 'v',
              concepto: 'Material',
              cantidad: 1,
              precioUnitario: 100,
            ),
          ],
          costosFijos: [],
        ),
        CalculoCostos(
          producto: 'Produccion con tildes: fabricación, ñ y amortización',
          cantidadMensual: 100,
          unidadProduccion: 'unidad',
          tasaGanancia: 0.2,
          costosVariables: List.generate(
            90,
            (i) => ItemCosto(
              id: '$i',
              concepto:
                  'Insumo $i con descripción extensa de producción artesanal',
              cantidad: 2,
              precioUnitario: 1500.50,
            ),
          ),
          costosFijos: [],
        ),
      ];
      const motor = CalculadoraService();
      expect(
        motor.calcular(casos.first).precioSugerido,
        closeTo(2353.6733333333336, 1e-8),
      );
      for (final caso in casos) {
        final bytes = await const PdfService().generar(
          calculo: caso,
          resultado: motor.calcular(caso),
          fecha: DateTime(2026, 9, 29),
        );
        var paginas = 0;
        // Canal nativo real: no se simula el rasterizador Android.
        await for (final pagina in Printing.raster(bytes, dpi: 72)) {
          expect(pagina.width, greaterThan(0));
          expect(pagina.height, greaterThan(0));
          expect(pagina.pixels, isNotEmpty);
          paginas++;
        }
        expect(paginas, greaterThan(0));
        if (caso.costosVariables.length == 90) {
          expect(paginas, greaterThan(1));
        }
      }
    });
    expect(tester.takeException(), isNull);
  });
}
