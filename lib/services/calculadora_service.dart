import '../models/calculo_costos.dart';
import '../models/item_costo.dart';
import '../models/resultado_calculo.dart';
import '../utils/validators.dart';

/// Motor Dart puro. Trazabilidad de fórmulas: docs/analisis_excel.md.
class CalculadoraService {
  const CalculadoraService();

  ResultadoCalculo calcular(CalculoCostos calculo) {
    Validators.textoObligatorio(calculo.producto, 'el nombre del producto');
    Validators.textoObligatorio(
      calculo.unidadProduccion,
      'la unidad del producto',
    );
    Validators.produccion(calculo.cantidadMensual);
    Validators.noNegativo(calculo.tasaGanancia, 'La tasa de ganancia');

    final variables = sumarCostos(calculo.costosVariables);
    final fijos = sumarCostos(calculo.costosFijos);
    final total = Validators.resultadoFinito(variables + fijos);
    final variableUnitario = Validators.resultadoFinito(
      variables / calculo.cantidadMensual,
    );
    final totalUnitario = Validators.resultadoFinito(
      total / calculo.cantidadMensual,
    );
    final gananciaUnidad = Validators.resultadoFinito(
      totalUnitario * calculo.tasaGanancia,
    );
    final precio = Validators.resultadoFinito(totalUnitario + gananciaUnidad);
    // El Excel supone la venta de toda la producción al precio completo.
    final ventas = Validators.resultadoFinito(calculo.cantidadMensual * precio);
    final utilidad = Validators.resultadoFinito(ventas - total);
    final gananciaRelativa = total == 0
        ? null
        : Validators.resultadoFinito(utilidad / total);
    final aporte = Validators.resultadoFinito(precio - variableUnitario);

    return ResultadoCalculo(
      costosVariablesTotales: variables,
      costosFijosTotales: fijos,
      costoTotal: total,
      costoVariableUnitario: variableUnitario,
      costoTotalUnitario: totalUnitario,
      gananciaPorUnidad: gananciaUnidad,
      precioSugerido: precio,
      ventasEstimadas: ventas,
      utilidad: utilidad,
      gananciaEstimadaSobreCosto: gananciaRelativa,
      motivoGananciaNoDisponible: total == 0
          ? 'No se puede calcular el porcentaje de ganancia sobre costos porque el costo total es cero.'
          : null,
      aportePorUnidad: aporte,
      equilibrio: calcularPuntoEquilibrio(
        costosFijosTotales: fijos,
        precioSugerido: precio,
        costoVariableUnitario: variableUnitario,
      ),
    );
  }

  /// No modifica la fórmula para devolver un equilibrio ficticio de cero.
  ResultadoEquilibrio calcularPuntoEquilibrio({
    required double costosFijosTotales,
    required double precioSugerido,
    required double costoVariableUnitario,
  }) {
    Validators.noNegativo(costosFijosTotales, 'Los costos fijos');
    Validators.noNegativo(precioSugerido, 'El precio sugerido');
    Validators.noNegativo(costoVariableUnitario, 'El costo variable unitario');
    final aporte = Validators.resultadoFinito(
      precioSugerido - costoVariableUnitario,
    );
    if (aporte <= 0) {
      return const ResultadoEquilibrio.noDisponible(
        'No se puede calcular el punto de equilibrio: el precio debe superar el costo variable por unidad.',
      );
    }
    final cantidad = costosFijosTotales / aporte;
    if (!cantidad.isFinite) {
      return const ResultadoEquilibrio.noDisponible(
        'El punto de equilibrio es demasiado grande para calcularlo con estos datos.',
      );
    }
    return ResultadoEquilibrio.disponible(cantidad);
  }

  /// Reutiliza la misma validación y suma para los subtotales del asistente.
  double sumarCostos(List<ItemCosto> items) {
    var suma = 0.0;
    for (final item in items) {
      Validators.textoObligatorio(item.concepto, 'el concepto de cada costo');
      Validators.noNegativo(item.cantidad, 'La cantidad de ${item.concepto}');
      Validators.noNegativo(
        item.precioUnitario,
        'El precio de ${item.concepto}',
      );
      suma = Validators.resultadoFinito(
        suma + Validators.resultadoFinito(item.total),
      );
    }
    return suma;
  }
}
