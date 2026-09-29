import 'package:flutter/material.dart';

import '../models/item_costo.dart';
import '../utils/formatters.dart';

class ItemCostoCard extends StatelessWidget {
  const ItemCostoCard({
    super.key,
    required this.item,
    required this.total,
    required this.editar,
    required this.eliminar,
  });
  final ItemCosto item;
  final double total;
  final VoidCallback editar, eliminar;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(item.concepto, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '${numeroArgentino(item.cantidad)} × ${dinero(item.precioUnitario)}',
          ),
          const SizedBox(height: 12),
          const Text('Total'),
          Text(dinero(total), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: editar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              TextButton.icon(
                onPressed: eliminar,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
