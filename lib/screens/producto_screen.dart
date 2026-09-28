import 'package:flutter/material.dart';

import '../state/calculo_controller.dart';
import '../utils/formatters.dart';
import '../widgets/campo_numerico.dart';
import '../widgets/paso_layout.dart';

class ProductoScreen extends StatefulWidget {
  const ProductoScreen({
    super.key,
    required this.controller,
    required this.atras,
    required this.continuar,
  });
  final CalculoController controller;
  final VoidCallback atras, continuar;
  @override
  State<ProductoScreen> createState() => _ProductoScreenState();
}

class _ProductoScreenState extends State<ProductoScreen> {
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Form(
      key: _form,
      child: PasoLayout(
        paso: 1,
        titulo: 'Producto',
        atras: widget.atras,
        continuar: () {
          if (_form.currentState!.validate()) widget.continuar();
        },
        children: [
          const Text('Indicá cuánto producís aproximadamente en un mes.'),
          TextFormField(
            key: const ValueKey('producto'),
            initialValue: c.producto,
            decoration: const InputDecoration(labelText: 'Nombre del producto'),
            validator: obligatorio,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (v) => c.actualizarProducto(nombre: v),
          ),
          CampoNumerico(
            key: const ValueKey('produccion'),
            label: 'Cantidad producida por mes',
            initialValue: c.cantidad,
            positivo: true,
            onChanged: (v) => c.actualizarProducto(cantidad: v),
          ),
          DropdownButtonFormField<String>(
            initialValue: c.unidad,
            decoration: const InputDecoration(labelText: 'Unidad de medida'),
            items: [
              for (final u in ['kg', 'unidad', 'litro', 'docena', 'otra'])
                DropdownMenuItem(value: u, child: Text(u)),
            ],
            onChanged: (v) {
              if (v != null) c.actualizarProducto(unidad: v);
            },
          ),
          if (c.unidad == 'otra')
            TextFormField(
              key: const ValueKey('otraUnidad'),
              initialValue: c.otraUnidad,
              decoration: const InputDecoration(labelText: 'Escribí la unidad'),
              validator: obligatorio,
              onChanged: (v) => c.actualizarProducto(otraUnidad: v),
            ),
        ],
      ),
    );
  }
}
