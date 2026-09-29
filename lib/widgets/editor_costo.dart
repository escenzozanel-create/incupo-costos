import 'package:flutter/material.dart';

import '../models/item_costo.dart';
import '../state/calculo_controller.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import 'campo_numerico.dart';

/// Ruta propia: el teclado tiene espacio y el formulario puede desplazarse.
class EditorCosto extends StatefulWidget {
  const EditorCosto({
    super.key,
    required this.controller,
    required this.tipo,
    this.item,
  });
  final CalculoController controller;
  final TipoCosto tipo;
  final ItemCosto? item;
  @override
  State<EditorCosto> createState() => _EditorCostoState();
}

class _EditorCostoState extends State<EditorCosto> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _concepto, _cantidad, _precio;
  String? _error;

  @override
  void initState() {
    super.initState();
    _concepto = TextEditingController(text: widget.item?.concepto ?? '');
    _cantidad = TextEditingController(
      text: widget.item == null ? '' : numeroEditable(widget.item!.cantidad),
    );
    _precio = TextEditingController(
      text: widget.item == null
          ? ''
          : numeroEditable(widget.item!.precioUnitario),
    );
  }

  @override
  void dispose() {
    _concepto.dispose();
    _cantidad.dispose();
    _precio.dispose();
    super.dispose();
  }

  String get _total {
    try {
      final item = ItemCosto(
        id: '',
        concepto: _concepto.text,
        cantidad: leerNumero(_cantidad.text),
        precioUnitario: leerNumero(_precio.text),
      );
      return dinero(widget.controller.totalItem(item));
    } on ValidacionException {
      return 'Completá los datos para ver el total.';
    }
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    try {
      widget.controller.guardarCosto(
        widget.tipo,
        id: widget.item?.id,
        concepto: _concepto.text,
        cantidad: leerNumero(_cantidad.text),
        precioUnitario: leerNumero(_precio.text),
      );
      FocusScope.of(context).unfocus();
      Navigator.of(context).pop();
    } on ValidacionException catch (e) {
      setState(() => _error = e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.item == null ? 'Agregar costo' : 'Editar costo'),
    ),
    body: SafeArea(
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Cargá el gasto correspondiente a un mes. La cantidad debe usar la misma unidad que el precio.',
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _concepto,
              decoration: const InputDecoration(
                labelText: 'Concepto',
                hintText: 'Ej.: Harina o alquiler',
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              validator: obligatorio,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 20),
            CampoNumerico(
              label: 'Cantidad',
              controller: _cantidad,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 20),
            CampoNumerico(
              label: 'Precio unitario',
              controller: _precio,
              action: TextInputAction.done,
              onSubmitted: _guardar,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 24),
            Text(
              'Total: $_total',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Semantics(liveRegion: true, child: Text(_error!)),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardar,
              child: const Text('Guardar costo'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    ),
  );
}
