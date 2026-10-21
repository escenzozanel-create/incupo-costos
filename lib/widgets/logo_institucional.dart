import 'package:flutter/material.dart';

class LogoInstitucional extends StatelessWidget {
  const LogoInstitucional({
    super.key,
    required this.archivo,
    required this.nombre,
    this.alternativo,
    this.alto = 120,
  });

  final String archivo;
  final String nombre;
  final String? alternativo;
  final double alto;

  @override
  Widget build(BuildContext context) {
    Widget imagen(String ruta) => Image.asset(
      ruta,
      height: alto,
      fit: BoxFit.contain,
      semanticLabel: nombre,
      errorBuilder: (_, error, stackTrace) => Text(
        nombre,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );

    return Image.asset(
      archivo,
      height: alto,
      fit: BoxFit.contain,
      semanticLabel: nombre,
      errorBuilder: (_, error, stackTrace) => alternativo != null
          ? imagen(alternativo!)
          : Text(
              nombre,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
    );
  }
}
