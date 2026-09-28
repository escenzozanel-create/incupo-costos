import 'package:flutter/material.dart';

import '../state/calculo_controller.dart';
import '../utils/formatters.dart';
import '../widgets/paso_layout.dart';

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
    Map<String, String> valores,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleLarge),
          for (final e in valores.entries)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.key),
                  Text(
                    e.value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final r = controller.resultado!;
    final unidad = controller.unidadProduccion;
    final equilibrio = r.puntoEquilibrio;
    return PasoLayout(
      paso: 5,
      titulo: 'Resultados',
      atras: atras,
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Precio sugerido de venta'),
                Text(
                  controller.producto,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  dinero(r.precioSugerido),
                  key: const ValueKey('precioResultado'),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text('por $unidad'),
              ],
            ),
          ),
        ),
        _seccion(context, 'Costos', {
          'Costos variables totales': dinero(r.costosVariablesTotales),
          'Costos fijos totales': dinero(r.costosFijosTotales),
          'Costos totales': dinero(r.costoTotal),
          'Costo variable unitario':
              '${dinero(r.costoVariableUnitario)} por $unidad',
          'Costo total unitario': '${dinero(r.costoTotalUnitario)} por $unidad',
        }),
        _seccion(context, 'Ganancia', {
          'Ganancia esperada sobre costos': porcentaje(controller.tasaGanancia),
          'Ganancia por unidad': dinero(r.gananciaPorUnidad),
          'Ganancia estimada sobre costos': r.gananciaEstimadaSobreCosto == null
              ? r.motivoGananciaNoDisponible!
              : porcentaje(r.gananciaEstimadaSobreCosto!),
          'Utilidad mensual estimada': dinero(r.utilidad),
        }),
        _seccion(context, 'Ventas mensuales estimadas', {
          'Importe estimado': dinero(r.ventasEstimadas),
        }),
        const Text(
          'Este cálculo supone que vendés toda la producción mensual al precio sugerido.',
        ),
        _seccion(context, 'Punto de equilibrio', {
          'Cantidad a vender': equilibrio == null
              ? r.motivoPuntoEquilibrioNoDisponible!
              : '${numeroArgentino(equilibrio)} $unidad',
        }),
        if (equilibrio != null)
          Text(
            'Necesitás vender aproximadamente ${numeroArgentino(equilibrio)} $unidad para cubrir todos tus costos.',
          ),
        const Text(
          'Los importes se muestran con dos decimales. Los cálculos conservan su precisión completa.',
        ),
        FilledButton.icon(
          onPressed: editar,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Volver a editar'),
        ),
        OutlinedButton(onPressed: nuevo, child: const Text('Nuevo cálculo')),
      ],
    );
  }
}
