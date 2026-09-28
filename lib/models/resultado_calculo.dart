/// Resultado de una división que puede no estar definida.
class ResultadoEquilibrio {
  const ResultadoEquilibrio.disponible(double this.cantidad) : motivo = null;

  const ResultadoEquilibrio.noDisponible(String this.motivo) : cantidad = null;

  final double? cantidad;
  final String? motivo;
}

/// Valores completos: el redondeo corresponde a la presentación, no al motor.
class ResultadoCalculo {
  const ResultadoCalculo({
    required this.costosVariablesTotales,
    required this.costosFijosTotales,
    required this.costoTotal,
    required this.costoVariableUnitario,
    required this.costoTotalUnitario,
    required this.gananciaPorUnidad,
    required this.precioSugerido,
    required this.ventasEstimadas,
    required this.utilidad,
    required this.gananciaEstimadaSobreCosto,
    required this.motivoGananciaNoDisponible,
    required this.aportePorUnidad,
    required this.equilibrio,
  });

  final double costosVariablesTotales;
  final double costosFijosTotales;
  final double costoTotal;
  final double costoVariableUnitario;
  final double costoTotalUnitario;
  final double gananciaPorUnidad;
  final double precioSugerido;
  final double ventasEstimadas;
  final double utilidad;
  final double? gananciaEstimadaSobreCosto;
  final String? motivoGananciaNoDisponible;
  final double aportePorUnidad;
  final ResultadoEquilibrio equilibrio;

  double? get puntoEquilibrio => equilibrio.cantidad;
  String? get motivoPuntoEquilibrioNoDisponible => equilibrio.motivo;
}
