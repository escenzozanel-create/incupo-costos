# Cierre Android - INCUPO Costos 1.0

## Estado al 29/09/2026

**INCUPO Costos 1.0 técnicamente terminada (1.0.0+1).** APK generada, firmada, instalada
en Android 16 y smoke test release aprobado. No quedan pendientes bloqueantes.
El teléfono físico, el icono institucional y la impresión física no bloquean el cierre técnico.
No se modificaron fórmulas, motor, fixture de pan ni Excel. El único cambio de la app en esta etapa es su versión.

## Entorno verificado

| Componente | Resultado |
|---|---|
| Flutter / Dart | 3.47.5 stable / 3.13.4; `.local/flutter` |
| Doctor | Android toolchain correcto y todas las licencias aceptadas |
| Aviso restante | Flutter/Dart fuera del PATH; se utiliza `tools/flutter.cmd` |
| Android Studio | 2026.1.4, instalado en `C:/Program Files/Android/Android Studio` |
| SDK | `C:/Android/Sdk`, enlace al SDK físico del perfil: `C:/Users/Lenovo v15/AppData/Local/Android/Sdk` |
| Plataformas | API 36 para la app; API 34 requerida por printing |
| Herramientas | Build-Tools 36.0.0, Platform-Tools 37.0.1, Command-line Tools 22.0, NDK 28.2.13676358 |
| Java de Flutter | OpenJDK 25.0.3 incluido con Android Studio, configurado mediante `flutter config --jdk-dir` |
| Emulador | `INCUPO_API_36`, Android 16/API 36 AOSP x86_64; Emulator 37.1.11; WHPX |
| Configuración de prueba | 2 núcleos, 2048 MB de RAM, gráficos software, ejecución sin ventana |

SDK, Java, licencias y emulador ya están instalados. **No reinstalarlos** para continuar en esta PC.
Se utiliza el enlace sin espacios `C:/Android/Sdk` para evitar el aviso NDK de Flutter.
La ventana interactiva del emulador produjo un fallo de composición gráfica de Windows;
las verificaciones Android se realizaron correctamente en modo sin ventana con ADB.
Esto no es un fallo de INCUPO Costos ni afecta al APK instalado.

## Verificaciones previas

- Git comenzó limpio en `main`, sincronizado con `origin/main`.
- `flutter doctor -v`: Android toolchain correcto.
- `flutter test`: **71 pruebas originales aprobadas**.
- `flutter test integration_test/android_test.dart -d emulator-5554`: **5 pruebas aprobadas**.
- Total: **76 pruebas aprobadas**, sin eliminar ni debilitar pruebas.
- `flutter analyze`: **No issues found!**.
- `:app:validateSigningRelease`: **BUILD SUCCESSFUL**.
- No se repitió la auditoría del Excel ni se cambiaron componentes validados.

Las cinco pruebas de integración ejecutan los cuatro recorridos existentes y el canal
nativo real de rasterización de PDF: pan, listas vacías, equilibrio no disponible y 90 costos.
Las 71 originales se ejecutan con `flutter test`; las cinco de Android se ejecutan por separado.

## Firma y secretos

La clave fue creada por el usuario localmente con `tools/configurar_firma.ps1`.
Gradle localiza el keystore y utiliza la configuración release de `android/key.properties`.
La APK fue firmada correctamente; su certificado no es Android Debug.
No se imprimieron contraseñas ni se agregaron secretos al código, documentación o commits.

Archivos necesarios para volver a firmar (no versionados):

- `%LOCALAPPDATA%/INCUPO/signing/incupo-release.jks`.
- `android/key.properties`, con referencia al keystore y credenciales locales.
- Contraseña conservada por el responsable de la firma.

**Respaldar y reutilizar la misma clave en futuras actualizaciones.** No crear otra firma
para actualizar instalaciones existentes. Para configurar otro equipo, restaurar la clave
privadamente y completar `android/key.properties` a partir de su plantilla, sin compartir
credenciales por chat ni Git. El script de creación inicial no sobrescribe una clave existente.

Se verificó `.gitignore`: excluye `key.properties`, `*.jks`, `*.keystore`, APK, AAB,
configuración local, SDK y archivos de prueba. Ninguno de esos archivos está versionado.

## APK release real

`flutter build apk --release` terminó correctamente (assembleRelease, 122,7 s).
No hubo errores; aparecieron avisos de herramientas Java y source/target Java 8 de dependencias.
No se cambiaron dependencias para silenciar esos avisos.

| Propiedad | Valor verificado |
|---|---|
| Archivo | `app-release.apk` |
| Ruta relativa | `build/app/outputs/flutter-apk/app-release.apk` |
| Ruta absoluta | `C:/Users/Lenovo v15/OneDrive/Escritorio/Practicas profesionalizantes 2/incupoAPK/build/app/outputs/flutter-apk/app-release.apk` |
| Tamaño | 55.919.121 bytes, aproximadamente 53,3 MiB |
| Versión | 1.0.0, versionCode 1 |
| Nombre | INCUPO Costos |
| applicationId | `ar.org.incupo.incupo_costos` |
| Android mínimo / objetivo | API 24 / API 36 |
| Arquitecturas | armeabi-v7a, arm64-v8a, x86_64 |
| Firma | `apksigner verify --verbose`: Verifies; esquema v2 válido, un firmante |
| SHA-256 | `bdcb0239da669f81281dce82f0b35714dabb4307e8ac1afa1a4672370a13174b` |

Se verificaron las fuentes Lato Regular y Bold dentro de la APK.
`aapt dump permissions` muestra únicamente el permiso interno de firma AndroidX
`ar.org.incupo.incupo_costos.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`.
No hay permisos de internet, almacenamiento general, cámara, contactos ni ubicación.

## Instalación y smoke test de release

Se instaló exactamente `app-release.apk` con ADB (`Success`) y se abrió mediante la
actividad del launcher, sin `flutter run`. Android informa versionName 1.0.0 y no incluye
la bandera DEBUGGABLE. La app debug de integración ya no estaba instalada al iniciar
esta validación; se confirmó su ausencia antes de instalar release.

Wi-Fi y datos se desactivaron únicamente en el emulador. **Smoke test aprobado sobre
la APK release instalada**, no sobre la app debug ni un ejecutor de integración:

- Apertura independiente mediante launcher, nombre e identificador correctos.
- Producto Pan, 1560 kg/mes, ocho costos variables y cinco fijos del fixture existente.
- Amortización manual adicional: cantidad 1 e importe mensual 25.000.
- Ganancia 4 %: precio sugerido **$ 2.370,34**, verificado en pantalla.
- Volver atrás, conservar datos y cambiar ganancia a 5 %: recálculo **$ 2.393,13**.
- PDF generado offline, vista previa renderizada y selector Android de compartir abierto
  con el archivo correcto. No se envió a un destinatario externo.
- Guardado mediante impresión nativa **Save as PDF**: archivo real
  `/sdcard/Download/incupo-release-1.0.pdf`, **23.691 bytes, dos páginas**.
- Verificación independiente del PDF con pypdf y renderizado PyMuPDF: Lato Regular/Bold
  embebidas, tildes y caracteres españoles, tablas completas, subtotales, precio,
  ganancias, proyección mensual, equilibrio y aclaraciones. Ambas páginas revisadas
  visualmente, sin cortes ni superposiciones.
- PDF final: variables **$ 2.383.010,00**, fijos **$ 1.172.500,00**, total **$ 3.555.510,00**,
  ventas **$ 3.733.285,50**, utilidad **$ 177.775,50**, equilibrio **1.354,61 kg**.
- Nuevo cálculo con confirmación: nombre y producción vacíos; listas de variables y
  fijos sin ítems y totales cero; porcentaje de ganancia vacío.

No se redondearon entradas ni operaciones intermedias. No hubo fallos que requirieran
correcciones en motor, controller, UI o PdfService. La impresión física y la recepción
en aplicaciones de mensajería no se probaron por falta de esos recursos; el selector
Android y el guardado local sí se verificaron.

Evidencias locales (excluidas de Git): `.local/android-setup/final-*.log`,
`release-smoke.log`, capturas y el PDF guardado desde la APK release.

## Reproducir compilación y verificación

Desde la raíz, con la firma local ya disponible:

```powershell
.\tools\flutter.cmd pub get
.\tools\flutter.cmd doctor -v
.\tools\flutter.cmd test
.\tools\flutter.cmd analyze
.\tools\flutter.cmd build apk --release
```

Pruebas Android con emulador iniciado:

```powershell
.\tools\flutter.cmd devices
.\tools\flutter.cmd test integration_test/android_test.dart -d emulator-5554
```

Usar el ID real que muestre devices. Las pruebas de integración instalan un ejecutor de
pruebas debug; para validar distribución, reinstalar después la APK release.
En esta máquina se limitó Gradle a 2 GB y dos workers mediante `GRADLE_OPTS` solo en los
comandos de la sesión, sin modificar la configuración global ni la del proyecto.

Para verificar o instalar el archivo generado:

```powershell
& C:\Android\Sdk\build-tools\36.0.0\apksigner.bat verify --verbose build/app/outputs/flutter-apk/app-release.apk
& C:\Android\Sdk\platform-tools\adb.exe -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk
```

Si hay una app debug firmada con otra clave, exportar cualquier cálculo que se desee
conservar y desinstalar esa app antes de instalar release. Las actualizaciones release
conservan el mismo applicationId y deben usar la misma clave, con versionCode aumentado.

## Próximos requisitos y pendientes no bloqueantes

- **Validación física en teléfono real pendiente.** Android 7 o superior, cable de datos,
  opciones de desarrollador, depuración USB y autorización RSA de esta computadora.
  Instalar la APK, abrirla desde su icono y repetir cálculo, recálculo, PDF, compartir,
  guardar, nuevo cálculo, teclado, scroll y uso sin conexión.
- **Icono oficial pendiente de recurso gráfico institucional.** Se conserva el icono
  temporal de Flutter; no se inventó una marca ni se bloqueó el release por ello.
- Impresión física pendiente: requiere impresora y servicio Android disponibles.
  Guardar como PDF no requiere impresora.
- Para recibir el PDF en mensajería u otro servicio, usar una aplicación destinataria
  instalada en el teléfono; el emulador AOSP permite verificar el selector del sistema.

Para instalar manualmente, transferir `app-release.apk` al teléfono, permitir instalación
desde esa fuente cuando Android lo solicite, instalar y abrir INCUPO Costos desde el icono.
No hace falta instalar SDK, Android Studio, Flutter ni Java en el teléfono.
