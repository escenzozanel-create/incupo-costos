import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/calculo_costos.dart';
import '../models/item_costo.dart';
import '../models/resultado_calculo.dart';
import '../utils/formatters.dart';

/// Presenta una instantánea ya calculada. No llama al motor, suma, divide ni
/// redondea datos de negocio. Los totales de ítem son los getters del modelo.
class PdfService {
  const PdfService();

  Future<Uint8List> generar({
    required CalculoCostos calculo,
    required ResultadoCalculo resultado,
    required DateTime fecha,
  }) async {
    final normal = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Lato-Regular.ttf'),
    );
    final negrita = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Lato-Bold.ttf'),
    );
    Future<pw.MemoryImage?> cargarLogo(List<String> rutas) async {
      for (final ruta in rutas) {
        try {
          final datos = await rootBundle.load(ruta);
          return pw.MemoryImage(
            datos.buffer.asUint8List(datos.offsetInBytes, datos.lengthInBytes),
          );
        } catch (_) {
          continue;
        }
      }
      return null;
    }

    final logo = await cargarLogo(['assets/images/incupo_logo.png']);
    final fundacion = await cargarLogo(['assets/images/fundacion_incupo.png']);
    final escuela = await cargarLogo([
      'assets/images/escuela_comercio.png',
      'assets/images/escuela_comercio.webp',
    ]);
    final doc = pw.Document(
      title: 'Calculadora de Costos - ${calculo.producto}',
      author: 'INCUPO',
      creator: 'Calculadora de Costos',
    );
    final verde = PdfColor.fromHex('#255B43');
    final claro = PdfColor.fromHex('#EDF3EC');
    final unidad = calculo.unidadProduccion;
    final unidadCantidad = unidad == 'unidad' ? 'unidades' : unidad;
    final fechaTexto =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

    pw.Widget titulo(String texto) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: verde,
        ),
      ),
    );

    pw.Widget par(String nombre, String valor) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(flex: 3, child: pw.Text(nombre)),
          pw.SizedBox(width: 12),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              valor,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    List<pw.Widget> costos(
      String nombre,
      List<ItemCosto> items,
      double total,
    ) => [
      pw.NewPage(freeSpace: 65),
      titulo(nombre),
      if (items.isEmpty)
        pw.Text('No se cargaron costos en esta categoría.')
      else
        pw.TableHelper.fromTextArray(
          headers: ['Concepto', 'Cantidad', 'Precio unitario', 'Total'],
          data: [
            for (final item in items)
              [
                item.concepto,
                numeroArgentino(item.cantidad),
                dinero(item.precioUnitario),
                dinero(item.total),
              ],
          ],
          border: null,
          headerStyle: pw.TextStyle(
            font: negrita,
            fontSize: 10,
            color: PdfColors.white,
          ),
          headerDecoration: pw.BoxDecoration(color: verde),
          cellStyle: pw.TextStyle(font: normal, fontSize: 10),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(3.2),
            1: const pw.FlexColumnWidth(1.2),
            2: const pw.FlexColumnWidth(1.8),
            3: const pw.FlexColumnWidth(1.8),
          },
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
          },
          oddRowDecoration: pw.BoxDecoration(color: claro),
        ),
      par('Total ${nombre.toLowerCase()}', dinero(total)),
    ];

    pw.Widget bloque(
      String etiqueta,
      List<pw.Widget> contenido, {
      bool destacado = false,
    }) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: destacado ? claro : null,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            etiqueta,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          ...contenido,
        ],
      ),
    );

    pw.Widget nota(String texto) =>
        pw.Text(texto, style: const pw.TextStyle(fontSize: 9));
    pw.Widget valor(String texto, {double tamano = 12}) => pw.Text(
      texto,
      style: pw.TextStyle(
        fontSize: tamano,
        fontWeight: pw.FontWeight.bold,
        color: verde,
      ),
    );
    final produccion =
        '${numeroArgentino(calculo.cantidadMensual)} $unidadCantidad';
    final equilibrio = resultado.puntoEquilibrio;
    final aproximado = equilibrio == null
        ? null
        : numeroArgentino(equilibrio.ceilToDouble())
              .replaceFirst(RegExp(r',00$'), '');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        maxPages: 1000,
        theme: pw.ThemeData.withFont(
          base: normal,
          bold: negrita,
        ).copyWith(defaultTextStyle: pw.TextStyle(font: normal, fontSize: 10)),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (logo != null) ...[
                  pw.Image(logo, width: 54, height: 22, fit: pw.BoxFit.contain),
                  pw.SizedBox(width: 8),
                ],
                pw.Text(
                  'Calculadora de Costos',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: verde,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (fundacion != null)
                  pw.Image(
                    fundacion,
                    width: 40,
                    height: 32,
                    fit: pw.BoxFit.contain,
                  ),
              ],
            ),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Fecha de emisión: $fechaTexto',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            pw.Divider(color: verde, height: 8),
          ],
        ),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  if (escuela != null) ...[
                    pw.Image(
                      escuela,
                      width: 26,
                      height: 26,
                      fit: pw.BoxFit.contain,
                    ),
                    pw.SizedBox(width: 6),
                  ],
                  pw.Expanded(
                    child: pw.Text(
                      'Desarrollado por estudiantes de 3er año de la Escuela Superior de Comercio N°43 – 2026',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'INCUPO | Cálculo orientativo mensual',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Página ${context.pageNumber} de ${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ),
        build: (_) => [
          pw.Text(
            calculo.producto,
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            'Producción mensual: ${numeroArgentino(calculo.cantidadMensual)} $unidadCantidad',
          ),
          pw.Text(
            'Ganancia esperada sobre costos: ${porcentaje(calculo.tasaGanancia)}',
          ),
          ...costos(
            'Costos variables',
            calculo.costosVariables,
            resultado.costosVariablesTotales,
          ),
          ...costos(
            'Costos fijos',
            calculo.costosFijos,
            resultado.costosFijosTotales,
          ),
          pw.NewPage(freeSpace: 90),
          titulo('Resumen del cálculo'),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(),
              1: const pw.FlexColumnWidth(),
            },
            border: pw.TableBorder.all(color: claro, width: 0.5),
            children: [
              pw.TableRow(
                children: [
                  bloque('¿Cuánto te cuesta producir?', [
                    par('Costos del mes', dinero(resultado.costoTotal)),
                    par(
                      'Costo por unidad',
                      '${dinero(resultado.costoTotalUnitario)} por $unidad',
                    ),
                    nota('Es el costo de producir $produccion durante el mes.'),
                  ]),
                  bloque('Precio sugerido de venta', [
                    valor(
                      '${dinero(resultado.precioSugerido)} por $unidad',
                      tamano: 15,
                    ),
                    pw.SizedBox(height: 3),
                    nota(
                      'Este precio cubre tus costos e incluye el ${porcentaje(calculo.tasaGanancia)} de ganancia que elegiste.',
                    ),
                    pw.SizedBox(height: 3),
                    nota(
                      resultado.gananciaEstimadaSobreCosto == null
                          ? resultado.motivoGananciaNoDisponible!
                          : 'Ganancia proyectada: ${porcentaje(resultado.gananciaEstimadaSobreCosto!)} sobre costos.',
                    ),
                  ], destacado: true),
                ],
              ),
              pw.TableRow(
                children: [
                  bloque('Si vendés toda tu producción', [
                    nota(
                      'Si vendés los $produccion del mes al precio sugerido:',
                    ),
                    par(
                      'Ingresos mensuales · Ingresarías',
                      dinero(resultado.ventasEstimadas),
                    ),
                    par(
                      'Utilidad mensual estimada',
                      dinero(resultado.utilidad),
                    ),
                    nota(
                      'Estos valores son estimaciones y suponen que se vende toda la producción.',
                    ),
                  ]),
                  bloque('¿Cuánto necesitás vender para cubrir tus costos?', [
                    if (equilibrio == null)
                      nota(resultado.motivoPuntoEquilibrioNoDisponible!)
                    else ...[
                      valor('Aproximadamente $aproximado $unidadCantidad'),
                      pw.SizedBox(height: 3),
                      nota(
                        '${numeroArgentino(equilibrio)} $unidadCantidad exactos',
                      ),
                      pw.SizedBox(height: 3),
                      nota(
                        'A partir de esa cantidad cubrís los costos del mes.',
                      ),
                    ],
                  ]),
                ],
              ),
            ],
          ),
          titulo('Otros datos del cálculo'),
          par(
            'Costo variable por $unidad',
            dinero(resultado.costoVariableUnitario),
          ),
          par(
            'Ganancia proyectada por $unidad',
            dinero(resultado.gananciaPorUnidad),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Los valores de ingresos y utilidad son estimaciones basadas en la producción y el precio informado. La aplicación no registra ventas reales.',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            'Los importes se muestran con dos decimales. Los cálculos conservan su precisión completa.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    return doc.save();
  }
}
