import 'validators.dart';

/// Conversión en el límite del formulario: 4 -> 0.04.
double porcentajeATasa(double porcentaje) {
  Validators.noNegativo(porcentaje, 'El porcentaje de ganancia');
  return porcentaje / 100;
}

/// Conversión para presentación: 0.04 -> 4. Sin redondear.
double tasaAPorcentaje(double tasa) {
  Validators.noNegativo(tasa, 'La tasa de ganancia');
  return Validators.resultadoFinito(tasa * 100);
}
