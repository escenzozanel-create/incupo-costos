# Preparación Android y registro de validación

## Estado al 29/09/2026

Esta etapa está **pendiente de entorno y pruebas físicas**, no es una entrega 1.0.
El usuario confirmó que Android Studio y el SDK no están instalados.

| Componente o verificación | Resultado |
|---|---|
| Flutter / Dart | 3.47.5 stable / 3.13.4; SDK local `.local/flutter` |
| `flutter doctor -v` | Android toolchain: `Unable to locate Android SDK`; Flutter/Dart fuera del PATH |
| Android Studio | No instalado, confirmado por el usuario |
| SDK / Platform / Build Tools / Platform Tools / Command-line Tools | No instalados; no hay ruta SDK configurada |
| Licencias | Pendientes; no se ejecutó aceptación porque falta SDK |
| Java | PATH: Oracle Java 24.0.1; JDK en `C:/Program Files/Java/jdk-24`; JAVA_HOME no definido |
| Java de Flutter | Doctor no informa JDK Android al faltar SDK; volver a comprobar tras instalar Studio |
| Dispositivos | `flutter devices`: Windows, Chrome y Edge; ningún Android detectado |
| Emuladores | `flutter emulators`: sin fuentes de emuladores |
| Pruebas | 71 aprobadas en esta revisión |
| `flutter analyze` | Sin observaciones (`No issues found!`) |
| Compilación debug | No ejecutada: falta SDK |
| Firma | Configuración externa preparada; sin keystore ni credenciales creadas; pendiente de compilar |
| Release / ruta real / tamaño | No generada; no hay artefacto ni tamaño que informar |
| Instalación / smoke test | Pendientes |
| Dispositivo real, PDF nativo, pantalla y offline | No probados; no se atribuyen resultados físicos a tests de widgets |

El nombre Android existente **INCUPO Costos** se conserva en `android/app/src/main/AndroidManifest.xml`.
El `applicationId`, namespace y paquete de MainActivity ya coinciden en
`ar.org.incupo.incupo_costos`; no se cambian. No hay un logo oficial en los recursos:
se conserva temporalmente el icono de la plantilla Flutter, reemplazable en las carpetas
`android/app/src/main/res/mipmap-*`. Su apariencia instalada está pendiente.

El manifest principal no declara permisos de internet ni almacenamiento. Debug y
profile conservan INTERNET para las herramientas Flutter. Al compilar, revisar también
el manifest fusionado de release (incluye dependencias). No se agregaron permisos.
El motor y las fuentes del PDF son locales; la comprobación en modo avión sigue pendiente.
No se modificaron la lógica matemática, los tests existentes ni el Excel.
SHA-256 verificado: `1f06ff91b8b4803d751a500dae819183eaaf022937de40dfe59b108ae0db3001`.

## Instalar el entorno

1. Instalar [Android Studio](https://developer.android.com/studio) y completar su asistente inicial.
2. Abrir **More Actions > SDK Manager** (o **Tools > SDK Manager**). Anotar la ruta real de **Android SDK Location**.
3. Instalar Android SDK Platform **API 36**, usada por este Flutter local; en SDK Tools instalar Build-Tools, Platform-Tools y Command-line Tools. El proyecto pide NDK **28.2.13676358**; instalar esa versión desde Show Package Details si no está disponible. Seguir cualquier requisito adicional de la compilación sin cambiar versiones al azar.
4. No es necesario instalar un emulador para usar un teléfono físico. El mínimo configurado por este Flutter es API 24 (Android 7).
5. Ejecutar desde la raíz del proyecto:

```powershell
.\tools\flutter.cmd doctor -v
```

Solo si Flutter no detecta el SDK, configurar la ruta **real observada** (sustituir el ejemplo):

```powershell
.\tools\flutter.cmd config --android-sdk 'C:\ruta\real\Android\Sdk'
.\tools\flutter.cmd doctor --android-licenses
.\tools\flutter.cmd doctor -v
```

Acepte las licencias necesarias en el diálogo. Confirmar Android toolchain correcto y
el JDK elegido por Flutter antes de compilar. No es necesario modificar Java globalmente
ni reparar componentes web/Windows. Referencia: [configuración Android de Flutter](https://docs.flutter.dev/platform-integration/android/setup).

## Conectar el teléfono y probar debug

1. En Ajustes > Acerca del teléfono, tocar siete veces **Número de compilación** (la ubicación varía por fabricante).
2. Abrir Opciones de desarrollador y activar **Depuración USB**.
3. Conectar por un cable USB que permita datos, desbloquear el teléfono y autorizar la huella de la computadora.
4. Ejecutar los siguientes comandos. Sustituir `ID_ANDROID` por el ID detectado:

```powershell
.\tools\flutter.cmd devices
.\tools\flutter.cmd run -d ID_ANDROID
```

Si no aparece, comprobar cable, autorización y controlador USB del fabricante en Windows.
Registrar modelo, Android, tamaño de pantalla y fecha. **No generar release hasta completar
las pruebas debug físicas.**

## Registro manual pendiente

Marcar cada punto solo tras ejecutarlo en el teléfono; adjuntar resultados y problemas reales.

- [ ] Abrir desde Inicio, iniciar cálculo, cargar producto, producción mensual y unidad.
- [ ] Agregar varios variables, editar uno y eliminar otro; comprobar subtotales.
- [ ] Agregar fijos y amortización manual (cantidad 1, importe mensual).
- [ ] Cargar porcentaje, obtener resultados, volver atrás conservando datos, cambiar un costo y comprobar recálculo.
- [ ] Reproducir el pan con las entradas de `test/fixtures/caso_pan.dart`: 1560 kg, ganancia 4 %, amortización 0. Comparar contra la tabla del README; nunca reingresar importes redondeados como resultados intermedios.
- [ ] Generar PDF, abrir vista previa, compartir hacia una aplicación elegida, guardar desde **Guardar o imprimir > Guardar como PDF** y abrir el archivo guardado.
- [ ] Comprobar disponibilidad de impresión. Registrar si no hay impresora para verificar salida física.
- [ ] Verificar tildes, ñ, fuentes, importes y continuidad de tablas con muchos costos/descripciones largas.
- [ ] Revisar Inicio, producto, listas largas, editor, teclado abierto, resultados, botones inferiores y vista previa: sin overflow, cortes, contenido tapado ni scroll defectuoso.
- [ ] Desactivar Wi-Fi y datos móviles; realizar otro cálculo y generar/abrir su PDF.
- [ ] Iniciar nuevo cálculo y confirmar que se limpian todos los datos.

## Firma local de distribución

`android/app/build.gradle.kts` lee `android/key.properties`. Release utiliza una
configuración propia y **ya no recurre a la clave debug**. Sin los datos de firma válidos,
release no podrá firmarse; debug no necesita ese archivo. La configuración aún no ha
sido validada por Gradle porque falta el SDK.

Antes de crear una clave, reutilizar la de distribución si ya existe. Para una nueva,
usar el `keytool` del JDK identificado por doctor, con un destino seguro **fuera del
repositorio**. Ejemplo (sustituir ambas rutas):

```powershell
& 'C:\ruta\jdk\bin\keytool.exe' -genkeypair -v -keystore 'C:\ruta-segura\incupo-release.jks' -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias incupo
Copy-Item android/key.properties.example android/key.properties
```

Ingresar contraseñas interactivamente y completar el archivo local con `storeFile`
(ruta absoluta, usar `/` en Windows), `storePassword`, `keyAlias` y `keyPassword`.
El ejemplo versionado no contiene contraseñas. Respaldar el keystore y sus credenciales
en un lugar seguro: las futuras actualizaciones requieren la misma firma. No compartir
esas credenciales en README, logs ni commits. Git excluye `key.properties`, `*.jks`,
`*.keystore`, `*.apk`, `*.aab` y `build/`.
Referencia: [firma Android en Flutter](https://docs.flutter.dev/deployment/android#sign-the-app).

## Compilar e instalar después de validar debug

```powershell
.\tools\flutter.cmd test
.\tools\flutter.cmd analyze
.\tools\flutter.cmd build apk --debug
# Solo con debug probado y firma configurada:
.\tools\flutter.cmd build apk --release
Get-Item build/app/outputs/flutter-apk/app-release.apk | Select-Object FullName, Length
```

La ruta **esperada, todavía no comprobada**, es `build/app/outputs/flutter-apk/app-release.apk`.
Verificar la firma con `apksigner verify --verbose --print-certs` de Build-Tools sobre
la APK y registrar tamaño y SHA-256. El proyecto conserva `0.1.0+1` hasta completar
la validación: cambiar a `1.0.0+1` antes de construir la candidata final, y aumentar
el código de versión para actualizaciones posteriores.

Transferir la APK al teléfono, abrirla, permitir instalación desde esa fuente cuando
Android lo solicite, instalar y abrir desde el icono. Alternativamente usar el `adb`
de Platform-Tools: `adb -s ID_ANDROID install -r build/app/outputs/flutter-apk/app-release.apk`.
Si existe una instalación debug con otra firma, Android puede rechazar la actualización;
exportar el cálculo que se quiera conservar y desinstalar debug antes de instalar release.

- [ ] Registrar nombre e icono en el menú Android y apertura fuera de `flutter run`.
- [ ] Completar un cálculo release con formularios, costos, navegación y resultados.
- [ ] Generar, previsualizar, guardar y compartir PDF en release.
- [ ] Repetir cálculo y PDF sin conexión, y reiniciar el cálculo.
- [ ] Registrar compilaciones, firma verificada, APK real, tamaño, instalación y smoke test.

Hasta completar estos puntos no declarar cerrada la versión 1.0.
