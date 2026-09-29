import 'package:flutter/material.dart';

import '../state/calculo_controller.dart';
import '../utils/formatters.dart';
import '../widgets/paso_layout.dart';
import '../widgets/exportar_pdf_button.dart';
import '../theme/app_theme.dart';

class ResultadoScreen extends StatelessWidget {
  const ResultadoScreen({
    super.key,
    required this.controller,
    required this.atras,
    required this.editar,
    required this.nuevo,
  });
  final CalculoController controller;
  final VoidCallback atras, editar, nuevo;

  Widget _seccion(
    BuildContext context,
    String titulo,
    Map<String, String> valores, {
    String? ayuda,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(Espacios.pagina),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(titulo, style: Theme.of(context).textTheme.titleLarge),
          ),
          for (final e in valores.entries)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.key, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(e.value, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          if (ayuda != null) ...[const Divider(), Text(ayuda)],
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final r = controller.resultado!;
    final unidad = controller.unidadProduccion;
    final unidadCantidad = unidad == 'unidad' ? 'unidades' : unidad;
    final equilibrio = r.puntoEquilibrio;
    final colores = Theme.of(context).colorScheme;
    return PasoLayout(
      paso: 5,
      titulo: 'Resultados',
      atras: atras,
      children: [
        Card(
          color: colores.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(Espacios.amplio),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.producto,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text('Precio sugerido de venta'),
                const SizedBox(height: 8),
                Text(
                  dinero(r.precioSugerido),
                  key: const ValueKey('precioResultado'),
                  style: Theme.of(context).textTheme.headlineLarge
                      ?.copyWith(color: colores.onPrimaryContainer),
                ),
                Text('por $unidad'),
                const Divider(),
                Text('Ganancia por unidad: ${dinero(r.gananciaPorUnidad)}'),
              ],
            ),
          ),
        ),
        ExportarPdfButton(calculo: controller.calculo, resultado: r),
        _seccion(context, 'Costos', {
          'Costos variables totales': dinero(r.costosVariablesTotales),
          'Costos fijos totales': dinero(r.costosFijosTotales),
          'Costos totales': dinero(r.costoTotal),
          'Costo variable unitario':
              '${dinero(r.costoVariableUnitario)} por $unidad',
          'Costo total unitario': '${dinero(r.costoTotalUnitario)} por $unidad',
        }),
        _seccion(
          context,
          'Proyección mensual',
          {
            'Ventas estimadas': dinero(r.ventasEstimadas),
            'Utilidad mensual estimada': dinero(r.utilidad),
            'Ganancia esperada sobre costos': porcentaje(
              controller.tasaGanancia,
            ),
            'Ganancia estimada sobre costos':
                r.gananciaEstimadaSobreCosto == null
                ? r.motivoGananciaNoDisponible!
                : porcentaje(r.gananciaEstimadaSobreCosto!),
          },
          ayuda: 'Este cálculo supone que vendés toda la producción mensual al precio sugerido.',
        ),
        _seccion(
          context,
          'Punto de equilibrio',
          {
            'Cantidad a vender': equilibrio == null
                ? r.motivoPuntoEquilibrioNoDisponible!
                : '${numeroArgentino(equilibrio)} $unidadCantidad',
          },
          ayuda: equilibrio == null ? null : 'Necesitás vender aproximadamente esta cantidad para cubrir todos tus costos.',
        ),
        const Text(
          'Los importes se muestran con dos decimales. Los cálculos conservan su precisión completa.',
        ),
        OutlinedButton.icon(
          onPressed: editar,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar datos'),
        ),
        TextButton(onPressed: nuevo, child: const Text('Nuevo cálculo')),
      ],
    );
  }
}
