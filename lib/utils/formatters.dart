import 'porcentajes.dart';
import 'validators.dart';

/// Solo presentación: nunca se vuelve a usar este texto para calcular.
String numeroArgentino(double valor) {
  Validators.resultadoFinito(valor);
  final texto = (valor == 0 ? 0.0 : valor).toStringAsFixed(2);
  if (texto.contains('e')) return texto.replaceAll('.', ',');
  final partes = texto.split('.');
  final entero = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '$entero,${partes[1]}';
}

String dinero(double valor) => '\$ ${numeroArgentino(valor)}';
String porcentaje(double tasa) => '${numeroArgentino(tasaAPorcentaje(tasa))} %';

/// Sin miles: la coma o el punto son decimales, nunca se adivinan agrupaciones.
double leerNumero(String texto) {
  final limpio = texto.trim();
  if (!RegExp(r'^\d+(?:[.,]\d+)?$').hasMatch(limpio)) {
    throw const ValidacionException(
      'Ingresá un número sin separador de miles. Podés usar coma o punto decimal.',
    );
  }
  final valor = double.tryParse(limpio.replaceAll(',', '.'));
  if (valor == null || !valor.isFinite) {
    throw const ValidacionException(
      'Ingresá un número válido dentro de un rango más pequeño.',
    );
  }
  return valor;
}

String numeroEditable(double valor) {
  final texto = valor.toString();
  if (!texto.contains('e')) return texto.replaceAll('.', ',');
  // Expandir notación científica permite editar también importes muy pequeños
  // o grandes con el mismo teclado y parser, sin redondear el valor.
  final partes = texto.split('e');
  final mantisa = partes[0].split('.');
  final digitos = mantisa.join();
  final posicion = mantisa[0].length + int.parse(partes[1]);
  if (posicion <= 0) return '0,${'0' * -posicion}$digitos';
  if (posicion >= digitos.length) {
    return '$digitos${'0' * (posicion - digitos.length)}';
  }
  return '${digitos.substring(0, posicion)},${digitos.substring(posicion)}';
}

String? errorNumero(String? texto, {bool positivo = false}) {
  try {
    final valor = leerNumero(texto ?? '');
    if (positivo) {
      Validators.produccion(valor);
    } else {
      Validators.noNegativo(valor, 'El valor');
    }
    return null;
  } on ValidacionException catch (e) {
    return e.mensaje;
  }
}

String? obligatorio(String? texto) =>
    texto == null || texto.trim().isEmpty ? 'Completá este campo.' : null;
