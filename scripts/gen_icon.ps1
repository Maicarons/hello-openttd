# Renders the hello-openttd application icon (1024x1024 PNG) programmatically.
# Geometry mirrors docs/public/logo.svg (64-viewBox depot glyph, x16 scale).
# Re-run after changing brand colors:  powershell -File scripts/gen_icon.ps1
Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

function New-RoundRect([int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = 2 * $r
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

$green = [System.Drawing.Color]::FromArgb(255, 46, 125, 50)
$dark  = [System.Drawing.Color]::FromArgb(255, 27, 94, 32)
$light = [System.Drawing.Color]::FromArgb(255, 165, 214, 167)
$cream = [System.Drawing.Color]::FromArgb(255, 232, 245, 233)

# Background rounded square (logo rect 4,4 56x56 rx14) + border.
$bg = New-RoundRect 64 64 896 896 224
$g.FillPath((New-Object System.Drawing.SolidBrush($green)), $bg)
$g.DrawPath((New-Object System.Drawing.Pen($dark, 4)), $bg)

# Outer arch (light): sides x256/x768 from y736 up to y480, dome ry192.
$outer = New-Object System.Drawing.Drawing2D.GraphicsPath
$outer.AddLine(256, 736, 256, 480)
$outer.AddArc(256, 288, 512, 384, 180, 180)
$outer.AddLine(768, 480, 768, 736)
$outer.CloseFigure()
$g.FillPath((New-Object System.Drawing.SolidBrush($light)), $outer)

# Inner arch (green, same as bg) creating the door ring.
$inner = New-Object System.Drawing.Drawing2D.GraphicsPath
$inner.AddLine(352, 736, 352, 544)
$inner.AddArc(352, 416, 320, 256, 180, 180)
$inner.AddLine(672, 544, 672, 736)
$inner.CloseFigure()
$g.FillPath((New-Object System.Drawing.SolidBrush($green)), $inner)

# Rail bar + three teeth (cream).
$rail = New-RoundRect 192 768 640 48 24
$g.FillPath((New-Object System.Drawing.SolidBrush($cream)), $rail)
foreach ($tx in 288, 480, 672) {
  $t = New-RoundRect $tx 832 48 96 16
  $g.FillPath((New-Object System.Drawing.SolidBrush($cream)), $t)
}

$outPath = Join-Path $PSScriptRoot "..\assets\icon\icon.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Host "icon written: $outPath"
