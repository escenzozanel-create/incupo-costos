import 'package:flutter_test/flutter_test.dart';
import 'package:incupo_costos/state/calculo_controller.dart';
import 'package:incupo_costos/utils/validators.dart';

import 'fixtures/caso_pan.dart';

void main() {
  late CalculoController c;
  setUp(() {
    c = CalculoController();
  });
  tearDown(() => c.dispose());

  void preparar() {
    c.actualizarProducto(nombre: 'Pan', cantidad: '10', unidad: 'kg');
    c.actualizarGanancia('4');
  }

  void agregar([TipoCosto tipo = TipoCosto.variable]) => c.guardarCosto(
    tipo,
    concepto: 'Insumo',
    cantidad: 2,
    precioUnitario: 100,
  );

  test('agrega, edita y elimina en categorías independientes', () {
    agregar();
    agregar(TipoCosto.fijo);
    final id = c.costos(TipoCosto.variable).single.id;
    expect(c.total(TipoCosto.variable), 200);
    c.guardarCosto(
      TipoCosto.variable,
      id: id,
      concepto: 'Harina',
      cantidad: 3,
      precioUnitario: 50,
    );
    expect(c.costos(TipoCosto.variable).single.id, id);
    expect(c.total(TipoCosto.variable), 150);
    expect(c.total(TipoCosto.fijo), 200);
    c.eliminarCosto(TipoCosto.variable, id);
    expect(c.costos(TipoCosto.variable), isEmpty);
    expect(c.total(TipoCosto.fijo), 200);
  });

  test(
    'conserva texto incompleto y unidad personalizada sin parsear al escribir',
    () {
      c.actualizarProducto(
        nombre: 'Tela',
        cantidad: '1,',
        unidad: 'otra',
        otraUnidad: 'metro',
      );
      c.actualizarGanancia('4,');
      agregar();
      expect(c.producto, 'Tela');
      expect(c.cantidad, '1,');
      expect(c.unidadProduccion, 'metro');
      expect(c.ganancia, '4,');
      c.actualizarProducto(unidad: 'kg');
      c.actualizarProducto(unidad: 'otra');
      expect(c.otraUnidad, 'metro');
    },
  );

  test('limpia todos los datos y resultados', () {
    preparar();
    agregar();
    agregar(TipoCosto.fijo);
    c.calcular();
    c.limpiar();
    expect(c.producto, isEmpty);
    expect(c.cantidad, isEmpty);
    expect(c.ganancia, isEmpty);
    expect(c.otraUnidad, isEmpty);
    expect(c.unidad, 'kg');
    expect(c.costos(TipoCosto.variable), isEmpty);
    expect(c.costos(TipoCosto.fijo), isEmpty);
    expect(c.resultado, isNull);
  });

  test('invalida resultados y recalcula después de editar o eliminar', () {
    preparar();
    agregar();
    expect(c.calcular().precioSugerido, 20.8);
    final id = c.costos(TipoCosto.variable).single.id;
    c.guardarCosto(
      TipoCosto.variable,
      id: id,
      concepto: 'Insumo',
      cantidad: 4,
      precioUnitario: 100,
    );
    expect(c.resultado, isNull);
    expect(c.calcular().precioSugerido, 41.6);
    c.actualizarProducto(cantidad: '20');
    expect(c.resultado, isNull);
    expect(c.calcular().precioSugerido, 20.8);
    c.actualizarGanancia('0');
    expect(c.resultado, isNull);
    expect(c.calcular().precioSugerido, 20);
    c.eliminarCosto(TipoCosto.variable, id);
    expect(c.resultado, isNull);
    expect(c.calcular().costoTotal, 0);
  });

  test('rechaza edición inválida sin perder el costo anterior', () {
    agregar();
    final id = c.costos(TipoCosto.variable).single.id;
    expect(
      () => c.guardarCosto(
        TipoCosto.variable,
        id: id,
        concepto: '',
        cantidad: 1,
        precioUnitario: 2,
      ),
      throwsA(isA<ValidacionException>()),
    );
    expect(c.total(TipoCosto.variable), 200);
    expect(
      () => c.guardarCosto(
        TipoCosto.fijo,
        concepto: 'Gasto',
        cantidad: 1e308,
        precioUnitario: 1e308,
      ),
      throwsA(isA<ValidacionException>()),
    );
    expect(c.costos(TipoCosto.fijo), isEmpty);
  });

  test('listas protegidas y notificaciones para la UI', () {
    var notificaciones = 0;
    c.addListener(() => notificaciones++);
    agregar();
    expect(notificaciones, 1);
    expect(() => c.costos(TipoCosto.variable).clear(), throwsUnsupportedError);
  });

  test('el controller reproduce el pan y convierte 4 una sola vez', () {
    final pan = casoPan();
    c.actualizarProducto(nombre: pan.producto, cantidad: '1560', unidad: 'kg');
    c.actualizarGanancia('4');
    for (final tipo in TipoCosto.values) {
      for (final item
          in tipo == TipoCosto.variable
              ? pan.costosVariables
              : pan.costosFijos) {
        c.guardarCosto(
          tipo,
          concepto: item.concepto,
          cantidad: item.cantidad,
          precioUnitario: item.precioUnitario,
        );
      }
    }
    expect(c.calculo.tasaGanancia, 0.04);
    final r = c.calcular();
    expect(r.precioSugerido, closeTo(2353.6733333333336, 1e-8));
    expect(r.puntoEquilibrio, closeTo(1389.0522723160118, 1e-8));
  });

  test('listas vacías válidas pero campos obligatorios no', () {
    expect(() => c.calcular(), throwsA(isA<ValidacionException>()));
    preparar();
    expect(c.calcular().costoTotal, 0);
    c.actualizarProducto(unidad: 'otra');
    expect(() => c.calcular(), throwsA(isA<ValidacionException>()));
    expect(c.resultado, isNull);
  });
}
