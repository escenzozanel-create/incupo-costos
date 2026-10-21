import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/logo_institucional.dart';

class InformacionScreen extends StatelessWidget {
  const InformacionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Información institucional')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Espacios.amplio),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Espacios.maxContenido),
            child: const Column(
              children: [
                LogoInstitucional(
                  archivo: 'assets/images/fundacion_incupo.png',
                  nombre: 'Fundación INCUPO',
                ),
                SizedBox(height: 32),
                LogoInstitucional(
                  archivo: 'assets/images/escuela_comercio.png',
                  alternativo: 'assets/images/escuela_comercio.webp',
                  nombre: 'Escuela de Comercio',
                ),
                SizedBox(height: 32),
                Text(
                  'Desarrollado por estudiantes de 3er año de la Escuela de Comercio – 2026',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
