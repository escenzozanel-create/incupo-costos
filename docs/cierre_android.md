# Preparación Android y registro de validación

## Estado al 29/09/2026

El entorno Android ya está configurado y la APK debug compila. Esta etapa está **pendiente de pruebas físicas, firma y release**, no es una entrega 1.0.
Android Studio está instalado en `C:/Program Files/Android/Android Studio` (2026.1.4).

| Componente o verificación | Resultado |
|---|---|
| Flutter / Dart | 3.47.5 stable / 3.13.4; SDK local `.local/flutter` |
| `flutter doctor -v` | Android toolchain correcto; queda únicamente el aviso de Flutter/Dart fuera del PATH, resuelto operativamente con `tools/flutter.cmd` |
| Android Studio | Instalado, 2026.1.4; no requiere reinstalación |
| SDK | `C:/Android/Sdk`, enlace local al SDK en `C:/Users/Lenovo v15/AppData/Local/Android/Sdk` |
| Componentes | Platform android-36 (app) y android-34 (printing), Build-Tools 36.0.0, Platform-Tools 37.0.1, Command-line Tools 22.0, NDK 28.2.13676358 |
| Licencias | `All SDK package licenses accepted`; doctor confirma todas aceptadas |
| Java | PATH: Oracle Java 24.0.1; JDK en `C:/Program Files/Java/jdk-24`; JAVA_HOME no definido |
| Java de Flutter | JBR de Android Studio, OpenJDK 25.0.3, seleccionado con `flutter config --jdk-dir` |
| Dispositivos | `flutter devices`: Windows, Chrome y Edge; ningún Android detectado |
| Emuladores | `flutter emulators`: sin fuentes de emuladores |
| Pruebas | 71 aprobadas en esta revisión |
| `flutter analyze` | Sin observaciones (`No issues found!`) |
| Compilación debug | Correcta: `build/app/outputs/flutter-apk/app-debug.apk`, 157.324.066 bytes (~150 MiB) |
| Firma | APK debug verificada con apksigner (v2, Android Debug). Firma release pendiente de contraseña local y creación de clave |
| Release / ruta real / tamaño | No generada; no hay artefacto ni tamaño que informar |
| Instalación / smoke test | Pendientes |
| Dispositivo real, PDF nativo, pantalla y offline | No probados; no se atribuyen resultados físicos a tests de widgets |

El nombre Android existente **INCUPO Costos** se conserva en `android/app/src/main/AndroidManifest.xml`.
También se verificó con `aapt dump badging` sobre la APK debug, junto con el applicationId,
minSdk 24, targetSdk 36 y versión actual 0.1.0+1. La vista instalada sigue pendiente.
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

## Configuración utilizada en esta máquina

No se reinstaló Android Studio. Al comenzar, el SDK no existía en la carpeta habitual.
Se descargaron las Command-line Tools oficiales, archivo `commandlinetools-win-15859902_latest.zip`,
con SHA-256 verificado `90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a`.
Se instalaron con `sdkmanager` únicamente los componentes de compilación indicados en la tabla.
La extracción inicial de PowerShell falló por longitud de rutas; se resolvió extrayendo
directamente en el SDK. Los archivos de descarga y logs están en `.local/android-setup/`, fuera de Git.

Doctor rechazó la ruta SDK con espacios por incompatibilidad con herramientas NDK.
Se creó un enlace de directorio (junction) `C:/Android/Sdk` al SDK físico, sin moverlo ni duplicarlo.
Se aplicó:

```powershell
.\tools\flutter.cmd config --android-sdk 'C:\Android\Sdk'
.\tools\flutter.cmd config --jdk-dir 'C:\Program Files\Android\Android Studio\jbr'
.\tools\flutter.cmd doctor --android-licenses
.\tools\flutter.cmd doctor -v
.\tools\flutter.cmd devices
.\tools\flutter.cmd emulators
```

La aceptación de licencias se completó con respuestas afirmativas según la autorización
de esta etapa. Doctor muestra Android toolchain correcto. ADB no detecta teléfonos y no
hay emuladores configurados. No se modificaron el PATH global ni el Java de otras aplicaciones.

`flutter build apk --debug` terminó correctamente. Gradle instaló además API 34,
requerida por `printing-5.15.1/android/build.gradle`; la app conserva API 36.
Hubo advertencias de acceso nativo de Java 25, XML del SDK y source/target Java 8 en
dependencias, sin impedir el build. No se alteraron dependencias ni fórmulas para ocultarlas.
La caché generada `android/.kotlin/` se agregó a `.gitignore`.

Ruta real de debug en esta máquina:
`C:/Users/Lenovo v15/OneDrive/Escritorio/Practicas profesionalizantes 2/incupoAPK/build/app/outputs/flutter-apk/app-debug.apk`.
Es una APK de desarrollo, no el artefacto de distribución.

## Componentes para reproducir el entorno

1. En esta máquina Android Studio ya está instalado. En otro equipo, usar [Android Studio](https://developer.android.com/studio) y completar su asistente inicial.
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

Para crear una nueva clave ingresando la contraseña solamente en la terminal local:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\configurar_firma.ps1
```

El script solicita y confirma la contraseña sin mostrarla, crea la clave fuera del
repositorio en `%LOCALAPPDATA%/INCUPO/signing/incupo-release.jks`, alias `incupo`,
y escribe `android/key.properties` (ignorado por Git). No sobrescribe archivos existentes.
Usa la contraseña elegida también para la entrada de la clave; no genera ni imprime contraseñas.
La referencia del certificado es `CN=INCUPO Costos`. Los escapes Unicode de Properties
conservan los caracteres especiales, **no cifran las credenciales**. Respaldar la clave
y proteger el archivo de propiedades. El script tiene sintaxis verificada; su ejecución
interactiva y la validación Gradle siguen pendientes hasta ingresar la contraseña.

`android/app/build.gradle.kts` lee `android/key.properties`. Release utiliza una
configuración propia y **ya no recurre a la clave debug**. Sin los datos de firma válidos,
release no podrá firmarse; debug no necesita ese archivo. Gradle compiló debug con esta
configuración; todavía falta validar las credenciales y la firma de release.

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
