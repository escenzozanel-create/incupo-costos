import 'package:flutter/material.dart';

import '../state/calculo_controller.dart';
import '../utils/validators.dart';
import '../widgets/campo_numerico.dart';
import '../widgets/paso_layout.dart';

class GananciaScreen extends StatefulWidget {
  const GananciaScreen({
    super.key,
    required this.controller,
    required this.atras,
    required this.continuar,
  });
  final CalculoController controller;
  final VoidCallback atras, continuar;
  @override
  State<GananciaScreen> createState() => _GananciaScreenState();
}

class _GananciaScreenState extends State<GananciaScreen> {
  final _form = GlobalKey<FormState>();
  String? _error;
  void _calcular() {
    if (!_form.currentState!.validate()) return;
    try {
      widget.controller.calcular();
      widget.continuar();
    } on ValidacionException catch (e) {
      setState(() => _error = e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: PasoLayout(
      paso: 4,
      titulo: 'Ganancia',
      atras: widget.atras,
      continuar: _calcular,
      textoContinuar: 'Ver resultados',
      children: [
        const Text(
          'El porcentaje de ganancia se agrega sobre el costo del producto.',
        ),
        CampoNumerico(
          label: 'Porcentaje de ganancia esperado',
          suffix: '%',
          initialValue: widget.controller.ganancia,
          onChanged: (v) {
            widget.controller.actualizarGanancia(v);
            setState(() => _error = null);
          },
        ),
        const Text(
          'Por ejemplo, escribí 4 para agregar un 4 %. También podés ingresar 0 %.',
        ),
        if (_error != null) Semantics(liveRegion: true, child: Text(_error!)),
      ],
    ),
  );
}
