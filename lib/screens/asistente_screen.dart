import 'package:flutter/material.dart';

import '../state/calculo_controller.dart';
import 'inicio_screen.dart';
import 'producto_screen.dart';
import 'costos_screen.dart';
import 'ganancia_screen.dart';
import 'resultado_screen.dart';

class AsistenteScreen extends StatefulWidget {
  const AsistenteScreen({super.key});
  @override
  State<AsistenteScreen> createState() => _AsistenteScreenState();
}

class _AsistenteScreenState extends State<AsistenteScreen> {
  final _controller = CalculoController();
  int _paso = -1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ir(int paso) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _paso = paso);
  }

  void _atras() => _ir(_paso - 1);
  void _continuar() => _ir(_paso + 1);

  Future<void> _nuevo() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Querés iniciar un nuevo cálculo?'),
        content: const Text(
          'Los datos actuales se eliminarán de la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nuevo cálculo'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    // Cambiar de paso antes de notificar evita renderizar resultados ya borrados.
    setState(() {
      _paso = -1;
      _controller.limpiar();
    });
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: _paso < 0,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _paso >= 0) _atras();
    },
    child: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => switch (_paso) {
        -1 => InicioScreen(iniciar: () => _ir(0)),
        0 => ProductoScreen(
          key: const ValueKey('productoPaso'),
          controller: _controller,
          atras: _atras,
          continuar: _continuar,
        ),
        1 => CostosScreen(
          key: const ValueKey('variablesPaso'),
          controller: _controller,
          tipo: TipoCosto.variable,
          atras: _atras,
          continuar: _continuar,
        ),
        2 => CostosScreen(
          key: const ValueKey('fijosPaso'),
          controller: _controller,
          tipo: TipoCosto.fijo,
          atras: _atras,
          continuar: _continuar,
        ),
        3 => GananciaScreen(
          controller: _controller,
          atras: _atras,
          continuar: _continuar,
        ),
        _ => ResultadoScreen(
          controller: _controller,
          atras: _atras,
          editar: () => _ir(0),
          nuevo: _nuevo,
        ),
      },
    ),
  );
}
