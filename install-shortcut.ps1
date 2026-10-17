# ============================================================
#  install-shortcut.ps1
#  Creates a Desktop shortcut that opens the price-tag tool
#  in direct-print mode (no printer settings dialog).
#
#  NOTE: this file is intentionally pure ASCII. The Arabic
#  strings are stored Base64-encoded so the file works no
#  matter what text encoding the machine uses.
# ============================================================
$ErrorActionPreference = 'Stop'

function Ar([string]$b64){
  return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
}

$url          = 'https://yahyazaqzouq.github.io/barcode-price-tags/'
$shortcutName = (Ar '2KfZhNin2LPYqtmK2YPYsdin2KogLSDYt9io2KfYudipINmF2KjYp9i02LHYqQ==') + '.lnk'
$doneMsg      = Ar '2KrZhSDYpdmG2LTYp9ihINin2YTYo9mK2YLZiNmG2KkuDQoNCtiq2YUg2LnZhdmEINin2YTYp9iu2KrYtdin2LEg2LnZhNmJINiz2LfYrSDYp9mE2YXZg9iq2KguDQoNCti32LHZitmC2Kkg2KfZhNin2LPYqtiu2K/Yp9mFOg0KICAxKSDYp9mB2KrYrSDYp9mE2KfYrtiq2LXYp9ixINmF2YYg2LPYt9itINin2YTZhdmD2KrYqA0KICAyKSDZgdi52ZHZhCAo2KfYt9io2Lkg2KrZhNmC2KfYptmK2YvYpyDYqNi52K8g2KfZhNmF2LPYrSkNCiAgMykg2KfZhdiz2K0g2KfZhNio2KfYsdmD2YjYryDZiNin2YTYp9iz2KrZitmD2LEg2YrYt9io2Lkg2LnZhNmJINi32YjZhA=='
$noBrowserMsg = Ar '2YXZgdmK2LQgR29vZ2xlIENocm9tZSDZiNmE2KcgTWljcm9zb2Z0IEVkZ2Ug2LnZhNmJINin2YTYrNmH2KfYsi4g2YbYstmR2YQgQ2hyb21lINmF2YYgaHR0cHM6Ly93d3cuZ29vZ2xlLmNvbS9jaHJvbWUv'

$profileDir = Join-Path $env:LOCALAPPDATA 'PriceTagPrint'
$icoPath    = Join-Path $profileDir 'icon.ico'

if(-not (Test-Path -LiteralPath $profileDir)){
  New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# ---------- 1) Build a barcode icon (best effort) ----------
try {
  Add-Type -AssemblyName System.Drawing
  $size = 256
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::FromArgb(22,50,79))
  $g.FillRectangle([System.Drawing.Brushes]::White, 22, 46, ($size-44), ($size-92))
  $bars = @(5,2,3,6,2,4,2,7,3,2,5,3,2,6,3,2,4,5,2,3,6,2,4,3,2,5,4,2,6,3)
  $x = 36; $y = 66; $h = $size - 132
  foreach($w in $bars){
    $g.FillRectangle([System.Drawing.Brushes]::Black, $x, $y, $w, $h)
    $x += $w + 4
    if($x -gt ($size-40)){ break }
  }
  $g.Dispose()
  $hicon = $bmp.GetHicon()
  $icon  = [System.Drawing.Icon]::FromHandle($hicon)
  $fs = [System.IO.File]::Create($icoPath)
  $icon.Save($fs); $fs.Close(); $icon.Dispose(); $bmp.Dispose()
  Write-Host 'Icon created.'
} catch {
  Write-Host ('Icon skipped: ' + $_.Exception.Message)
}

# ---------- 2) Find an installed browser ----------
function Find-Browser {
  param([string]$relative)
  $roots = @($env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:LOCALAPPDATA)
  foreach($root in $roots){
    if(-not $root){ continue }
    $p = Join-Path $root $relative
    if(Test-Path -LiteralPath $p){ return $p }
  }
  return $null
}

$exe = Find-Browser 'Google\Chrome\Application\chrome.exe'
if(-not $exe){ $exe = Find-Browser 'Microsoft\Edge\Application\msedge.exe' }
if(-not $exe){ Write-Host $noBrowserMsg; exit 1 }

# ---------- 3) Create the shortcut ----------
$browserArgs = '--kiosk-printing --no-first-run --user-data-dir="' + $profileDir + '" --app=' + $url
$desktop = [Environment]::GetFolderPath('Desktop')

function New-TagShortcut {
  param([string]$fileName)
  $lnk = Join-Path $desktop $fileName
  $sh = New-Object -ComObject WScript.Shell
  $sc = $sh.CreateShortcut($lnk)
  $sc.TargetPath = $exe
  $sc.Arguments = $browserArgs
  $sc.WorkingDirectory = Split-Path -Parent $exe
  if(Test-Path -LiteralPath $icoPath){ $sc.IconLocation = $icoPath + ',0' }
  $sc.Description = 'Price Tag Stickers - Direct Print'
  $sc.Save()
  return $lnk
}

$saved = $null
try {
  $saved = New-TagShortcut $shortcutName
} catch {
  Write-Host ('Arabic name failed (' + $_.Exception.Message + '), using English name.')
  $saved = New-TagShortcut 'Price Tag Stickers.lnk'
}

Write-Host ''
Write-Host $doneMsg
Write-Host ''
Write-Host ('Shortcut: ' + $saved)
