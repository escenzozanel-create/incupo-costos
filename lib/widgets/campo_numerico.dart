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
    this.action = TextInputAction.next,
    this.onSubmitted,
  });
  final String label;
  final String? initialValue, suffix;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool positivo;
  final TextInputAction action;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    initialValue: controller == null ? initialValue : null,
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      helperText: 'Sin miles. Ejemplo: 1500,50',
      helperMaxLines: 2,
      hintText: positivo ? 'Ej.: 1560' : 'Ej.: 1500,50',
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textInputAction: action,
    onFieldSubmitted: (_) {
      if (action == TextInputAction.next) {
        FocusScope.of(context).nextFocus();
      } else {
        FocusScope.of(context).unfocus();
        onSubmitted?.call();
      }
    },
    onTapOutside: (_) => FocusScope.of(context).unfocus(),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (texto) => errorNumero(texto, positivo: positivo),
    onChanged: onChanged,
  );
}
