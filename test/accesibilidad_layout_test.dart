import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incupo_costos/main.dart';
import 'package:incupo_costos/screens/resultado_screen.dart';
import 'package:incupo_costos/state/calculo_controller.dart';
import 'package:incupo_costos/theme/app_theme.dart';
import 'package:incupo_costos/widgets/editor_costo.dart';

import 'fixtures/caso_pan.dart';

Future<void> captura(WidgetTester tester, GlobalKey key, String nombre) async {
  if (!const bool.fromEnvironment('CAPTURAR_UI')) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final imagen = await boundary.toImage(pixelRatio: 1.5);
    final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
    Directory('.local/ui-qa').createSync(recursive: true);
    await File('.local/ui-qa/$nombre.png')
        .writeAsBytes(datos!.buffer.asUint8List());
    imagen.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Lato')
      ..addFont(rootBundle.load('assets/fonts/Lato-Regular.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  testWidgets('inicio y resultados legibles en teléfono; captura de revisión', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: key, child: const IncupoApp()),
    );
    await tester.pumpAndSettle();
    await captura(tester, key, 'inicio');
    final c = CalculoController();
    addTearDown(c.dispose);
    final pan = casoPan();
    c.actualizarProducto(nombre: 'Pan casero', cantidad: '1560');
    c.actualizarGanancia('4');
    for (final item in pan.costosVariables) {
      c.guardarCosto(
        TipoCosto.variable,
        concepto: item.concepto,
        cantidad: item.cantidad,
        precioUnitario: item.precioUnitario,
      );
    }
    for (final item in pan.costosFijos) {
      c.guardarCosto(
        TipoCosto.fijo,
        concepto: item.concepto,
        cantidad: item.cantidad,
        precioUnitario: item.precioUnitario,
      );
    }
    c.calcular();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          home: ResultadoScreen(
            controller: c,
            atras: () {},
            editar: () {},
            nuevo: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await captura(tester, key, 'resultados');
    expect(find.text(r'$ 2.353,67'), findsOneWidget);
    expect(find.text('Guardar o compartir PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    '320 px con texto ampliado y teclado mantiene foco y botones accesibles',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final c = CalculoController();
      addTearDown(c.dispose);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.claro,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.6)),
              child: child!,
            ),
            home: EditorCosto(controller: c, tipo: TipoCosto.fijo),
          ),
        ),
      );
      final campo = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Concepto',
      );
      await tester.enterText(
        campo,
        'Amortización de equipamiento de producción artesanal',
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.scrollUntilVisible(
        find.text('Guardar costo'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await captura(tester, key, 'editor-pequeno');
      expect(tester.takeException(), isNull);
    },
  );
}
