import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class CampoNumerico extends StatelessWidget {
  const CampoNumerico({
    super.key,
    required this.label,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.positivo = false,
    this.suffix,
  });
  final String label;
  final String? initialValue, suffix;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool positivo;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    initialValue: controller == null ? initialValue : null,
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      helperText: 'Sin miles. Ejemplo: 1500,50',
      helperMaxLines: 2,
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textInputAction: TextInputAction.next,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (texto) => errorNumero(texto, positivo: positivo),
    onChanged: onChanged,
  );
}
