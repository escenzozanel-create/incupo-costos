import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incupo_costos/main.dart';

Future<void> tocar(WidgetTester tester, String texto) async {
  final finder = find.text(texto).last;
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> escribir(
  WidgetTester tester,
  String etiqueta,
  String texto,
) async {
  final finder = find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.labelText == etiqueta,
  );
  await tester.ensureVisible(finder);
  await tester.enterText(finder, texto);
  await tester.pump();
}

Future<void> iniciar(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const IncupoApp());
  await tocar(tester, 'Iniciar cálculo');
}

Future<void> producto(WidgetTester tester) async {
  await escribir(tester, 'Nombre del producto', 'Pan casero');
  await escribir(tester, 'Cantidad producida por mes', '10');
  await tocar(tester, 'Continuar');
}

void main() {
  testWidgets(
    'unidad personalizada y edición desde resultados conservan el producto',
    (tester) async {
      await iniciar(tester);
      await escribir(tester, 'Nombre del producto', 'Tela');
      await escribir(tester, 'Cantidad producida por mes', '12,5');
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tocar(tester, 'otra');
      await tocar(tester, 'Continuar');
      expect(find.text('Completá este campo.'), findsOneWidget);
      await escribir(tester, 'Escribí la unidad', 'metro');
      await tocar(tester, 'Continuar');
      await tocar(tester, 'Continuar');
      await tocar(tester, 'Continuar');
      await escribir(tester, 'Porcentaje de ganancia esperado', '150');
      await tocar(tester, 'Ver resultados');
      expect(find.text('por metro'), findsOneWidget);
      expect(find.text('150,00 %'), findsOneWidget);
      await tocar(tester, 'Editar datos');
      expect(find.widgetWithText(TextFormField, 'Tela'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '12,5'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'metro'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'flujo móvil completo, editar, recalcular y reiniciar con confirmación',
    (tester) async {
      await iniciar(tester);
      await producto(tester);
      await tocar(tester, 'Agregar costo variable');
      await escribir(tester, 'Concepto', 'Harina');
      await escribir(tester, 'Cantidad', '2');
      await escribir(tester, 'Precio unitario', '100');
      await tocar(tester, 'Guardar costo');
      expect(find.text('Total de costos variables: \$ 200,00'), findsOneWidget);
      await tocar(tester, 'Continuar');
      await tocar(tester, 'Agregar costo fijo');
      await escribir(tester, 'Concepto', 'Amortización de bienes');
      await escribir(tester, 'Cantidad', '1');
      await escribir(tester, 'Precio unitario', '50');
      await tocar(tester, 'Guardar costo');
      await tocar(tester, 'Continuar');
      await escribir(tester, 'Porcentaje de ganancia esperado', '4');
      await tocar(tester, 'Ver resultados');
      expect(find.text(r'$ 26,00'), findsOneWidget);
      await tocar(tester, 'Atrás');
      expect(find.widgetWithText(TextFormField, '4'), findsOneWidget);
      await tocar(tester, 'Atrás');
      expect(find.text('Amortización de bienes'), findsOneWidget);
      await tocar(tester, 'Atrás');
      await tocar(tester, 'Editar');
      await escribir(tester, 'Cantidad', '3');
      await tocar(tester, 'Guardar costo');
      await tocar(tester, 'Continuar');
      await tocar(tester, 'Continuar');
      await tocar(tester, 'Ver resultados');
      expect(find.text(r'$ 36,40'), findsOneWidget);
      await tocar(tester, 'Nuevo cálculo');
      await tocar(tester, 'Cancelar');
      expect(find.text('Paso 5 de 5 · Resultados'), findsOneWidget);
      await tocar(tester, 'Nuevo cálculo');
      await tocar(tester, 'Nuevo cálculo');
      expect(find.text('Iniciar cálculo'), findsOneWidget);
      await tocar(tester, 'Iniciar cálculo');
      final campo = tester.widget<TextField>(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Nombre del producto',
        ),
      );
      expect(campo.controller!.text, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'errores visibles, atrás del sistema conserva borrador, listas vacías y equilibrio no disponible',
    (tester) async {
      await iniciar(tester);
      await tocar(tester, 'Continuar');
      expect(find.text('Completá este campo.'), findsOneWidget);
      await escribir(tester, 'Nombre del producto', 'Prueba');
      await escribir(tester, 'Cantidad producida por mes', '0');
      await tocar(tester, 'Continuar');
      expect(find.textContaining('mayor que cero'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tocar(tester, 'Iniciar cálculo');
      expect(find.widgetWithText(TextFormField, 'Prueba'), findsOneWidget);
      await escribir(tester, 'Cantidad producida por mes', '1,5');
      await tocar(tester, 'Continuar');
      await tocar(tester, 'Continuar');
      await tocar(tester, 'Continuar');
      await escribir(tester, 'Porcentaje de ganancia esperado', '0');
      await tocar(tester, 'Ver resultados');
      expect(find.byKey(const ValueKey('precioResultado')), findsOneWidget);
      expect(find.textContaining('el precio debe superar'), findsOneWidget);
      expect(find.textContaining('costo total es cero'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'editor incompleto no guarda; cancelar y eliminar no dejan gastos fantasma',
    (tester) async {
      await iniciar(tester);
      await producto(tester);
      await tocar(tester, 'Agregar costo variable');
      await tocar(tester, 'Guardar costo');
      expect(find.text('Completá este campo.'), findsOneWidget);
      await tocar(tester, 'Cancelar');
      expect(find.text('Total de costos variables: \$ 0,00'), findsOneWidget);
      await tocar(tester, 'Agregar costo variable');
      await escribir(tester, 'Concepto', 'Gasto');
      await escribir(tester, 'Cantidad', '1');
      await escribir(tester, 'Precio unitario', '100');
      await tocar(tester, 'Guardar costo');
      await tocar(tester, 'Eliminar');
      await tocar(tester, 'Cancelar');
      expect(find.text('Gasto'), findsOneWidget);
      await tocar(tester, 'Eliminar');
      await tocar(tester, 'Eliminar');
      expect(find.text('Gasto'), findsNothing);
      expect(find.text('Total de costos variables: \$ 0,00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
