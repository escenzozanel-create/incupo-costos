/// Un gasto del mes. El total se deriva de cantidad y precio, nunca se almacena.
class ItemCosto {
  const ItemCosto({
    required this.id,
    required this.concepto,
    required this.cantidad,
    required this.precioUnitario,
  });

  final String id;
  final String concepto;
  final double cantidad;
  final double precioUnitario;

  double get total => cantidad * precioUnitario;
}
