import 'package:flutter/material.dart';

import '../models/calculo_costos.dart';
import '../models/resultado_calculo.dart';
import '../services/pdf_service.dart';
import '../screens/pdf_screen.dart';

class ExportarPdfButton extends StatefulWidget {
  const ExportarPdfButton({
    super.key,
    required this.calculo,
    required this.resultado,
    this.service = const PdfService(),
  });
  final CalculoCostos calculo;
  final ResultadoCalculo resultado;
  final PdfService service;
  @override
  State<ExportarPdfButton> createState() => _ExportarPdfButtonState();
}

class _ExportarPdfButtonState extends State<ExportarPdfButton> {
  bool _generando = false;
  Future<void> _exportar() async {
    if (_generando) return;
    setState(() => _generando = true);
    final fecha = DateTime.now();
    try {
      final bytes = await widget.service.generar(
        calculo: widget.calculo,
        resultado: widget.resultado,
        fecha: fecha,
      );
      if (!mounted) return;
      final nombre =
          'incupo-costos-${fecha.year}${fecha.month.toString().padLeft(2, '0')}${fecha.day.toString().padLeft(2, '0')}.pdf';
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PdfScreen(bytes: bytes, nombreArchivo: nombre),
        ),
      );
    } catch (error, stack) {
      debugPrint('Generación PDF: $error\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo generar el PDF. Intentá nuevamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: _generando ? null : _exportar,
    icon: _generando
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.picture_as_pdf_outlined),
    label: Text(_generando ? 'Preparando PDF…' : 'Guardar o compartir PDF'),
  );
}
