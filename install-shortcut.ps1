# ============================================================
#  install-shortcut.ps1
#  ينشئ اختصار على سطح المكتب يفتح أداة الاستيكرات
#  في وضع الطباعة المباشرة (بدون نافذة إعدادات الطابعة)
# ============================================================
$ErrorActionPreference = 'Stop'

$url        = 'https://yahyazaqzouq.github.io/barcode-price-tags/'
$profileDir = Join-Path $env:LOCALAPPDATA 'PriceTagPrint'
$icoPath    = Join-Path $profileDir 'icon.ico'

if(-not (Test-Path -LiteralPath $profileDir)){ New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }

# ---------- 1) توليد أيقونة باركود ----------
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
  Write-Host 'تم إنشاء الأيقونة.'
} catch {
  Write-Host ('تعذر إنشاء الأيقونة: ' + $_.Exception.Message)
}

# ---------- 2) تحديد المتصفح ----------
$chrome = @(
  (Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe'),
  (Join-Path ${env:ProgramFiles(x86)} 'Google\Chrome\Application\chrome.exe'),
  (Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe')
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

$edge = @(
  (Join-Path $env:ProgramFiles 'Microsoft\Edge\Application\msedge.exe'),
  (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe')
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

$exe = if($chrome){ $chrome } elseif($edge){ $edge } else { $null }
if(-not $exe){
  Write-Host 'مفيش Google Chrome ولا Microsoft Edge. نزّل Chrome من https://www.google.com/chrome/'
  exit 1
}

# ---------- 3) إنشاء الاختصار ----------
$browserArgs = '--kiosk-printing --no-first-run --user-data-dir="' + $profileDir + '" --app=' + $url
$desktop = [Environment]::GetFolderPath('Desktop')
$lnk = Join-Path $desktop 'الاستيكرات - طباعة مباشرة.lnk'

$sh = New-Object -ComObject WScript.Shell
$sc = $sh.CreateShortcut($lnk)
$sc.TargetPath = $exe
$sc.Arguments = $browserArgs
$sc.WorkingDirectory = Split-Path -Parent $exe
if(Test-Path -LiteralPath $icoPath){ $sc.IconLocation = $icoPath + ',0' }
$sc.Description = 'أداة طباعة استيكرات الأسعار - طباعة مباشرة'
$sc.Save()

Write-Host ''
Write-Host 'تم. اختصار "الاستيكرات - طباعة مباشرة" بقى على سطح المكتب.'
Write-Host ''
Write-Host 'طريقة الاستخدام:'
Write-Host '  1) افتح الاخصار من سطح المكتب'
Write-Host '  2) فعّل "اطبع تلقائيًا بعد المسح"'
Write-Host '  3) امسح الباركود والاستيكر يطبع على طول'
