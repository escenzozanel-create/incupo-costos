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
    pw.MemoryImage? logo;
    try {
      final datos = await rootBundle.load('assets/images/incupo_logo.png');
      logo = pw.MemoryImage(
        datos.buffer.asUint8List(datos.offsetInBytes, datos.lengthInBytes),
      );
    } catch (_) {
      logo = null;
    }
    final doc = pw.Document(
      title: 'INCUPO Costos - ${calculo.producto}',
      author: 'INCUPO',
      creator: 'INCUPO Costos',
    );
    final verde = PdfColor.fromHex('#255B43');
    final claro = PdfColor.fromHex('#EDF3EC');
    final unidad = calculo.unidadProduccion;
    final unidadCantidad = unidad == 'unidad' ? 'unidades' : unidad;
    final fechaTexto =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

    pw.Widget titulo(String texto) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 15,
          fontWeight: pw.FontWeight.bold,
          color: verde,
        ),
      ),
    );

    pw.Widget par(String nombre, String valor) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
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
      pw.NewPage(freeSpace: 90),
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
            horizontal: 8,
            vertical: 6,
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

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        maxPages: 1000,
        theme: pw.ThemeData.withFont(base: normal, bold: negrita),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (logo != null) ...[
                  pw.Image(logo, width: 64, height: 32, fit: pw.BoxFit.contain),
                  pw.SizedBox(width: 12),
                ],
                pw.Text(
                  'INCUPO Costos',
                  style: pw.TextStyle(
                    fontSize: 18,
                    color: verde,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(fechaTexto, style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Calculadora de costos para emprendedores',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Divider(color: verde),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Desarrollado por estudiantes de 3er año de la Escuela de Comercio – 2026',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.SizedBox(height: 5),
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
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Producción mensual: ${numeroArgentino(calculo.cantidadMensual)} $unidadCantidad',
          ),
          pw.Text(
            'Ganancia esperada sobre costos: ${porcentaje(calculo.tasaGanancia)}',
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: claro,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PRECIO SUGERIDO DE VENTA',
                  style: pw.TextStyle(
                    color: verde,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  '${dinero(resultado.precioSugerido)} por $unidad',
                  style: pw.TextStyle(
                    fontSize: 24,
                    color: verde,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
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
          pw.NewPage(freeSpace: 80),
          titulo('Resumen del cálculo'),
          par(
            'Costos variables totales',
            dinero(resultado.costosVariablesTotales),
          ),
          par('Costos fijos totales', dinero(resultado.costosFijosTotales)),
          par('Costo total mensual', dinero(resultado.costoTotal)),
          par(
            'Costo variable unitario',
            '${dinero(resultado.costoVariableUnitario)} por $unidad',
          ),
          par(
            'Costo total unitario',
            '${dinero(resultado.costoTotalUnitario)} por $unidad',
          ),
          par('Ganancia por unidad', dinero(resultado.gananciaPorUnidad)),
          par(
            'Precio sugerido',
            '${dinero(resultado.precioSugerido)} por $unidad',
          ),
          par('Ventas mensuales estimadas', dinero(resultado.ventasEstimadas)),
          par('Utilidad mensual estimada', dinero(resultado.utilidad)),
          if (resultado.gananciaEstimadaSobreCosto != null)
            par(
              'Ganancia proyectada sobre costos',
              porcentaje(resultado.gananciaEstimadaSobreCosto!),
            )
          else
            pw.Text(resultado.motivoGananciaNoDisponible!),
          pw.NewPage(freeSpace: 110),
          pw.Container(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                titulo('Punto de equilibrio'),
                if (resultado.puntoEquilibrio == null)
                  pw.Text(resultado.motivoPuntoEquilibrioNoDisponible!)
                else
                  pw.Text(
                    'Necesitás vender aproximadamente ${numeroArgentino(resultado.puntoEquilibrio!)} $unidadCantidad para cubrir todos tus costos.',
                  ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Las ventas y la utilidad estimadas suponen que se vende toda la producción mensual al precio sugerido.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Los importes se muestran con dos decimales. Los cálculos conservan su precisión completa.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return doc.save();
  }
}
