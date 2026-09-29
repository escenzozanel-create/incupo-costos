import 'package:flutter/material.dart';

import '../models/item_costo.dart';
import '../state/calculo_controller.dart';
import '../utils/formatters.dart';
import '../widgets/editor_costo.dart';
import '../widgets/item_costo_card.dart';
import '../widgets/paso_layout.dart';

/// Una sola pantalla parametrizada evita duplicar variables y fijos.
class CostosScreen extends StatelessWidget {
  const CostosScreen({
    super.key,
    required this.controller,
    required this.tipo,
    required this.atras,
    required this.continuar,
  });
  final CalculoController controller;
  final TipoCosto tipo;
  final VoidCallback atras, continuar;

  void _editar(BuildContext context, [ItemCosto? item]) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              EditorCosto(controller: controller, tipo: tipo, item: item),
        ),
      );

  Future<void> _eliminar(BuildContext context, ItemCosto item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar costo'),
        content: Text('¿Querés eliminar “${item.concepto}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true) controller.eliminarCosto(tipo, item.id);
  }

  @override
  Widget build(BuildContext context) {
    final variable = tipo == TipoCosto.variable;
    final plural = variable ? 'variables' : 'fijos';
    return PasoLayout(
      paso: variable ? 2 : 3,
      titulo: 'Costos $plural',
      atras: atras,
      continuar: continuar,
      children: [
        Text(
          variable
              ? 'Son los gastos que aumentan o disminuyen según cuánto producís.'
              : 'Son los gastos que tenés aunque no produzcas.',
        ),
        const Text(
          'Usá importes del mes. No cargues el mismo gasto en ambas categorías.',
        ),
        if (!variable)
          const Text(
            'Ejemplos: alquiler, servicios, remuneraciones o amortización de bienes. La amortización es manual: cantidad 1 y precio igual al importe mensual.',
          ),
        if (controller.costos(tipo).isEmpty)
          const Text(
            'Todavía no agregaste costos. Si no tenés gastos en esta categoría, podés continuar.',
          ),
        for (final item in controller.costos(tipo))
          ItemCostoCard(
            key: ValueKey(item.id),
            item: item,
            total: controller.totalItem(item),
            editar: () => _editar(context, item),
            eliminar: () => _eliminar(context, item),
          ),
        OutlinedButton.icon(
          onPressed: () => _editar(context),
          icon: const Icon(Icons.add),
          label: Text(
            variable ? 'Agregar costo variable' : 'Agregar costo fijo',
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Total de costos $plural: ${dinero(controller.total(tipo))}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
