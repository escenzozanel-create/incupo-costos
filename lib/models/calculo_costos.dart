import 'item_costo.dart';

/// Un producto y sus gastos mensuales. No persiste información.
class CalculoCostos {
  CalculoCostos({
    required this.producto,
    required this.cantidadMensual,
    required this.unidadProduccion,
    required this.tasaGanancia,
    required List<ItemCosto> costosVariables,
    required List<ItemCosto> costosFijos,
  }) : costosVariables = List.unmodifiable(costosVariables),
       costosFijos = List.unmodifiable(costosFijos);

  final String producto;
  final double cantidadMensual;
  final String unidadProduccion;

  /// Fracción sobre el costo: 4 % se representa como 0.04.
  final double tasaGanancia;
  final List<ItemCosto> costosVariables;

  /// Incluye amortización manual, si se carga, como un ítem normal.
  final List<ItemCosto> costosFijos;
}
