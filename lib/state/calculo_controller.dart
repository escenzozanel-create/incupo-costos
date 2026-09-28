import 'package:flutter/foundation.dart';

import '../models/calculo_costos.dart';
import '../models/item_costo.dart';
import '../models/resultado_calculo.dart';
import '../services/calculadora_service.dart';
import '../utils/formatters.dart';
import '../utils/porcentajes.dart';

enum TipoCosto { variable, fijo }

/// Conserva texto sin validar mientras se escribe; solo construye el modelo al
/// calcular. Así volver atrás no pierde entradas incompletas ni decimales.
class CalculoController extends ChangeNotifier {
  CalculoController([this._service = const CalculadoraService()]);

  final CalculadoraService _service;
  String _producto = '',
      _cantidad = '',
      _unidad = 'kg',
      _otraUnidad = '',
      _ganancia = '';
  final List<ItemCosto> _variables = [], _fijos = [];
  int _secuencia = 0;
  ResultadoCalculo? _resultado;

  String get producto => _producto;
  String get cantidad => _cantidad;
  String get unidad => _unidad;
  String get otraUnidad => _otraUnidad;
  String get unidadProduccion =>
      _unidad == 'otra' ? _otraUnidad.trim() : _unidad;
  String get ganancia => _ganancia;
  double get tasaGanancia => porcentajeATasa(leerNumero(_ganancia));
  ResultadoCalculo? get resultado => _resultado;
  List<ItemCosto> costos(TipoCosto tipo) => List.unmodifiable(_lista(tipo));
  List<ItemCosto> _lista(TipoCosto tipo) =>
      tipo == TipoCosto.variable ? _variables : _fijos;

  void actualizarProducto({
    String? nombre,
    String? cantidad,
    String? unidad,
    String? otraUnidad,
  }) {
    _producto = nombre ?? _producto;
    _cantidad = cantidad ?? _cantidad;
    _unidad = unidad ?? _unidad;
    _otraUnidad = otraUnidad ?? _otraUnidad;
    _invalidar();
  }

  void actualizarGanancia(String texto) {
    _ganancia = texto;
    _invalidar();
  }

  double total(TipoCosto tipo) => _service.sumarCostos(_lista(tipo));
  double totalItem(ItemCosto item) => _service.sumarCostos([item]);

  void guardarCosto(
    TipoCosto tipo, {
    String? id,
    required String concepto,
    required double cantidad,
    required double precioUnitario,
  }) {
    final item = ItemCosto(
      id: id ?? 'costo-${_secuencia++}',
      concepto: concepto.trim(),
      cantidad: cantidad,
      precioUnitario: precioUnitario,
    );
    final lista = _lista(tipo);
    final nuevos = [...lista];
    if (id == null) {
      nuevos.add(item);
    } else {
      final indice = nuevos.indexWhere((c) => c.id == id);
      if (indice < 0) throw StateError('El costo ya no existe.');
      nuevos[indice] = item;
    }
    // Validar antes de mutar: un error no destruye el ítem anterior.
    _service.sumarCostos(nuevos);
    lista
      ..clear()
      ..addAll(nuevos);
    _invalidar();
  }

  void eliminarCosto(TipoCosto tipo, String id) {
    _lista(tipo).removeWhere((c) => c.id == id);
    _invalidar();
  }

  CalculoCostos get calculo => CalculoCostos(
    producto: _producto.trim(),
    cantidadMensual: leerNumero(_cantidad),
    unidadProduccion: unidadProduccion,
    tasaGanancia: tasaGanancia,
    costosVariables: _variables,
    costosFijos: _fijos,
  );

  ResultadoCalculo calcular() {
    _resultado = null;
    final resultado = _service.calcular(calculo);
    _resultado = resultado;
    notifyListeners();
    return resultado;
  }

  void limpiar() {
    _producto = _cantidad = _otraUnidad = _ganancia = '';
    _unidad = 'kg';
    _variables.clear();
    _fijos.clear();
    _secuencia = 0;
    _invalidar();
  }

  void _invalidar() {
    _resultado = null;
    notifyListeners();
  }
}
