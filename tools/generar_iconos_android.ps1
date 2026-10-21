$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$raizProyecto = Split-Path $PSScriptRoot -Parent
$recursos = Join-Path $raizProyecto 'android/app/src/main/res'
$logo = [System.Drawing.Image]::FromFile((Join-Path $raizProyecto 'assets/images/incupo_logo.png'))

function Guardar-Icono([int]$lado, [double]$ocupacion, [string]$destino, [bool]$transparente) {
    $bitmap = [System.Drawing.Bitmap]::new($lado, $lado)
    $grafico = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $fondo = if ($transparente) { [System.Drawing.Color]::Transparent } else { [System.Drawing.Color]::White }
        $grafico.Clear($fondo)
        $grafico.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $grafico.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $ancho = [int]($lado * $ocupacion)
        $alto = [int]($ancho * $logo.Height / $logo.Width)
        $grafico.DrawImage($logo, [int](($lado - $ancho) / 2), [int](($lado - $alto) / 2), $ancho, $alto)
        $bitmap.Save($destino, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $grafico.Dispose()
        $bitmap.Dispose()
    }
}

try {
    $densidades = @{ mdpi = 1; hdpi = 1.5; xhdpi = 2; xxhdpi = 3; xxxhdpi = 4 }
    foreach ($densidad in $densidades.GetEnumerator()) {
        $carpeta = Join-Path $recursos ('mipmap-' + $densidad.Key)
        New-Item -ItemType Directory -Path $carpeta -Force | Out-Null
        Guardar-Icono ([int](48 * $densidad.Value)) 0.88 (Join-Path $carpeta 'ic_launcher.png') $false
        Guardar-Icono ([int](108 * $densidad.Value)) 0.60 (Join-Path $carpeta 'ic_launcher_foreground.png') $true
    }
} finally {
    $logo.Dispose()
}
