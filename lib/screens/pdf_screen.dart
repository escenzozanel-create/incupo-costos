import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// La misma instantánea de bytes se previsualiza, comparte e imprime.
class PdfScreen extends StatefulWidget {
  const PdfScreen({
    super.key,
    required this.bytes,
    required this.nombreArchivo,
  });
  final Uint8List bytes;
  final String nombreArchivo;
  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  bool _ocupado = false;
  Future<void> _accion(bool compartir) async {
    setState(() => _ocupado = true);
    try {
      if (compartir) {
        await Printing.sharePdf(
          bytes: widget.bytes,
          filename: widget.nombreArchivo,
        );
      } else {
        await Printing.layoutPdf(
          name: widget.nombreArchivo,
          format: PdfPageFormat.a4,
          dynamicLayout: false,
          onLayout: (_) async => widget.bytes,
        );
      }
    } catch (error, stack) {
      debugPrint('Acción PDF: $error\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo abrir esta opción. Intentá nuevamente o elegí otra forma de guardar el PDF.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tu resumen en PDF')),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PdfPreview(
              build: (_) async => widget.bytes,
              initialPageFormat: PdfPageFormat.a4,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              useActions: false,
              allowPrinting: false,
              allowSharing: false,
              pdfFileName: widget.nombreArchivo,
              loadingWidget: const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Cargando vista previa',
                ),
              ),
              onError: (context, error) {
                debugPrint('Vista previa PDF: $error');
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No se pudo mostrar la vista previa. Podés intentar compartir o guardar el documento con los botones de abajo.',
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Para guardar, elegí “Guardar como PDF” en las opciones de impresión de tu dispositivo.',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _ocupado ? null : () => _accion(true),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Compartir'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _ocupado ? null : () => _accion(false),
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Guardar o imprimir'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
