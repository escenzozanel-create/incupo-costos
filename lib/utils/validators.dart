/// Error de datos apto para mostrar en un formulario, sin mensajes del runtime.
class ValidacionException implements Exception {
  const ValidacionException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

class Validators {
  const Validators._();

  static void textoObligatorio(String valor, String nombre) {
    if (valor.trim().isEmpty) {
      throw ValidacionException('Completá $nombre.');
    }
  }

  static void noNegativo(double valor, String nombre) {
    if (!valor.isFinite || valor < 0) {
      throw ValidacionException(
        '$nombre debe ser un número finito mayor o igual a cero.',
      );
    }
  }

  static void produccion(double valor) {
    if (!valor.isFinite || valor <= 0) {
      throw const ValidacionException(
        'La cantidad producida por mes debe ser un número finito mayor que cero.',
      );
    }
  }

  static double resultadoFinito(double valor) {
    if (!valor.isFinite) {
      throw const ValidacionException(
        'Los valores ingresados son demasiado grandes o pequeños para calcular. Revisá las cantidades y los precios.',
      );
    }
    return valor;
  }
}
