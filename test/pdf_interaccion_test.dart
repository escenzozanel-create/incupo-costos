import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incupo_costos/models/calculo_costos.dart';
import 'package:incupo_costos/models/resultado_calculo.dart';
import 'package:incupo_costos/screens/pdf_screen.dart';
import 'package:incupo_costos/services/calculadora_service.dart';
import 'package:incupo_costos/services/pdf_service.dart';
import 'package:incupo_costos/theme/app_theme.dart';
import 'package:incupo_costos/widgets/exportar_pdf_button.dart';

import 'fixtures/caso_pan.dart';

class PdfConError extends PdfService {
  @override
  Future<Uint8List> generar({
    required CalculoCostos calculo,
    required ResultadoCalculo resultado,
    required DateTime fecha,
  }) async {
    throw StateError('Fallo interno simulado');
  }
}

void main() {
  const channel = MethodChannel('net.nfet.printing');
  testWidgets(
    'error al generar muestra mensaje y permite reintentar sin perder resultados',
    (tester) async {
      final calculo = casoPan();
      final resultado = const CalculadoraService().calcular(calculo);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.claro,
          home: Scaffold(
            body: ExportarPdfButton(
              calculo: calculo,
              resultado: resultado,
              service: PdfConError(),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Guardar o compartir PDF'));
      await tester.pumpAndSettle();
      expect(
        find.text('No se pudo generar el PDF. Intentá nuevamente.'),
        findsOneWidget,
      );
      expect(find.textContaining('Fallo interno'), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      expect(resultado.precioSugerido, closeTo(2353.6733333333336, 1e-8));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('comparte los bytes y nombre del PDF mediante el canal nativo', (
    tester,
  ) async {
    final bytes = Uint8List.fromList([37, 80, 68, 70, 45]);
    MethodCall? compartido;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'printingInfo') {
        return {'canRaster': false, 'canPrint': true, 'canShare': true};
      }
      if (call.method == 'sharePdf') {
        compartido = call;
        return 1;
      }
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PdfScreen(bytes: bytes, nombreArchivo: 'incupo-prueba.pdf'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartir'));
    await tester.pumpAndSettle();
    expect(compartido?.arguments['doc'], orderedEquals(bytes));
    expect(compartido?.arguments['name'], 'incupo-prueba.pdf');
    expect(tester.takeException(), isNull);
  });

  testWidgets('error nativo de impresión informa sin cerrar el PDF', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'printingInfo') {
        return {'canRaster': false, 'canPrint': true, 'canShare': true};
      }
      if (call.method == 'printPdf') {
        throw PlatformException(code: 'sin_impresora');
      }
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: PdfScreen(
          bytes: Uint8List.fromList([37, 80, 68, 70, 45]),
          nombreArchivo: 'incupo-prueba.pdf',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar o imprimir'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No se pudo abrir esta opción'), findsOneWidget);
    expect(find.text('Tu resumen en PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
