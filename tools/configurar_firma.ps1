# Ejecutar localmente: powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\configurar_firma.ps1
# Las contrasenas se solicitan sin mostrarlas. Nunca se pasan como argumentos.
param(
    [string]$Keytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe',
    [string]$Keystore = (Join-Path $env:LOCALAPPDATA 'INCUPO\signing\incupo-release.jks')
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$propertiesPath = Join-Path $projectRoot 'android\key.properties'
$Keystore = [IO.Path]::GetFullPath($Keystore)
if (!(Test-Path -LiteralPath $Keytool)) { throw 'No se encontro keytool; indicar -Keytool con la ruta del JDK.' }
if ($Keystore.StartsWith($projectRoot + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Elegir una ubicacion del keystore fuera del repositorio.'
}
if ((Test-Path -LiteralPath $Keystore) -or (Test-Path -LiteralPath $propertiesPath)) {
    throw 'Ya existe un keystore o key.properties. No se sobrescribe: revisar y reutilizar la firma existente.'
}
function ConvertTo-PropertyValue([string]$Value) {
    # Java Properties usa escapes Unicode; conserva caracteres especiales exactamente.
    return (($Value.ToCharArray() | ForEach-Object { '\u{0:x4}' -f [int]$_ }) -join '')
}
$securePassword = Read-Host 'Contrasena nueva (minimo 6 caracteres; guardarla en un lugar seguro)' -AsSecureString
$secureConfirm = Read-Host 'Repetir contrasena' -AsSecureString
$password = $null
$confirm = $null
$previousPasswordEnv = [Environment]::GetEnvironmentVariable('INCUPO_SIGNING_PASSWORD', 'Process')
try {
    $password = [Net.NetworkCredential]::new('', $securePassword).Password
    $confirm = [Net.NetworkCredential]::new('', $secureConfirm).Password
    if ($password.Length -lt 6 -or $password -cne $confirm) {
        throw 'La contrasena debe tener al menos 6 caracteres y coincidir con la confirmacion.'
    }
    New-Item -ItemType Directory -Force -Path (Split-Path $Keystore -Parent) | Out-Null
    [Environment]::SetEnvironmentVariable('INCUPO_SIGNING_PASSWORD', $password, 'Process')
    & $Keytool -genkeypair -keystore $Keystore -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias incupo -dname 'CN=INCUPO Costos' -storepass:env INCUPO_SIGNING_PASSWORD -keypass:env INCUPO_SIGNING_PASSWORD
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo crear la clave; revisar el error de keytool.' }
    & $Keytool -list -keystore $Keystore -alias incupo -storepass:env INCUPO_SIGNING_PASSWORD
    if ($LASTEXITCODE -ne 0) { throw 'La clave se creo, pero su validacion fallo. Conservarla y revisar antes de continuar.' }
    $lines = @(
        ('storeFile=' + (ConvertTo-PropertyValue $Keystore.Replace('\', '/'))),
        ('storePassword=' + (ConvertTo-PropertyValue $password)),
        'keyAlias=incupo',
        ('keyPassword=' + (ConvertTo-PropertyValue $password))
    )
    [IO.File]::WriteAllLines($propertiesPath, $lines, [Text.Encoding]::ASCII)
    Write-Host "Firma local creada. Keystore: $Keystore"
    Write-Host 'Respaldar el keystore y la contrasena. key.properties contiene secretos: no compartirlo.'
    Write-Host 'La validacion de Gradle y de la APK queda pendiente de la compilacion release.'
} finally {
    [Environment]::SetEnvironmentVariable('INCUPO_SIGNING_PASSWORD', $previousPasswordEnv, 'Process')
    $password = $null
    $confirm = $null
    $lines = $null
    $securePassword.Dispose()
    $secureConfirm.Dispose()
}
